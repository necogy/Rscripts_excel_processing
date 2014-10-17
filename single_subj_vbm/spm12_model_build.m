
function spm12_model_build(pathtosmwc1,controldir,resultsdir,agetxt,tivtxt)
spm('defaults', 'PET')
spm_jobman('initcfg'),
pathtosmwc1 = strcat(cellstr(pathtosmwc1),',1');
resultsdir=cellstr(resultsdir);
controls=dir(strcat(controldir,'/*nii'));
controls={controls.name};
controls=strcat(controldir,'/',controls);
controls=controls(:);

ages=csvread(agetxt);
tivs=csvread(tivtxt);

matlabbatch{1}.spm.stats.factorial_design.dir = resultsdir;
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = controls;
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = pathtosmwc1;
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = ages;
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'age';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 5;
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = tivs;
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'tiv';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 5;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tmr.rthresh = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
spm_jobman('run',matlabbatch)
end