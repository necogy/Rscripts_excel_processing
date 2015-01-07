function sVBM_plot_timeseries(scans_to_process, metric)
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
        ROIdates(nSubject,1:size(scans_to_process(nSubject).Deltatime,2)) = 365*scans_to_process(nSubject).Deltatime;
        for nTimepoint = 1:size(scans_to_process(nSubject).Timepoint,2)
            ROIextractions(nSubject, nTimepoint) = ...
                scans_to_process(nSubject).Timepoint{nTimepoint}.ROI{metricrow, nROI};
            
            
        end
        
       
        
    end
     %ROIdates(ROIdates==0) = [];
        ROIextractions(ROIextractions==0) =NaN;
        
        % plot all
        f=figure();
        
        plot(ROIdates', ROIextractions','LineWidth', 2)
        ylim([min(ROIextractions(ROIextractions>0)) max(ROIextractions(:))])
        xlabel('Days from first scan')
        ylabel('ROI Volume in liters from c1avg*jd')
        title([scans_to_process(1).Timepoint{1}.ROI(1,nROI) ' ' metric],'Interpreter', 'none')
        
        figurefolder = fileparts(fileparts(scans_to_process(1).Fullpath));
        plotpath = fullfile(figurefolder,'figures',['roi_vol_by_time_' metric]);
        mkdir(plotpath);
        filename = fullfile(plotpath, [scans_to_process(1).Timepoint{1}.ROI{1,nROI} '_ROIvols_' metric]);
        
        print(f,'-dpdf',filename);
        close(f)
    
    
    
    
    % print figure
    
    
    
    clear ROIdates;
    clear ROIextractions;
    
end % for nROI = 1:numROIs



end % function sVBM_plot_timeseries(scans_to_process, scantype)

