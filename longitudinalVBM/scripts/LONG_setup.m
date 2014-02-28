%% LONG_setup
% Sets up Longitudinal VBM using the second revision of the
% pipeline.

%make sure to add spm12b folder and longitudinalVBM folder with subfolders
%to matlab path.

clear
spm_my_defaults; % set up max mem  = edit and set this to half of your avilable ram % this might not be necssary unless doing stats
%scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','testfolder');
scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','FLOOR_feb2014_reprocess','images','images_dir');

scans_to_process = LONG_load_inputfile( scandatafolder );

%path to SPM12b folder 
spmpath = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','spm12b');


%% steps to run:

%% Longitudinal registration to generate mean images
scans_to_process = LONG_run_registration( scans_to_process ); % done + ran

%% Segment mean images generated from longitudinal toolbox 
scans_to_process = LONG_run_segmentation( scans_to_process, 'mean', spmpath ); % done + ran

%% rigidly realign and reslice mean images for DARTEL
% this step doesn't work because the new segment doesn't create the
% appropriate fields.

%voxelsize =1;
%scans_to_process = LONG_DARTELimport( scans_to_process, voxelsize ); 

%% inter-subject registration of mean images using Dartel (requires template
% or create a new one

DARTELnorms = [841;1124;1362;1416;1418;1813;2046;2062;2557;2679;2680;2688;2692;2699;2715;2720;2732;2735;2743;2744;2774;2801;3015;3027;3530;3773;4062;4063;4348;4943;5061;5064;5436;5595;5627;5844;65;3884;6248;6842;6867;6868;6908;6909;6935;6976;7142;7396;7397;7418;7802;7811;7837;7838;7851;7938;8193;8538;8565;8590;8593;8601;8698;9320;9440;9757;10445;10683;11241;11247;11296;11727];
DARTELpatients =[98;588;951;1004;1176;1319;1340;1463;1586;2275;2500;2711;3521;4160;4375;4379;4471;5468;5830;6110;10114;10880;11735;11965;12555;13108;13138;13185;13272;13512;13919;14427;15774;84;278;1615;2522;3690;3824;4747;6600;9283;10032;10434;11028;11704;11773;13962];

PIDNlist = [DARTELnorms ; DARTELpatients];
scans_to_process = LONG_DARTELregistration_to_new(scans_to_process, PIDNlist); % done + ran 
% MOVE GENERATED TEMPLATE FILES TO TEMPLATE FOLDER 
templatepath = 'R:\users\sattygalle\Matlab\longitudinal\Feb2014_SD_NORM'; % set this to the new template name.
scans_to_process = LONG_DARTELregistration_to_existing(scans_to_process, templatepath);


%% Code below is not done%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% multiply segmented mean images with longitudinal change maps
scans_to_process = LONG_multiply_segments_with_change(scans_to_process);

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



