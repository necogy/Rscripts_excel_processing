function sVBM_plot_timeseries(scans_to_process, scantype)
%sVBM_plot_timeseries - generate various time series plots of change
%structure
%
% Syntax:  sVBM_plot_timeseries(plottype)
%
% Inputs:  plottype:
%
%
% Outputs: generates images in folder
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
% Created 12/22/2014
%
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

numROIs =  size(scans_to_process(1).Timepoint{1}.ROI,2);
numSubjects=  size(scans_to_process,2);

for nROI = 1:numROIs
 
    % grab a subjects data and time for all time points
    for nSubject = 1: numSubjects
           ROIdates(nSubject) = scans_to_process(nSubject).Deltatime;
        for nTimepoint = 1:size(scans_to_process(nSubject).Timepoint,2)
           ROIextractions{nROI}(nSubject, nTimepoint) = ... 
                scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{metricrow, nROI};  
        end   
    end
end

% plot all


% print figure


end

