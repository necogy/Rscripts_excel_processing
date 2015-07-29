%% LONG_config
% Sets up paths that will be used by LONG_setup using the second revision of the
% pipeline. Create a copy of this file to make edits to for a specific data
% set.

%path to data:
scandatafolder = 'pathto/images_dir';

%path to spm12 folder:
% spmpath = 'spm12path'; this is automatically determined in LONG_setup

%path to dartel template for your study (or where a dartel template will
%be created if it doesn't exist yet):
templatepath = 'path_to_dartel_template'; % set this to the new template folder name.

%path to ROIs to use to extract mean/median change values from a specific
%ROI:
% Make sure the ROIs are in the same space as your images to extract from
pathtoROIs = 'path_to_ROIs_for_extraction';% set this to the new template folder name. 

