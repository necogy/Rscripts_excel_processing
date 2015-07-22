function newheader = matNI_fixHeaderDimensions(imagetofix,templateimage)
%matNI_fixHeaderDimensions replace incorrect header dims with correct ones
%   Takes existing image and template image and matches the pixel dimension
%   header information to the template image. This assumes the image was
%   written with the incorrect header information and makes no changes to
%   the actual image data, i.e. no interpolation.
%
% Syntax:  matNI_extractROIsfromSPM12labels(imagetofix, templateimage)
%
% Inputs:   imagetofix  - path to nii/analyze image
%           templateimage - path to nii/analyze image
%
% Outputs: writes image to imagetofix sourcepath
%
% Other m-files required: SPM
%
% Author: Suneth Attygalle
% Created 11/20/14
%
% Revisions:
%----------------------

problemimageheader = spm_vol(imagetofix);
templateimageheader = spm_vol(templateimage);

fixedimageheader = problemimageheader;

%check that the datasizes match
if size(templateimageheader.private.dat) ~= size(problemimageheader.private.dat)
    error('image to fix and template image have different data dimensions')
end

%update filename
[pathstr, name, ext] = fileparts(problemimageheader.fname) ;
fixedimageheader.fname = fullfile(pathstr, ['fixed_' name ext]);

%update other field names
fixedimageheader.dim = templateimageheader.dim;
fixedimageheader.mat = templateimageheader.mat;
fixedimageheader.private.mat = templateimageheader.private.mat;
fixedimageheader.private.mat_intent = 'Aligned';
fixedimageheader.private.mat0 = templateimageheader.private.mat0;
fixedimageheader.private.mat0_intent = 'Aligned';

data = spm_read_vols(problemimageheader);
spm_write_vol(fixedimageheader,data);
newheader = fixedimageheader;



