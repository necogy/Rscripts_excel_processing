classdef LONG_participant
    %LONG_participant participant info for longitudinal processing
    %   Detailed explanation goes here
    
    properties
        PIDN
        %folder
        Datapath
        Date1
        Date2
        Date1num
        Date2num
        Time1filename
        Time2filename
        DeltaTime
        
    end
    
    methods
        function lp = LONG_participant(pidn, datapath)
            if nargin > 0 % Support calling with 0 arguments
                lp.PIDN = pidn;
                lp.Datapath = datapath;
                
                % load two time point dates
                t = SAdir(fullfile(datapath,pidn),  '\d{4}-\d{2}-\d{2}'); % load two time point dates        
                if size(t,2) > 1
                    error('Data for more than two dates present, check folder')
                end
                date(1) = datenum(t(1).name, 'yyyy-mm-dd');
                date(2) = datenum(t(2).name , 'yyyy-mm-dd') ;
                
                %make sure dates are order sequentially
                [~,I] = sort(date);
                lp.Date1 = t(I(1)).name;
                lp.Date2 = t(I(2)).name;
                lp.Date1num = date(I(1));
                lp.Date2num = date(I(2));
                
                %load filenames
                file1 = SAdir(fullfile(datapath,pidn, lp.Date1), '^MP-LAS_\w+(.img|.nii)');
                lp.Time1file = file1.name;
                file2 = SAdir(fullfile(datapath,pidn, lp.Date2), '^MP-LAS_\w+(.img|.nii)');
                lp.Time2file=file2.name;
                
            end
        end % LONG_participant
        
        function deltatime= get.DeltaTime(obj)
            if isempty(obj.Date1) || isempty(obj.Date2)
                error('Dates not properly loaded')
            end
            deltatime= datenum(obj.Date2, 'yyyy-mm-dd')-datenum(obj.Date1, 'yyyy-mm-dd') ;
        end %get.deltat
        
        
        
        
    end
    
end

