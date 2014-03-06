function scans_to_process = LONG_DARTEL_to_MNI( scans_to_process, dartelpath )
%LONG_DARTEL_to_MNI - warp DARTEL to MNI 
%
% Syntax:  scans_to_process = LONG_DARTEL_to_MNI( scans_to_process)
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:

% To Do: 
%
% Author: Suneth Attygalle
% Created 03/06/2014
%
% Revisions:




%look for template_6 file and set 
template = fullfile(dartelpath, 'Template_6.nii') % Template_6 file


for 
spm('defaults', 'PET');
spm_jobman('initcfg');
flowfield % u_rc1avg_8.nii file
matlabbatch{1}.spm.tools.dartel.mni_norm.template = template;
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = flowfield;
prefixes = {'avg','mavg','c1avg','c2avg','l_c1avg_jd','l_c1avg_jd','l_c2avg_jd','l_c2avg_jd' };





%images in dartel space to transform to MNI:
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images{1} 
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images{2}
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images{3}
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images{4}




matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];

spm_jobman('run',matlabbatch);

% 
%   warning('please make sure dartel normalize SPM job has correct number of fields')
%         
%     prefixes = {'u_rc1avg','avg','mavg','c1avg','c2avg', 'c1jd','c1dv','c2jd','c2dv' };
%    % prefixes = {'u_rc1avg','c1jd','c1dv','c2jd','c2dv' };
%     inputs = cell(size(prefixes,2)+1,1);
%     inputs{1, 1} = {fullfile(dartelpath, 'Template_6.nii')};% Group-specific DARTEL template
%     
%     %build input file of average file:
%     for n = 1:size(prefixes,2)
%         
%         files = cell(size(input.subjectdir,1),1);
%         for i = 1:size(input.subjectdir,1)
%             
%             file = SAdir(input.subjectdir{i}, ['^' prefixes{n} '_.*nii$'] );
%             files{i,1} = [input.subjectdir{i} filesep file.name];
%             
%         end
%         inputs{n+1,1}= files;
%     end
% 

% 
% 
% prefixes = {'c1avg_', 'c2avg_'};
% maptypes = {'jd_' ,'dv_'};
% 
% for subject = 1:size(scans_to_process,2)
%     for p = 1:size(prefixes,2)
%         for jdordv = 1:size(maptypes,2)
%             
%             segpath = LONG_buildvolumelist(scans_to_process(subject), prefixes{p});
%             segvolume = strrep(segpath{1}, 'img', 'nii'); %avg filenames sometimes were img not nii
%             
%             date1path = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1);
%             filestruct = SAdir( date1path, ['^' maptypes{jdordv}]) ;
%             
%             jdpath = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, filestruct.name);
%             outpath = SAinsertStr2Paths(jdpath, ['l_' prefixes{p}]);
%             
%             SAmultiply2Images(segvolume, jdpath, outpath)
%         end
%     end
%     
% end
% 
% end
% 








