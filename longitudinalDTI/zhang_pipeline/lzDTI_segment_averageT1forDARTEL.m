function scans_to_process = lzDTI_segment_averageT1forDARTEL( scans_to_process )
%zDTI_segment_averageT1forDARTEL- dartel import
% Creates an array of objects of the class lzDTI_participant
%
% Syntax:  participants_to_process =lzDTI_segment_averageT1fo(scans_to_process )
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
spmpath = fileparts(which('spm'));
dartelimport = 1;
spm('defaults', 'PET');
spm_jobman('initcfg');

for sub = 1:size(scans_to_process,2)
    
    avgfile = SAinsertStr2Paths(      scans_to_process(sub).Timepoint{1}.Image_T1.path, 'avg_w');
    avgfile = strrep(avgfile, 'img','nii');
    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = {avgfile}; % the avg images are only in the time 1 folders.
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spmpath,'tpm','TPM.nii,1')};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 dartelimport];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spmpath,'tpm','TPM.nii,2')};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 dartelimport];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spmpath,'tpm','TPM.nii,3')};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spmpath,'tpm','TPM.nii,4')};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0]; 
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spmpath,'tpm','TPM.nii,5')};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0]; 
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spmpath,'tpm','TPM.nii,6')};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.025 0.1];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
    
    spm_jobman('run',matlabbatch);
    clear matlabbatch
end


end