function scans_to_process = sVBM_extract_baseline_vols( scans_to_process, pathtoROIs)
%sVBM_extract_baseline_vols - extract ROI volumes from MNI
% warped tissues.
%
% Syntax:  scans_to_process = sVBM_extract_baseline_vols( scans_to_process, pathtoROIs)
%
% Inputs: scans_to_process - array of objects of class sVBM_participant
%         pathtoROIs -
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 12/15/2014
% Revisions:
d=SAdir(pathtoROIs, '\w');
ROInames = strrep({d.name},'.nii','');
ROInames = {d.name};
numSubjects = size(scans_to_process,2);
for nSubject = 1: numSubjects% for every subject
    
    basename = fullfile(scans_to_process(nSubject).Timepoint{1}.Fullpath, ...
        scans_to_process(nSubject).Timepoint{1}.File.name);
    
    imagetoextractfrom= strrep(SAinsertStr2Paths(basename, 'mwc1'),'img','nii');
    nSubject
    
    for r = 1:size(ROInames,2)
        roi = fullfile(pathtoROIs, ROInames{r});
        %try
        roi_extraction = spm_summarise(imagetoextractfrom, roi);
        
        scans_to_process(nSubject).BaselineROIVolumes{1,r} = ROInames{r}(1:end-4) ;%name
        scans_to_process(nSubject).BaselineROIVolumes{2,r} = sum(roi_extraction);% sum
        scans_to_process(nSubject).BaselineROIVolumes{3,r} = mean(roi_extraction);% mean
        scans_to_process(nSubject).BaselineROIVolumes{4,r} = median(roi_extraction);% median
        scans_to_process(nSubject).BaselineROIVolumes{5,r} = svd(roi_extraction,0); %first
        
        %eignevariate
        %catch
        %end
        
    end
    
    scans_to_process(nSubject).BaselineTissueVolumes.GMvol =spm_summarise(imagetoextractfrom, 'all', 'litres');
    scans_to_process(nSubject).BaselineTissueVolumes.WMvol = spm_summarise(strrep(imagetoextractfrom, 'mwc1', 'mwc2'), 'all', 'litres');
    scans_to_process(nSubject).BaselineTissueVolumes.CSFvol = spm_summarise(strrep(imagetoextractfrom, 'mwc1', 'mwc3'), 'all', 'litres');
    scans_to_process(nSubject).BaselineTissueVolumes.TIV =  scans_to_process(nSubject).BaselineTissueVolumes.GMvol + scans_to_process(nSubject).BaselineTissueVolumes.WMvol+ scans_to_process(nSubject).BaselineTissueVolumes.CSFvol;
    
end


end % function scans_to_process = sVBM_extract_baseline_vols( scans_to_process, pathtoROIa)

