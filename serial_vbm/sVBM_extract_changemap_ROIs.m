function scans_to_process = sVBM_extract_changemap_ROIs(scans_to_process, pathtoROIs)
%sVBM_extract_changemap_ROIs - extract ROIs and add to scans_to_process
%structure
%
% Syntax:  scans_to_process = sVBM_extract_changemap_ROIs(scans_to_process, pathtoROIs)
%
% Inputs:   scans_to_process - 
%           pathtoROIs - 
%           extraction
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: 
% Subfunctions:
%
% MAT-files required:
%
% See also:
%
% To Do:n
%
% Author: Suneth Attygalle
% Created 12/2/2014
%
% Revisions:

d=SAdir(pathtoROIs, '\w');
ROInames = strrep({d.name},'.nii','');
ROInames = {d.name};

for  nSubject = 1:size(scans_to_process,2)
    nSubject
    for nTimepoint = 1:size(scans_to_process(nSubject).Timepoint,2)
        nTimepoint
        
        basename = fullfile(scans_to_process(nSubject).Timepoint{nTimepoint}.Fullpath, ...
            scans_to_process(nSubject).Timepoint{nTimepoint}.File.name);
        imagetoextractfrom= strrep(SAinsertStr2Paths(basename, 'wc1avgj_'),'img','nii');
        
        for r = 1:size(ROInames,2)
            roi = fullfile(pathtoROIs, ROInames{r});
            try
            roi_extraction = spm_summarise(imagetoextractfrom, roi,'litres');
            
            scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{1,r} = ROInames{r}(1:end-4) ;%name
            scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{r,2} = sum(roi_extraction);% sum (average)
            scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{r,3} = mean(roi_extraction);% mean
            scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{r,4} = median(roi_extraction);% median
            scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{r,5} = svd(roi_extraction,0); %first
            scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{r,6} = max(roi_extraction); %peak
            
            %eignevariate
            catch
            end

        end
    end
end
