function scans_to_process = LONG_extractROIsInNativeSpace(scans_to_process, templatepath, roipath, timepoint)
%LONG_extractROIsInNativeSpace - warp atlas ROIs into native timepoint
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

for subject = 1:size(scans_to_process,2)

    switch lower(timepoint)
        case 'time1'
            rawtimepointimage = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, scans_to_process(subject).Time1file);
            rawtimepointimagenii = strrep(rawtimepointimage, 'img', 'nii'); %avg filenames sometimes were img not nii
            
        case 'time2'
            rawtimepointimage = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date2, scans_to_process(subject).Time2file);
            rawtimepointimagenii = strrep(rawtimepointimage, 'img', 'nii'); %avg filenames sometimes were img not nii
            
    end
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    flowfield =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, ['u_rc1avg_'  scans_to_process(subject).Time1file]);
    flowfield = strrep(flowfield, 'img', 'nii'); %avg filenames sometimes were img not nii
    
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = cellstr(flowfield);
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [1 0];
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = cellstr(template);
    
    yfile = SAinsertStr2Paths(rawtimepointimagenii, 'y_'); % deformation to intrasubject average
    
    matlabbatch{1}.spm.util.defs.comp{2}.def = cellstr(yfile);
    matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'toAVGtoMNIForPush';
    matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = cellstr(fileparts(rawtimepointimage));
    
    
    %get all rois in roipath
    
    d = SAdir(roipath, '\w*.nii');
    roinames = {d.name} ;
    roistowarp= strcat( [roipath '\'], roinames');
    
    
    matlabbatch{1}.spm.util.defs.out{2}.push.fnames = roistowarp;
        
%     matlabbatch{1}.spm.util.defs.out{2}.push.fnames = {
%                                                        'R:\groups\rosen\longitudinalVBM\FLOOR_mar2014_reprocess_2\rois\rACC.nii'
%                                                        'R:\groups\rosen\longitudinalVBM\FLOOR_mar2014_reprocess_2\rois\rACC.nii'
%                                                        'R:\groups\rosen\longitudinalVBM\FLOOR_mar2014_reprocess_2\rois\rAmygdala.nii'
%                                                        'R:\groups\rosen\longitudinalVBM\FLOOR_mar2014_reprocess_2\rois\rAnt_FG.nii'
%                                                        'R:\groups\rosen\longitudinalVBM\FLOOR_mar2014_reprocess_2\rois\rInsula.nii'
%                                                        };
%                                                    
    matlabbatch{1}.spm.util.defs.out{2}.push.weight = {''};
    newROIdir = fullfile(fileparts(rawtimepointimage), 'roi_extraction');
    mkdir(newROIdir ); 
    matlabbatch{1}.spm.util.defs.out{2}.push.savedir.saveusr = cellstr(newROIdir);
    matlabbatch{1}.spm.util.defs.out{2}.push.fov.file = cellstr(rawtimepointimage); %image to base voxel dims (native space time point image)
    matlabbatch{1}.spm.util.defs.out{2}.push.preserve = 1;
    matlabbatch{1}.spm.util.defs.out{2}.push.fwhm = [0 0 0];
    spm_jobman('run',matlabbatch);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
    %%% 
%     flowfield =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, ['u_rc1avg_'  scans_to_process(subject).Time1file]);
%     flowfield = strrep(flowfield, 'img', 'nii'); %avg filenames sometimes were img not nii
%     warpedavg = strrep( flowfield, 'u_rc1avg_', 'wavg_');
%     spm('defaults', 'PET');
%     spm_jobman('initcfg');
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.flowfield = cellstr(flowfield);% DARTEL flowfield from AVG u_rc
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.times = [1 0];
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.K = 6;
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.template =cellstr(template);
%     timepttoavg = SAinsertStr2Paths(rawtimepointimagenii, 'y_');
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.def = cellstr(timepttoavg); % Timepoint's deform field to AVG (Y)" y"
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.space = cellstr(rawtimepointimage); % raw time point image
%     matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'toAVGtoMNI_InvForPush'; % output image name
%     matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = cellstr(fileparts(rawtimepointimagenii)) ; % out put folder
%     matlabbatch{1}.spm.util.defs.out{2}.push.fnames =  { SAinsertStr2Paths(rawtimepointimagenii, 'c1'), SAinsertStr2Paths(rawtimepointimagenii, 'c2') ,SAinsertStr2Paths(rawtimepointimagenii, 'c3')};
%     matlabbatch{1}.spm.util.defs.out{2}.push.weight = '';
%     matlabbatch{1}.spm.util.defs.out{2}.push.savedir.savesrc = 1;   
%     matlabbatch{1}.spm.util.defs.out{2}.push.fov.file = cellstr(warpedavg);  (warped avg)   
%     matlabbatch{1}.spm.util.defs.out{2}.push.preserve = 1;
%     matlabbatch{1}.spm.util.defs.out{2}.push.fwhm = [0 0 0];
%     
    
    %%%
end

end




