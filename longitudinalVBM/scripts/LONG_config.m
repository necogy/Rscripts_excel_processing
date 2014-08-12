%% LONG_config
% Sets up paths that will be used by LONG_setup using the second revision of the
% pipeline. Create a copy of this file to make edits to for a specific data
% set.


%path to data:
scandatafolder = 'R:\groups\rosen\longitudinalVBM\FLOOR_mar2014_reprocess_2\images\images_dir';

%path to spm12b folder:
spmpath = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','spm12b');

%path to dartel template for your study (or where a dartel template will
%be created if it doesn't exist yet):
templatepath = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','darteltemplates','Mar2014_SD_NORM'); % set this to the new template folder name.

%path to ROIs to use to extract mean/median change values from a specific
%ROI:
pathtoROIs = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','FLOOR_Mar2014_reprocess_2','roistowarp');% set this to the new template folder name.
