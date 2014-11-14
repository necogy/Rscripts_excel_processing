function scans_to_process = lzDTI_longitudinal_registerFA( scans_to_process )
%lzDTI_longitudinal_registerFA- coreg time1 FA to time2 FA
% Creates an array of objects of the class lzDTI_participant
%
% Syntax:  participants_to_process =lzDTI_longitudinal_registerFA(scans_to_process )
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
% Created 10/30/14
%
% Revisions:
spm('defaults', 'PET');
spm_jobman('initcfg');

for sub = 1:size(scans_to_process,2)
    
    time1FA = SAinsertStr2Paths(      scans_to_process(sub).Timepoint{1}.Image_FA.path, 'flirt');
    time2FA = SAinsertStr2Paths(      scans_to_process(sub).Timepoint{2}.Image_FA.path, 'flirt');    
    deltatime =  (scans_to_process(sub).Timepoint{2}.Datenum - scans_to_process(sub).Timepoint{1}.Datenum)/365;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.vols1 = {time1FA};
    matlabbatch{1}.spm.tools.longit{1}.pairwise.vols2 = {time2FA};
    matlabbatch{1}.spm.tools.longit{1}.pairwise.tdif = deltatime;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.noise = NaN;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.wparam = [0 0 100 25 100];
    matlabbatch{1}.spm.tools.longit{1}.pairwise.bparam = 1000000;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_avg = 1;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_jac = 1;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_div = 1;
    matlabbatch{1}.spm.tools.longit{1}.pairwise.write_def = 1;
    
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    
    
end