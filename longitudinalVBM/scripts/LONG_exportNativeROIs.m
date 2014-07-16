function nativeROIvolumes = LONG_exportNativeROIs(scans_to_process, timepoint)
%LONG_extractVolumes - extract WM/GM/CSF/TIV and add to scans_to_process
%structure
%
% Syntax:  scans_to_process = LONG_extractVolumes( scans_to_process,scantype )
%
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%
% Outputs: scans_to_process - updated array with run status
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
% Created 6/25/14
%
% Revisions:

    switch lower(timepoint)
        case 'time2'
           fieldname = 'ROIextractionsTime2';
        case 'time1'
           fieldname = 'ROIextractionsTime1';
    end
    
    numROIs = size(scans_to_process(1).(fieldname), 2 );
    
    extractions = [scans_to_process.(fieldname) ];
    
    for r = 1:size(numROIs)
        
        ROIindex =  r:numROIs:size(extractions,2)
        
        ROIextraction(r) = [extractions(ROIindex).sum];
        
    end 
    
    
    




