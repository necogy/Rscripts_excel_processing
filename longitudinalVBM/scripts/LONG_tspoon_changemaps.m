function scans_to_process = LONG_tspoon_changemaps( scans_to_process)
%LONG_tspoon_changemaps - apply t-spoon smoothing to change maps
%
% Syntax:  scans_to_process = LONG_tspoon_changemaps( scans_to_process,scantype )
%
% Inputs:   scans_to_process - array of objects of class LONG_participant,
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:

% To Do: 
%
% Author: Suneth Attygalle
% Created 04/07/2014
%
% Revisions:

%binarize wc1avg and wc2avg at 0.5 + combine
prefixestobinarize = {'wc1avg_', 'wc2avg_'};
for subject = 1:size(scans_to_process,2)
  for prefix = 1:size(prefixestobinarize,2)
    inputfile = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, strcat(prefixestobinarize(prefix), scans_to_process(subject).Time1file));
    inputfile = strrep(inputfile, '.img', '.nii');
    outputfile = strrep(inputfile, 'wc', 'bm50wc');
    outputfile = strrep(outputfile, '.img', '.nii');
    spm('defaults', 'PET');
    spm_jobman('initcfg');

    matlabbatch{1}.spm.util.imcalc.input = cellstr(inputfile);
    matlabbatch{1}.spm.util.imcalc.output = char(outputfile);
    matlabbatch{1}.spm.util.imcalc.outdir = cellstr(fileparts(inputfile{:}));
    matlabbatch{1}.spm.util.imcalc.expression = 'i1>0.5';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype =16;
    spm_jobman('run',matlabbatch);  

  end
end

%mask change images by new combine images mask 
longprefixes = {'wl_c1avg_jd_','wl_c2avg_jd_' } ;
for subject = 1:size(scans_to_process,2)
    for prefix = 1:size(longprefixes,2)

        filename = strcat(longprefixes(prefix), scans_to_process(subject).Time1file(1:end-4) ,'_', scans_to_process(subject).Time2file);
        filename = strrep(filename, '.img', '.nii');
        
        input1 =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, filename);
        
        input2 = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, strcat('wc1avg_', scans_to_process(subject).Time1file));
        input2 = strrep(input2, '.img', '.nii');
        
        input2 = strrep(input2, 'wc', 'bm50wc');
        input3 = strrep(input2, 'wc1', 'wc2');
        input = {input1{:}, input2, input3};
        outfile = strrep(input1, 'wl_' , 'bmwl_');
        
        spm('defaults', 'PET');
        spm_jobman('initcfg');

        matlabbatch{1}.spm.util.imcalc.input = input;
        matlabbatch{1}.spm.util.imcalc.output = char(outfile);
        matlabbatch{1}.spm.util.imcalc.outdir = cellstr(fileparts(input2));
        matlabbatch{1}.spm.util.imcalc.expression = 'i1.*(i2+i3)';
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
        spm_jobman('run',matlabbatch);  
    end
end

%smooth combined masked image and smooth longitudinal image
longprefixes = {'wl_c1avg_jd_','wl_c2avg_jd_' } ;
for subject = 1:size(scans_to_process,2)
    fwhm = 6;
    LONG_smooth_images( scans_to_process,'bmwl_c1avg_jd', fwhm)
    LONG_smooth_images( scans_to_process,'bmwl_c2avg_jd', fwhm)
    LONG_smooth_images( scans_to_process,'wl_c1avg_jd', fwhm)
    LONG_smooth_images( scans_to_process,'wl_c2avg_jd', fwhm)
    
end

%dived smoothed image by smoothed mask 

tissuetype = {'c1avg_jd_', 'c2avg_jd_'};

    for subject = 1:size(scans_to_process,2)
        for tissueclass = 1:size(tissuetype,2)
            spm('defaults', 'PET');
            spm_jobman('initcfg');

            filename = strcat('s6wl_', tissuetype{tissueclass}, scans_to_process(subject).Time1file(1:end-4) ,'_', scans_to_process(subject).Time2file) ;  
            input1 =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, strrep(filename, '.img', '.nii'));

            input2 = strrep(input1, 's6wl', 's6bmwl');
            
            input = {input1, input2};
            outfile =  fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, strcat('T', strrep(filename, '.img', '.nii')));
            

            matlabbatch{1}.spm.util.imcalc.input = input;
            matlabbatch{1}.spm.util.imcalc.output = char(outfile);
            matlabbatch{1}.spm.util.imcalc.outdir = cellstr(fileparts(input2));
            matlabbatch{1}.spm.util.imcalc.expression = 'i1./i2';
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
            spm_jobman('run',matlabbatch);    
        end
    end
end

