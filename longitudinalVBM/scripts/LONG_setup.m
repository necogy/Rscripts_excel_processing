%% LONG_setup
% Sets up Longitudinal VBM using the second revision of the
% pipeline. Set all of your paths first in LONG_config.  Create a copy of this file if you make edits to for a specific data
% set.

%make sure to add spm12b folder and longitudinalVBM folder with subfolders
%to matlab path.

% enable cell evaluation in matlab settings for easier use of this script
clear

%load parameters:
LONG_config

%scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','testfolder');
%scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','FLOOR_Mar2014_reprocess_2','images','images_dir');
scans_to_process = LONG_load_inputfile( scandatafolder );

%path to SPM12b folder 
%spmpath = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','spm12b');


%% steps to run:

%% Longitudinal registration to generate mean images
scans_to_process = LONG_run_registration( scans_to_process ); 

%% Segment mean images generated from longitudinal toolbox 
scans_to_process = LONG_run_segmentation( scans_to_process, 'mean', spmpath ); 

%% rigidly realign and reslice mean images for DARTEL
% this step doesn't work because the new segment doesn't create the
% appropriate fields, but it might work in future SPM versions

%voxelsize =1;
%scans_to_process = LONG_DARTELimport( scans_to_process, voxelsize ); 

%% inter-subject registration of mean images using Dartel (requires template
% or create a new one

%specify subjects to include to generate a new template(subset of all available patients in your
%study  to include in the template as follows:) 
DARTELnorms = [841;1124;1362;1416;1418;1813;2046;2062;2557;2679;2680;2688;2692;2699;2715;2720;2732;2735;2743;2744;2774;2801;3015;3027;3530;3773;4062;4063;4348;4943;5061;5064;5436;5595;5627;5844;65;3884;6248;6842;6867;6868;6908;6909;6935;6976;7142;7396;7397;7418;7802;7811;7837;7838;7851;7938;8193;8538;8565;8590;8593;8601;8698;9320;9440;9757;10445;10683;11241;11247;11296;11727];
DARTELpatients =[98;588;951;1004;1176;1319;1340;1463;1586;2275;2500;2711;3521;4160;4375;4379;4471;5468;5830;6110;10114;10880;11735;11965;12555;13108;13138;13185;13272;13512;13919;14427;15774;84;278;1615;2522;3690;3824;4747;6600;9283;10032;10434;11028;11704;11773;13962];
PIDNlist = [DARTELnorms ; DARTELpatients];
scans_to_process = LONG_DARTELregistration_to_new(scans_to_process, PIDNlist);  %create new template

% After generating a template in the previous step, MOVE GENERATED TEMPLATE FILES TO the TEMPLATE FOLDER specified in LONG_config 
scans_to_process = LONG_DARTELregistration_to_existing(scans_to_process, templatepath);

%% Segment time1 and time2 images:
scans_to_process = LONG_run_segmentation( scans_to_process, 'time1', spmpath ); 
scans_to_process = LONG_run_segmentation( scans_to_process, 'time2', spmpath ); 

%% multiply segmented mean images with longitudinal change maps
scans_to_process = LONG_multiply_segments_with_change(scans_to_process); %this works but needs refactoring to speed it up

%% Transform longitudinal images to group/MNI space
scans_to_process = LONG_DARTEL_to_MNI(scans_to_process, templatepath);

%% Group results:

%% generate average maps of c_jd/dv maps and wholebrain 
LSD_PIDNs = [98;588;951;1004;1176;1319;1340;1463;1586;2275;2500;2711;3521;4160;4375;4379;4471;5468;5830;6110;10114;10880;11735;11965;12555;13108;13138;13185;13272;13512;13919;14427;15774];
RSD_PIDNs = [84;278;1615;2522;3690;3824;4747;6600;9283;10032;10434;11028;11704;11773;13962];
SD_PIDNs = [LSD_PIDNs; RSD_PIDNs];
HC_PIDNs = [841;1124;1362;1416;1418;1813;2046;2062;2557;2679;2680;2688;2692;2699;2702;2703;2715;2720;2732;2735;2743;2744;2774;2801;3015;3027;3530;3773;4062;4063;4348;4943;5061;5064;5436;5595;5627;5844;65;1641;3700;3884;5133;5888;6248;6741;6838;6842;6857;6860;6867;6868;6908;6909;6922;6934;6935;6976;6977;7142;7396;7397;7411;7418;7444;7749;7792;7793;7802;7811;7813;7837;7838;7850;7851;7938;8182;8193;8510;8533;8538;8545;8565;8590;8592;8593;8594;8601;8619;8627;8698;8706;8913;9320;9440;9621;9757;10445;10683;11241;11247;11296;11329;11463;11727];
%scans_to_process = LONG_generatemeanmaps(scans_to_process, PIDNlistforgroup, 'titletoprependtoaverageimage');

scans_to_process = LONG_generatemeanmaps(scans_to_process, LSD_PIDNs, 'SDL');
scans_to_process = LONG_generatemeanmaps(scans_to_process, RSD_PIDNs, 'SDR');
scans_to_process = LONG_generatemeanmaps(scans_to_process, SD_PIDNs, 'SDLR');
scans_to_process = LONG_generatemeanmaps(scans_to_process, HC_PIDNs, 'HC');

%% Transform time1 and time2 data to mni using intermediate longitudinal image warp
scans_to_process = LONG_timepoint_to_MNI(scans_to_process, templatepath, 'time1');
scans_to_process = LONG_timepoint_to_MNI(scans_to_process, templatepath, 'time2');

%% T-Spoon for stats ( you might not want to use this vs normal smoothing below)
scans_to_process = LONG_tspoon_changemaps(scans_to_process);

%% Smooth individual participant change maps images for stats 
fwhm = 6 ;
scans_to_process = LONG_smooth_changemaps(scans_to_process, fwhm);

%% extract mean/median change values in ROIs and save to scans_to_process
%structure
%pathtoROIs = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','ROIs');
ROIprefix = '^rr';
changemapprefix = 'wl_c1avg_jd_';
scans_to_process = LONG_extractROIs(scans_to_process, changemapprefix, pathtoROIs, ROIprefix); %extract ROI values and add to scans_to_process structure
[ROImeans, ROImedians] = LONG_exportROIs(scans_to_process); %pull out mean and median values from scans_to_process in a convenient format

%% extract mean/median changes values from combined GM/WM change maps

ROIprefix = '^rr';
changemapprefix = 'wl_c*avg_jd_';
scans_to_process = LONG_extractWMGMROIs(scans_to_process, changemapprefix, pathtoROIs, ROIprefix)
[ROImeans, ROImedians] = LONG_exportROIs(scans_to_process); %pull out mean and median values from scans_to_process in a convenient format


%% Extract ROIs from change maps in Dartel Space
scans_to_process = LONG_extractROIsinDARTEL(scans_to_process, changemapprefix, pathtoROIs, ROIprefix); 


%% extract mean/median change values from warped timepoints (MNI) and save to scans_to_process
%pathtoROIs = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','ROIs');
scans_to_process = LONG_extractMNItimepointROIs(scans_to_process, pathtoROIs, 'time1'); %extract ROI values and add to scans_to_process structure
scans_to_process = LONG_extractMNItimepointROIs(scans_to_process, pathtoROIs, 'time2'); %extract ROI values and add to scans_to_process structure

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



