%% longitudinal DTI Processing Pipeline based on Yu Zhang's at the SF VA
%
% To use this pippeline. Set all of your file paths first in the
% "initialize things" section
% Create a copy of the config file if you make edits to for a specific data set
% set so it doesn't get overwritten if you download a new version of the
% code in the same directory.
%
% Make sure to add spm12 folder (not with subfolders) and the lzDTI folderwith subfolders
% to the Matlab path. Steps will error out if SPM12 is not added to the
% path.
%
% fTor easier use of this script enable cell evaluation in matlab settings. 
%
% Suneth Attygalle - 10/24/14 - UCSF Memory and Aging Center

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize Things:
clear
clear classes

%load parameters:
%path to data:
scandatafolder = '/mnt/macdata/groups/imaging_core/suneth/analyses/longDTI_bri/pidns';
scans_to_process = lzDTI_load_rawdata( scandatafolder );

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







