function scans_to_process = sVBM_DARTEL_registration_to_existing(scans_to_process, DARTEL_template_path, scantype)
%sVBM_DARTEL_registration_to_existing SPM12b DARTEL register to template
%   Detailed explanation goes here
% Syntax:  scans_to_process = sVBM_DARTEL_registration_to_existing( scans_to_process, DARTEL_template_path)
%
% Inputs: scans_to_process - array of objects of class sVBM_participant,
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
% Author: Suneth Attygalle
% Created 07/07/2014
%
% Revisions:
spm('defaults', 'PET');
spm_jobman('initcfg');


switch scantype
    case 'timepoint'
        for subject = 1:size(scans_to_process,2) % for every subject
            
            for timepoint = 1%:size(scans_to_process(subject).Timepoint,2) % for every timepoint
                
                rc1file = fullfile( scans_to_process(subject).Timepoint{timepoint}.Fullpath, ['rc1' scans_to_process(subject).Timepoint{timepoint}.File.name]  ) ;
                rc1file = strrep(rc1file, 'img', 'nii');
                
                rc2file = fullfile( scans_to_process(subject).Timepoint{timepoint}.Fullpath, ['rc2' scans_to_process(subject).Timepoint{timepoint}.File.name]  ) ;
                rc2file = strrep(rc2file, 'img', 'nii');
                
                disp(['Now DARTEL Registering: ' num2str(scans_to_process(subject).PIDN )])
                disp(['Timepoint: ' num2str(timepoint)])
                
                dartelregistertimepoint(rc1file,rc2file, DARTEL_template_path) % call subfunction to process that subject
                
            end
        end
        
    case 'average'
        for subject = 1:size(scans_to_process,2) % for every subject
            
            rc1file = fullfile( scans_to_process(subject).Fullpath, 'avg', ['rc1avg_' scans_to_process(subject).Timepoint{1}.File.name]  ) ;
            rc1file = strrep(rc1file, 'img', 'nii');
            
            rc2file = strrep(rc1file, 'rc1avg_','rc2avg_');
            pathtofile = strrep(rc1file, 'rc1avg', 'u_rc1avg');
            if checkifexisting(pathtofile) == 0
                
                disp(['Now DARTEL Registering average file for PIDN: ' num2str(scans_to_process(subject).PIDN )])
                dartelregistertimepoint(rc1file,rc2file, DARTEL_template_path) % call subfunction to process that subject
            else
            end
        end
        
end

    function fileexists = checkifexisting(pathtofile)
        d= SAdir(fileparts(pathtofile), '^u_rc1');
        numfiles = size(d,1);
        
        if numfiles == 0
            fileexists = 0;
        elseif numfiles >1
            fileexists = 1;
        %elseif numfiles ~= 1
           % error(['More than one file found']);
            %fileexists  = 1;
            
        end
        
        
    end
    function dartelregistertimepoint(rc1,rc2, templatepath)
        
        clear matlabbatch
        matlabbatch{1}.spm.tools.dartel.warp1.images{1} = cellstr(rc1)   ;
        matlabbatch{1}.spm.tools.dartel.warp1.images{2} = cellstr(rc2)   ;
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

