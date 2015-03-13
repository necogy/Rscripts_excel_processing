function SA_SPM12_warpMNI_ROIstoDARTEL( y_poptoICBMfield ,Template_6, pathtoROIs)
%SA_SPM12_warpMNI_ROIstoDARTEL - Warp ROIs to DARTEL template using pop to
%ICBM y field using deformations utility
%
% Syntax:  SA_SPM12_generateDARTELToICBM( pathtotemplate6)
%
% Inputs:   
%           y_poptoICBMfield 
%           Template_6 
%           pathtoROIs
% Outputs: generates ROIs in DARTEL space with prefix w
%
% Other m-files required: SPM12 in path
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do: 
%
% Author: Suneth Attygalle
% Created 03/05/15
% Revisions:

rois = SAdir( pathtoROIs,  '\w*');

%templatepath = fileparts(Template_6);
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = cellstr(y_poptoICBMfield );
matlabbatch{1}.spm.util.defs.comp{1}.inv.space = cellstr(fullfile(pathtoROIs, rois(1).name));

allrois = SAinsertStr2Paths({rois.name}', [fullfile(pathtoROIs) '\']);

matlabbatch{1}.spm.util.defs.out{1}.push.fnames =      cellstr(allrois) ;
matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
matlabbatch{1}.spm.util.defs.out{1}.push.fov.file =cellstr(Template_6);
matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];



spm('defaults', 'PET');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
end