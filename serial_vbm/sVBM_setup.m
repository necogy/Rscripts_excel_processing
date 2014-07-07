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


%% Initialize Things:
clear
clear classes

%load parameters:
%sVBM_config % or name of edited config file 

%set scan data folder where image were placed using image_finder.sh
scandatafolder = 'R:\groups\rosen\longitudinalVBM\gene_carriers_serialVBMtest';

%read in directories and store info in scans_to_process structure
scans_to_process = sVBM_load_rawdata( scandatafolder );

%% Segmentation of timepoints:
scans_to_process = sVBM_run_segmentation(scans_to_process); % (will segment all available timepoints in the directories)

%% Longitudinal Registration

%% Segmentation of Longitudinal Images

%% Multiply Change Maps with Segmentations

%% Transform Longitudinal Images to Group/MNI space

%% Transform Timepoint Data to MNI using Intermediate Longitudinal Image Warp

%% Warp ROIs from Atlas Space to Native Timepoint Space.






