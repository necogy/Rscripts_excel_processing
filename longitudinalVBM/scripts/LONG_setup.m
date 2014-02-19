%% LONG_setup
% Sets up Longitudinal VBM using the second revision of the
% pipeline.

clear

scandatafolder = 'R:\groups\rosen\longitudinalVBM\testfolder';
scans_to_process = LONG_load_inputfile( scandatafolder );

%path to SPM12b folder 
spmpath = 'R:\users\sattygalle\Matlab\spm12b';

%path to DARTEL template
dartelpath = 'R:\users\sattygalle\Matlab\longitudinal\Template_binney';


%% steps to run:

% Longitudinal registration to generate mean images
scans_to_process = LONG_run_registration( scans_to_process ); % done

% Segment mean images generated from longitudinal toolbox 
scans_to_process = LONG_run_segmentation( scans_to_process, 'mean' );

% multiply segmented mean images with longitudinal change maps
scans_to_process = LONG_multiply_segments_with_change(scans_to_process);

% inter-subject registration of mean images using Dartel (requires template
% or create a new one)
scans_to_process = LONG_DARTELregistration_to_existing(scans_to_process);
scans_to_process = LONG_DARTELregistration_to_new(scans_to_process);

% Transform longitudinal images to group/MNI space
scans_to_process = LONG_DARTELnormalise_to_MNI(scans_to_process, 'mean');

% Smooth individual participant change maps images for stats 
scans_to_process = LONG_smooth_changemaps(scans_to_process);

% Segment time1 and time2 images:
scans_to_process = LONG_run_segmentation( scans_to_process, 'time1' );
scans_to_process = LONG_run_segmentation( scans_to_process, 'time2' );

% Transform time1 and time2 data to mni using intermediate longitudinal image
scans_to_process = LONG_DARTELnormalise_to_MNI(scans_to_process, 'time1');
scans_to_process = LONG_DARTELnormalise_to_MNI(scans_to_process, 'time2');

%Group:
LONG_extractROIs %extract from custom ROIs
LONG_extractVolumes %WM/GM/CSF/TIV
LONG_generatemeanmaps % create average change maps



