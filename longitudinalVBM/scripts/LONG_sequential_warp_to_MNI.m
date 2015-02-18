% warp step by step


function scans_to_process = LONG_sequential_warp_to_MNI( scans_to_process, dartelpath)
%LONG_sequential_warp_to_MNI - warp timepoints to MNI in multiple steps
% this warps 1. from timepoint to subject average, then 2. subj average to
% group average(DARTEL) 3. DARTEL average to MNI (either by ICBM or affine)
%
% Syntax:  scans_to_process = LONG_sequential_warp_to_MNI( scans_to_process, dartelpath)
%
% Inputs:   scans_to_process - array of objects of class LONG_participant
%           dartelpath - path to dartel template
%
% Outputs: scans_to_process -
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 02/18/2015
%
% Revisions:
%----------------------
spm_jobman('initcfg')
for subject = 2 :size(scans_to_process,2)
    for timepoint = 1:2
        clear matlabbatch
         timept1 = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, scans_to_process(subject).Time1file);     
                timept1nii = strrep(timept1, 'img', 'nii'); %avg filenames sometimes were img not nii
        switch timepoint
            
            case 1
                timept = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, scans_to_process(subject).Time1file);     
                timeptnii = strrep(timept, 'img', 'nii'); %avg filenames sometimes were img not nii
                
            case 2
                timept = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date2, scans_to_process(subject).Time2file);
                timeptnii = strrep(timept, 'img', 'nii'); %avg filenames sometimes were img not nii
        end
        
        
        %% warp timepoint to subj average (generates wc1 images)
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = {SAinsertStr2Paths( timeptnii,'y_')};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {SAinsertStr2Paths(timeptnii, 'c1')};
        matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {SAinsertStr2Paths(timeptnii, 'c1'), SAinsertStr2Paths(timeptnii, 'c2'), SAinsertStr2Paths(timeptnii, 'c3')} ;
        matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
        matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
        matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {SAinsertStr2Paths(timept1nii, 'avg_')};
        matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 1;
        matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
        
        %% warp to DARTEL either with ICBM with modulation?
        matlabbatch{2}.spm.tools.dartel.mni_norm.template = {''};
        
        matlabbatch{2}.spm.tools.dartel.mni_norm.data.subj.flowfield = {SAinsertStr2Paths(timept1nii, 'u_rc1avg_')};
        matlabbatch{2}.spm.tools.dartel.mni_norm.data.subj.images = {SAinsertStr2Paths(timeptnii, 'mwc1'), SAinsertStr2Paths(timeptnii, 'mwc2'), SAinsertStr2Paths(timeptnii, 'mwc3')} ;
        matlabbatch{2}.spm.tools.dartel.mni_norm.vox = [1 1 1];
        matlabbatch{2}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
            NaN NaN NaN];
        matlabbatch{2}.spm.tools.dartel.mni_norm.preserve = 1;
        matlabbatch{2}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];
        
        %% warp from DARTEL to ICBM (needs ICBM warping already generated) with modulation?
        matlabbatch{3}.spm.util.defs.comp{1}.def = {fullfile(dartelpath,'y_Template_6_2mni.nii')};
        matlabbatch{3}.spm.util.defs.out{1}.push.fnames = {SAinsertStr2Paths(timeptnii, 'mwmwc1'), SAinsertStr2Paths(timeptnii, 'mwmwc2'), SAinsertStr2Paths(timeptnii, 'mwmwc3')};
        matlabbatch{3}.spm.util.defs.out{1}.push.weight = {''};
        matlabbatch{3}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
        matlabbatch{3}.spm.util.defs.out{1}.push.fov.file = {fullfile(dartelpath,'Template_6.nii')};
        % matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.bb = [-90,-126,-72
        %                                                         91 90 108];
        % matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.vox = [1 1 1];
        matlabbatch{3}.spm.util.defs.out{1}.push.preserve = 1;
        matlabbatch{3}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
        
        
        %% warp to MNI either with affine to TPM-MNI and modulation (deprecated by ICBM deformation field)
        %         matlabbatch{2}.spm.tools.dartel.mni_norm.template = cellstr(template);
        %         matlabbatch{2}.spm.tools.dartel.mni_norm.data.subjs.flowfields = cellstr(flowfield);
        %         matlabbatch{2}.spm.tools.dartel.mni_norm.data.subjs.images =images ;
        %         matlabbatch{2}.spm.tools.dartel.mni_norm.vox = [1 1 1];
        %         matlabbatch{2}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
        %             NaN NaN NaN];
        %         matlabbatch{2}.spm.tools.dartel.mni_norm.preserve = 1;
        %         matlabbatch{2}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];
        
        spm_jobman('run',matlabbatch);
        
    end
end

end



% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\y_MP-LAS_GHB243X1.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\c1MP-LAS_GHB243X1.nii'};
% matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {
%                                                    'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\cc1MP-LAS_GHB243X1.nii'
%                                                    'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\cc2MP-LAS_GHB243X1.nii'
%                                                    'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\cc3MP-LAS_GHB243X1.nii'
%                                                    };
% matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
% matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
% matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\avg_MP-LAS_GHB243X1.nii'};
% matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
% matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];




