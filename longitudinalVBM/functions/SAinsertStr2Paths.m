%SAinsertstr- inserts a string into a filename path cell array
%inserts the string before the filename while retaining full path
%
% Syntax: cellarraywithinsertions = SAinsertstr(originalcellaray, stringtoinsert)
%
% Inputs: 
%           path - pathname to look for file
%           regexptomatch - regular expression to match a file name within
%           the directory. 
%
% Outputs:
%    directorystructure - same output as dir command with ./.. removed
%
% Example: 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
%
% To Do:
%
% Author: Suneth Attygalle
% Created 12/17/13
% 
% Revisions:

function cellarraywithinsertions = SAinsertStr2Paths(originalcellarray, stringtoinsert)
cellarraywithinsertions = cell(size(originalcellarray,1),1);

for i = 1:size(originalcellarray,1)
    [pathstr, name, ext] = fileparts(originalcellarray{i}) ;
    cellarraywithinsertions{i}=  fullfile(pathstr, [stringtoinsert name ext] );
end

end
