function spm12_contrasts(spmmat)
spm('defaults', 'PET')
spm_jobman('initcfg')
spmmat = strcat(cellstr(spmmat));
matlabbatch{1}.spm.stats.con.spmmat = spmmat;
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Controls>Patient';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Controls<Patient';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 0;
spm_jobman('run',matlabbatch)
end