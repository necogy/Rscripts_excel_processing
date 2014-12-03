function scans_to_process = sVBM_multiply_segments_with_change(scans_to_process)
%LONG_multiply_segments_with_change - multiple c1/c2 images with jd/dv
%images. Iterates through all the subjects in scans_to_process.
%
% Syntax:  scans_to_process = sVBM_multiply_segments_with_change(scans_to_process )
%
% Inputs: scans_to_process - array of objects of class sVBM_participant
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 11/21/2014
%
% Revisions:.

spm('defaults', 'PET');
spm_jobman('initcfg');

for subject = 1:size(scans_to_process,2)
    %get average file
    averagefile = fullfile(scans_to_process(subject).Fullpath, 'avg', ...
        ['avg_' scans_to_process(subject).Timepoint{1}.File.name ]);
    averagefile = strrep(averagefile, '.img', '.nii');
    
    for ntimepoint = 1:size(scans_to_process(subject).Timepoint,2)
        
        %get jacobian image
        timepointJ_image = fullfile(scans_to_process(subject).Timepoint{ ntimepoint}.Fullpath, ...
            ['dv_' scans_to_process(subject).Timepoint{ ntimepoint}.File.name ]);
        timepointJ_image = strrep(timepointJ_image, '.img', '.nii');
        
        segments = {'c1','c2'};
        
        for nseg = 1:size(segments,2)
            caveragefile = SAinsertStr2Paths(averagefile, segments{nseg});
            filestomultiply = {caveragefile, timepointJ_image};
            outputimage = SAinsertStr2Paths(  timepointJ_image, [segments{nseg} 'avg']);
            
            matlabbatch{1}.spm.util.imcalc.input = filestomultiply;
            matlabbatch{1}.spm.util.imcalc.output = outputimage;
            matlabbatch{1}.spm.util.imcalc.outdir = {''};
            matlabbatch{1}.spm.util.imcalc.expression = 'i1.*i2';
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
            try
                spm_jobman('run',matlabbatch);
            catch
            end
            
            clear matlabbatch
        end
        
    end
    
end

