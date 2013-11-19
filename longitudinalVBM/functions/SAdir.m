function directorystructure = SAdir(path, regexptomatch)
%SAdir - return files that match exp with ./.. removed
%more details
%
% Syntax: directorystructure = SAdir(pat, regexptomatch)
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
%   Add ability to specify files or folders only
%   Change to varargin to 
%
% Author: Suneth Attygalle
% Created 10/29/13
% 
% Revisions:
%   10/30/13 added regexp input - SA

d=dir(path);

if size(d,1)>=3 && strcmp(d(1).name, '.') && strcmp(d(2).name, '..') % this is superceded by using the regular expression.
    d(1:2) = [] ;% remove . and .. from directory listing
end

filenames= {d.name};
index = regexp(filenames, regexptomatch);
inds = ~cellfun(@isempty,index); %turn regexp matching into a logical array

d= d(inds) ; %remove elements that didn't match regexp

directorystructure = d;