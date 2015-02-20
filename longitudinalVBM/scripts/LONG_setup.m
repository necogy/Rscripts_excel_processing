%% LONG_setup
% Sets up Longitudinal VBM using the second revision of the
% pipeline. Set all of your paths first in LONG_config.  Create a copy of this file if you make edits to for a specific data
% set.

%make sure to add spm12 folder and longitudinalVBM folder with subfolders
%to matlab path.

%use image_finder.sh to pull images into the correct folder structure, or
%do it yourself as follows /14929/2015-01-01/MP-LAS.nii , /14929/2015-09-31/MP-LAS.nii

% enable cell evaluation in matlab settings for easier use of this script
clear

%% steps to run:

%% 1. Initialize: 
clear
% a. Load parameters:
%LONG_config %<-------------- OPEN THIS and replace with paths specific to your study
%path to data:
scandatafolder = fullfile('R:\groups\rosen\longitudinalVBM\SD_floor_project\test_timepointwarping02_2015\');

%path to spm12 folder:
spmpath = fileparts(which('spm'));

%path to dartel template for your study (or where a dartel template will
%be created if it doesn't exist yet):
templatepath = 'path_to_dartel_template'; % set this to the new template folder name.
templatepath='R:\groups\rosen\longitudinalVBM\SD_floor_project'

%path to ROIs to use to extract mean/median change values from a specific
%ROI:
pathtoROIs = 'path_to_ROIs_for_extraction';% set this to the new template folder name. Make sure the ROIs are in the same space as your images to extract from

% b. Load Data
scans_to_process = LONG_load_inputfile( scandatafolder );

%% PREPROCESSING (Steps 2-6)

%% 2. Longitudinal registration to generate subject average images 
scans_to_process = LONG_run_registration( scans_to_process ); 

%% 3. Segment mean images generated from longitudinal toolbox 
scans_to_process = LONG_run_segmentation( scans_to_process, 'mean', spmpath ); 

%% rigidly realign and reslice mean images for DARTEL
% this step doesn't work because the new segment doesn't create the
% appropriate fields, but it might work in future SPM versions
%voxelsize =1;
%scans_to_process = LONG_DARTELimport( scans_to_process, voxelsize ); 

%% 4. Inter-subject registration of mean images using Dartel (requires template)
% or create a new one

% specify subjects to include to generate a new template(subset of all available patients in your
%study  to include in the template as follows:) 
% if you want to use all the available subjects set PIDNlist = [];
DARTELnorms = [841;1124;1362;1416;1418;1813;2046;10683;11241;11247;11296;11727];
DARTELpatients =[98;588;951;1004;1176;1319;13919;14427;15774;84;11028;11704;11773;13962];
PIDNlist = [DARTELnorms ; DARTELpatients];
scans_to_process = LONG_DARTELregistration_to_new(scans_to_process, PIDNlist);  %create new template

% After generating a template in the previous step, MOVE GENERATED TEMPLATE FILES TO the TEMPLATE FOLDER you then specify in LONG_config 
scans_to_process = LONG_DARTELregistration_to_existing(scans_to_process, templatepath);

%% 5. multiply segmented mean images with longitudinal change maps
scans_to_process = LONG_multiply_segments_with_change(scans_to_process); %this works but needs refactoring to speed it up

%% 6. Transform longitudinal images to group/MNI space
scans_to_process = LONG_DARTEL_to_MNI(scans_to_process, templatepath);
% at this point you have generated warped change maps that can be used for
% statistical analysis, you might want to smooth the images using the
% following steps.

%% Generate population to ICBM registration deformation field
SA_SPM12_generateDARTELToICBM(fullfile(templatepath, 'Template_6.nii')); % generates dartel pop to ICBM deformation field using SPM12

%% push dartel images to ICBM 


%%%%%%% up to here revised 02/19/15


%% Smooth individual participant change maps images for stats 
fwhm = 6 ; % <-- this should be changed depending on the data
scans_to_process = LONG_smooth_changemaps(scans_to_process, fwhm);

%% T-Spoon for stats ( you might not want to use this vs normal smoothing below)
% T-spoon smoothing is an improved algorithm for smoothing that reduces the
% effect of smoothing the brain outside of the actual brain
scans_to_process = LONG_tspoon_changemaps(scans_to_process);


%% extract mean/median change values in ROIs and save to scans_to_process
% paths to ROI folder should be set in LONG_config
ROIprefix = '^s'; % <-- the ROIs that will be used to to extract will start with the prefix here
changemapprefix = 'wl_c1avg_jd_'; % <---Specify  the image you want to extract from by including the prefix of the file here
scans_to_process = LONG_extractROIs(scans_to_process, changemapprefix, pathtoROIs, ROIprefix); %extract GM ROI values and add to scans_to_process structure
scans_to_process = LONG_extractWMGMROIs(scans_to_process, changemapprefix, pathtoROIs, ROIprefix); % if you want combined GM/WM extractions, run this line instead.

[ROImeans, ROImedians] = LONG_exportROIs(scans_to_process); %pull out mean and median values from scans_to_process in a convenient format

%% optional steps

%% Generate average maps of warped c_jd/dv maps and wholebrain for plotting
% you can specify the PIDNs so you can plot averages of subsets of subjects
% (e.g by group/disease) use PIDNlist = []; to use all subjects
PIDNsforAverage = [98;588;951;1004;1176;1319;1340;1463;1586;2275;2500;2711;3521;4160;4375;4379;4471;5468;5830;6110;10114;10880;11735;11965;12555;13108;13138;13185;13272;13512;13919;14427;15774];
%scans_to_process = LONG_generatemeanmaps(scans_to_process, PIDNlistforgroup, 'titletoprependtoaverageimage');
scans_to_process = LONG_generatemeanmaps(scans_to_process,PIDNsforAverage, 'titleForImage');

%% Segment time1 and time2 images:
scans_to_process = LONG_run_segmentation( scans_to_process, 'time1', spmpath ); 
scans_to_process = LONG_run_segmentation( scans_to_process, 'time2', spmpath ); 

%% %%%%%%% USE STEPS BELOW AT YOUR OWN RISK, not all fully vetted %%%%%%%%%%%%%
templatepath = 'R:\groups\rosen\longitudinalVBM\SD_floor_project';
scans_to_process = LONG_sequential_warp_to_MNI(scans_to_process, templatepath);


%% Transform time1 and time2 data to mni using intermediate longitudinal image warp
% This step might be broken.
scans_to_process = LONG_timepoint_to_MNI(scans_to_process, templatepath, 'time1');
scans_to_process = LONG_timepoint_to_MNI(scans_to_process, templatepath, 'time2');

%% Extract ROIs from change maps in Dartel Space
scans_to_process = LONG_extractROIsinDARTEL(scans_to_process, changemapprefix, pathtoROIs, ROIprefix); 

%% extract mean/median change values from warped timepoints (MNI) and save to scans_to_process
%pathtoROIs = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','ROIs');
pathtoROIs = 'R:\groups\rosen\longitudinalVBM\SD_floor_project\ROIs15'
scans_to_process = LONG_extractMNItimepointROIs(scans_to_process, pathtoROIs, 'time1'); %extract ROI values and add to scans_to_process structure
scans_to_process = LONG_extractMNItimepointROIs(scans_to_process, pathtoROIs, 'time2'); %extract ROI values and add to scans_to_process structure

scans_to_process = LONG_extractMNItimepointROIVolumes(scans_to_process, pathtoROIs, 'time1'); %extract ROI values and add to scans_to_process structure
scans_to_process = LONG_extractMNItimepointROIVolumes(scans_to_process, pathtoROIs, 'time2'); %extract ROI values and add to scans_to_process structure

nativeROIvolumes_time1 = LONG_exportMNI_ROIs(scans_to_process, 'time1');
nativeROIvolumes_time2 = LONG_exportMNI_ROIs(scans_to_process, 'time2');

%% extract time 1 and time 2 volumes
scans_to_process = LONG_extractVolumes(scans_to_process, 'time1'); 
scans_to_process = LONG_extractVolumes(scans_to_process, 'time2'); 

%% DTI related scripts below %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create and apply inverse deformations from ROI to native space
ROImodulationon = 0;
scans_to_process = LONG_warpROIsToNativeSpace(scans_to_process, templatepath, pathtoROIs, 'time1', ROImodulationon);
scans_to_process = LONG_warpROIsToNativeSpace(scans_to_process, templatepath, pathtoROIs, 'time2', ROImodulationon);

%extract ROIs in native space 
d=SAdir(pathtoROIs, '\w');
ROInames = strrep({d.name},'.nii','');
ROImodulationon = 0;
scans_to_process = LONG_extractROIsInNativeSpace(scans_to_process, ROInames, 'time1', ROImodulationon);
scans_to_process = LONG_extractROIsInNativeSpace(scans_to_process, ROInames, 'time2', ROImodulationon);

%export native ROI volumes
nativeROIvolumes_time1 = LONG_exportNativeROIs(scans_to_process, 'time1')';
nativeROIvolumes_time2 = LONG_exportNativeROIs(scans_to_process, 'time2')';



