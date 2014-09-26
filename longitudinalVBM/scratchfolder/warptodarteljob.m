% List of open inputs
% Create Warped: Flow fields - cfg_files
% Create Warped: Images - cfg_repeat
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\SAttygalle\Documents\GitHub\imaging-core\longitudinalVBM\scratchfolder\warptodarteljob_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Create Warped: Flow fields - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Create Warped: Images - cfg_repeat
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
