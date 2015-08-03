function  volumemat = sVBM_export_TIV(scans_to_process)
%sVBM_export_TIV - export GM/WM/CSF/TIV vol into spreadsheet
%structure
%
% Syntax:  output = ssVBM_export_TIV(scans_to_process)
%
% Inputs:   scans_to_process -
%           
% Outputs: volume mat ( pidn, date, gmvol, wmvol, csfvol, tiv)
%
% Other m-files required:
% Subfunctions:
%
% MAT-files required:
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created: 08/3/2015
% Revisions:

% initialize matrix
numSubjects =  size(scans_to_process,2);
outmat = [];

for nSubject = 1:numSubjects
    numTimepoints = size(scans_to_process(nSubject).Timepoint,2) ;
    for nTimepoint = 1:numTimepoints
        
        
        volu.gm =  scans_to_process(nSubject).Timepoint{nTimepoint}.GMvol;
        volu.wm =  scans_to_process(nSubject).Timepoint{nTimepoint}.WMvol;
        volu.csf =  scans_to_process(nSubject).Timepoint{nTimepoint}.CSFvol;
        volu.tiv =  scans_to_process(nSubject).Timepoint{nTimepoint}.TIV;
         
        out = [str2num(scans_to_process(nSubject).PIDN), scans_to_process(nSubject).Timepoint{nTimepoint}.Datenum - 693960, volu.gm, volu.wm, volu.csf, volu.tiv];
               
        outmat = [outmat;out];
    end
    
end

volumemat = outmat;
%add labels
% headings = ['PIDN', 'date', 'daysfrombaseline'  scans_to_process(nSubject).Timepoint{nTimepoint}.ROI(1, :)];
% xlswrite(fullfile(fileparts(scandatafolder), ['ROIextraction_labels_' date '.xlsx']),headings)
% xlswrite(fullfile(fileparts(scandatafolder), ['ROIextractions_' date '.xlsx']),ROImat)



