classdef lzDTI_participant
    %lzDTI_participant contains links to participant's data
    %   Detailed explanation goes here
    
    properties       
        PIDN
        Fullpath
        Datapath
        Group
        Timepoint
        Deltatime  
    end
    
    methods
        
        function lp = lzDTI_participant(pidn, datapath)
            if nargin > 0 % Support calling with 0 arguments
                try % load parameters
                    lp.PIDN = pidn;
                    lp.Datapath = datapath;
                    lp.Fullpath = fullfile(datapath,pidn);
                    
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
                        lp.Timepoint{timepointindex} = lzDTI_timepoint( fullfile( lp.Fullpath,  t(timepointindex).name) );
                        
                    end
                    
                catch err
                   error(['problem with PIDN:' num2str(pidn)])
                   rethrow(err)
                end
                
                
            end
            
        end
        
    end
    
end
