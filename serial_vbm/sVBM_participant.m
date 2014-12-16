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
        
    end
    
    methods
        
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
                
                
            end
            
        end
        
    end
    
end
