function mergedarray = SAgetBestLongDataFromLava( varargin )
%FUNCTION_NAME - takes an Lava Worksheet and finds the best rows to use for
%longitudinal data and optionally makes a new sheet compiling all sheets into one.
%
% Syntax:  SAgetBestLongDataFromLava(varargin)
%
% Inputs:
%
% Outputs:
%
% Author: Suneth Attygalle
% 12/23/2013;

% To do:
% specificatoins for excel sheet

%------------- BEGIN CODE --------------%

%%
if nargin == 0
    % get user input for file if not specified
    DialogTitle = 'Please select LAVA excel file';
    FilterSpec = {'*.xls*'} ;
    [FileName,PathName,FilterIndex] = uigetfile(FilterSpec,DialogTitle);
    
    % else
    %     [PathName, FileName, ext] = fileparts(varargin{1});
    % end
end

badcodes = [-9,-7,-5,-2,-1]; % bad data codes in Lava sheet

%read file and get names of sheets
[status,sheets] = xlsfinfo( (fullfile(PathName,FileName)) );

if size(sheets,2) == 1
    error('Only one sheet found, please check if correct sheet was selected or that it is formatted correctly.')
elseif isempty(status)
    error('Could not read excel sheet-- check if file is correct')
end

filepath =  fullfile(PathName, FileName);

for sheetnum = 1:size(sheets,2) %loop through sheets (ignore first sheet since it's just the PIDN link info
    newfilename{sheetnum}=processSingleWorksheet(filepath, badcodes, sheetnum, sheets)  
end

pathsofsheets = cellfun(@(x) fullfile(PathName,x), newfilename(1:end), 'UniformOutput', false);
mergedarray = SAmergeXLSsheets(pathsofsheets, fullfile(PathName,[FileName(1:end-5) '_merged.xlsx']));

end
%end

%% Subfunctions:
function newfilename = processSingleWorksheet(filepath, badcodes, sheetnum, sheets)

[num,txt,raw] = xlsread(filepath, sheetnum);

linkID.col = strcmpi('linkID', txt(1,:));
linkID.daydiffcol = strcmpi('daydiff', txt(1,:));

linkID.vals = num(:,linkID.col);
linkID.datediff = num(:,linkID.daydiffcol);
linkID.unique = unique(linkID.vals);

linkID.datacodecount= sum(ismember(num,badcodes),2);

counts =hist(linkID.vals,linkID.unique);
linkID.repeated=linkID.unique(counts>1);

linkID.numbad = sum( ismember(num, badcodes),2);
keep= zeros(1,size(linkID.vals,1));
i=1;
%generate logical index for Num that returns no duplicate links
while i <= size(linkID.vals,1)
    %for i = 1:size(linkID.repeated,1)
    
    if ~ismember(linkID.vals(i), linkID.repeated)
        keep(i) = 1;
        i= i+1;
        
    else
        n= ismember(linkID.repeated,linkID.vals(i));
        currentlinkID = linkID.repeated(n);
        rowstocompare =(linkID.vals==currentlinkID);
        clear displaystring displaystringcell
        displaystring(1,:) = num(rowstocompare,linkID.daydiffcol);
        displaystring(2,:)=linkID.datacodecount(rowstocompare);
        displaystringcell = num2cell(displaystring);
        
        %find which has lower values for both
        minrow = getmin(displaystring);
        
        if ~isnan(minrow(1))
            displaystringcell{3,minrow(1)}  = '*******selected';
        else
            unsuccesstring = '?????';
            
            [displaystringcell{3,1:size(displaystringcell,2)}] = deal(unsuccesstring);
            error('not sure which one to pick')
            % find minimum of error codes for dates less than 60 days away.
            %prompt = 'please type a number to pick one of the rows above to use.'
            % result = input(prompt)
            
        end
        if ~isnan(minrow)
            keep(i+(minrow-1)) = 1;
        end
        i = i+ size(displaystring,2);
        
        fprintf('LinkID: %d ', currentlinkID)
        fprintf('PIDN: %s \n', num2str(num(rowstocompare,1)'))
        fprintf('DayDiff: %d  NumBadCodes: %d %s \n', displaystringcell{:})
        fprintf(' ')
        fprintf('\n')
        
    end
    
end
keeplog = logical([1 keep])
[~, name, ext] = fileparts(filepath);
newfilename = [name '_unique_' sheets{sheetnum} '.xls'];


xlswrite(newfilename, raw(keeplog,:))
end

function minrow = getmin(displaystring)
%check no data codes > 30
baddataind = displaystring(2,:)>30;
%check no dates > 180
baddateind = abs(displaystring(1,:))>180;

if all(baddataind==1) % if all of the data has above threshold bad codes then just use the smallest date.
    baddataind(baddataind==1)= 0;
end

acceptableinds = double(~baddataind & ~baddateind);
acceptableinds(acceptableinds==0) = NaN;

totals = sum(abs(displaystring),1);

%check for duplicate values
counts = hist(totals,unique(totals));

if any(counts>3)
    minrow =NaN;
    return
elseif numel(find(counts==2)==1)
    minrow  = 1;
    return
elseif any(counts>2)
    minrow=NaN;
    return
end

if all(counts==1) % no duplicates
    [minval, minind ]=min(totals.*acceptableinds);
    minrow=minind;
    return
end

end
