%script called by SA_config_run_group_SPM12LongRegPipe_generic.m to run
%longitudinal processing steps

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
        
        files = cell(size(input.subjectdir,1),1);
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

