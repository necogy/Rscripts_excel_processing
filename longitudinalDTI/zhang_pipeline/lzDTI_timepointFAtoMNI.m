function scans_to_process = lzDTI_timepointFAtoMNI(scans_to_process, dartelpath)
%lzDTI_timepointFAtoMNI SPM12 DARTEL register to new template
%   Detailed explanation goes here
% Syntax:  scans_to_process = lzDTI_timepointFAtoMNI( scans_to_process)
%
% Inputs: scans_to_process - array of objects of class lzDTI_participant,
%         DARTEL_template_path - path to the desired DARTEL tempalte
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created: 11/5/14
%
% Revisions:

%dartelpath;
spm('defaults', 'PET');
spm_jobman('initcfg');
for sub = 1:size(scans_to_process,2)
    for iTimepoint= 1:size(scans_to_process(sub).Timepoint,2)
        scans_to_process(sub).Timepoint{1}.Image_T1.path;
        y_timepointToFAavg = SAinsertStr2Paths(   scans_to_process(sub).Timepoint{iTimepoint}.Image_FA.path, 'y_rT1'); %'R:\groups\imaging_core\suneth\analyses\longDTI_bri\pidns\0065\2010-04-29\y_rT1GHB243X1_v1_FA.nii'
        u_FAavgToDartel=SAinsertStr2Paths(   scans_to_process(sub).Timepoint{1}.Image_T1.path, 'u_rc1avg_w');
        u_FAavgToDartel=strrep(u_FAavgToDartel, 'img','nii');
        u_FAavgToDartel=strrep(u_FAavgToDartel, '.nii','_Template.nii');
                
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = {y_timepointToFAavg};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield = {u_FAavgToDartel};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template = {dartelpath};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.space = { scans_to_process(sub).Timepoint{iTimepoint}.Image_FA.path};
        matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {scans_to_process(sub).Timepoint{iTimepoint}.Image_FA.path};
        matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
        matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.bb = [NaN NaN NaN
            NaN NaN NaN];
        matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.vox = [NaN NaN NaN];
        matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
        matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
        matlabbatch{1}.spm.util.defs.out{2}.savedef.ofname = 'FAtoMNIviaLongzDTI';
        matlabbatch{1}.spm.util.defs.out{2}.savedef.savedir.saveusr = {fileparts(scans_to_process(sub).Timepoint{iTimepoint}.Image_FA.path)};
        
        spm_jobman('run',matlabbatch);
    end
end