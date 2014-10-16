% Extract segmentation volumes from sVBM scans_to_process structure
% Suneth Attygalle 10/16/14


for sub = 1:size(scans_to_process,2)
    for col = 1:size(scans_to_process(sub).Timepoint,2)
        
        extraction.GMvol(sub,col) =scans_to_process(sub).Timepoint{col}.GMvol;
        extraction.WMvol(sub,col) =scans_to_process(sub).Timepoint{col}.WMvol;
        extraction.CSFvol(sub,col) =scans_to_process(sub).Timepoint{col}.CSFvol;
        extraction.TIV(sub,col) = scans_to_process(sub).Timepoint{col}.TIV;
        extraction.Date{sub,col} =scans_to_process(sub).Timepoint{col}.Date;
        
        
    end
end

PIDNs = {scans_to_process.PIDN};