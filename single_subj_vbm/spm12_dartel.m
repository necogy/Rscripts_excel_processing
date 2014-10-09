
function spm12_dartel(pathtorc1,pathtorc2,singvbm)
spm('defaults', 'PET')
spm_jobman('initcfg'),
% spmpath = './spm12b/';
pathtorc1 = strcat(cellstr(pathtorc1),',1');
pathtorc2 = strcat(cellstr(pathtorc2),',1');

strcat(singvbm,'/dartel_tempalte/jon_dartel_template_ADFTLD_1.nii')

% matlabbatch{1}.spm.tools.dartel.warp1.images = {
%                                                 {'pathtorc1,1'}
%                                                 {'pathtorc2,1'}
%                                                 }';
matlabbatch{1}.spm.tools.dartel.warp1.images{1} = pathtorc1     ;                  
matlabbatch{1}.spm.tools.dartel.warp1.images{2} = pathtorc2    ;
matlabbatch{1}.spm.tools.dartel.warp1.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).template = {strcat(singvbm,'/dartel_template/jon_dartel_template_ADFTLD_1.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).template = {strcat(singvbm,'/dartel_template/jon_dartel_template_ADFTLD_2.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).template = {strcat(singvbm,'/dartel_template/jon_dartel_template_ADFTLD_3.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).template = {strcat(singvbm,'/dartel_template/jon_dartel_template_ADFTLD_4.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).template = {strcat(singvbm,'/dartel_template/jon_dartel_template_ADFTLD_5.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).template = {strcat(singvbm,'/dartel_template/jon_dartel_template_ADFTLD_5.nii')};
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.its = 3;
spm_jobman('run',matlabbatch);
end