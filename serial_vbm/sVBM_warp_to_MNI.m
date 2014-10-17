function scans_to_process = sVBM_warp_to_MNI( scans_to_process)
%LONG_timepoint_to_MNI - warp all timepoints to MNI using output from SPM12
%segmentation, not using DARTEL intermediate
%
% Syntax:  scans_to_process = sVBM_warp_to_MNI( scans_to_process)
%
% Inputs:   scans_to_process - array of objects of class sVBM_participant
%
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 10/16/2014
%
% Revisions:
%----------------------

spm('defaults', 'PET');

for subject = 1:size(scans_to_process,2)
    
    for col = 1:size(scans_to_process(subject).Timepoint,2)
        clear matlabbatch
               
        deformationfield = fullfile(scans_to_process(subject).Timepoint{col}.Fullpath, scans_to_process(subject).Timepoint{col}.File.name);
        deformationfield = strrep(SAinsertStr2Paths(deformationfield, 'y_'), 'img', 'nii');
        imagestowarp = {strrep(deformationfield, 'y_', 'c1'), strrep(deformationfield, 'y_', 'c2')};
        fovimage = fullfile(SA_getSPMpath('12'),'/tpm/TPM.nii');
        
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = {deformationfield};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {fovimage};
        matlabbatch{1}.spm.util.defs.out{1}.push.fnames = imagestowarp;
        matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
        matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.bb = [NaN NaN NaN
            NaN NaN NaN];
        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.vox = [1.5 1.5 1.5];
        matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 1;
        matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
        try
        spm_jobman('run',matlabbatch);
        catch
        end
        clear deformationfield
        clear imagestowarp
    end
end