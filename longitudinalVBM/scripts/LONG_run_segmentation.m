function scans_to_process = LONG_run_segmentation( scans_to_process, scantype, spmpath)
%LONG_run_segmentation - SPM12b Segmentation for Longitudinal processing
%
% Syntax:  participantstructure = LONG_run_segmentation(scans_to_process )
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
% scantype - string specifying whether to segment time1, time2 or mean image.
% spmpath - path to spm 12b installation
%
% Outputs: scans_to_process - updated array with run status
%
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also: longitudinal registration should be run first to generate mean
% images
%
% To Do:
%
% Author: Suneth Attygalle
% Created 02/21/2014
%
% Revisions:

switch lower(scantype)
    case 'mean'
        prefixes ='avg_' ;% average images start with "avg_++
        volumepaths = LONG_buildvolumelist(scans_to_process, prefixes);
        volumes = strrep(volumepaths(:,1), 'img', 'nii'); %avg filenames sometimes were img not nii
        writeforavgonly = 1;
        
    case {'time1','time2'}
        prefixes ='' ;% average images start with "avg_++
        volumepaths = LONG_buildvolumelist(scans_to_process, prefixes);
        writeforavgonly = 1;
        if strcmpi(scantype,'time1')
            volumes = volumepaths(:,1);
            writeforavgonly =0;
        elseif strcmpi(scantype,'time2')
            volumes = volumepaths(:,2);
            writeforavgonly = 0;
        end       
end

dartelimport = 1; % it's better to do the dartel import separately so voxel size can be specified ( this might work in future versions of SPM)

spm('defaults', 'PET');
spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.preproc.channel.vols = volumes; % the avg images are only in the time 1 folders.
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spmpath,'tpm','TPM.nii,1')};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;  
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 dartelimport];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spmpath,'tpm','TPM.nii,2')};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2; 
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 dartelimport];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spmpath,'tpm','TPM.nii,3')};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2; 
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 dartelimport];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spmpath,'tpm','TPM.nii,4')};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [writeforavgonly 0]; % only need to write these images for the average which is used for dartel.
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spmpath,'tpm','TPM.nii,5')};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [writeforavgonly 0]; % only need to write these images for the average which is used for dartel.
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

end
