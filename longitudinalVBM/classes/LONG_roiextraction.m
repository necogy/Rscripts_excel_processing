classdef LONG_roiextraction
    %LONG_roiextraction roi extraction values
    %   store name, value and ROI extraction type for longitudinal data
    
    properties
        Pathtoroi
        Pidn
        Timepoint
        
    end
    
    properties (Dependent)
        Extraction
        Roiname
    end
   
    methods
        function rexs = LONG_roiextraction(pathtoroi)
            try
                
            roivalues = spm_read_vols(spm_vol(pathtoroi));
            rexs.Extraction   = sum(roivalues);
            
            [~, name, ~] = fileparts(pathtoroi) ;
            
            rexs.Roiname = name;
            
            catch err
                   error(['problem extracting values with' pathtoroi] )
                   rethrow(err)
            end
            
        end
        
        
        
    end
    
end

