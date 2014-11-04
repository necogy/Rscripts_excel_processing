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
spmpath = fileparts(which('spm'));
scans_to_process = lzDTI_load_rawdata( scandatafolder );

nSubjects = size(scans_to_process,2);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%individual subject processing;
for iSubject=1:nSubjects
    sprintf(['now pre-processing subject ' num2str(iSubject)])
    try
        % 1 .Coregister FA to T1
        lzDTI_coregisterFAtoT1(scans_to_process(iSubject));
        
        % 2. Dartel Register time1 FA to time2 FA
        lzDTI_longitudinal_registerFA(scans_to_process(iSubject));
        
        % 3. Warp timepoint T1 to FA average space
        lzDTI_warp_timepointT1toFAavgSpace(scans_to_process(iSubject))
        
        % 4. Generate mean image
        %lzDTI_calculate_averageT1inFAavgSpaceForDARTEL(scans_to_process(iSubject))
        lzDTI_coregisterWarpedT1sUsingLongitudinalRegistration(scans_to_process(iSubject))
        
        % 5. Segment Average T1 for DARTEL
        lzDTI_segment_averageT1forDARTEL(scans_to_process(iSubject))
        
    catch
        sprintf(['error with subject ' num2str(iSubject)])
    end
end

%subs to redo (use find(ind) for previous loop to redo subjects)
substoredo = {'10440','10445','10668','2720','7142','8601'};
ind=zeros(1,size(scans_to_process,2));
for isubs = 1:length(substoredo)
    ind =ind+SA_FindStringInStructArray(scans_to_process, 'PIDN', substoredo{isubs});
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Group processing

% 1.Run DARTEL on T1 averages
lzDTI_DARTEL_registration_to_new(scans_to_process)




% Warp T1s to MNI

% Generate Combined warps

% Apply to FA images.



