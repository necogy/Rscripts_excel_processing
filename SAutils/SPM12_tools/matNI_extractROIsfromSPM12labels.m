function matNI_extractROIsfromSPM12labels(label_nifti_file)
%matNI_extractROIsfromSPM12labels Grab ROIs from SPM12 Atlas
%   Loads labelled NIFTI file and finds matching xml file and outputs all
%   of the ROIs as separate files for ROI extraction.
%
% Syntax:  matNI_extractROIsfromSPM12labels(label_nifti_file)
%
% Inputs:  label_nifti_file - likely \spm12\tpm\labels_Neuromorphometrics.nii
%
% Outputs: writes ROIs to \spm12\tpm\splitROIs
%
% Other m-files required: SPM12
%
% Author: Suneth Attygalle
% Created 10/02/2014
%
% Revisions:
%----------------------
try
    vhdr = spm_vol(label_nifti_file);
    v = spm_read_vols(vhdr);
    
    %read in xml file for labels
    str= fileread(strrep(label_nifti_file, 'nii', 'xml'));
catch err
     error('problem loading nifti or accompanying xml file');
end

expression = '<label><index>(\d+)</index><name>(.*?)</name></label>'; %matches all IDs and Labels between tags
tokens= regexp( str, expression, 'tokens' ); %extract values
mkdir(fullfile(fileparts(label_nifti_file), 'splitROIs')); 
%for each ROI, extract ROI and save it. 
for roi = 1:size(tokens,2)

    ROIindex = str2double(tokens{roi}{1});
    ROIimage = v;
    ROIimage(ROIimage~=ROIindex)=0; %set all values outside ROI to zero
    ROIimage(ROIimage==ROIindex)=1; %set all values ROI to 1 (binarize)

    newhdr= vhdr;
    newhdr.fname = fullfile(fileparts(label_nifti_file), 'splitROIs', strrep([tokens{roi}{2} '.nii'],' ', '_')  );
    
    spm_write_vol(newhdr, ROIimage);
    
end

