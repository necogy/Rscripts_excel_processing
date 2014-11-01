%-----------------------------------------------------------------------
% Job saved on 30-Oct-2014 20:25:13 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.imcalc.input = {
                                        '/mnt/macdata/groups/imaging_core/suneth/analyses/longDTI_bri/pidns/0065/2010-04-29/wMP-LAS_GHB243X1.img,1'
                                        '/mnt/macdata/groups/imaging_core/suneth/analyses/longDTI_bri/pidns/0065/2013-03-14/wMP-LAS_GHB243X2.nii,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'wT1_Avg';
matlabbatch{1}.spm.util.imcalc.outdir = {'/mnt/macdata/groups/imaging_core/suneth/analyses/longDTI_bri/pidns/0065'};
matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2)/2';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
