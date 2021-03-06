function sVBM_pushAVGtoICBMviaDARTEL(scans_to_process, templatepath, modulationON, smoothingFWHM)
%sVBM_pushAVGtoICBMviaDARTEL - warp longitudinal images from subject to DARTEL
%
% Syntax:  scans_to_process = sVBM_pushAVGtoICBMviaDARTEL( scans_to_process,templatepath)
%
% Inputs: scans_to_process - array of objects of class sVBM_participant,
%           templatepath - path to dartel template
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: SPM12
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 04/9/2015
% Revisions:

spm('defaults', 'PET');
spm_jobman('initcfg');
spmpath = fileparts(which('spm')); % add this to scans_to_process structure

imageprefixes = {'c1avgj_','c1avgdv_','c2avgj_','c2avgdv_' };

for subject = 1:size(scans_to_process,2) % for every subject
    
    flowfield =  fullfile( scans_to_process(subject).Fullpath, 'avg',  scans_to_process(subject).Timepoint{1}.File.name);
    flowfield =  SAinsertStr2Paths(strrep(flowfield, 'img', 'nii'), 'u_rc1avg_');
    
    for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
        
        %         matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.comp{1}.def  = {fullfile(templatepath, 'y_Template_6_2mni.nii')};
        %         matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.inv.space={fullfile(spmpath,'toolbox','DARTEL','icbm152.nii')};
        %         matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.flowfield = {flowfield} ;
        %         matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.times = [1 0];
        %         matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.K = 6;
        %         matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.dartel.template = {''};
        %         matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {fullfile(spmpath,'toolbox','DARTEL','icbm152.nii')};
        
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.flowfield = {flowfield} ;
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.times = [1 0];
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.K = 6;
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.dartel.template = {''};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.inv.comp{1}.def =  {fullfile(templatepath, 'y_Template_6_2mni.nii')};

        
        for image = 1:size(imageprefixes,2)
            imagetowarp = SAinsertStr2Paths( fullfile( scans_to_process(subject).Timepoint{timepoint}.Fullpath,  scans_to_process(subject).Timepoint{timepoint}.File.name), imageprefixes{image}) ;
            matlabbatch{1}.spm.util.defs.out{1}.push.fnames{image} = strrep(imagetowarp, 'img', 'nii');
        end
        
        
        matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{2}.inv.space = {strrep(imagetowarp, 'img', 'nii')};
        matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {strrep(imagetowarp, 'img', 'nii')};
        
        
        matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
        matlabbatch{1}.spm.util.defs.out{1}.push.savedir.savesrc = 1;
        matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {fullfile(spmpath,'toolbox','DARTEL','icbm152.nii')};
        matlabbatch{1}.spm.util.defs.out{1}.push.preserve = modulationON;
        matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [smoothingFWHM smoothingFWHM smoothingFWHM];
        spm_jobman('run',matlabbatch);
        clear matlabbatch
        clear imagetowarp
        
        
    end
    clear flowfield
end

%%%


