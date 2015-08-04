function longDTI_generateDARTELToICBM(templatepath)
%longDTI_generateDARTELToICBM - generate population to ICBM warping for
%use with deformations utility
%
% Syntax:  longDTI_generateDARTELToICBM( pathtotemplate6)
%
% Inputs:    templatepath - path to final dartel template folder
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
% Author: Gabe Marx
% Created 08/03/2015
% Revisions:

spm_path=which('spm');
if ~strcmp(spm_path,'/mnt/macdata/groups/imaging_core/dti/spm12/spm.m')
    error('USING WRONG SPM PATH. REMOVE CURRENT SPM PATH AND SET NEW SPM PATH TO: /mnt/macdata/groups/imaging_core/dti/spm12/')
end

matlabbatch{1}.spm.tools.dartel.popnorm.template = cellstr(strcat(templatepath,'/Template_6.nii'));

spm('defaults', 'PET');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
