function spm12_results(spmmat)
spm('defaults', 'PET')
spm_jobman('initcfg')
spmmat = strcat(cellstr(spmmat));
matlabbatch{1}.spm.stats.results.spmmat = spmmat;
matlabbatch{1}.spm.stats.results.conspec(1).titlestr = '';
matlabbatch{1}.spm.stats.results.conspec(1).contrasts = 1;
matlabbatch{1}.spm.stats.results.conspec(1).threshdesc = 'none';
matlabbatch{1}.spm.stats.results.conspec(1).thresh = 0.001;
matlabbatch{1}.spm.stats.results.conspec(1).extent = 0;
matlabbatch{1}.spm.stats.results.conspec(1).mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
matlabbatch{1}.spm.stats.results.units = 1;
matlabbatch{1}.spm.stats.results.print = 'pdf';
matlabbatch{1}.spm.stats.results.write.nary.basename = 'nonbinary';
matlabbatch{2}.spm.stats.con.spmmat = spmmat;
% matlabbatch{2}.spm.stats.con.consess{1}.tcon.name = 'SING<CON';
% matlabbatch{2}.spm.stats.con.consess{1}.tcon.weights = [-1 1];
% matlabbatch{2}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
% matlabbatch{2}.spm.stats.con.consess{2}.tcon.name = 'SING>CON';
% matlabbatch{2}.spm.stats.con.consess{2}.tcon.weights = [1 -1];
% matlabbatch{2}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{2}.spm.stats.con.delete = 0;
spm_jobman('run',matlabbatch)
end