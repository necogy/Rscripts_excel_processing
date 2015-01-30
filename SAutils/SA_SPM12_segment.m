function SA_SPM12_segment(volumestosegment, mode)
%SA_SPM12_segment- unified segmentation using SPM12
%
% Syntax: SA_SPM12_segment(volumestosegment, mode)
%
% Inputs:
%
% Outputs:
%
% Example:
%
% Other m-files required: SPM12
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 11/24/14
%
% Revisions:
        o.dartelimport = 0;
        o.native = 0  ;
        o.warped = 0;
        o.all = 0;
        o.modulated=0;
        o.deformation = 0;
switch mode
    case 'dartel' % dartel import
        o.dartelimport = 1;
    case 'native' % native images
        o.native = 1;
    case 'warped'
        o.warped = 1;
        o.deformation = 1;
    case 'modulated'
        o.modulated=1;
        o.deformation = 1;
    case 'all'
        o.all = 1;
        o.deformation = 1;
        o.dartelimport = 1;
        o.native = 1;
        o.warped = 1;
        o.modulated=1;
        
    case 'batch'
    otherwise
        o.dartelimport = 1;
        o.native = 1  ;
        o.warped = 0;
        o.all = 0;
        o.modulated=0;
        o.deformation = 0;
end

spmpath = fileparts(which('spm'));

spm('defaults', 'PET');
spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.preproc.channel.vols = {volumestosegment}; 
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spmpath,'tpm','TPM.nii,1')};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [o.native o.dartelimport];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [o.modulated o.warped];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spmpath,'tpm','TPM.nii,2')};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [o.native o.dartelimport];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [o.modulated o.warped];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spmpath,'tpm','TPM.nii,3')};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [o.native 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [o.modulated o.warped];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spmpath,'tpm','TPM.nii,4')};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [o.all 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spmpath,'tpm','TPM.nii,5')};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [o.all 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spmpath,'tpm','TPM.nii,6')};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [o.all 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.025 0.1];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 o.deformation];

spm_jobman('run',matlabbatch);
