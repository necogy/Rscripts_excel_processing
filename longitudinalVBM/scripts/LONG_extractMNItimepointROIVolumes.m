function scans_to_process = LONG_extractMNItimepointROIs(scans_to_process, pathtoROIs, timepoint)
%LONG_extractMNItimepointROI - extract ROIs and add to scans_to_process
%structure
%
% Syntax:  scans_to_process = LONG_extractMNItimepointROIs(scans_to_process, pathtoROIs, timepoint)
%
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%           pathtoROIs - path where the ROIs that will be used for
%           extraction
%           timepoint - 'time1' or 'time2' to extract for specific
%           timepoint
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b,
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created
%
% Revisions:
d=SAdir(pathtoROIs, '\w');
ROInames = strrep({d.name},'.nii','');
ROInames = {d.name};

for subject = 1: size(scans_to_process,2)
    subject
    switch lower(timepoint)
        case 'mean'
        case 'time2'
            timepointpath =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date2,scans_to_process(subject).Time2file) ;
            fieldname = 'MNI_ROIvolumesTime2';
            
        case 'time1'
            timepointpath =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1,scans_to_process(subject).Time1file);
            fieldname = 'MNI_ROIvolumesTime1';
    end
    for r = 1:size(ROInames,2)
        roi = fullfile(pathtoROIs, ROInames{r});
        imagetoextractfrom= strrep(SAinsertStr2Paths(timepointpath, 'mwmwmwc1'),'img','nii');
        
        roi_extraction = spm_summarise(imagetoextractfrom, roi, 'litres');
        
        scans_to_process(subject).(fieldname).mean{1,r} = ROInames(r);
        scans_to_process(subject).(fieldname).mean{2,r} = roi_extraction;
    end
    
end % for subject = 1:size(scans_to_process,2)

