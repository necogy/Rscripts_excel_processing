function scans_to_process = LONG_extractROIsinDARTEL(scans_to_process, changemapprefix, pathtoROIs, ROIprefix)
%LONG_extractROIsinDARTEL-Extract ROIs from change maps in Dartel Space
%
% Syntax:  scans_to_process =  LONG_extractROIsinDARTEL(scans_to_process, changemapprefix, pathtoROIs, ROIprefix)
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
% See also:
% To Do:
%
% Author: Suneth Attygalle
% Created 09/26/2014
%
% Revisions:

% First check if files already exist

% Generate files in DARTEL Intersubject Group Average Space

imageprefixes = {'avg','mavg','c1avg','c2avg','l_c1avg_jd','l_c2avg_jd','dv_', 'jd_' };
spm('defaults', 'PET');
for subject = 1:size(scans_to_process,2)
    
    flowfield =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, ['u_rc1avg_'  scans_to_process(subject).Time1file]);
    flowfield = strrep(flowfield, 'img', 'nii'); %avg filenames sometimes were img not nii
    
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.tools.dartel.crt_warped.flowfields = cellstr(flowfield);
    
    for image = 1:size(imageprefixes,2)    % set images to warp
        d=SAdir(fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1), ['^' imageprefixes{image} '.*nii']);
        imagetowarp = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, d.name) ;
        matlabbatch{1}.spm.tools.dartel.crt_warped.images{image} = cellstr(imagetowarp);
    end
    
    matlabbatch{1}.spm.tools.dartel.crt_warped.jactransf = 0; % modulation
    matlabbatch{1}.spm.tools.dartel.crt_warped.K = 6; %timesteps (2^6 = 64)
    matlabbatch{1}.spm.tools.dartel.crt_warped.interp = 4; % 4th degree b-spline
    spm_jobman('run',matlabbatch);
    clear matlabbatch
end

%get list of ROIs
%
% rois = SAdir(pathtoROIs,  ROIprefix);
%
%     [~, a, ~] = fileparts(scans_to_process(subject).Time1file);
%     [~, b, ~] = fileparts(scans_to_process(subject).Time2file);
%     changemap = [changemapprefix a '_', b, '.nii'];
%     vol = spm_vol(fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1,  changemap));
%     img_arr = spm_read_vols(vol);
%
%     for r = 1:size(rois,1)
%         roivol  = spm_vol(fullfile(pathtoROIs, rois(r).name));
%         roi_arr = spm_read_vols(roivol);
%         roi_arr(isnan(roi_arr))=0;
%         roiones = ~roi_arr==0;
%         includedvalues = img_arr(roiones);
%         scans_to_process(subject).ROIsum{1,r} = rois(r).name;
%         scans_to_process(subject).ROIsum{2,r} = sum(includedvalues);
%         scans_to_process(subject).ROImean{1,r} = rois(r).name;
%         scans_to_process(subject).ROImean{2,r} = mean(includedvalues);
%         scans_to_process(subject).ROImedian{1,r} = rois(r).name;
%         scans_to_process(subject).ROImedian{2,r} = median(includedvalues);
%
%     end
% end
%
%


