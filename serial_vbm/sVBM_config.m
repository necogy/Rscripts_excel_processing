%% sVBM_config
% Sets up paths that will be used by LONG_setup using the second revision of the
% pipeline. Create a copy of this file to make edits to for a specific data
% set.


%path to data:
scandatafolder = '/mnt/ramdisk/serial_svPPA_oct2014/pidn_dir';
%path to dartel template for your study (or where a dartel template will
%be created if it doesn't exist yet):
templatepath = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','darteltemplates','Aug2014_SD_NORM'); % set this to the new template folder name.
templatepath = '/mnt/ramdisk/serial_svPPA_oct2014/Aug2014_SD_NORM'

%path to ROIs to use to extract mean/median change values from a specific
%ROI:
pathtoROIs = fullfile( SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','ROIs');% set this to the new template folder name.
pathtoROIs= '/mnt/ramdisk/serial_svPPA_oct2014/NovROIs';