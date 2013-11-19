function fullfilestring = SAnativePath(path)
%SAnativePath - input path, get line to use in fullfile instead
% Syntax: fullfilestring = SAnativePath(path)
%
% Inputs: 
%           path - input file path (windows/linux/osxpath)
%
% Outputs:
%    fullfilestring - what you would input into fullfile
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
% Created 10/31/13
% 
% Revisions:

%Check with file separators are in file

forwardslashes = strfind(path, '/');
backwardslashes = strfind(path, '\');

if ~isempty(forwardslashes) && ~isempty(backwardslashes)
   error('This path has both forward and backslashes so the file path may be interpreted incorrectly, check it manually instead');
end

if ~isempty(forwardslashes)
    pathparts = strsplit(path,'/'); %unix

elseif ~isempty(backwardslashes)
    pathparts = strsplit(path,'\'); %windows
  
end

fullfilestring = ['''' strjoin(pathparts,''',''') ''''];




