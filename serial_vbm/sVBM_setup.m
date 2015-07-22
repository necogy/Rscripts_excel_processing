%% Serial VBM Processing Pipeline
%
% Preprocesses date using SPM12 and performs serial longitudinal registration
% with multiple timepoints 
% Can be used to process single timepoint data as well, but some options
% might be tailored towards longitudinal processing.
%
% For two timepoint longitudinal data, use the longitudinalVBM package
% instead.
%
% To use this pippeline. Set all of your file paths first in sVBM_config.m 
% Create a copy of the config file if you make edits to for a specific data set
% set so it doesn't get overwritten if you download a new version of the
% code in the same directory.
%
% Make sure to add spm12 folder (not with subfolders) and the sVBM folder with subfolders
% to the Matlab path. Steps will error out if SPM12 is not added to the
% path.
%
% for easier use of this script enable cell evaluation in matlab settings. 
%
% Suneth Attygalle - 7/1/14 - Memory and Aging Center

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Initialize Things:
clear
clear classes

%load parameters:
sVBM_config % or name of edited config file %% OPEN THIS AND EDIT PATHS

%read in directories and store info in scans_to_process structure
scans_to_process = sVBM_load_rawdata( scandatafolder );


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Serial Longitudinal Registration (multiple timepoints)
scans_to_process = sVBM_run_long_registration(scans_to_process); 

%% 3. Segmentation of Average Images (DARTEL import)
reprocess = 0;
dartelimport = 1;
scans_to_process = sVBM_run_segmentation(scans_to_process, 'average', reprocess, dartelimport); % (will segment all available timepoints in the directories)

%% 4. DARTEL registration of Longitudinal Average Images to New DARTEL Template
scans_to_process = sVBM_DARTEL_registration_to_new(scans_to_process);

%% 5. DARTEL registration of Longitudinal AverageImages to Existing DARTEL Template
scantype = 'average';
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, templatepath, scantype);

%% 6. Generate population to ICBM registration deformation field
SA_SPM12_generateDARTELToICBM(fullfile(templatepath, 'Template_6.nii')); % generates dartel pop to ICBM deformation field using SPM12

%% option 1 - use average image space change maps warped to ICBM:

%% 7. Multiply Change Maps with Segmentations
scalebytime  =0;
scans_to_process = sVBM_multiply_segments_with_change(scans_to_process, 'j',scalebytime);
scans_to_process = sVBM_multiply_segments_with_change(scans_to_process,'dv',scalebytime);

scalebytime  =1;
scans_to_process = sVBM_multiply_segments_with_change(scans_to_process, 'j',scalebytime);
scans_to_process = sVBM_multiply_segments_with_change(scans_to_process,'dv',scalebytime);

%% 8. Transform longitudinal images to ICBM space (AKA Normalize)
modulationON = 0; % Set to 1 to enable modulation
smoothingFWHM = 3; % Set to FWHM mm value to smoothe during modulation 
sVBM_pushAVGspacetoICBMviaDARTEL(scans_to_process, templatepath, modulationON, smoothingFWHM)

% %% [Transform Longitudinal Images to Group/MNI space] (DEPRECATED)
% scantype = 'timepointdv';
% sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );
% 
% scantype = 'timepointj';
% sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );

%% option 2: Warp timepoints to ICBM 

%% 7. Segment timepoints
reprocess = 0;
dartelimport = 0;
scans_to_process = sVBM_run_segmentation(scans_to_process(9:80), 'timepoints', reprocess, dartelimport); % (will segment all available timepoints in the directories)

%% 8. Transform Timepoint Data to MNI using Intermediate Longitudinal Image Warp
sVBM_warp_timepoint_to_MNI_via_long(scans_to_process, templatepath);


%% both options


%% 9. Extract ROI volumes from warped ICBM images
extractionfileprefix = 'smwc1MP'; % <-- specify what the prefix for the images to extract from is
scans_to_process=sVBM_extract_changemap_ROIs(scans_to_process,pathtoROIs,extractionfileprefix);

% export them
metric = 'sum'; % available options: 'mean', 'median', 'sum', 'svd', 'peak' 
scantype = 'timepoint';
ROIextractions = sVBM_export_ROI_values(scans_to_process,metric,scantype);
ROIextractions = sVBM_export_ROI_values_to_excel(scans_to_process,metric);

ROIsheet = sVBM_export_ROI_values_to_excel(scans_to_process,metric)

%% 10. Generate ROI time series 
sVBM_plot_timeseries(scans_to_process, 'sum');
sVBM_plot_timeseries(scans_to_process, 'mean');
sVBM_plot_timeseries(scans_to_process, 'median');
sVBM_plot_timeseries(scans_to_process, 'svd');
%sVBM_plot_timeseries(scans_to_process2, 'peak') % peak is noisy






%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Extra stuff that may or may not work:

%% Warp ROIs from Atlas Space to Native Timepoint Space via Longitudinal Image Warp
% use inverse of deformation used to warp from timepoint to ICBM

%% Non longitudinal processing %%%%%%%%%%%%%%%%%%%%%%

%% DARTEL registration of Timepoint Images to Existing DARTEL Template
scantype = 'timepoint';
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, templatepath, scantype);

scantype = 'baseline';
sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );

% extract ROI volumes
scans_to_process = sVBM_extract_baseline_vols(scans_to_process,pathtoROIs);
bROIextractions = sVBM_export_ROI_values(scans_to_process, 'sum','baseline'); % 'mean','median','sum','eigenvariate' 

%% DARTEL registration of Timepoint Images to Existing DARTEL Template (not longitudinal)
scantype = 'timepoint';
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, templatepath, scantype);

%% Warp timepoint one to MNI (not longitudinal) for baseline volumes.
scantype = 'timepoint';
sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );

%% Segmentation of timepoints:
reprocess = 0;
dartelimport = 0;
scans_to_process = sVBM_run_segmentation(scans_to_process, 'timepoints', reprocess, dartelimport); % (will segment all available timepoints in the directories)

%% Register Timepoints to existing Dartel. 
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, DARTEL_template_path); 

%% Warp Timepoints to MNI via DARTEL (ignores longitudinal images)
%scans_to_process = sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path );

%% Warp Timepoints to MNI, standard normalization, no DARTEL
scans_to_process = sVBM_warp_to_MNI(scans_to_process);

%% Extract ROI values from MNI warped timepoints 
scans_to_process = sVBM_extractMNItimepointROIs(scans_to_process, pathtoROIs);



