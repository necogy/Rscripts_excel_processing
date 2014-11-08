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
        
        [status,result]= runflirt(T1image, FAimage)
    end
    
end
end
function  [status,result]= runflirt(T1image, FAimage)

coregisteredFAimage= SAinsertStr2Paths(FAimage, 'flirt');
commandstring = ['flirt -searchcost normmi -dof 6 -in ' char(FAimage) ' -ref ' char(T1image) ' -out ' char(coregisteredFAimage)];
[status,result] = system(commandstring);
end
