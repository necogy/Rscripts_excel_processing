function scans_to_process = longDTI_DARTEL_registration_to_new(scans_to_process, templatepath)
%longDTI_DARTEL_registration_to_new SPM12b DARTEL register to new template
%   Detailed explanation goes here
% Syntax:  scans_to_process = longDTI_DARTEL_registration_to_new( scans_to_process)
%
% Inputs: scans_to_process - array of objects of class longDTI_participant,
%         DARTEL_template_path - path to the desired DARTEL tempalte
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Gabe Marx
% Created 08/03/2015
%
% Revisions:
% rc1files=[];
% rc2files=[];

spm_path=which('spm');
if ~strcmp(spm_path,'/mnt/macdata/groups/imaging_core/dti/spm12/spm.m')
    error('USING WRONG SPM PATH. REMOVE CURRENT SPM PATH AND SET NEW SPM PATH TO: /mnt/macdata/groups/imaging_core/dti/spm12/')
end


for subject = 1:size(scans_to_process,2) % for every subject
    scans_to_process(subject)
    avgfile = fullfile(scans_to_process(subject).Fullpath,'avg', scans_to_process(subject).Timepoint{1}.File.name);
    avgfile = SAinsertStr2Paths(avgfile, 'avg_r');
    volumes{subject} = avgfile;
    
end

disp('now running DARTEL registration to a new template')
spm('defaults', 'PET');
spm_jobman('initcfg');
matlabbatch{1}.spm.tools.dartel.warp.images = {volumes};
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

spm_jobman('run',matlabbatch)

[status,message,~]=movefile(fullfile(scans_to_process(1).Fullpath,'avg','Template_*'),templatepath);
 

end

