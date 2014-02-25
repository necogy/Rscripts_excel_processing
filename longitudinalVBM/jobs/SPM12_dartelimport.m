% List of open inputs
% Initial Import: Parameter Files - cfg_files
% Initial Import: Output Directory - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\SAttygalle\Documents\GitHub\imaging-core\longitudinalVBM\jobs\SPM12_dartelimport_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Initial Import: Parameter Files - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Initial Import: Output Directory - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
