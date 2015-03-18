function SA_SPM12_generateDARTELToICBM(pathtotemplate6)
%SA_SPM12_generateDARTELToICBM - generate population to ICBM warping for
%use with deformations utility
%
% Syntax:  SA_SPM12_generateDARTELToICBM( pathtotemplate6)
%
% Inputs:    pathtotemplate6 - path to final dartel template
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: SPM12 in path
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do: 
%
% Author: Suneth Attygalle
% Created 02/19/2015
% Revisions:

matlabbatch{1}.spm.tools.dartel.popnorm.template = cellstr(pathtotemplate6);

spm('defaults', 'PET');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
