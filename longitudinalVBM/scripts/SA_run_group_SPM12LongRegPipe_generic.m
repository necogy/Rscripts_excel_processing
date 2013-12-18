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
    
    %build input file of average file, first selecting t1 images because
    %avg files use t1 in their filename
    inputfiles = cellfun(@(x) strrep(x, 'img', 'nii'), input.t1, 'UniformOutput', false);%change to suffix to .nii 
        
    %insert "avg_" into avg image name.
    stringtoinsert = 'avg_';
    avgfiles = SAinsertStr2Paths(inputfiles, stringtoinsert);
        
    %Run SPM12 segmentation
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    spm_jobman('run',  fullfile( jobspath, 'SPM12_segmentanddartelimport_job.m'), avgfiles);
end 


%% Run imcalc to create c1.*jd/dv and c2.*jd/dv images (looped by subject) (on average imges)
if jobstorun.multiplysegmentmaps == 1
      mapstring = {'dv','dv','jd','jd'};
      cstring = {'c1', 'c2','c1','c2'};
    
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
     inputfiles = cellfun(@(x) strrep(x, 'img', 'nii'), input.t1, 'UniformOutput', false);
            
        %insert "rc1/2avg_" into avg image name.
        stringtoinsert = 'rc1avg_';
        rc1files = SAinsertStr2Paths(inputfiles, stringtoinsert);
        
        stringtoinsert = 'rc2avg_';
        rc2files = SAinsertStr2Paths(inputfiles, stringtoinsert);
        
        
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
    inputs{1, 1} = {fullfile(dartelpath, 'Template_6.nii')};% Group-specific DARTEL template
    
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
if jobstorun.DARTELt1timepoint_to_MNI ==1 %tthis is only running on t1 right now
    for i = 1:size(input.t1,1) % for each subject
        % prefixes = {'u_rc1avg','y','','toAVGtoMNI_InvForPush','.','c1','c2','c3','wavg' };
        inputseg = input.t1{i};
        inputs = cell(7,1);
        inputs{3,1}= cellstr( inputseg); % Image to base inverse on for PUSH warp (raw timepoint image)
        inputseg = strrep(inputseg,'img','nii');%change to suffix to .nii:
             
        inputs{1,1}=  cellstr(SAinsertStr2Paths(inputseg, 'u_rc1avg_'));% DARTEL flowfield from AVG
        inputs{2,1}=  cellstr(SAinsertStr2Paths(inputseg, 'y_rc1avg_'));% Timepoint's deform field to AVG (Y)
        inputs{4,1}=  cellstr(SAinsertStr2Paths(inputseg, 'toAVGtoMNI_InvForPush_'));% output name for NEW deformation field
        inputs{5,1}=  cellstr(fileparts(inputseg));% output directory for deform field
        
        % Images to apply to: c1 and c2 and c3 of timepoint
        inputs{6,1} =  { SAinsertStr2Paths(inputseg, 'c1'), ...
            SAinsertStr2Paths(inputseg, 'c2'), ...
            SAinsertStr2Paths(inputseg, 'c3'), ...
            };
        
        inputs{7,1} = cellstr(SAinsertStr2Paths(inputseg, 'wavg_'));% defines voxel dims (warped avg for subject)

        %%%%%%%%%%%%%%%%s
        
        spm('defaults', 'PET');
        spm_jobman('initcfg');
        spm_jobman('run', fullfile( jobspath, 'SPM12_combdeform3_andwarpindivtimepntsegs_thruavg_thruto_MNIgrouptemplate_job.m'), inputs{:});
        
        
    end
    
end

%% Run DARTEL Normalise to MNI from original time point using combined deformation
if jobstorun.t2DARTELt1timepoint_to_MNI ==1 %tthis is only running on t1 right now
    for i = 1:size(input.t1,1) % for each subject
        % prefixes = {'u_rc1avg','y','','toAVGtoMNI_InvForPush','.','c1','c2','c3','wavg' };
        inputseg = input.t1{i};
        inputsegt2 = input.t2{i};
        inputs = cell(7,1);
       % inputs{3,1}= cellstr( inputseg); % Image to base inverse on for PUSH warp (raw timepoint image)
        inputseg = strrep(inputseg,'img','nii');%change to suffix to .nii:
        inputsegt2 = strrep(inputsegt2,'img','nii');
             
        inputs{1,1}=  cellstr(SAinsertStr2Paths(inputseg, 'u_rc1avg_'));% DARTEL flowfield from AVG
        inputs{2,1}=  cellstr(SAinsertStr2Paths(inputseg, 'y_rc1avg_'));% Timepoint's deform field to AVG (Y)
        inputs{4,1}=  cellstr(SAinsertStr2Paths(inputsegt2, 'toAVGtoMNI_InvForPush_'));% output name for NEW deformation field
        inputs{5,1}=  cellstr(fileparts(inputsegt2));% output directory for deform field
        
        % Images to apply to: c1 and c2 and c3 of timepoint
        inputs{6,1} =  { SAinsertStr2Paths(inputsegt2, 'c1'), ...
            SAinsertStr2Paths(inputsegt2, 'c2'), ...
            SAinsertStr2Paths(inputsegt2, 'c3'), ...
            };
        
        inputs{7,1} = cellstr(SAinsertStr2Paths(inputseg, 'wavg_'));% defines voxel dims (warped avg for subject)

        %%%%%%%%%%%%%%%%s
        
        spm('defaults', 'PET');
        spm_jobman('initcfg');
        spm_jobman('run', fullfile( jobspath, 'SPM12_combdeform3_andwarpindivtimepntsegs_thruavg_thruto_MNIgrouptemplate_job.m'), inputs{:});
        
        
    end
    
end


%% Smooth c*jd and c*dv
if jobstorun.smooth == 1
prefixes = {'wc1jd','wc1dv','wc2jd','wc2dv' };

for n = 1:size(prefixes,2)
    
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

