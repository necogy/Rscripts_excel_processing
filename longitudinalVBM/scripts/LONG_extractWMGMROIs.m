function scans_to_process = LONG_extractWMGMROIs(scans_to_process, changemapprefix, pathtoROIs, ROIprefix)
%LONG_extractWMGMROIs - combine WM/GM change maps and extract ROIs
%
% Syntax:  scans_to_process =  LONG_extractROIs( scans_to_process,pathtoROIs )
%
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%           pathtoROIs - path to folder with ROIs to extract from, ensure
%           that they are in MNI at the same resolution as the final images
%           from longitudinal registration processing. If the images do not
%           match they will be resliced. The ROIs should be resliced and
%           smoothed(if necessary) beforehand to the same dimension as your
%           warped images to extract from. (likely 1x1x1 MNI images)
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
% Created 10/31/14
%
% Revisions:

rois = SAdir(pathtoROIs,  ROIprefix);

for subject = 1:size(scans_to_process,2)
    
    [~, a, ~] = fileparts(scans_to_process(subject).Time1file);
    [~, b, ~] = fileparts(scans_to_process(subject).Time2file);
    changemap = [changemapprefix a '_', b, '.nii'];
    
    GMchangemap = strrep(changemap, '*','1');
    WMchangemap = strrep(changemap, '*', '2');
    
    
    wmvol= spm_read_vols(spm_vol(fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1,  WMchangemap)));
    gmvol= spm_read_vols(spm_vol(fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1,  GMchangemap)));
    
    
    %add them
    combined = wmvol+gmvol;
    for r = 1:size(rois,1)
        roivol  = spm_vol(fullfile(pathtoROIs, rois(r).name));
        roi_arr = spm_read_vols(roivol);
        roi_arr(isnan(roi_arr))=0;
        roiones = ~roi_arr==0;
        includedvalues = combined(roiones);
        scans_to_process(subject).ROIsum{1,r} = rois(r).name;
        scans_to_process(subject).ROIsum{2,r} = sum(includedvalues);
        scans_to_process(subject).ROImean{1,r} = rois(r).name;
        scans_to_process(subject).ROImean{2,r} = mean(includedvalues);
        scans_to_process(subject).ROImedian{1,r} = rois(r).name;
        scans_to_process(subject).ROImedian{2,r} = median(includedvalues);
        
    end
    
end
