function scans_to_process = LONG_generatemeanmaps( scans_to_process, PIDNlist, groupname )
%LONG_generatemeanmaps - averge c1/c2*jd/dv and jd/dv images
%
% Syntax:  scans_to_process = LONG_generatemeanmaps( scans_to_process)
%
% Inputs: 
%   scans_to_process - array of objects of class LONG_participant,
%   PIDNs - PIDNs to include for specific grou
%   groupname - name of the group to title your output image
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:

% To Do: 
%
% Author: Suneth Attygalle
% Created 03/07/2014
%
% Revisions:


allPIDNs = {scans_to_process.PIDN};

% get indices of PIDNs to check against scans_to_process
  if ~isempty(PIDNlist)
        keep(subject) = ismember( str2double(allPIDNs{subject}) , PIDNlist)     ;
    else
        keep(subject) = 1;
    end
trimmed_scans = scans_to_process(keep);

%imageprefixes = {'wl_c1avg_jd','wl_c1avg_dv','wl_c2avg_jd','wl_c2avg_dv', 'wavg', 'wc1avg', 'wc2avg' };
imageprefixes = {'wl_c1avg_jd','wl_c2avg_jd','wavg', 'wc1avg', 'wc2avg' };

for imagetype = 1:size(imageprefixes,2 )

    for subject = 1:size(trimmed_scans,2)
        d=SAdir(fullfile(trimmed_scans(subject).Fullpath, trimmed_scans(subject).Date1), ['^' imageprefixes{imagetype} '.*nii']);

        inputfile{subject} =  fullfile(trimmed_scans(subject).Fullpath, trimmed_scans(subject).Date1, d.name) ;
    end
    
    mkdir(fullfile( fileparts(fileparts(trimmed_scans(1).Datapath )), 'group_averages'))
    
    outfile = fullfile( fileparts(fileparts(trimmed_scans(1).Datapath )), 'group_averages', [groupname '_average_' imageprefixes{imagetype} '.nii']) ;
    spm('defaults', 'PET');
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.util.imcalc.input = inputfile;
    matlabbatch{1}.spm.util.imcalc.output = outfile;
    matlabbatch{1}.spm.util.imcalc.outdir = {''};
    matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
    
    spm_jobman('run',matlabbatch);
end




% take average and save with groupname.


