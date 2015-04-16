function  ROIextractions = sVBM_export_ROI_values(scans_to_process,metric,scantype)
%sVBM_export_ROI_values - extract ROIs and add to scans_to_process
%structure
%
% Syntax:  output = VBM_export_ROI_values(scans_to_process,metric)
%
% Inputs:   scans_to_process -
%           metric - 'mean', 'median', 'sum', 'svd'
% Outputs:
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
% Created 12/3/2014
% Revisions:
switch lower(metric) % this should be class
    case 'sum'
        metricrow = 2;
    case 'mean'
        metricrow = 3;
    case 'median'
        metricrow = 4;
    case 'svd'
        metricrow = 5;
    case 'peak'
        metricrow = 6;
end

switch lower(scantype)
    case 'baseline'
        numROIs= size(scans_to_process(1).BaselineROIVolumes, 1);
        
    case 'timepoint'
        numROIs= size(scans_to_process(1).Timepoint{1}.ROI, 2);
        
end


numSubjects=  size(scans_to_process,2);

for nROI = 1:numROIs
    clear output
    
    for  nSubject = 1: numSubjects
        
        if strcmp(scantype, 'baseline')
            ROIextractions(nSubject,nROI) = scans_to_process(nSubject).BaselineROIVolumes{metricrow, nROI};
            
        elseif strcmp(scantype, 'timepoint')
            for nTimepoint = 1:size(scans_to_process(nSubject).Timepoint,2)
                ROIextractions{nROI}(nSubject, nTimepoint) = scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{metricrow, nROI};
            end
            
        end
        
    end
    
   % ROIextractions{nROI} = output;
    
end
end



