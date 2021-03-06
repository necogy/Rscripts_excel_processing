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

for subject = 1: size(scans_to_process,2)
    subject
    switch lower(timepoint)
        case 'mean'
        case 'time2'
            timepointpath =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date2,scans_to_process(subject).Time2file) ;
            fieldname = 'MNI_ROIextractionsTime2';
            
        case 'time1'
            timepointpath =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1,scans_to_process(subject).Time1file);
            fieldname = 'MNI_ROIextractionsTime1';
    end
    
    vol = spm_vol(strrep(SAinsertStr2Paths(timepointpath, 'mwmwmwc1'),'img', 'nii'));
    img_arr = spm_read_vols(vol);
    
    d=SAdir(pathtoROIs, '\w');
    ROInames = strrep({d.name},'.nii','');
    ROInames = {d.name};
    for r = 1:size(ROInames,2)
        
        roivol  = spm_vol(fullfile(pathtoROIs, ROInames(r) ));
        roi_arr = spm_read_vols(roivol{:});
        roiones = ~roi_arr==0;
        includedvalues = img_arr(roiones);
        
        scans_to_process(subject).(fieldname).mean{1,r} = ROInames(r);
        scans_to_process(subject).(fieldname).mean{2,r} = mean(includedvalues);
        scans_to_process(subject).(fieldname).median{1,r} = ROInames(r);
        scans_to_process(subject).(fieldname).median{2,r} = median(includedvalues);
        
        
    end
    % chheck if it exists and add first row of ROI names
    %
    %     myformat = ['%s, ', repmat('%f,',1,size(roiex,2)) '\n'];
    %     %append to text file
    %     fid = fopen('extractions.txt', 'a');
    %     % write values at end of file
    %     fprintf(fid, myformat,scans_to_process(subject).PIDN, [roiex.sum]);
    %
    %     % close the file
    %     fclose(fid);
    %     scans_to_process(subject).(fieldname) = roiex;
    %     clear roiex
end % for subject = 1:size(scans_to_process,2)

