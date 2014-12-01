function scans_to_process = sVBM_DARTEL_warp_to_MNI( scans_to_process, dartelpath , scantype)
%sVBM_DARTEL_warp_to_MNI - warp from DARTEL space to MNI
%
% Syntax:  scans_to_process = sVBM_DARTEL_warp_to_MNI( scans_to_process, dartelpath)
%
% Inputs: scans_to_process - array of objects of class sVBM_participant,
%           dartelpath - path to dartel template
%           scanype - 'average' or 'timepoint'
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required:
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 07/08/2014
% Revisions: 11/30/14 add scantype - SA


%look for template_6 file and set
template = fullfile(dartelpath, 'Template_6.nii'); % Template_6 file
spm('defaults', 'PET');
spm_jobman('initcfg');

switch scantype
    case 'timepoint'
        for subject = 1:size(scans_to_process,2) % for every subject
            
            for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
                
                basefile =strrep(scans_to_process(subject).Timepoint{timepoint}.File.name,'.img','.nii');
                
                c1file = ['c1' basefile];
                c2file = ['c2' basefile];
                c3file = ['c3' basefile];
                files = fullfile(scans_to_process(subject).Timepoint{timepoint}.Fullpath, {c1file, c2file,c3file});
                
                disp(['Now Warping from DARTEL to MNI, PIDN : ' num2str(scans_to_process(subject).PIDN )])
                disp(['Timepoint: ' num2str(timepoint)])
                
                warp_timepointtoMNI(files, template ) % call subfunction to process that subject
            end
        end
    case 'timepointdv'
        for subject = 1:size(scans_to_process,2) % for every subject
            
            for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
                
                basefile =strrep(scans_to_process(subject).Timepoint{timepoint}.File.name,'.img','.nii');
                
                c1file = ['c1avgdv_' basefile];
                c2file = ['c2avgdv_' basefile];
                
                files = fullfile(scans_to_process(subject).Timepoint{timepoint}.Fullpath, {c1file, c2file});
                avgfilename =['u_rc1avg_' strrep(scans_to_process(subject).Timepoint{1}.File.name, 'img', 'nii')];
                
                u_rcfile = fullfile(scans_to_process(subject).Fullpath, 'avg', avgfilename);
                disp(['Now Warping from DARTEL to MNI, PIDN : ' num2str(scans_to_process(subject).PIDN )])
                disp(['Timepoint: ' num2str(timepoint)])
                try
                    warp_timepointtoMNI(files,u_rcfile, template ) % call subfunction to process that subject
                end
            end
        end
end


    function warp_timepointtoMNI(files,u_rcfile, DARTEL_template_path )
        
        clear matlabbatch
        matlabbatch{1}.spm.tools.dartel.mni_norm.template = cellstr(DARTEL_template_path);
        
        flowfield = u_rcfile;
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.flowfield = cellstr(flowfield); % u_rc1
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.images = cellstr(files);
        matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
            NaN NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 1;
        matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];
        
        spm_jobman('run',matlabbatch);
    end

end
