% List of open inputs
% Realign: Reslice: Images - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\SAttygalle\Documents\GitHub\imaging-core\serial_vbm\scratch_folder\resclicejob_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Realign: Reslice: Images - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
