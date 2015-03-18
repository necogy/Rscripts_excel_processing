function SA_SPM12_DARTEL_warpNativetoICBM(datadirectory, y_DARTEL_to_MNI, modulation_on, fwhm)
%SA_SPM12_DARTEL_warpNativetoICBM - Warp ROIs to ICBM using combined deformations
%
% Syntax:  SA_SPM12_DARTEL_warpNativetoICBM(y_DARTEL_to_MNI, datadirectory)
%
% Inputs:
%
%       datadirectory  - path that contains c1/c2 files and u_rc1 files
%       y_DARTEL_to_MNI - path to ICBM deformation from dartel to ICBM
%       modulation_on - set to 1 to use modulation
%       fwhm - set smoothing level, 0 for none
% Outputs:
%
% Other m-files required: SPM12 in path, SAdir function from imaging-core
% github
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 03/17/2015
% Revisions:

icbmpath = fullfile(SAreturnDriveMap('R'),'groups','imaging_core','software','spm12','toolbox','DARTEL','icbm152.nii');

spm('defaults', 'PET');
spm_jobman('initcfg');

d= SAdir(datadirectory, '^u_rc1');
numScans = size(d,1);

for nScan = 1:numScans
    clear matlabbatch
    
    
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.comp{1}.def = {y_DARTEL_to_MNI};
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.space = cellstr(icbmpath );
    flowpath = fullfile( datadirectory, d(nScan).name);
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield = cellstr(flowpath);
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template = {''};
    matlabbatch{1}.spm.util.defs.comp{1}.inv.space = cellstr(icbmpath );
    matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {strrep(flowpath, 'u_rc1', 'c1'), strrep(flowpath, 'u_rc1', 'c2') } ;
    matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
    matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
    matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = cellstr(icbmpath );
    matlabbatch{1}.spm.util.defs.out{1}.push.preserve = modulation_on;
    matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [fwhm fwhm fwhm];
    
    try
        spm_jobman('run', matlabbatch);
    catch
        error(['problem with ' flowpath])
    end
    
end
end