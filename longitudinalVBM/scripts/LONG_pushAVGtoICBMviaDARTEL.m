function LONG_pushAVGtoICBMviaDARTEL(scans_to_process, templatepath)
%LONG_pushAVGtoICBMviaDARTEL - warp longitudinal images from subject to DARTEL
%
% Syntax:  scans_to_process = LONG_pushAVGtoICBMviaDARTEL( scans_to_process)
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
%           templatepath - path to dartel template 
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: SPM12
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do: 
%
% Author: Suneth Attygalle
% Created 03/26/2014
% Revisions:

spm('defaults', 'PET');
spm_jobman('initcfg');
spmpath = fileparts(which('spm')); % add this to scans_to_process structure

imageprefixes = {'l_c1avg_jd','l_c1avg_dv','l_c2avg_jd','l_c2avg_dv' };

for subject = 1:size(scans_to_process,2)
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.comp{1}.def  = {fullfile(templatepath, 'y_Template_6_2mni.nii')};
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.space
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template = {''};
    
    for image = 1:size(imageprefixes,2)
        d=SAdir(fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1), ['^' imageprefixes{image} '.*nii']);
        imagetowarp = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, d.name) ;
        matlabbatch{1}.spm.util.defs.out{1}.push.fnames{image} = imagetowarp;
    end
    
    matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
    matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
    matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {fullfile(spmpath,'toolbox','DARTEL','icbm152.nii')};
    matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
    matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
    spm_jobman('run',matlabbatch);
    clear matlabbatch
end % subject = 1:size(scans_to_process,2)

end % LONG_pushAVGtoICBMviaDARTEL(scans_to_process, templatepath)
