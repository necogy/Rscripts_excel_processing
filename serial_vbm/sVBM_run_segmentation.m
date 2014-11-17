function scans_to_process = sVBM_run_segmentation(scans_to_process, imagetype, reprocess)
%sVBM_run_segmentation - SPM12b Segmentation for serial Longitudinal processing
%
% Syntax:  participantstructure = LONG_run_segmentation(scans_to_process )
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
% scantype - string specifying whether to segment time1, time2 or mean image.
% spmpath - path to spm 12b installation
% reprocess - 1 or 0 to re-run existing calculations.
%
% Outputs: scans_to_process - updated array with run status
%
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12
% Subfunctions:
%
% MAT-files required: none
%
% See also: longitudinal registration should be run first to generate mean
% images
%
% To Do:
%
% Author: Suneth Attygalle
% Created 07/3/2014
%
% Revisions:
% 10/14/14 Suneth: Add segment volume calculations and reprocess flag

spm('defaults', 'PET');
spm_jobman('initcfg');
for subject = 1:size(scans_to_process,2) % for every subject
    
    switch imagetype
        case 'timepoints'
            for timepoint = 1:size(scans_to_process(subject).Timepoint,2) % for every timepoint
                
                file = scans_to_process(subject).Timepoint{timepoint}.File.name;
                fullpath =  scans_to_process(subject).Timepoint{timepoint}.Fullpath;
                
                volume = fullfile(fullpath, file);
                
                disp(['Now segmenting: ' num2str(scans_to_process(subject).PIDN )])
                disp(['Timepoint: ' num2str(timepoint)])
                
                %check for existing segmented volume, check for re-running.
                cvolumes = strrep(SAinsertStr2Paths(volume,'c*'),'img','nii');
                d=dir(cvolumes)     ;                        
                                      
                %volumes found but reprocess set to 1 or no volumes found
                if reprocess == 1 || size(d,1) ~= 3
                segmenttimepoint(volume) % call subfunction to process that subject
       
 
                else
                        disp('Skipping Timepoint because segmentation already found')
                end
           %extract volumes and add to scans_to_process structure 
           % this should be incorporated into the class or a seprate class
           % function
                segfile =  strrep(SAinsertStr2Paths(volume,'c1'),'img','nii');
                [scans_to_process(subject).Timepoint{timepoint}.GMvol, ~]=spm_summarise(segfile,'all','litres',1);
                segfile =  strrep(SAinsertStr2Paths(volume,'c2'),'img','nii');
                [scans_to_process(subject).Timepoint{timepoint}.WMvol, ~]=spm_summarise(segfile,'all','litres',1);
                segfile =  strrep(SAinsertStr2Paths(volume,'c3'),'img','nii');
                [scans_to_process(subject).Timepoint{timepoint}.CSFvol, ~]=spm_summarise(segfile,'all','litres',1);
                
                scans_to_process(subject).Timepoint{timepoint}.TIV = ...
                    scans_to_process(subject).Timepoint{timepoint}.GMvol ...
                    + scans_to_process(subject).Timepoint{timepoint}.WMvol ...
                    + scans_to_process(subject).Timepoint{timepoint}.CSFvol ;
            end
            
        case 'average'
            avgfile = fullfile(scans_to_process(subject).Fullpath,'avg', scans_to_process(subject).Timepoint{1}.File.name); 
            
            avgfile=strrep(avgfile, '.img', '.nii');
            avgfile = SAinsertStr2Paths(avgfile, 'avg_');
            volume = avgfile;
            
            disp(['Now segmenting average image for: ' num2str(scans_to_process(subject).PIDN )])
            
            segmenttimepoint(volume) % call subfunction to process that subject
    end
    
end

    function segmenttimepoint(volume)
        dartelimport = 1;
        writeforavgonly = 1; % for now just run this for all timepoints as well.
        spmpath = SA_getSPMpath(12);
        clear matlabbatch;
        
        matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(volume); % the avg images are only in the time 1 folders.
        matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spmpath,'tpm','TPM.nii,1')};
        matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 dartelimport];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spmpath,'tpm','TPM.nii,2')};
        matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 dartelimport];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spmpath,'tpm','TPM.nii,3')};
        matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spmpath,'tpm','TPM.nii,4')};
        matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spmpath,'tpm','TPM.nii,5')};
        matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spmpath,'tpm','TPM.nii,6')};
        matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        
        % Clean up, Smoothing and deformations;
        matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.025 0.1];
        matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.warp.write = [0 writeforavgonly];
        
        try
        spm_jobman('run',matlabbatch);
       
        catch
            disp(['problem segmenting' cellstr(volume)])
        end
    end

end

