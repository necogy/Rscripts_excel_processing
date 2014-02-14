function scans_to_process = LONG_load_inputfile( scandatafolder )
%FUNCTION_NAME - Set up patient dataset to input into longitudinal processing
% Creates an array of objects of the class LONG_participant
%
% Syntax:  participants_to_process = LONG_load_inputfile( scandatafolder )
%
% Inputs: scandatafolder - folder that has all the PIDNs that you will
% process, each PIDN folder should only have two timepoints of data inside
% it
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
scandatafolder = 'R:\groups\rosen\longitudinalVBM\testfolder';
datapath = fullfile(scandatafolder);

d=SAdir(fullfile(datapath), '\d');

clear allparticipants
clear ans
for i = 1:size(d,1)
    allparticipants(i) = LONG_participant(d(i).name, datapath);
end
allparticipants(1)
allparticipants(2)
