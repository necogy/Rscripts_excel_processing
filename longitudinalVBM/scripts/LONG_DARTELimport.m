function scans_to_process = LONG_DARTELimport( scans_to_process, voxelsize)
%LONG_run_segmentation - SPM12b Segmentation for Longitudinal processing
%
% Syntax:  participantstructure = LONG_run_segmentation(scans_to_process )
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
% string specifying whether to segment time1, time2 or mean image.
%
% Outputs: scans_to_process - updated array with run status
%
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also: longitudinal registration should be run first to generate mean
% images
%
% To Do:
%
% Author: Suneth Attygalle
% Created 02/21/2014
%
% Revisions:


prefixes ='avg_' ; % use c1 images to make sure segmentatoin occured.

volumepaths = LONG_buildvolumelist(scans_to_process, prefixes);
%volumes = strrep(volumepaths(:,1), 'img', 'nii'); %avg filenames sometimes were img not nii
seg_matfiles = strrep(volumepaths(:,1), '.nii', '_seg8.mat'); 

for i = 1:size(seg_matfiles,1)
outdir(i,1) = {fileparts(seg_matfiles{i}) };
end


spm('defaults', 'PET');
for n = 1:size(seg_matfiles,1)

spm_jobman('initcfg');
matlabbatch{1}.spm.tools.dartel.initial.matnames = {seg_matfiles{n}} ;
matlabbatch{1}.spm.tools.dartel.initial.odir = {outdir{n}};
matlabbatch{1}.spm.tools.dartel.initial.bb = [NaN NaN NaN
                                              NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.initial.vox = voxelsize; % default voxelsize was 1.5
matlabbatch{1}.spm.tools.dartel.initial.image = 0;
matlabbatch{1}.spm.tools.dartel.initial.GM = 1;
matlabbatch{1}.spm.tools.dartel.initial.WM = 1;
matlabbatch{1}.spm.tools.dartel.initial.CSF = 0;

spm_jobman('run',matlabbatch);



end

end
