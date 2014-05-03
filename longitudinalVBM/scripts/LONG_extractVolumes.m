function scans_to_process = LONG_extractVolumes( scans_to_process,scantype )
%LONG_extractVolumes - extract WM/GM/CSF/TIV and generate spreadsheet
%
% Syntax:  scans_to_process = LONG_extractVolumes( scans_to_process,scantype )
%
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%           scantype - string specifying whether to segment time1, time2 or mean image.
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:

% To Do: 
%
% Author: Suneth Attygalle
% Created 
%
% Revisions:

% TIV = GM + WM + CSF  (probablistic segmentatoins)
    
for subject = 1:size(scans_to_process,2)
    
    GMpath =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, scans_to_process(subject).Time1file);
    GMpath = SAinsertStr2Paths(GMpath, 'mwc1');
    GMpath = strrep(GMpath, 'img','nii');
    WMpath = strrep(GMpath, 'mwc1','mwc2');
    CSFpath = strrep(GMpath, 'mwc1','mwc3');
           
    GMvol  = spm_read_vols(spm_vol(GMpath));
    WMvol  = spm_read_vols(spm_vol(WMpath));
    CSFvol = spm_read_vols(spm_vol(CSFpath));
    
    GMtotal = sum(GMvol(:));
    WMtotal = sum(WMvol(:));
    CSFtotal =sum(CSFvol(:));
    
    TIV = GMtotal+WMtotal+CSFtotal;
    
    scans_to_process(subject).baselineGMvol  = GMtotal;
    scans_to_process(subject).baselineWMvol = WMtotal;
    scans_to_process(subject).baselineCSFvol =CSFtotal;
    scans_to_process(subject).baselineTIVvol = TIV;

    
  
    
end


end

