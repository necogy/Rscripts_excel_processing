function  SAmultiply2Images(file1, file2, outfile )
%SAmultiply2Images - multiply two images
%more details
%
% Syntax: SAmultiply2Image(file1, file2, outfile )
%
% Inputs: 
%           file 1 - full path of first image
%           file 2 - full path of second image
%           outfile - name and full path of the output image with suffix 
%
% Outputs:
%    saves multiplied image in directory where file 1 was specified.
%
% Example: 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
%
% To Do:
%
% Author: Suneth Attygalle
% Created 11/4/13
% 
% Revisions:

inputs = cell(3,1);
inputs{1, 1} = {file1, file2};% c1 dv
inputs{2, 1} = [outfile] ; % output filename c1dv
inputs{3, 1} = 'i1.*i2';

spm('defaults', 'PET');
spm_jobman('initcfg');
jobspath =fullfile(SAreturnDriveMap('R'),'users','sattygalle','Matlab','longitudinal','jobs');

spm_jobman('run', fullfile( jobspath, 'SPM12_imcalc_job.m'), inputs{:});


end

