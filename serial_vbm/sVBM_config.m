%% sVBM_config
% Sets up paths that will be used by sVBM_setup using the second revision of the
% pipeline. Create a copy of this file to make edits to for a specific data
% set.


%path to data: (set scan data folder where image were placed using
%image_finder.sh)

scandatafolder = '/mnt/macdata/groups/rosen/longitudinalVBM/SD_floor_project/staffaroni_paper/BothFieldStrengths';

%path to dartel template for your study (or where a dartel template will
%be created if it doesn't exist yet):
templatepath = '/mnt/macdata/groups/rosen/longitudinalVBM/SD_floor_project/staffaroni_paper/dartel_template_3t15t_n193';

%path to ROIs to use to extract mean/median change values from a specific
%ROI:
pathtoROIs = '/mnt/macdata/groups/rosen/longitudinalVBM/SD_floor_project/staffaroni_paper/NMrois';% set this to the new template folder name.
