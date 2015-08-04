function scans_to_process = longDTI_DARTEL_create_warp_to_template(scans_to_process, DARTEL_template_path)
%longDTI_DARTEL_create_warp_to_template SPM12b DARTEL register to template
%   Detailed explanation goes here
% Syntax:  scans_to_process = longDTI_DARTEL_create_warp_to_template( scans_to_process, DARTEL_template_path)
%
% Inputs: scans_to_process - array of objects of class longDTI_participant,
%         DARTEL_template_path - path to the desired DARTEL tempalte
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
spm('defaults', 'PET');
spm_jobman('initcfg');



for subject = 1:size(scans_to_process,2) % for every subject

    avg_img = fullfile( scans_to_process(subject).Fullpath, 'avg', ['avg_r' scans_to_process(subject).Timepoint{1}.File.name]  ) ;

    prev_warpfile = strrep(avg_img, 'avg_r', 'u_avg_r');
    if ~exist(prev)warpfile,'file')
        disp(['Now DARTEL Registering average file for PIDN: ' num2str(scans_to_process(subject).PIDN )])
        dartelregistertimepoint(avg_img, DARTEL_template_path) % call subfunction to process that subject
    else
        
    end
end
        


    function dartelregistertimepoint(avg_img, templatepath)
        
        clear matlabbatch
        matlabbatch{1}.spm.tools.dartel.warp1.images{1} = cellstr(avg_img)     ;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.rform = 0;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).its = 3;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).K = 0;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).template = {fullfile(templatepath, 'Template_1.nii')};
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).its = 3;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).K = 0;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).template = {fullfile(templatepath, 'Template_2.nii')};
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).its = 3;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).K = 1;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).template = {fullfile(templatepath, 'Template_3.nii')};
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).its = 3;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).K = 2;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).template = {fullfile(templatepath, 'Template_4.nii')};
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).its = 3;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).K = 4;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).template = {fullfile(templatepath, 'Template_5.nii')};
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).its = 3;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).K = 6;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).template = {fullfile(templatepath, 'Template_6.nii')};
        matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
        matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.its = 3;
        
        spm_jobman('run',matlabbatch);
    end


end

