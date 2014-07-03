%% Serial VBM Processing Pipeline

% Preprocesses date using SPM12b and performs longitudinal registration
% with multiple timepoints
% Can be used to process single timepoint data. 
% For two timepoint longitudinal data, use the longitudinalVBM package
% instead.
 
% Set all of your file paths first in LONG_config.  Create a copy of this
% file if you make edits to for a specific data set
% set.

%make sure to add spm12b folder and longitudinalVBM folder with subfolders
%to matlab path.

% enable cell evaluation in matlab settings for easier use of this script
clear
clear classes

%load parameters:
sVBM_config % or name of new config file 

%scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','testfolder');
%scandatafolder = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','FLOOR_Mar2014_reprocess_2','images','images_dir');
scandatafolder = 'R:\groups\rosen\longitudinalVBM\gene_carriers_serialVBMtest';
scans_to_process = sVBM_load_rawdata( scandatafolder );

scans_to_process2 = sVBM_run_segmentation(scans_to_process);