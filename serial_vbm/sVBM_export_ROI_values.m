function  ROIextractions = sVBM_export_ROI_values(scans_to_process,metric)
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
switch lower(metric)
    case 'sum'
        metricrow = 2;
    case 'mean'
        metricrow = 3;
    case 'median'
        metricrow = 4;
    case 'svd'
        metricrow = 5;
end

numROIs= size(scans_to_process(1).Timepoint{1}.ROI, 1)-1; % first row is ROI name
numSubjects=  size(scans_to_process,2);

for nROI = 1:numROIs
    clear output
    for  nSubject = 1: numSubjects
        for nTimepoint = 1:size(scans_to_process(nSubject).Timepoint,2)
            output(nSubject, nTimepoint) = scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{metricrow, nROI+1};
        end
    end
    ROIextractions{nROI} = output;
end