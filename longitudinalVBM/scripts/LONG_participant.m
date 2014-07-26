classdef LONG_participant
    %LONG_participant participant info for longitudinal processing
    %   Detailed explanation goes here
    
    properties
        PIDN
        %folder
        Fullpath
        Datapath
        Date1
        Date2
        Date1num
        Date2num
        Time1file
        Time2file
        ROImean
        ROImedian
        ROIextraction
        ROIextractionsTime1
        ROIextractionsTime2
        
        MNI_ROIextractionsTime1
        MNI_ROIextractionsTime2
        
        baselineGMvol
        baselineWMvol
        baselineCSFvol
        baselineTIVvol
        
        time2GMvol
        time2WMvol
        time2CSFvol
        time2TIVvol
        
        Group % HC, L_SD, R_SD
       % DeltaTime
       
       %Ran_Longitudinal_registration % yes, date, prefix
       %Ran_Longitudinal_Segmentation
       %Ran_DARTEL_intersubject_registration
       %Ran_DARTEL_normalize_LONG_to_MNI
       
      % Ran_t1_Segmentation
       %Ran_t2_Segmentation
       
       %Ran_DARTEL_normalize_t1_to_MNI
       %Ran_DARTEL_normalize_t2_to_MNI
       
       
       
       
        
    end
    properties (Dependent = true, SetAccess = private)
        DeltaTime
    end
    methods
        function lp = LONG_participant(pidn, datapath)
            if nargin > 0 % Support calling with 0 arguments
                try
                lp.PIDN = pidn;
                lp.Datapath = datapath;
                lp.Fullpath = fullfile(datapath,pidn);
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
                file1 = SAdir(fullfile(datapath,pidn, lp.Date1), '^MP-LAS\S+(.img|.nii)');
                lp.Time1file = file1.name;
                %file2 = SAdir(fullfile(datapath,pidn, lp.Date2), '^MP-LAS\w+(.img|.nii)');
                file2 = SAdir(fullfile(datapath,pidn, lp.Date2), '^MP-LAS\S+(.img|.nii)');

                lp.Time2file=file2.name;
     
                catch err
                   error(['problem with PIDN:' num2str(pidn)])
                   rethrow(err)
                end
                
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

