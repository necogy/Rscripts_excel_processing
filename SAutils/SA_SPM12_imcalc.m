function SA_SPM12_imcalc(images, equation, outputfilename)
%SA_SPM12_imcalc - run SPM12 IMCALC
%
% Syntax: SA_SPM12_imcalc(images, equation)
%
% Inputs:
%           images - cell array of images
%           equation - imcalc equation (e.g. 'i1+i2')
%           outputfilename - name of output file
%
% Outputs:
%    saves ooutput image in same location as first image in equation
%
% Example:
%
% Other m-files required: SPM12
% Subfunctions: none
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created
%
% Revisions:

spm('defaults', 'PET');
spm_jobman('initcfg');

%get data type of first image. 
image1 = spm_vol(images{1});
dtype = image1.dt(1);

matlabbatch{1}.spm.util.imcalc.input = images;
matlabbatch{1}.spm.util.imcalc.output =fullfile(fileparts(images{1}), outputfilename);
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = equation;
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 4;
matlabbatch{1}.spm.util.imcalc.options.dtype = dtype;

spm_jobman('run',matlabbatch);

end

