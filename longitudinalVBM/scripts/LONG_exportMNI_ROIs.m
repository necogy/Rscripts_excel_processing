function nativeROIvolumes = LONG_exportNativeROIs(scans_to_process, timepoint)
%LONG_exportNativeROIs - export ROI extractions generated by LONG_extractMNItimepointROIs
%
% Syntax:  scans_to_process = LONG_extractVolumes( scans_to_process,timepoint )
%
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%           timepoint = 'time1' or 'time2'
%
% Outputs: scans_to_process - updated array with ROI extractions
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b, LONG_extractROIsInNativeSpace
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 7/25/14
%
% Revisions:

switch lower(timepoint)
    case 'time2'
        fieldname = 'MNI_ROIextractionsTime2';
    case 'time1'
        fieldname = 'MNI_ROIextractionsTime1';
end

nativeROIvolumes = zeros(size(scans_to_process,2), size([scans_to_process(1).(fieldname).mean{2,:}],2)) ;
for subject = 1:size(scans_to_process,2)
    nativeROIvolumes(subject, :) = [scans_to_process(subject).(fieldname).mean{2,:}];
end