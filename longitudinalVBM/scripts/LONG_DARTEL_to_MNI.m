function scans_to_process = LONG_DARTEL_to_MNI( scans_to_process, dartelpath )
%LONG_DARTEL_to_MNI - warp DARTEL to MNI 
%
% Syntax:  scans_to_process = LONG_DARTEL_to_MNI( scans_to_process)
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
%           dartelpath - path to dartel template 
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do: 
%
% Author: Suneth Attygalle
% Created 03/06/2014
% Revisions:


%look for template_6 file and set 
template = fullfile(dartelpath, 'Template_6.nii'); % Template_6 file
imageprefixes = {'avg','mavg','c1avg','c2avg','c3avg','l_c1avg_jd','l_c1avg_dv','l_c2avg_jd','l_c2avg_dv', 'dv_', 'jd_' };
for subject = 1:size(scans_to_process,2)
    
    flowfield =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, ['u_rc1avg_'  scans_to_process(subject).Time1file]);
    flowfield = strrep(flowfield, 'img', 'nii'); %avg filenames sometimes were img not nii
   % flowfield = strrep(flowfield, '.nii', '_Template.nii'); %avg filenames sometimes were img not nii

    spm('defaults', 'PET');
    spm_jobman('initcfg');
    matlabbatch{1}.spm.tools.dartel.mni_norm.template = cellstr(template);
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = cellstr(flowfield);
    
    for image = 1:size(imageprefixes,2)    
        d=SAdir(fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1), ['^' imageprefixes{image} '.*nii']);
        imagetowarp = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, d.name) ;  
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images{image} = cellstr(imagetowarp);    
    end
    
    matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [1 1 1];
    matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                                   NaN NaN NaN];                                          
    matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
    matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];

    spm_jobman('run',matlabbatch);
    
end

