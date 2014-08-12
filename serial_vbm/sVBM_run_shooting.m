function scans_to_process = sVBM_run_shooting(scans_to_process)
%sVBM_run_segmentation - SPM12b Segmentation for serial Longitudinal processing
%
% Syntax:  participantstructure = sVBM_run_shooting(scans_to_process )
%
% Inputs: scans_to_process - array of objects of class svbm_participant
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:
% To Do:
%
% Author: Suneth Attygalle
% Created 07/8/2014
%
% Revisions:

%load up filenames
for subject = 1:size(scans_to_process,2) 
    time1directory = fullfile(scans_to_process(subject).Timepoint{1}.Fullpath);
    d=SAdir(time1directory, '^hess_2_pos_avg_');
    avgfile{subject} = cellstr(fullfile(scans_to_process(subject).Timepoint{1}.Fullpath,d.name));
end

spm('defaults', 'PET');
spm_jobman('initcfg')
matlabbatch{1}.spm.tools.shoot.warp.images = avgfile; % run shooting
spm_jobman('run',matlabbatch);