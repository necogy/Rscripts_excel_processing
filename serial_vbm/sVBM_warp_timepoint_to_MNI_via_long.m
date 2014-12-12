function scans_to_process = sVBM_warp_timepoint_to_MNI_via_long( scans_to_process, dartelpath )
%sVBM_warp_timepoint_to_MNI_via_long - warp from DARTEL space to MNI
%
% Syntax:  scans_to_process = sVBM_warp_timepoint_to_MNI_via_long( scans_to_process, dartelpath)
%
% Inputs: scans_to_process - array of objects of class sVBM_participant,
%           dartelpath - path to dartel template
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 12/9/14


%look for template_6 file and set
template = fullfile(dartelpath, 'Template_6.nii'); % Template_6 file
spm('defaults', 'PET');
spm_jobman('initcfg');

modulation = 1;

for subject = 1:size(scans_to_process,2) % for every subject
    
    for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
        
        basefile =strrep(scans_to_process(subject).Timepoint{timepoint}.File.name,'.img','.nii');
        
        c1file = ['c1' basefile];
        c2file = ['c2' basefile];
        
        files = fullfile(scans_to_process(subject).Timepoint{timepoint}.Fullpath, {c1file, c2file});
        avgfilename =['u_rc1avg_' strrep(scans_to_process(subject).Timepoint{1}.File.name, 'img', 'nii')];
        
        u_rcfile = fullfile(scans_to_process(subject).Fullpath, 'avg', avgfilename);
        
        clear matlabbatch
        
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.flowfield = cellstr(u_rcfile);% DARTEL flowfield from AVG u_rc
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.times = [1 0];
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.K = 6;
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.template =cellstr(template);
        
        timepttoavg = strrep(files{1}, 'c1','y_');
        
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.def = cellstr(timepttoavg); % Timepoint's deform field to AVG (Y)" y"
        matlabbatch{1}.spm.util.defs.comp{1}.inv.space = cellstr(fullfile(scans_to_process(subject).Timepoint{timepoint}.Fullpath, scans_to_process(subject).Timepoint{timepoint}.File.name)); % raw time point image
        matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'toAVGtoMNI_InvForPush'; % output image name
        matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = cellstr(scans_to_process(subject).Timepoint{timepoint}.Fullpath) ; % out put folder
        
        matlabbatch{1}.spm.util.defs.out{2}.push.fnames = files;
        matlabbatch{1}.spm.util.defs.out{2}.push.weight = '';
        matlabbatch{1}.spm.util.defs.out{2}.push.savedir.savesrc = 1;
        
        matlabbatch{1}.spm.util.defs.out{2}.push.fov.file = cellstr(template);% cellstr(warpedavg); %image to base voxel dims (warped avg)
        
        matlabbatch{1}.spm.util.defs.out{2}.push.preserve = modulation;
        matlabbatch{1}.spm.util.defs.out{2}.push.fwhm = [0 0 0];
        
        disp(['Now Warping from DARTEL to MNI, PIDN : ' num2str(scans_to_process(subject).PIDN )])
        disp(['Timepoint: ' num2str(timepoint)])

        try
            spm_jobman('run',matlabbatch);
        end
    end
end





end
