function scans_to_process = LONG_warpROIsToNativeSpace(scans_to_process, templatepath, roipath, timepoint, modulation)
%LONG_warpROIsToNativeSpace - warp atlas ROIs into native timepoint
%space
%
% Syntax:  scans_to_process = LONG_extractROIsInNativeSpace(scans_to_process, timepoint)
%
% Inputs:   scans_to_process - array of objects of class LONG_participant
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
% Created 05/29/2014
%
% Revisions:
%----------------------

template = fullfile(templatepath, 'Template_6.nii'); % Template_6 file from DARTEL
spm('defaults', 'PET');
spm_jobman('initcfg');
for subject = 1:size(scans_to_process,2)
    
    clear rawtimepointimage
    clear rawtimepointimagenii
    clear flowfield
    
    display(scans_to_process(subject).PIDN)
    switch lower(timepoint)
        case 'time1'
            rawtimepointimage = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, scans_to_process(subject).Time1file);
            rawtimepointimagenii = strrep(rawtimepointimage, 'img', 'nii'); %avg filenames sometimes were img not nii
            
        case 'time2'
            rawtimepointimage = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date2, scans_to_process(subject).Time2file);
            rawtimepointimagenii = strrep(rawtimepointimage, 'img', 'nii'); %avg filenames sometimes were img not nii
            
    end
    
    flowfield =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, ['u_rc1avg_'  scans_to_process(subject).Time1file]);
    flowfield = strrep(flowfield, 'img', 'nii'); %avg filenames sometimes were img not nii
    clear matlabbatch
    
    %%%%%%%%%%%%%%%%
    yfile = SAinsertStr2Paths(rawtimepointimagenii, 'y_'); % deformation to intrasubject average
    
    
    matlabbatch{1}.spm.util.defs.comp{1}.comp{1}.def = cellstr(yfile);
    matlabbatch{1}.spm.util.defs.comp{1}.comp{2}.dartel.flowfield =cellstr(flowfield);
    matlabbatch{1}.spm.util.defs.comp{1}.comp{2}.dartel.times = [1 0];
    matlabbatch{1}.spm.util.defs.comp{1}.comp{2}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{1}.comp{2}.dartel.template =cellstr(template);
    
    %get all rois in roipath
    d = SAdir(roipath, '\w*.nii');
    roinames = {d.name} ;
    roistowarp= strcat( [roipath '\'], roinames');
    
    matlabbatch{1}.spm.util.defs.out{1}.push.fnames = roistowarp;
    
    matlabbatch{1}.spm.util.defs.out{1}.push.weight ={''};
    newROIdir = fullfile(fileparts(rawtimepointimage), 'roi_extraction');
    mkdir(newROIdir );
    matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr =cellstr(newROIdir);
    matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.bb = [NaN NaN NaN
        NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.out{1}.push.fov.bbvox.vox =[NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.out{1}.push.preserve = modulation;
    matlabbatch{1}.spm.util.defs.out{1}.push.fwhm =[0 0 0];
    
    
    %%%%%%%%%%%%%%%%
    
    spm_jobman('run',matlabbatch);
    
    
end

end




