% List of open inputs
% Run Shooting (create Templates): Images - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\SAttygalle\Documents\GitHub\imaging-core\serial_vbm\scratch_folder\shootjob_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Shooting (create Templates): Images - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
