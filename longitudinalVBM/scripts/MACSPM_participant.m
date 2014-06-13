classdef MACSPM_participant
%LONG_participant participant info for longitudinal processing
%Detailed explanation goes here

properties
        PIDN
        %folder
        Fullpath
        Datapath
        Date1
        Date1num
        Time1file
        ROImean
        ROImedian
        
        baselineGMvol
        baselineWMvol
        baselineCSFvol
        baselineTIVvol

        
        Group % HC, L_SD, R_SD

methods
        function participant = MACSPM_participant(pidn, datapath)
            if nargin > 0 % Support calling with 0 arguments
                try
                lp.PIDN = pidn;
                lp.Datapath = datapath;
                lp.Fullpath = fullfile(datapath,pidn);
                % load two time point dates
                t = SAdir(fullfile(datapath,pidn),  '\d{4}-\d{2}-\d{2}'); % load two time point dates
             
                date(1) = datenum(t(1).name, 'yyyy-mm-dd');
                
                %make sure dates are order sequentially
                %[~,I] = sort(date);
                lp.Date1 = t(I(1)).name;
                %lp.Date2 = t(I(2)).name;
                lp.Date1num = date(I(1));
               % lp.Date2num = date(I(2));
                
                %load filenames
                file1 = SAdir(fullfile(datapath,pidn, lp.Date1), '^MP-LAS\S+(.img|.nii)');
                lp.Time1file = file1.name;
                %file2 = SAdir(fullfile(datapath,pidn, lp.Date2), '^MP-LAS\w+(.img|.nii)');
                %file2 = SAdir(fullfile(datapath,pidn, lp.Date2), '^MP-LAS\S+(.img|.nii)');

                %lp.Time2file=file2.name;
     
                catch err
                   error(['problem with PIDN:' num2str(pidn)])
                   rethrow(err)
                end
                
            end
        end % LONG_participant
end
