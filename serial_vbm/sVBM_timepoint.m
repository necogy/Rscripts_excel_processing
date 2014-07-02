classdef sVBM_timepoint
    %sVBM_timepoint - timepoint data info for a participant
    %   Detailed explanation goes here
    
    properties
        Date
        Datenum
        File
        Fullpath
        
        GMvol
        WMvol
        CSFvol
        TIV
        
    end
    
    methods
        
        function st = sVBM_timepoint(pathtotimepoints)
            if nargin > 0 % Support calling with 0 arguments
                try % load parameters
                    st.Fullpath = pathtotimepoints;
                    
                    [ ~ , loadeddate,  ~] = fileparts(pathtotimepoints) ;
                    
                    st.Date = loadeddate ;
                    st.Datenum = datenum(loadeddate) ;
                    
                    %find structural image within date folder
                    st.File = SAdir(pathtotimepoints, '^MP-LAS\S+(.img|.nii)') ;
                    
                    if size(st.File,1)>1
                        error('More than one structural scan found, check directory for extra scans and delete them')
                    end
                    
                    
                    
                catch err
                    
                end
                
                
            end
            
        end
        
    end
    
end

