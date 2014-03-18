function scans_to_process = LONG_DARTELregistration_to_existing( scans_to_process, templatepath)
%LONG_run_LONG_DARTELregistration_to_exiswting - SPM12b DARTEL registration
%to existing template based 
%
% Syntax:  scans_to_process = LONG_DARTELregistration_to_existing( scans_to_process, templatepath)
%           
% Inputs: scans_to_process - array of objects of class LONG_participant,
%         templatepath - path to the desired DARTEL tempalte
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
% MAT-files required: none
%
% See also: 
%
% To Do:
%
% Author: Suneth Attygalle
% Created 02/28/2014
%
% Revisions:

prefixes ='rc1avg_' ; % use c1 images to make sure segmentatoin occured.
c1volumes = LONG_buildvolumelist(scans_to_process, prefixes);
c1volumes = strrep(c1volumes, 'img', 'nii'); %avg filenames sometimes were img not nii

prefixes ='rc2avg_' ; % use c1 images to make sure segmentatioin occured.
c2volumes = LONG_buildvolumelist(scans_to_process, prefixes);
c2volumes = strrep(c2volumes, 'img', 'nii'); %avg filenames sometimes were img not nii

spm('defaults', 'PET');
spm_jobman('initcfg');

% matlabbatch{1}.spm.tools.dartel.warp.images = {
%                                                c1volumes(:,1) c2volumes(:,1)
%                                                }';
matlabbatch{1}.spm.tools.dartel.warp1.images{1} = c1volumes(:,1)     ;                  
matlabbatch{1}.spm.tools.dartel.warp1.images{2} = c2volumes(:,1)    ;                           
matlabbatch{1}.spm.tools.dartel.warp1.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).template = {fullfile(templatepath, 'Template_1.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).template = {fullfile(templatepath, 'Template_2.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).template = {fullfile(templatepath, 'Template_3.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).template = {fullfile(templatepath, 'Template_4.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).template = {fullfile(templatepath, 'Template_5.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).template = {fullfile(templatepath, 'Template_6.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.its = 3;

spm_jobman('run',matlabbatch);



end


