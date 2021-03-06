function  ROIsheet = sVBM_export_ROI_values_to_excel(scans_to_process,metric)
%sVBM_export_ROI_values - export ROIs into spreadsheet
%structure
%
% Syntax:  output = sVBM_export_ROI_values_to_excel(scans_to_process,metric,scantype)
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
% To Do:
%
% Author: Suneth Attygalle
% Created 04/20/2015
% Revisions:
scandatafolder = fileparts(scans_to_process(1).Fullpath);
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

%switch lower(scantype)
%case 'baseline'
%   numROIs= size(scans_to_process(1).BaselineROIVolumes, 1);

% case 'timepoint'
numROIs= size(scans_to_process(1).Timepoint{1}.ROI, 2);

%end

% initialize matrix
numSubjects =  size(scans_to_process,2);
ROImat = [];

for nSubject = 1:numSubjects
    clear ROI;
    numTimepoints = size(scans_to_process(nSubject).Timepoint,2) ;
    for nTimepoint = 1:numTimepoints
                
        ROI = [ scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{metricrow, :}]; %data
        ROI = [scans_to_process(nSubject).Timepoint{nTimepoint}.Datenum - scans_to_process(nSubject).Timepoint{1}.Datenum, ROI];
        ROI = [scans_to_process(nSubject).Timepoint{nTimepoint}.Datenum - 693960, ROI] ; %date
        ROI = [str2num(scans_to_process(nSubject).PIDN), ROI]; %PIDN
        
        ROImat = [ROImat,ROI];
    end
    
  
end

ROIsheet = ROImat
%add labels
% headings = ['PIDN', 'date', 'daysfrombaseline'  scans_to_process(nSubject).Timepoint{nTimepoint}.ROI(1, :)];
% xlswrite(fullfile(fileparts(scandatafolder), ['ROIextraction_labels_' date '.xlsx']),headings)
% xlswrite(fullfile(fileparts(scandatafolder), ['ROIextractions_' date '.xlsx']),ROImat)



