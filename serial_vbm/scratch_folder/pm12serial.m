% List of open inputs
% Serial Longitudinal Registration: Volumes - cfg_files
% Serial Longitudinal Registration: Times - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/home/sattygalle/imaging-core/serial_vbm/scratch_folder/pm12serial_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Serial Longitudinal Registration: Volumes - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Serial Longitudinal Registration: Times - cfg_entry
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
