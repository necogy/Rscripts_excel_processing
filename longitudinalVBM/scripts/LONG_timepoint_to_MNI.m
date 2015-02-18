function scans_to_process = LONG_timepoint_to_MNI( scans_to_process, dartelpath, timepoint)
%LONG_timepoint_to_MNI - warp timepoint to MNI
%
% Syntax:  scans_to_process = LONG_timepoint_to_MNI( scans_to_process, dartelpath, timepoint)
%
% Inputs:   scans_to_process - array of objects of class LONG_participant
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
% Created 03/10/2014
%
% Revisions:
%----------------------

template = fullfile(dartelpath, 'Template_6.nii'); % Template_6 file
% for subject = 1:size(scans_to_process,2)
%
%     file = SAdir(input.subjectdir{1i}, ['^' prefixes{n} '_.*nii$'] );
%     files{1i,1} = [input.subjectdir{1i} filesep file.name];
%
% end
%

    spm('defaults', 'PET');

for subject = 1:size(scans_to_process,2)
    clear matlabbatch
    clear rawtimepointimage
    clear rawtimepointimagenii
    clear flowfield
    switch lower(timepoint)
        case 'time1'
            rawtimepointimage = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, scans_to_process(subject).Time1file);
            rawtimepointimagenii = strrep(rawtimepointimage, 'img', 'nii'); %avg filenames sometimes were img not nii
            
        case 'time2'
            rawtimepointimage = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date2, scans_to_process(subject).Time2file);
            rawtimepointimagenii = strrep(rawtimepointimage, 'img', 'nii'); %avg filenames sometimes were img not nii
            
    end
    %avg filenames sometimes were img not nii
    
    flowfield =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, ['u_rc1avg_'  scans_to_process(subject).Time1file]);
    flowfield = strrep(flowfield, 'img', 'nii'); %avg filenames sometimes were img not nii
    warpedavg = strrep( flowfield, 'u_rc1avg_', 'wavg_');
    
    spm_jobman('initcfg');
    
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.comp{1}.def = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\y_Template_6_2mni.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.space = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\Template_6.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\u_rc1avg_MP-LAS_GHB243X1.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template = {''};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{3}.def = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\0065\2010-04-29\y_MP-LAS_GHB243X1.nii'};
    
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.comp{1}.def = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\y_Template_6_2mni.nii'};
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.space = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\Template_6.nii'};
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield = cellstr(flowfield);% DARTEL flowfield from AVG u_rc
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template = {''} ;%cellstr(template);
%     
%     timepttoavg = SAinsertStr2Paths(rawtimepointimagenii, 'y_');
%     
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{3}.def = cellstr(timepttoavg); % Timepoint's deform field to AVG (Y)" y"
%     matlabbatch{1}.spm.util.defs.comp{1}.inv.space = cellstr(rawtimepointimage); % raw time point image
%     matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'toAVGtoMNI_InvForPush'; % output image name
%     matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = cellstr(fileparts(rawtimepointimagenii)) ; % out put folder
%     
%     matlabbatch{1}.spm.util.defs.out{2}.push.fnames =  { SAinsertStr2Paths(rawtimepointimagenii, 'c1'), SAinsertStr2Paths(rawtimepointimagenii, 'c2') ,SAinsertStr2Paths(rawtimepointimagenii, 'c3')};
%     matlabbatch{1}.spm.util.defs.out{2}.push.weight = '';
%     matlabbatch{1}.spm.util.defs.out{2}.push.savedir.savesrc = 1;
%     
%     matlabbatch{1}.spm.util.defs.out{2}.push.fov.file = cellstr(warpedavg); %image to base voxel dims (warped avg)
%     matlabbatch{1}.spm.util.defs.out{2}.push.preserve = 1;
%     matlabbatch{1}.spm.util.defs.out{2}.push.fwhm = [0 0 0];
%     spm_jobman('run',matlabbatch);

    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.flowfield = cellstr(flowfield);% DARTEL flowfield from AVG u_rc
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.times = [1 0];
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.template =cellstr(template)%{''} ;%cellstr(template);
    
    timepttoavg = SAinsertStr2Paths(rawtimepointimagenii, 'y_');
    
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.def = cellstr(timepttoavg); % Timepoint's deform field to AVG (Y)" y"
    matlabbatch{1}.spm.util.defs.comp{1}.inv.space = cellstr(rawtimepointimage); % raw time point image
  %  matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'toAVGtoMNI_InvForPush'; % output image name
   % matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = cellstr(fileparts(rawtimepointimagenii)) ; % out put folder
    
    matlabbatch{1}.spm.util.defs.out{1}.push.fnames =  { SAinsertStr2Paths(rawtimepointimagenii, 'c1'), SAinsertStr2Paths(rawtimepointimagenii, 'c2') ,SAinsertStr2Paths(rawtimepointimagenii, 'c3')};
    matlabbatch{1}.spm.util.defs.out{1}.push.weight = '';
    matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
    
    matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = cellstr(warpedavg); %image to base voxel dims (warped avg)
    matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
    matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
    spm_jobman('run',matlabbatch);


end

end

