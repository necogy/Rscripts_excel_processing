function  scans_to_process = sVBM_get_timepoint_tissue_volumes(scans_to_process)
% sVBM_get_timepoint_tissue_volumes - get timepoint volumes from c1/c2 files
% structure
%
% Syntax:  scans_to_process = sVBM_export_ROI_values_to_excel(scans_to_process)
%
% Inputs:   scans_to_process
% Outputs: scans_to_process updated with GM/WM/CSF/ TIV values
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
% Created 07/22/2015
% Revisions:

numSubjects =  size(scans_to_process,2);

for nSubject = 1:numSubjects
    nSubject
    numTimepoints = size(scans_to_process(nSubject).Timepoint,2) ;
    
    for nTimepoint = 1:numTimepoints
        
        c1file = fullfile(scans_to_process(nSubject).Timepoint{nTimepoint}.Fullpath, scans_to_process(nSubject).Timepoint{nTimepoint}.File.name);
        c1file = strrep(c1file, '.img', '.nii');
        c1file  =SAinsertStr2Paths(c1file, 'c1')   ;
        
        scans_to_process(nSubject).Timepoint{nTimepoint}.GMvol = spm_summarise(c1file, 'all', 'litres');
        c2file = strrep(c1file, 'c1','c2');
        scans_to_process(nSubject).Timepoint{nTimepoint}.WMvol = spm_summarise(c2file, 'all', 'litres');
        c3file = strrep(c1file, 'c1','c3');
        scans_to_process(nSubject).Timepoint{nTimepoint}.CSFvol = spm_summarise(c3file, 'all', 'litres');
        scans_to_process(nSubject).Timepoint{nTimepoint}.TIV =  ...
            scans_to_process(nSubject).Timepoint{nTimepoint}.GMvol  + ...
            scans_to_process(nSubject).Timepoint{nTimepoint}.WMvol + ...
            scans_to_process(nSubject).Timepoint{nTimepoint}.CSFvol ;
        
        clear c1file c2file c3file
        
        
    end
end
