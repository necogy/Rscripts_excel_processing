function scans_to_process = sVBM_warp_timepoint_to_MNI_via_long( scans_to_process, templatepath )
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
template = fullfile(templatepath, 'Template_6.nii'); % Template_6 file
spm('defaults', 'PET');
spm_jobman('initcfg');

modulation = 1;

for subject = 1:size(scans_to_process,2) % for every subject
    
    for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
        
        img = fullfile(scans_to_process(subject).Timepoint{timepoint}.Fullpath, scans_to_process(subject).Timepoint{timepoint}.File.name);
        basefile =strrep(scans_to_process(subject).Timepoint{timepoint}.File.name,'.img','.nii');
        
        %c1file = ['c1' basefile];
       % c2file = ['c2' basefile];
        
        %files = fullfile(scans_to_process(subject).Timepoint{timepoint}.Fullpath, {c1file, c2file});
        avgfilename =['u_rc1avg_' strrep(scans_to_process(subject).Timepoint{1}.File.name, 'img', 'nii')];
        
        u_rcfile = fullfile(scans_to_process(subject).Fullpath, 'avg', avgfilename);
        
        clear matlabbatch
        
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = cellstr(strrep(SAinsertStr2Paths(img, 'y_'), 'img', 'nii')); % timepoint to subj avg.
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield = cellstr(u_rcfile);% DARTEL flowfield from AVG u_rc
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template ={''};       
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{3}.inv.comp{1}.def =  {fullfile(templatepath,'y_Template_6_2mni.nii')};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{3}.inv.space = cellstr(img); % raw time point image
        matlabbatch{1}.spm.util.defs.comp{1}.inv.space =cellstr(img);
        matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'toAVGtoMNI_InvForPush'; % output image name
        matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = cellstr(scans_to_process(subject).Timepoint{timepoint}.Fullpath) ; % out put folder
        matlabbatch{1}.spm.util.defs.out{2}.push.fnames = cellstr(img);
        matlabbatch{1}.spm.util.defs.out{2}.push.weight = '';
        matlabbatch{1}.spm.util.defs.out{2}.push.savedir.savesrc = 1;
        matlabbatch{1}.spm.util.defs.out{2}.push.fov.file = cellstr(template);% cellstr(warpedavg); %image to base voxel dims (warped avg)
        matlabbatch{1}.spm.util.defs.out{2}.push.preserve = modulation;
        matlabbatch{1}.spm.util.defs.out{2}.push.fwhm = [3 3 3];
        
        disp(['Now Warping from DARTEL to MNI, PIDN : ' num2str(scans_to_process(subject).PIDN )])
        disp(['Timepoint: ' num2str(timepoint)])

        try
            spm_jobman('run',matlabbatch);
        end
    end
end





end

% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\staffaroni_paper\BothFieldStrengths\0065\2011-06-23\y_MP-LAS-ABN_ABN00248X1.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\staffaroni_paper\BothFieldStrengths\0065\avg\u_rc1avg_MP-LAS-ABN_ABN00248X1.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template = {''};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{3}.inv.comp{1}.def = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\staffaroni_paper\dartel_template_3t15t_n193\y_Template_6_2mni.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{3}.inv.space = {'R:\groups\imaging_core\software\spm12\toolbox\DARTEL\icbm152.nii'};
% matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\staffaroni_paper\BothFieldStrengths\0065\2011-06-23\MP-LAS-ABN_ABN00248X1.img'};
% matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'toAVGtoMNI_InvForPush';
% matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.savepwd = 1;
% matlabbatch{1}.spm.util.defs.out{2}.push.fnames = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\staffaroni_paper\BothFieldStrengths\0065\2011-06-23\MP-LAS-ABN_ABN00248X1.img'};
% matlabbatch{1}.spm.util.defs.out{2}.push.weight = '';
% matlabbatch{1}.spm.util.defs.out{2}.push.savedir.saveusr = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\staffaroni_paper'};
% matlabbatch{1}.spm.util.defs.out{2}.push.fov.file = {'R:\groups\rosen\longitudinalVBM\SD_floor_project\staffaroni_paper\dartel_template_3t15t_n193\Template_6.nii'};
% matlabbatch{1}.spm.util.defs.out{2}.push.preserve = 1;
% matlabbatch{1}.spm.util.defs.out{2}.push.fwhm = [0 0 0];