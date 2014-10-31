function scans_to_process = lzDTI_coregisterWarpedT1sUsingLongitudinalRegistration( scans_to_process )
%lzDTI_coregisterWarpedT1sUsingLongitudinalRegistration- coreg warped T1s
% Creates an array of objects of the class lzDTI_participant
%
% Syntax:  participants_to_process =lzDTI_coregisterWarpedT1sUsingLongitudinalRegistration(scans_to_process )
%
% Inputs:
%
% Outputs: scans_to_process - array of objects of class lzDTI_participant
%
% Example:
%
% Other m-files required: spm12
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 10/31/14
%
% Revisions:
spm('defaults', 'PET');
spm_jobman('initcfg');

for sub = 1:size(scans_to_process,2)
    
    time1warpedtoFAavgT1 = SAinsertStr2Paths(      scans_to_process(sub).Timepoint{1}.Image_T1.path, 'w');
    time2warpedtoFAavgT1 = SAinsertStr2Paths(      scans_to_process(sub).Timepoint{2}.Image_T1.path, 'w');    
    deltatime =  1;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.vols1 = {time1warpedtoFAavgT1};
    matlabbatch{1}.spm.tools.longit{1}.pairwise.vols2 = {time2warpedtoFAavgT1};
    matlabbatch{1}.spm.tools.longit{1}.pairwise.tdif = deltatime;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.noise = NaN;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.wparam = [0 0 100 25 100];
    matlabbatch{1}.spm.tools.longit{1}.pairwise.bparam = 1000000;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_avg = 1;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_jac = 0;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_div = 0;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_def = 1;
    
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    
    
end