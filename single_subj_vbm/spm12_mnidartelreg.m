
function spm12_mnidartelreg(pathtoc1,pathtou,singvbm)
spm('defaults', 'PET')
spm_jobman('initcfg'),
% spmpath = './spm12b/';

matlabbatch{1}.spm.tools.dartel.mni_norm.template = {strcat(singvbm,'/dartel_template/jon_dartel_template_ADFTLD_6.nii')};
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = cellstr(pathtou);
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images{1} = cellstr(pathtoc1);
matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 1;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [8 8 8];

spm_jobman('run',matlabbatch);
end