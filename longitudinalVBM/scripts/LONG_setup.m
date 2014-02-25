%% LONG_setup
% Sets up Longitudinal VBM using the second revision of the
% pipeline.

clear

scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','testfolder');
%scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','FLOOR_feb2014_reprocess','images','images_dir');

scans_to_process = LONG_load_inputfile( scandatafolder );

%path to SPM12b folder 
spmpath = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','spm12b');

%path to DARTEL template
%dartelpath = 'R:\users\sattygalle\Matlab\longitudinal\Template_binney';


%% steps to run:

%% Longitudinal registration to generate mean images
scans_to_process = LONG_run_registration( scans_to_process ); % done

%% Segment mean images generated from longitudinal toolbox 
scans_to_process = LONG_run_segmentation( scans_to_process, 'mean', spmpath ); % done

%% multiply segmented mean images with longitudinal change maps
scans_to_process = LONG_multiply_segments_with_change(scans_to_process);

%% rigidly realign and reslice mean images for DARTEL
% this step doesn't work because the new segment doesn't create the
% appropriate fields.
voxelsize =1;
scans_to_process = LONG_DARTELimport( scans_to_process, voxelsize ); 

%% inter-subject registration of mean images using Dartel (requires template
% or create a new one)
scans_to_process = LONG_DARTELregistration_to_existing(scans_to_process, templatepath); %could use vararg 
scans_to_process = LONG_DARTELregistration_to_new(scans_to_process);

%% Transform longitudinal images to group/MNI space
scans_to_process = LONG_DARTELnormalise_to_MNI(scans_to_process, 'mean');

%% Smooth individual participant change maps images for stats 
scans_to_process = LONG_smooth_changemaps(scans_to_process);

%% Segment time1 and time2 images:
scans_to_process = LONG_run_segmentation( scans_to_process, 'time1' );
scans_to_process = LONG_run_segmentation( scans_to_process, 'time2' );

%% Transform time1 and time2 data to mni using intermediate longitudinal image
scans_to_process = LONG_DARTELnormalise_to_MNI(scans_to_process, 'time1');
scans_to_process = LONG_DARTELnormalise_to_MNI(scans_to_process, 'time2');

%% Group:
LONG_extractROIs %extract from custom ROIs and generate spreadsheet
LONG_extractVolumes %WM/GM/CSF/TIV and generate spreadsheet
LONG_generatemeanmaps % create average change maps



