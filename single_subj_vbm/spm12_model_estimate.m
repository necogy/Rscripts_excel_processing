function spm12_model_estimate(spmmat)
spm('defaults', 'PET')
spm_jobman('initcfg'),
spmmat = strcat(cellstr(spmmat));
matlabbatch{1}.spm.stats.fmri_est.spmmat = spmmat;
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',matlabbatch)
end