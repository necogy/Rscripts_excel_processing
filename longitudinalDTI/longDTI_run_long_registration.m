function scans_to_process = longDTI_run_long_registration(scans_to_process)
%longDTI_run_long_registration SPM12b serial longitudinal registration
%   Detailed explanation goes here
% Syntax:  scans_to_process = longDTI_run_long_registration( scans_to_process)
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
    clear volumes
    clear times
    clear file
    clear fullpath
    clear timedeltas
    clear avgdirectory
    clear d
    
    for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
        
        file = scans_to_process(subject).Timepoint{timepoint}.File.name;
        fullpath =  scans_to_process(subject).Timepoint{timepoint}.Fullpath;
        
        volumes{timepoint} = SAinsertStr2Paths(fullfile(fullpath, file),'r');
        times(timepoint) = scans_to_process(subject).Timepoint{timepoint}.Datenum;
        
    end
    
    %compute timedeltas
    timedeltas = (times-times(1))/365.25 ;
    
    disp(['Now running longitudinal Registration on: ' num2str(scans_to_process(subject).PIDN ) ' at ' datestr(now)])

    
    avgdirectory = fullfile(scans_to_process(subject).Fullpath, 'avg');

    % check for existing avg files
    
    d = SAdir(scans_to_process(subject).Timepoint{1}.Fullpath, '^avg_*');
    d_avg = SAdir(avgdirectory,  '^avg_*');
    if size(d,1)<1 || size(d_avg,1)<1
        try
            registersubject(volumes, timedeltas); % call subfunction to process that subject
             mkdir(avgdirectory)
             avgfile = fullfile(scans_to_process(subject).Timepoint{1}.Fullpath, scans_to_process(subject).Timepoint{1}.File.name);
             avgfile = SAinsertStr2Paths(avgfile, 'avg_r');
             [status,message,~]=movefile(avgfile,avgdirectory);
        catch
            disp(['problem registering: ' num2str(scans_to_process(subject).PIDN )])
        end
    else
        disp(['skipping because avg files already exist for : ' num2str(scans_to_process(subject).PIDN )])
        clear d;
    end
    
end

end

function registersubject(volumes, timedeltas)
clear matlabbatch
matlabbatch{1}.spm.tools.longit{1}.series.vols = cellstr(volumes);
matlabbatch{1}.spm.tools.longit{1}.series.times = timedeltas;
matlabbatch{1}.spm.tools.longit{1}.series.noise = NaN;
matlabbatch{1}.spm.tools.longit{1}.series.wparam = [0 0 100 25 100];
matlabbatch{1}.spm.tools.longit{1}.series.bparam = 1000000;
matlabbatch{1}.spm.tools.longit{1}.series.write_avg = 1;
matlabbatch{1}.spm.tools.longit{1}.series.write_jac = 0;
matlabbatch{1}.spm.tools.longit{1}.series.write_div = 0;
matlabbatch{1}.spm.tools.longit{1}.series.write_def = 1;
spm_jobman('run',matlabbatch);
end








