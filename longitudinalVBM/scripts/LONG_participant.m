classdef LONG_participant
    %LONG_participant participant info for longitudinal processing
    %   Detailed explanation goes here
    
    properties
        PIDN
        %folder
        Datapath
        Date1
        Date2
        Time1filename
        Time2filename
        DeltaTime
        
    end
    
    methods
        function lp = LONG_participant(pidn, datapath)
            if nargin > 0 % Support calling with 0 arguments
                lp.PIDN = pidn;
                lp.Datapath = datapath;
                
                t = SAdir(fullfile(datapath,pidn),  '\d{4}-\d{2}-\d{2}');
                                
                lp.Date1 = datenum(t(1).name, 'yyyy-mm-dd');
                lp.Date2 = datenum(t(2).name , 'yyyy-mm-dd') ;
            end
        end % LONG_participant
        
        function deltatime= get.DeltaTime(obj)
            if isempty(obj.Date1) || isempty(obj.Date2)
                error('Dates not properly loaded')
            end
            deltatime= obj.Date2-obj.Date1;
        end %get.deltat
        
        
        
        
    end
    
end

