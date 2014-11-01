function scans_to_process = lzDTI_calculate_averageT1inFAavgSpaceForDARTEL( scans_to_process )
%lzDTI_calculate_averageT1inFAavgSpaceForDARTEL- mean of warped T1s
% Creates an array of objects of the class lzDTI_participant
%
% Syntax:  participants_to_process = lzDTI_calculate_averageT1inFAavgSpaceForDARTEL(scans_to_process )
%
% Inputs:
%
% Outputs: scans_to_process - array of objects of class lzDTI_participant
%
% Example:
%
% Other m-files required: spm12
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 10/30/14
%
% Revisions:
spm('defaults', 'PET');
spm_jobman('initcfg');

for sub = 1:size(scans_to_process,2)
    
    time1T1 =  SAinsertStr2Paths( scans_to_process(sub).Timepoint{1}.Image_T1.path, 'w');
    time2T1 = SAinsertStr2Paths( scans_to_process(sub).Timepoint{2}.Image_T1.path, 'w');
    outputpath = fileparts(scans_to_process(sub).Timepoint{1}.Image_T1.path);
    matlabbatch{1}.spm.util.imcalc.input = {time1T1 time2T1};
    matlabbatch{1}.spm.util.imcalc.output = {'wT1avgInFAavgSpace'} ;
    matlabbatch{1}.spm.util.imcalc.outdir = {outputpath};
    matlabbatch{1}.spm.util.imcalc.expression =  '(i1+i2)/2';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
    
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    
    
end