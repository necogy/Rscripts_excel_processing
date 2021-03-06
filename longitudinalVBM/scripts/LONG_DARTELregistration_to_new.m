function scans_to_process = LONG_DARTELregistration_to_new( scans_to_process, PIDNlist)
%LONG_run_LONG_DARTELregistration_to_new - SPM12 DARTEL generation of new
%template based on average images in longitudinal pipeline and specified
%PIDNs. Check the template after running and move it to a new directory and
%specify the new path in LONG_config.m
%
% Syntax:  scans_to_process = LONG_DARTELregistration_to_new( scans_to_process, PIDNlist)
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
%         PIDNlist - list of PIDNs you want to include from full set
%           to creat template, probably matched in some way to the patients
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12
% Subfunctions:
% MAT-files required: none
%
% See also: longitudinal registration should be run first to generate mean
% images
%
% To Do:
%
% Author: Suneth Attygalle
% Created 02/25/2014
%
% Revisions:

allPIDNs = {scans_to_process.PIDN};


for subject = 1:size(allPIDNs,2)
    if ~isempty(PIDNlist)
        keep(subject) = ismember( str2double(allPIDNs{subject}) , PIDNlist)     ;
    else
        keep(subject) = 1;
    end
end

prefixes ='rc1avg_' ; % use c1 images to make sure segmentation occured.
c1volumes = LONG_buildvolumelist(scans_to_process(keep), prefixes);
c1volumes = strrep(c1volumes, 'img', 'nii');

prefixes ='rc2avg_' ; % use c1 images to make sure segmentation occured.
c2volumes = LONG_buildvolumelist(scans_to_process(keep), prefixes);
c2volumes = strrep(c2volumes, 'img', 'nii');

spm('defaults', 'PET');
spm_jobman('initcfg');

% matlabbatch{1}.spm.tools.dartel.warp.images = {
%                                                c1volumes(:,1) c2volumes(:,1)
%                                                }';
matlabbatch{1}.spm.tools.dartel.warp.images{1} = c1volumes(:,1)     ;
matlabbatch{1}.spm.tools.dartel.warp.images{2} = c2volumes(:,1)    ;
matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;

spm_jobman('run',matlabbatch);

% add code to move generated templates
end


