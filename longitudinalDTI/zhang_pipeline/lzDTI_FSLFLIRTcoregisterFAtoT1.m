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

%  % segment T1 image into WM/GM
        % run hessian on FA image
        % Coregister hessianFA to WM/GM
  
        

        
for sub = 1:size(scans_to_process,2)
    
    for iTimepoint= 1:size(scans_to_process(sub).Timepoint,2)
        
        T1image = scans_to_process(sub).Timepoint{iTimepoint}.Image_T1.path; %T1 image
        FAimage = scans_to_process(sub).Timepoint{iTimepoint}.Image_FA.path; %FA image
        
        %segment T1image
        SA_SPM12_segment(T1image,'native');
        %Add c1 and c2 together
        formula = 'i1+i2';
        c1image;
        c2image;
        images = {c1image, c2image};
        SA_SPM12_imcalc(images, formula);
        
        %take hessian of FA image
        
        %run flirt to coregister hessian_FA to c1+c2 image
        
        [status,result]= runflirt(T1image, FAimage)
    end
    
end
end
function  [status,result]= runflirt(T1image, FAimage)

coregisteredFAimage= SAinsertStr2Paths(FAimage, 'flirt');
commandstring = ['flirt -searchcost normmi -dof 6 -in ' char(FAimage) ' -ref ' char(T1image) ' -out ' char(coregisteredFAimage)];
[status,result] = system(commandstring);
end
