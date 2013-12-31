function mergedarray = SAmergeXLSsheets(pathsofsheets, newfilename)
%SAmergeXLSsheets - takes a cell array of names of sheets in a folder and
%combines them into one sheet, making sure PIDN/linkID match  
%
% Syntax:  SAmergeXLSsheets(pathsofsheets, newfilename)
%
% Inputs:
%   pathsofsheets = cell array containing each full path of sheets to merge
%   newfilename = string with new path and filename to save merged sheet
%
% Outputs:
%   an excel sheet "newfilename"
%
% Author: Suneth Attygalle
% 12/30/2013;

% To do:

%------------- BEGIN CODE --------------%
allraw = {};
for i = 1:length(pathsofsheets)
    [status,sheets] = xlsfinfo( pathsofsheets{i} );
     
    % read in data and store it
    [num{i},txt{i},raw{i}] = xlsread(pathsofsheets{i}, 1) ;
    

end
%check PIDNs/linkIDs match up 

%merge sheet data into one cell array

allraw = [raw{:}];

mergedarray = allraw
%write excel sheet

[status,message ] = xlswrite(newfilename, allraw)
%cell2csv(newfilename,allraw,[],[],[])

