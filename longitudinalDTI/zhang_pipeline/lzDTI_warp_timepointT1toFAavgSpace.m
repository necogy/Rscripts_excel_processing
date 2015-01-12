function scans_to_process = lzDTI_warp_timepointT1toFAavgSpace( scans_to_process)
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
    for iTimepoint= 1:size(scans_to_process(sub).Timepoint,2)
        y_FAtoFAavg= SAinsertStr2Paths(scans_to_process(sub).Timepoint{ iTimepoint}.Image_FA.path, 'y_flirted');
        T1image = scans_to_process(sub).Timepoint{iTimepoint}.Image_T1.path;
        FAavgfile = SAinsertStr2Paths(scans_to_process(sub).Timepoint{ 1}.Image_FA.path, 'avg_flirted'); %same for time 1 and 2
        
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = {y_FAtoFAavg};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {T1image};
        matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {T1image};
        matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
        matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
        matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {FAavgfile };
        matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
        matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
        matlabbatch{1}.spm.util.defs.out{2}.savedef.ofname = 'fromT1NativeToFAavg';
        matlabbatch{1}.spm.util.defs.out{2}.savedef.savedir.saveusr ={fileparts(T1image)};
        
        spm_jobman('run',matlabbatch);
        clear matlabbatch
    end
end

