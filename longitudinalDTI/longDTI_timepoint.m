classdef longDTI_timepoint
    %longDTI_timepoint - timepoint data info for a participant
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
        
        ROI
        
    end
    
    methods
        
        function st = longDTI_timepoint(pathtotimepoints)
            if nargin > 0 % Support calling with 0 arguments
                try % load parameters
                    st.Fullpath = pathtotimepoints;
                    
                    [ ~ , loadeddate,  ~] = fileparts(pathtotimepoints) ;
                    
                    st.Date = loadeddate ;
                    st.Datenum = datenum(loadeddate) ;
                    
                    %find raw FA image within date folder
                    file = SAdir(pathtotimepoints, '\_FA.nii');
                    index=zeros(1,length(file));
                    for k=1:length(length(file))
                        index(k)=size(file(k).name,2);
                    end
                    
                    [M I]=min(index);
                    
                    st.File=file(I);                    
                    
                    if size(st.File,1)>1
                        error('More than one FA image found, check directory for extra scans and delete them')
                    end
                    
                    
                    
                catch err
                    
                end
                
                
            end
            
        end
        
    end
    
end