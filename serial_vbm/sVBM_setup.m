%% Serial VBM Processing Pipeline
%
% Preprocesses date using SPM12b and performs longitudinal registration
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
% Make sure to add spm12b folder (not with subfolders) and the sVBM folder with subfolders
% to the Matlab path. Steps will error out if SPM12 is not added to the
% path.
%
% for easier use of this script enable cell evaluation in matlab settings. 
%
% Suneth Attygalle - 7/1/14 - Memory and Aging Center

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize Things:
clear
clear classes

%load parameters:
sVBM_config % or name of edited config file 
scandatafolder='/mnt/ramdisk/';

%set scan data folder where image were placed using image_finder.sh

%DARTEL_template_path = templatepath;

%read in directories and store info in scans_to_process structure
scans_to_process = sVBM_load_rawdata( scandatafolder );


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Serial Longitudinal Registration (multiple timepoints)
scans_to_process = sVBM_run_long_registration(scans_to_process)

%% Segmentation of Average Images
reprocess = 0;
scans_to_process = sVBM_run_segmentation(scans_to_process, 'average', reprocess) % (will segment all available timepoints in the directories)

%% DARTEL registration of Longitudinal Average Images to New DARTEL Template
scans_to_process = sVBM_DARTEL_registration_to_new(scans_to_process);

%% DARTEL registration of Longitudinal AverageImages to Existing DARTEL Template
scantype = 'average';
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, templatepath, scantype);

%% Multiply Change Maps with Segmentations
scans_to_process = sVBM_multiply_segments_with_change(scans_to_process, 'j');
scans_to_process = sVBM_multiply_segments_with_change(scans_to_process,'dv');


%% Transform Longitudinal Images to Group/MNI space
scantype = 'timepointdv';
sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );

scantype = 'timepointj';
sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );


%% DARTEL registration of Timepoint Images to Existing DARTEL Template
scantype = 'timepoint';
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, templatepath, scantype);

scantype = 'baseline';
sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );

% extract ROI volumes/mnt/ramdisk/0065/avg/Template_0.nii
scans_to_process = sVBM_extract_baseline_vols(scans_to_process,pathtoROIs);
bROIextractions = sVBM_export_ROI_values(scans_to_process, 'sum','baseline'); % 'mean','median','sum','eigenvariate' 



%% DARTEL registration of Timepoint Images to Existing DARTEL Template (not longitudinal)
scantype = 'timepoint';
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, templatepath, scantype);

%% Warp timepoint one to MNI (not longitudinal) for baseline volumes.
scantype = 'timepoint';
sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path, scantype );

%% Transform Timepoint Data to MNI using Intermediate Longitudinal Image Warp
sVBM_warp_timepoint_to_MNI_via_long(scans_to_process, dartelpath);

%% Warp ROIs from Atlas Space to Native Timepoint Space via Longitudinal Image Warp
sVBM_warp_ROIs_to_avg_and_to_timepoint_(scans_to_process)

%% Extract ROI volumes from warped MNI images
scans_to_process=sVBM_extract_changemap_ROIs(scans_to_process,pathtoROIs);





%% Generate ROI time series 
sVBM_plot_timeseries(scans_to_process2, 'sum')
sVBM_plot_timeseries(scans_to_process2, 'mean')
sVBM_plot_timeseries(scans_to_process2, 'median')
sVBM_plot_timeseries(scans_to_process2, 'svd')
%sVBM_plot_timeseries(scans_to_process2, 'peak') % peak is noisy



























%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Non-longitudinal processing 

%% Segmentation of timepoints:
reprocess = 0;
scans_to_process = sVBM_run_segmentation(scans_to_process, 'timepoints', reprocess); % (will segment all available timepoints in the directories)

%% Register Timepoints to existing Dartel. 
scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, DARTEL_template_path); 

%% Warp Timepoints to MNI via DARTEL (ignores longitudinal images)
%scans_to_process = sVBM_DARTEL_warp_to_MNI( scans_to_process, DARTEL_template_path );

%% Warp Timepoints to MNI, standard normalization, no DARTEL
scans_to_process = sVBM_warp_to_MNI(scans_to_process);

%% Extract ROI values from MNI warped timepoints 
scans_to_process = sVBM_extractMNItimepointROIs(scans_to_process, pathtoROIs);



