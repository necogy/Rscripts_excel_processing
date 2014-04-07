function scans_to_process = LONG_smooth_images( scans_to_process,prefix, fwhm)
%LONG_smooth_imagese - smooth change images before stats
%
% Syntax:  scans_to_process = LONG_smooth_changemaps( scans_to_process)
%
% Inputs:   scans_to_process - array of objects of class LONG_participant
%           prefix - prefix for file 
%           fwhm - full width half maximum setting for smoothing 
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
% Created 03/20/14
%
% Revisions:
allsubs =[];
for sub = 1:size(scans_to_process,2)
        
      subdirectory = fullfile(scans_to_process(sub).Datapath, scans_to_process(sub).PIDN, scans_to_process(sub).Date1);
      %file = SAdir(subdirectory, '^l_' );
      file = SAdir(subdirectory, ['^' prefix '_'] );
      
      for files = 1:size(file,1)
      filestosmooth{files,1} = fullfile(subdirectory, file(files).name);
           
      end
    
      allsubs = [allsubs; filestosmooth];
end

spm('defaults', 'PET');
spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.smooth.data = cellstr(allsubs);
matlabbatch{1}.spm.spatial.smooth.fwhm = [fwhm fwhm fwhm];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = ['s' num2str(fwhm)];

spm_jobman('run',matlabbatch);

end