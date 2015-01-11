function scans_to_process = lzDTI_FSLFLIRTcoregisterFAtoT1( scans_to_process )
%lzDTI_FSLFLIRTcoregisterFAtoT1- coreg FA to T1 using FSL flirt
% Creates an array of objects of the class lzDTI_participant
%
% Syntax:  participants_to_process = lzDTI_FSLFLIRTcoregisterFAtoT1(scans_to_process )
%
% Inputs:
%
% Outputs: scans_to_process - array of objects of class lzDTI_participant
%
% Example:
%
% Other m-files required: FSL, SAinsertStr2Paths.m
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 11/7/14
%
% Revisions:

for sub = 1:size(scans_to_process,2)
    
    for iTimepoint= 1:size(scans_to_process(sub).Timepoint,2)
        
        T1image = scans_to_process(sub).Timepoint{iTimepoint}.Image_T1.path; %T1 image
        FAimage = scans_to_process(sub).Timepoint{iTimepoint}.Image_FA.path; %FA image
        
        %segment T1image
%        SA_SPM12_segment(T1image,'native');
        
        %Add c1 and c2 together
        formula = 'i1+i2';
        c1image = SAinsertStr2Paths(T1image, 'c1') ;
        c1image = strrep(c1image, '.img', '.nii');
        c2image = strrep(c1image, 'c1', 'c2');
        images = {c1image, c2image};
        [c1c2path, c1c2image, c1c2ext] = fileparts(c2image);
        
 %       SA_SPM12_imcalc(images, formula, ['c1' c1c2image '.nii'] );
        
        %take hessian of FA image
        matNI_DTI_hessian_cardan(FAimage, 2)
        
        %run flirt to coregister hessian_FA to c1+c2 image
        c1c2file = fullfile(c1c2path, ['c1' c1c2image c1c2ext]);
        hessFAimage=  SAinsertStr2Paths(FAimage, 'hess_2_');
        [status,result]= runflirt(c1c2file,hessFAimage);
        % gunzip coregisted FA
     %  gunzip([SAinsertStr2Paths(hessFAimage, 'flirt') '.gz']);
        
        %apply generated mat file to origina FA image

   omat = fullfile( fileparts(c1c2file), 'flirt_FAtoT1.mat' );

    applyflirt(FAimage, omat, c1c2file);
    gunzip([SAinsertStr2Paths(FAimage, 'flirted') '.gz'])
    end
    
end
end
function  [status,result]= runflirt(Template, Source)

coregisteredimage= SAinsertStr2Paths(Source, 'flirt');
coreg_mat = fullfile( fileparts(Template), 'flirt_FAtoT1.mat' );
commandstring = ['flirt -cost mutualinfo -dof 6 -nosearch -omat ' coreg_mat ' -in ' char(Source) ' -ref ' char(Template) ' -out ' char(coregisteredimage)];
[status,result] = system(commandstring);
end

function [status, result] = applyflirt(image, omat, template)


commandstring= ['flirt -ref ' template ' -in ' image ' -applyxfm -init ' omat ' -out ' SAinsertStr2Paths(image, 'flirted')] ;
[status,result] = system(commandstring);
end

