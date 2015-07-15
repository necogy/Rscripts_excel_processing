function c12icbm( c1, urc, t1, icbm, ydeform, outpath )
%UNTITLED2 Summary of this function goes here
%   c12icbm('${c1}','${uimage}','${t1image}','${template}','${ydeform}','${outpath}')

 matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.flowfield = {urc};
 matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.times = [1 0];
 matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.K = 6;%
 matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.template = {''};
 matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.inv.comp{1}.def = {ydeform};
 matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.inv.space = {icbm};
 matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {c1};
 matlabbatch{1}.spm.util.defs.out{1}.push.fnames = {c1};
 matlabbatch{1}.spm.util.defs.out{1}.push.weight = {};
 matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
 matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {icbm};
 matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 1;
 matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
 matlabbatch{1}.spm.util.defs.out{2}.savedef.ofname = 'PUSHdartelicbm';
 matlabbatch{1}.spm.util.defs.out{2}.savedef.savedir.saveusr = {outpath};

spm_jobman('run', matlabbatch)
end

