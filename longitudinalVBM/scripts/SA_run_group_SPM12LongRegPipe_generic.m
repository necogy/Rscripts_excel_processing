%Script to run longitudinal registration pipeline for several subjects 
% it assumes the following structure for your pair of time 1 and time 2 images:
% /imagesdir/PIDN/yyyy-mm-dd/**.img/nii

%% initialize
clear;

%load participant structure:  (Edit the function to adjust it to your
%particular data structure.
[participants, datapath] = SA_load_participant_info_longreg('Nov2013_NIFDcontrols');

%regular expression that would grab your single timepoint image file:
filenameregexp = '^\d+_\d.{4}\d.{2}\d.{2}MP-LAS_\w+(.img|.nii)';% e.g "6764_2012-06-18_MP-LAS_NIFD077X1.nii" 

%path to images:
%datapath= fullfile(SAreturnDriveMap('R'),'groups','rosen','gene_carrier_imaging_all','VBM','sa_longitudinal', 'images','images_dir');
%datapath= participants.datapath; %datapath should be specified in 'SA_load_participant_info_longreg.m'

%path to jobs folder
jobspath =fullfile(SAreturnDriveMap('R'),'groups','rosen','longitudinalVBM','jobs'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set steps you want to re-run:
jobstorun.inputfiles = 1;
jobstorun.longitudinalregistration =0;
jobstorun.segmentation = 0;
jobstorun.multiplysegmentmaps = 0;


%%%%%%%%%stop here. 
jobstorun.DARTELregistration_to_existing =0;
jobstorun.DARTELnormalise_to_MNI =0;
jobstorun.smooth =0; %ran on wc*jd and wc*dv 
jobstorun.time1and2segmentation = 0;
%%%%%%%%%%%%%%%%%%%%% all previous steps have been run as of 11/8/13

jobstorun.DARTELtimepoint_to_MNI =0; %ran on T1s


%% initialize input data files (scans, subjectID, delta T. etc)
%for each combination of visits (1-2, 2-3. 3-4, etc) - this might not be
%ideal for multiple time points
%build input file for pairwise longitudinal (file name 1, file name 2, time)

if jobstorun.inputfiles == 1
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

%% Run SPM12 pairwise longitudinal registration 
if jobstorun.longitudinalregistration == 1
    
    inputs=cell(3,1);
    inputs{1,1} = input.t1(1:end); % colum of Time 1 Vols
    inputs{2,1} = input.t2(1:end); % column of Time 2 Vols (same order as time 1 - i.e., by subject)
    inputs{3,1} = cell2mat(input.deltaT(1:end))/365; % Vector of proportion of a year between time 1 and time 2 (e.g., 0.5 = 6months)

    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run', fullfile( jobspath, 'SPM12_longitudinalregister_job.m'), inputs{:}); 
    clear inputs;
end

%% Run segment from SPM12b with latest updates on average of 2 timepoints from long-reg

if jobstorun.segmentation == 1
    
    %build input file of average file:
    
        %change to suffix to .nii:
        inputseg = cellfun(@(x) strrep(x, 'img', 'nii'), input.t1, 'UniformOutput', false);

        %find last backslash for all images:
        idx = regexp(inputseg,filesep);
        avgfiles = cell(size(inputseg,1),1);
        
        %insert "avg_" into avg image name.
        for i = 1:size(inputseg,1)
            avgfiles{i}=  [inputseg{i}(1:idx{i}(end)) 'avg_' inputseg{i}(idx{i}(end)+1:end)];
        end
    
    %Run SPM12 segmentation
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run',  fullfile( jobspath, 'SPM12_segmentanddartelimport_job.m'), avgfiles);
end 

%%% do following:

%% Run imcalc to create c1.*jd/dv and c2.*jd/dv images (looped by subject) (on average imges)
if jobstorun.multiplysegmentmaps == 1
      mapstring = {'dv','dv','jd','jd'};
      cstring = {'c1', 'c2','c1','c2'};
            
    %for each subject set
    %idx = regexp(input.t1,filesep)
    
    for i = 1:size(input.t1,1)
        for n = 1:4      
            try
                filestruct = SAdir(input.subjectdir{i}, ['^' mapstring{n} '_']) ;
                mapimage = fullfile(input.subjectdir{i},filestruct.name); %dv or jd image

                filestruct = SAdir(input.subjectdir{i},['^' cstring{n} 'avg_'] ) ;
                cimage = fullfile(input.subjectdir{i},filestruct.name); %c1 or %c2

                outfile = strrep(mapimage, mapstring{n}, [cstring{n} mapstring{n}]); 

                SAmultiply2Images(cimage, mapimage, outfile);
                
            catch err
                disp(err)
            end
        end
    end
    
end

%% Run DARTEL inter subject registration using existing template 
if jobstorun.DARTELregistration_to_existing == 1
    
     %build input file of average file:
     inputseg = cellfun(@(x) strrep(x, 'img', 'nii'), input.t1, 'UniformOutput', false);
     
        %find last backslash for all images:
        idx = regexp(inputseg,filesep);
        rc1files = cell(size(idx,1),1);
        rc2files = cell(size(idx,1),1);
        
        %insert "avg_" into avg image name.
        for i = 1:size(idx,1)
            rc1files{i}=  [inputseg{i}(1:idx{i}(end)) 'rc1avg_' inputseg{i}(idx{i}(end)+1:end)];
            rc2files{i}=  [inputseg{i}(1:idx{i}(end)) 'rc2avg_' inputseg{i}(idx{i}(end)+1:end)];
        end
    
    inputs = cell(2,1);
    inputs{1,1} = rc1files; %rc1avg
    inputs{2,1} = rc2files; %rc2avg
    
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run', fullfile( jobspath, 'SPM12_dartel_existingtemplate_job.m'), inputs{:});
    
end

%% Run DARTEL Normalise to MNI with Zero Smoothing and no modulation (all subjects at once)
if jobstorun.DARTELnormalise_to_MNI ==1
    %to do: update jobs dynamically so following warning is irrelvant
    warning('please make sure dartel normalize SPM job has correct number of fields')
        
    prefixes = {'u_rc1avg','avg','mavg','c1avg','c2avg', 'c1jd','c1dv','c2jd','c2dv' };
   % prefixes = {'u_rc1avg','c1jd','c1dv','c2jd','c2dv' };
    inputs = cell(size(prefixes,2)+1,1);
    inputs{1, 1} = {fullfile(SAreturnDriveMap('R'),'users','sattygalle','Matlab','longitudinal','Template_binney','Template_6.nii')};% Group-specific DARTEL template
    
    %build input file of average file:
    for n = 1:size(prefixes,2)
        
        files = cell(38,1);
        for i = 1:size(input.subjectdir,1)
            
            file = SAdir(input.subjectdir{i}, ['^' prefixes{n} '_.*nii$'] );
            files{i,1} = [input.subjectdir{i} filesep file.name];
            
        end
        inputs{n+1,1}= files;
    end
    
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run', fullfile( jobspath, 'SPM12_applydeformations_to_MNI_job.m'), inputs{:});
end

%% Segment original Time 1 and Time 2 for extracting volumes later. 
if jobstorun.time1and2segmentation== 1
    
    inputs=  [input.t1; input.t2];

    %remove dupes
    uniqueinputs = unique(inputs);
  
    %Run SPM12 segmentation
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run',  fullfile( jobspath, 'SPM12_segment_nativeonly_forsingleimgvolumes_job.m'), uniqueinputs);
end 

%% Run DARTEL Normalise to MNI from original time point using combined deformation
if jobstorun.DARTELtimepoint_to_MNI ==1 %tthis is only running on t1 right now
    for i = 1:size(input.t1,1) % for each subject
      
       % prefixes = {'u_rc1avg','y','','toAVGtoMNI_InvForPush','.','c1','c2','c3','wavg' };
        
        inputseg = input.t1{i};
        
        inputs = cell(7,1);
        inputs{3,1}= cellstr( inputseg); % Image to base inverse on for PUSH warp (raw timepoint image)
        inputseg = strrep(inputseg,'img','nii')   ;%change to suffix to .nii:
     
        %find last backslash for all images:
        idx = regexp(inputseg,filesep); 
        %avgfiles = cell(size(inputseg,1));
        
        inputs{1,1}=  cellstr([inputseg(1:idx(end)) 'u_rc1avg_' inputseg(idx(end)+1:end)]);% DARTEL flowfield from AVG
        inputs{2,1}=  cellstr([inputseg(1:idx(end)) 'y_avg_' inputseg(idx(end)+1:end)]);% Timepoint's deform field to AVG (Y)
        inputs{4,1}= [inputseg(1:idx(end)) 'toAVGtoMNI_InvForPush_' inputseg(idx(end)+1:end)];% output name for NEW deformation field
        inputs{5,1}=  cellstr([input.subjectdir{i}]);% output directory for deform field
    
        inputs{6,1} =  { [inputseg(1:idx(end)) 'c1' inputseg(idx(end)+1:end)]
            [inputseg(1:idx(end)) 'c2' inputseg(idx(end)+1:end)]
           [inputseg(1:idx(end)) 'c3' inputseg(idx(end)+1:end)]
            
        };  % Images to apply to: c1 and c2 and c3 of timepoint
        
        
        inputs{7,1} = cellstr([inputseg(1:idx(end)) 'wavg_' inputseg(idx(end)+1:end)]);% defines voxel dims (warped avg for subject)

        %inputscell = cellfun(@cellstr,inputs, 'UniformOutput', 0)
        
%%%%%%%%%%%%%%%%s
    
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run', fullfile( jobspath, 'SPM12_combdeform3_andwarpindivtimepntsegs_thruavg_thruto_MNIgrouptemplate_job.m'), inputs{:});
    
    
    end
    
end



%% Smooth c*jd and c*dv
if jobstorun.smooth == 1
prefixes = {'wc1jd','wc1dv','wc2jd','wc2dv' };

for n = 4%:size(prefixes,2)
    
    files = cell(38,1);
    
    for i = 1:size(input.subjectdir,1)
        
        file = SAdir(input.subjectdir{i}, ['^' prefixes{n} '_.*nii$'] );
        files{i,1} = [input.subjectdir{i} filesep file.name];
        
    end
    
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run',  fullfile( jobspath, 'SPM12_Smooth_6mm_job.m'), files);
    

end
end











%% Notes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 1)      Rough alignment � the toolbox is very robust, but it occasionally fails. Sometimes this can be due to initial alignment and you can always straighten up images and orient to AC-PC to give it a helping hand. 
% 2)      Run longitudinal toolbox. Outputs a mean image and two images which are estimates of longitudinal change called �dv_*� and �jd_*� (in mean image space; the difference between the two is explained in the help section of the GUI but is minimal)
% 3)      Segment the mean image
% 4)      Optional (Howie can discuss this with you)� multiply the longitudinal image by the Grey matter segment.
% 5)      Estimate inter-subject registration of mean images � if you use DARTEL, I would suggest using a pre-existing template. Jen Y has a good one, and I have one. There are a number of discussion points around DARTEL vs. not-DARTEL, who comprises the template, etc but that is for another day perhaps.
% 6)      Transform longitudinal images to group/MNI space.
% 7)      Smooth (6mm).
% 8)      Stats 

% 1.) Run the SPM12b pairwise longitudinal registration to generate the
% > subject average and Jacobian difference (jd)
% >
% >  2.) Segment the subject average, generating c1, rc1, rc2
% >
% >  3.) Use ImCalc to compute c1.*jd (possibly dividing the result by the time
% > difference to give the rate of atrophy)
% >
% >  4.) Run DARTEL, aligning the rc1 and rc2 images from all subjects together
% >
% >  5.) Normalise and smooth the c1.*jd images
% >
% >  6.) Run stats.

%% OLD Run DARTEL Normalise to MNI with Zero Smoothing and no modulation (all subjects at once)
% %  OLD VERSION THAT DIDNT USE DIR  to get file names (deprecated 11/7/13)
% % prefixes = {'u_rc1avg','avg','mavg','c1avg','c2avg'};
% % inputs = cell(size(prefixes,2)+1,1);
% % inputs{1, 1} = {fullfile(SAreturnDriveMap('R'),'users','sattygalle','Matlab','longitudinal','Template_binney','Template_6.nii')};% Group-specific DARTEL template
% %     
% % %build input file of average file: %% use DIR instead of assuming names 
% %         %change to suffix to .nii:
% %         inputseg = cellfun(@(x) strrep(x, 'img', 'nii'), input.t1, 'UniformOutput', false);
% %         %find last backslash for all images:
% %         idx = regexp(inputseg,filesep);
% %       
% % for n = 1:size(prefixes,2)
% %         %insert prefix into image name.
% %             files = cell(size(inputseg,1),1);
% %             for i = 1:size(inputseg,1)
% %                 files{i,1}=  [inputseg{i}(1:idx{i}(end)) prefixes{n} '_' inputseg{i}(idx{i}(end)+1:end)];
% %             end       
% %             inputs{n+1,1} = files;
% % end
% % 
% % spm('defaults', 'PET');
% % spm_jobman('initcfg');
% % spm_jobman('run', fullfile( jobspath, 'SPM12_applydeformations_to_MNI_job.m'), inputs{:});


