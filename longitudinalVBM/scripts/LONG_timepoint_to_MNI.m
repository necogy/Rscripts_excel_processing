function scans_to_process = LONG_timepoint_to_MNI( scans_to_process, dartelpath)
%LONG_DARTEL_to_MNI - warp DARTEL to MNI 
%
% Syntax:  scans_to_process = LONG_DARTEL_to_MNI( scans_to_process)
%
% Inputs:   scans_to_process - array of objects of class LONG_participant
%           dartelpath - path to dartel template 
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do: 
%
% Author: Suneth Attygalle
% Created 03/10/2014
%
% Revisions:
%----------------------


spm('defaults', 'PET');
spm_jobman('initcfg');

matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.flowfield = '<UNDEFINED>';;% DARTEL flowfield from AVG u_rc
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.times = [1 0];
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.K = 6;
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.template ={fullfile(dartelpath , 'Template_6.nii')};
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.def = '<UNDEFINED>'; % Timepoint's deform field to AVG (Y) y_rc1
matlabbatch{1}.spm.util.defs.comp{1}.inv.space = '<UNDEFINED>'; % raw time point image
matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = '<UNDEFINED>'; % output image name
matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = '<UNDEFINED>'; % out put folder
matlabbatch{1}.spm.util.defs.out{2}.push.fnames = '<UNDEFINED>'; %images to apply to (c1, c2, c3 of timepoint)
matlabbatch{1}.spm.util.defs.out{2}.push.weight = '';
matlabbatch{1}.spm.util.defs.out{2}.push.savedir.savesrc = 1;
matlabbatch{1}.spm.util.defs.out{2}.push.fov.file = '<UNDEFINED>'; %image to base voxel dims (warped avg)
matlabbatch{1}.spm.util.defs.out{2}.push.preserve = 1;
matlabbatch{1}.spm.util.defs.out{2}.push.fwhm = [0 0 0];

spm_jobman('run',matlabbatch);

   
end   
   
  
\