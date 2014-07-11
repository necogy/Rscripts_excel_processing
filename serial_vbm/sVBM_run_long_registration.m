function scans_to_process = sVBM_run_long_registration(scans_to_process)
%sVBM_run_long_registration SPM12b serial longitudinal registration
%   Detailed explanation goes here
% Syntax:  scans_to_process = sVBM_run_long_registration( scans_to_process)
%
% Inputs: scans_to_process - array of objects of class sVBM_participant,
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
% Author: Suneth Attygalle
% Created 07/09/2014
%
% Revisions:

spm('defaults', 'PET');
spm_jobman('initcfg');

for subject = 1:size(scans_to_process,2) % for every subject
    for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
        
        file = scans_to_process(subject).Timepoint{timepoint}.File.name;
        fullpath =  scans_to_process(subject).Timepoint{timepoint}.Fullpath;
        
        volumes{timepoint} = fullfile(fullpath, file);
        times(timepoint) = scans_to_process(subject).Timepoint{timepoint}.Datenum;
        
    end
    
    %compute timedeltas
    timedeltas = (times-times(1))/365.25 ;
    
    disp(['Now running longitudinal Registration on: ' num2str(scans_to_process(subject).PIDN )])
    registersubject(volumes, timedeltas); % call subfunction to process that subject
    avgdirectory = fullfile(scans_to_process(subject).Fullpath, 'avg');
    mkdir(avgdirectory)
        
    avgfile = fullfile(scans_to_process(subject).Timepoint{1}.Fullpath, scans_to_process(subject).Timepoint{1}.File.name);
    avgfile=strrep(avgfile, '.img', '.nii');
    avgfile = SAinsertStr2Paths(avgfile, 'avg_');

    [status,message,~]=movefile(avgfile,avgdirectory) ;
    
   
    clear volumes
    clear times
    clear timedeltas
end

    function registersubject(volumes, timedeltas)
        clear matlabbatch
        matlabbatch{1}.spm.tools.longit{1}.series.vols = cellstr(volumes);
        matlabbatch{1}.spm.tools.longit{1}.series.times = timedeltas;
        matlabbatch{1}.spm.tools.longit{1}.series.noise = NaN;
        matlabbatch{1}.spm.tools.longit{1}.series.wparam = [0 0 100 25 100];
        matlabbatch{1}.spm.tools.longit{1}.series.bparam = 1000000;
        matlabbatch{1}.spm.tools.longit{1}.series.write_avg = 1;
        matlabbatch{1}.spm.tools.longit{1}.series.write_jac = 1;
        matlabbatch{1}.spm.tools.longit{1}.series.write_div = 1;
        matlabbatch{1}.spm.tools.longit{1}.series.write_def = 1;
        spm_jobman('run',matlabbatch);
    end






end

