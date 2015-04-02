classdef sVBM_participant
    %sVBM_participant Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PIDN
        Fullpath
        Datapath
        Group
        Timepoint
        Deltatime
        
        BaselineROIVolumes
        BaselineTissueVolumes       
%         
        Slope
        
    end
    
    methods
        
        function value = get.Deltatime(obj)
            numTimepoints= size(obj.Timepoint,2);
            value(numTimepoints) = 0;
            for nTimepoint = 1:numTimepoints
                value(nTimepoint) = (obj.Timepoint{nTimepoint}.Datenum - obj.Timepoint{1}.Datenum)/365; 
            end          
            
        end
        
%         function value = get.Slope(obj)
%             % need to add error if ROI values not extracted
%             numTimepoints = size(obj.Timepoint,2);
%             numROIs = size(obj.Timepoint{1}.ROI,2);
%             metricrow  = 3;
%             
%             for nROI = 1:numROIs
%                 xdates = obj.Deltatime;
%                 for nTimepoint = 1:numTimepoints
%                     %xdates(nTimepoint) = (obj.Timepoint{nTimepoint}.Datenum - obj.Timepoint{1}.Datenum)/365;
%                     yvalues(nTimepoint)= obj.Timepoint{nTimepoint}.ROI{metricrow, nROI};
%                     
%                 end
%                 
%                 p = polyfit(xdates,yvalues,1);
%                 value(nROI) = p(2); % get slope
%                 clear yvalues;
%                 
%                 
%             end
%         end % value = get.Slope(obj)
        
        function sp = sVBM_participant(pidn, datapath)
            if nargin > 0 % Support calling with 0 arguments
                try % load parameters
                    sp.PIDN = pidn;
                    sp.Datapath = datapath;
                    sp.Fullpath = fullfile(datapath,pidn);
                    
                    % load dates
                    t = SAdir(fullfile(datapath,pidn),  '\d{4}-\d{2}-\d{2}');
                    
                    % sort by date
                    numtimepoints = size(t,1);
                    scandates = zeros(1,numtimepoints);
                    
                    for datedir= 1: numtimepoints
                        scandates(datedir) = datenum(t(datedir).name, 'yyyy-mm-dd');
                        
                    end
                    
                    [~, timeindex] = sort(scandates);
                    
                    % resort t
                    t = t(timeindex);
                    % create sVBM_timepoint for each date and store in
                    % array
                    for timepointindex = 1: numtimepoints
                        sp.Timepoint{timepointindex} = sVBM_timepoint( fullfile( sp.Fullpath,  t(timepointindex).name) );
                        
                    end
                    
                catch err
                    error(['problem with PIDN:' num2str(pidn)])
                    rethrow(err)
                end
                
            end % nargin > 0
            
        end %  function sp = sVBM_participant(pidn, datapath)
        
    end % methods
    
end % classdef sVBM_participant
