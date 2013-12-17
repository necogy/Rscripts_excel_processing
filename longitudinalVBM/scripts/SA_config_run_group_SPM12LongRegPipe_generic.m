%% Script to configure and run longitudinal registration pipeline for several subjects 
% it assumes the following structure for your pair of time 1 and time 2 images:
% /imagesdir/PIDN/yyyy-mm-dd/**.img/nii
% Based on Richard Binney's original scripts and "pipelined" by Suneth Attygalle 11/2013.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PROCESSING STEPS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1)    Rough alignment- the toolbox is very robust, but it occasionally fails. 
%       Sometimes this can be due to initial alignment and you can always straighten 
%       up images and orient to AC-PC to give it a helping hand. 
% 2)    Run longitudinal toolbox. SPM12b pairwise longitudinal registration 
%       Outputs a mean image and two images which are estimates of longitudinal change 
%       called �dv_*� and �jd_*� (in mean image space; the difference between the two is 
%       explained in the help section of the GUI but is minimal)
% 3)    Segment the mean image (generating c1, rc1, rc2)
% 4)    multiply the longitudinal image by the Grey matter segment. using Imacalc
% 5)    Estimate inter-subject registration of mean images using DARTEL, aligning the rc1 and rc2 images from all subjects together.
%       if you use DARTEL, I would suggest using a pre-existing template. Jen Y has a good one, and Richard Binney have one. 
%       There are a number of discussion points around DARTEL vs. not-DARTEL, who comprises the template, etc but that is for another day perhaps.
% 6)    Transform longitudinal images to group/MNI space.
% 7)    Smooth (6mm). (Normalise and smooth the c1.*jd images)
% 8)    Stats (NOT PERFORMED BY THIS SCRIPT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initialize
clear;

%load participant structure:  (Edit the called function to adjust it to your
%particular data format structure.
[participants, datapath] = SA_load_participant_info_longreg('casestudy1');

%regular expression that would grab your single timepoint image file:
%filenameregexp = '^\d+_\d.{4}\d.{2}\d.{2}MP-LAS_\w+(.img|.nii)';% e.g "6764_2012-06-18_MP-LAS_NIFD077X1.nii" 
filenameregexp = '^MP-LAS_\w+(.img|.nii)';

%path to images:
%datapath= fullfile(SAreturnDriveMap('R'),'groups','rosen','gene_carrier_imaging_all','VBM','sa_longitudinal', 'images','images_dir');
%datapath= participants.datapath; %datapath should be specified in 'SA_load_participant_info_longreg.m'

%path to jobs folder
jobspath =fullfile(SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','jobs'); 

%path to SPM12b folder 
spmpath =fullfile(SAreturnDriveMap('R'),'users','sattygalle','Matlab','spm12b');

%path to dartel template
dartelpath= fullfile(SAreturnDriveMap('R'),'users','sattygalle','Matlab','longitudinal','Template_binney');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set steps you want to re-run:
jobstorun.inputfiles = 1; %initialize data structure (usually always 1 except when debugging)


jobstorun.longitudinalregistration =0; % Run longitudinal registration 
jobstorun.segmentation = 0; % segment mean images from longitudinal toolbox 
jobstorun.multiplysegmentmaps =0; % multiply segmented mean images with longitudinal change maps


jobstorun.DARTELregistration_to_existing =0; % inter-subject registration of mean images using Dartel (requires template)
jobstorun.DARTELnormalise_to_MNI =0; % Transform longitudinal images to group/MNI space
jobstorun.smooth =0; %smooth 'wc1jd','wc1dv','wc2jd','wc2dv'  for stats later
jobstorun.time1and2segmentation = 0; %segment time 1 data (will eventually also segment time 2 data)
jobstorun.DARTELtimepoint_to_MNI =0; %transform time1 data to mni using intermediate longitudinal image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% initialize input data files (scans, subjectID, delta T. etc) %<-- roll this into "SA_load_participant_info_longreg"
%for each combination of visits (1-2, 2-3. 3-4, etc) - this might not be
%ideal for multiple time points
%build input file for pairwise longitudinal (file name 1, file name 2, time)

if jobstorun.inputfiles == 1 %this loop should be combined with the previous function call
    input.t1={};
    input.t2={};
    input.subjectdir = {};
    input.deltaT={};
    
    for i=1:size(participants,2)
        % ASSUMES FILES ARE LOADED IN ORDER BY DATE (the following few commented out lines could
        % solve this..)
        % get order of dates
        % datearray = cell2mat(participants(i).MRIdatenum);
        %[sorteddates, dateorder] = sort(datearray);
        
        for n = 1:size(participants(i).MRIdatenum,2)-1
            % n=dateorder(ind)
            
            %get data file (Which can be either img or nii), there will be
            %problems if both are found though. 
            data(1).dir = SAdir(fullfile(datapath, participants(i).PIDN, participants(i).MRIdate{n}), filenameregexp); %filename regular expression defined earlier 
            data(2).dir = SAdir(fullfile(datapath, participants(i).PIDN, participants(i).MRIdate{n+1}), filenameregexp);
            
            
            if size(data(1).dir,1) > 1
                error('Too many data files found for t1 check folders for PIDN: %s in %s folder',  participants(i).PIDN, participants(i).MRIdate{n})

            elseif size(data(2).dir,1) > 1
                error('Too many data files found for t1 check folders for PIDN: %s in %s folder',  participants(i).PIDN, participants(i).MRIdate{n+1})
            end
    
            input.t1 = [input.t1; fullfile(datapath, participants(i).PIDN, participants(i).MRIdate{n}, data(1).dir.name)];
            input.t2 = [input.t2; fullfile(datapath, participants(i).PIDN, participants(i).MRIdate{n+1}, data(2).dir.name)];
            input.subjectdir = [input.subjectdir; fullfile(datapath, participants(i).PIDN, participants(i).MRIdate{n})];
            input.deltaT = [input.deltaT; cell2mat(participants(i).MRIdatenum(n+1)) - cell2mat(participants(i).MRIdatenum(n))];
        end
    end
end



%% Run steps
stepfields(1,:) = fieldnames(jobstorun)';

for i = 1:size(stepfields,2)
    stepfields{2,i} = jobstorun.(stepfields{1,i});
end

dialogmessage = sprintf('\n %s = %d \n',stepfields{:} );
    
button = questdlg(['Run the following steps and overwrite existing data?' dialogmessage] ,'Confirm steps before running') ;

if strcmp(button,'Yes')
SA_run_group_SPM12LongRegPipe_generic %<- convert this to a function taking in "input" structure and "jobstorun"
end
