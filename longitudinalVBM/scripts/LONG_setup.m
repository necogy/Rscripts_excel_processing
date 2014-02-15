%LONG_setup
% Sets up Longitudinal VBM using the second revision of the
% pipeline.

clear

scandatafolder = 'R:\groups\rosen\longitudinalVBM\testfolder';
scans_to_process = LONG_load_inputfile( scandatafolder );

%path to SPM12b folder 
spmpath = 'R:\users\sattygalle\Matlab\spm12b';

%path to DARTEL template
dartelpath = 'R:\users\sattygalle\Matlab\longitudinal\Template_binney';

%steps to run:

jobstorun.longitudinalregistration =0; % Run longitudinal registration 


jobstorun.segmentation = 0; % segment mean images from longitudinal toolbox 
jobstorun.multiplysegmentmaps =0; % multiply segmented mean images with longitudinal change maps
jobstorun.DARTELregistration_to_existing =0; % inter-subject registration of mean images using Dartel (requires template)
jobstorun.DARTELnormalise_to_MNI =0; % Transform longitudinal images to group/MNI space

jobstorun.time1and2segmentation = 0; %segment time 1 and time 2 data 
jobstorun.t1DARTELtimepoint_to_MNI =0; %transform time1 data to mni using intermediate longitudinal image
jobstorun.t2DARTELtimepoint_to_MNI =0; %transform time1 data to mni using intermediate longitudinal image
jobstorun.smooth =0; %smooth individual participant 'wc1jd','wc1dv','wc2jd','wc2dv' images for stats 


jobstorun.extractROIS
jobstorun.extractVolumes %WM/GM/CSF/TIV

%Group:

jobstorun.generatemeanmaps

%optional steps



%% Run steps
stepfields(1,:) = fieldnames(jobstorun)';

for i = 1:size(stepfields,2)
    stepfields{2,i} = jobstorun.(stepfields{1,i});
end

dialogmessage = sprintf('\n %s = %d \n',stepfields{:} );
button = questdlg(['Run the following steps and overwrite existing data? ' dialogmessage] ,'Confirm steps before running') ;
