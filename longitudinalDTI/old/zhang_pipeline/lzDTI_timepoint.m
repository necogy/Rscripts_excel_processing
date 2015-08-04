classdef lzDTI_timepoint
    %sVBM_timepoint - timepoint data info for a participant
    %   Detailed explanation goes here
    
    properties
        Date
        Datenum
        %File
        %Fullpath
        Image_FA
        Image_T1
    end
    
    methods
        
        function lt = lzDTI_timepoint(pathtotimepoints)
            if nargin > 0 % Support calling with 0 arguments
                try % load parameters
                    %st.Fullpath = pathtotimepoints;
                    
                    [ ~ , loadeddate,  ~] = fileparts(pathtotimepoints) ;
                    
                    lt.Date = loadeddate ;
                    lt.Datenum = datenum(loadeddate) ;
                    
                    T1file = SAdir(pathtotimepoints, '^MP-LAS\S+(.img|.nii)') ;
                
                    lt.Image_T1= lzDTI_image(fullfile(pathtotimepoints,T1file.name));
                    
                    FAfile = strrep(T1file.name, 'MP-LAS_', ''); %remove MP-LAS part
                    FAfile = strrep(FAfile, 'img', 'nii');% swap img with nii
                    FAfile = strrep(FAfile, '.nii', '_v1_FA.nii');% % add v1_FA
                 
                    lt.Image_FA = lzDTI_image(fullfile(pathtotimepoints,FAfile));
                         

                    
                catch err
                    
                end
                
                
            end
            
        end
        
    end
    
end

