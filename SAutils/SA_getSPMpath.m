function spmpath = SA_getSPMpath( version )
%SAgetSPMpath locates SPM filepath for use in scripts
%   looks for version number in path, if it isn't found gives a warn and
%   returns empty matrix for spmpath
%
% Syntax:  spmpath = SAgetSPMpath( version )
%
% Inputs: version - number of SPM version (e.g. 5, 8 , 12) 
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: 
% Subfunctions:
% MAT-files required: none
% See also: 
% To Do:
%
% Author: Suneth Attygalle
% Created 07/3/2014
%
% Revisions:

spmpath = which('spm');

if isempty(strfind(spmpath, ['spm' num2str(version)]))
    
    spmpath = [];
    warning('Correct version of SPM not found, please make sure it is added to the matlab path')
end
    
spmpath = fileparts(spmpath);
