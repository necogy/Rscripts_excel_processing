function scans_to_process = longDTI_coregistertoTPM(scans_to_process)
%longDTI_coregistertoTPM SPM coregistration to TPM (FA template in TPM
%space)
%   Detailed explanation goes here
% Syntax:  scans_to_process =longDTI_coregistertoTPM( scans_to_process)
%
% Inputs: scans_to_process - array of objects of class longDTI_participant,
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
% MAT-files required: none
%
% See also:
%
% To Do: build volume list to use for registration
%
% Author: Gabe Marx
% Created 08/03/2015
%
% Revisions:
spm_path=which('spm');
if ~strcmp(spm_path,'/mnt/macdata/groups/imaging_core/dti/spm12/spm.m')
    error('USING WRONG SPM PATH. REMOVE CURRENT SPM PATH AND SET NEW SPM PATH TO: /mnt/macdata/groups/imaging_core/dti/spm12/')
end

spm('defaults', 'PET');
spm_jobman('initcfg');

for subject = 1:size(scans_to_process,2) % for every subject
%     clear volumes
%     clear times
%     clear file
%     clear fullpath
%     clear timedeltas
%     clear avgdirectory
%     clear d
    
    for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
        
        file = scans_to_process(subject).Timepoint{timepoint}.File.name;
        fullpath =  scans_to_process(subject).Timepoint{timepoint}.Fullpath;
        
        img = fullfile(fullpath, file);
        
    
    % check for existing coregistered files
    if ~exist(SAinsertStr2Paths(img,'r'))
        try
            registerFA_to_TPM(img); % call subfunction to process that subject
        catch
            disp(['problem registering: ' num2str(scans_to_process(subject).PIDN ) ' TP ' num2str(timepoint)])
        end
    else
        disp(['skipping because registered file already exist for : ' num2str(scans_to_process(subject).PIDN ) ' TP ' num2str(timepoint)])
    end
    
end

end
end

function registerFA_to_TPM(img)
clear matlabbatch
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {'/mnt/macdata/groups/imaging_core/dti/rFMRIB58_FA_1mm.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {img};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);
end








