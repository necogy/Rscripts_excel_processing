function scans_to_process = lzDTI_coregisterFAtoT1( scans_to_process )
%lzDTI_coregisterFAtoT1- coreg FA to T1
% Creates an array of objects of the class lzDTI_participant
%
% Syntax:  participants_to_process = lzDTI_coregisterFAtoT1(scans_to_process )
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
    for iTimepoint= 1:size(scans_to_process(sub).Timepoint,2)
        
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {scans_to_process(sub).Timepoint{iTimepoint}.Image_T1.path}; %T1 image
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = {scans_to_process(sub).Timepoint{iTimepoint}.Image_FA.path}; %FA image
        matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'rT1';
        
       
        
        
        
        spm_jobman('run',matlabbatch);
        clear matlabbatch
    end
    
end