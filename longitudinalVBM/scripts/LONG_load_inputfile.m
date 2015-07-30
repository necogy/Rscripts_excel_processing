function scans_to_process = LONG_load_inputfile( scandatafolder )
%LONG_load_inputfile - Set up patient dataset to input into longitudinal processing
% Creates an array of objects of the class LONG_participant,
% LONG_particpant will automatically populate 
%
% Syntax:  participants_to_process = LONG_load_inputfile( scandatafolder )
%
% Inputs: scandatafolder - folder that has all the PIDNs that you will
% process, each PIDN folder should only have two timepoints of data inside
% it as follows /14929/2015-01-01/MP-LAS.nii , /14929/2015-09-31/MP-LAS.nii
%    
% Outputs: scans_to_process - array of objects of class LONG_participant
%    
% Example:
%
% Other m-files required: none
% Subfunctions:
%   
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 2/12/14
%
% Revisions:

datapath = fullfile(scandatafolder);
d=SAdir(fullfile(datapath), '\d');

allparticipants =LONG_participant.empty(size(d,1),0);

for i = 1:size(d,1)
    allparticipants(i) = LONG_participant(d(i).name, datapath); % LONG_participant class will load data for each subject.
end

scans_to_process = allparticipants;
