function LONG_pushDARTELtoICBM(scans_to_process, templatepath)
%LONG_pushDARTELtoICBM - warp longitudinal images from dartel to ICBM
%
% Syntax:  scans_to_process = LONG_pushDARTELtoICBM(scans_to_process, templatepath)
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
% Created: 
% Revisions:

spm('defaults', 'PET');
spm_jobman('initcfg')
imageprefixes = {'wl_c1avg_jd','wl_c1avg_dv','wl_c2avg_jd','wl_c2avg_dv', 'wdv_', 'wjd_' };

for subject = 1:size(scans_to_process,2)
    matlabbatch{1}.spm.util.defs.comp{1}.def = {fullfile(templatepath, 'y_Template_6_2mni.nii')};
    
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

end % LONG_pushDARTELtoICBM(scans_to_process, templatepath)


