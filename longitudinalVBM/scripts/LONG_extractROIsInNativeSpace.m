function scans_to_process = LONG_extractROIsInNativeSpace(scans_to_process, rois, timepoint)
%LONG_extractVolumes - extract WM/GM/CSF/TIV and add to scans_to_process
%structure
%
% Syntax:  scans_to_process = LONG_extractVolumes( scans_to_process,scantype )
%
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%           rois = cell array of roi names that will be inside
%           "roi_extraction" folder based on previous processing steps
%           scantype - string specifying whether to segment time1, time2 or mean image.
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:

% To Do:
%
% Author: Suneth Attygalle
% Created 6/23/14
%
% Revisions:

for subject = 1: 5%size(scans_to_process,2)
    subject
    switch lower(timepoint)
        case 'mean'   
        case 'time2'
           timepointpath =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date2); 
           fieldname = 'ROIextractionsTime2';
           
        case 'time1'
            timepointpath =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1);  
            fieldname = 'ROIextractionsTime1';
    end

    %roiextraction =LONG_roiextraction.empty(size(rois,1),0);

    
    for r = 1:size(rois,2)
       ROIpath = fullfile( timepointpath, 'roi_extraction', [rois{r} '.nii'] );
       roivalues =spm_read_vols(spm_vol(ROIpath)) ;
       roiex(r).sum = sum(roivalues(:));
       clear roivalues
       roiex(r).name = rois{r} ;
       
    end
    
    scans_to_process(subject).(fieldname) = roiex;
    clear roiex
end % for subject = 1:size(scans_to_process,2)

