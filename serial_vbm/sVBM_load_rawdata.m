function scans_to_process = sVBM_load_rawdata( scandatafolder )
%sVBM_load_rawdata - Set up patient dataset to input into longitudinal processing
% Creates an array of objects of the class sVBM_participant
%
% Syntax:  participants_to_process = sVBM_load_rawdata( scandatafolder )
%
% Inputs: scandatafolder - folder that has all the PIDNs that you will
% process, each PIDN folder should only have two timepoints of data inside
% it
%    
% Outputs: scans_to_process - array of objects of class sVBM_participant
%    
% Example:
%
% Other m-files required: sVBM_participant 
% Subfunctions:
%   
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 7/1/14
%
% Revisions:

datapath = fullfile(scandatafolder);
d = SAdir(fullfile(datapath), '\d');

if isempty(d)
    error('no folders found in raw data directory')
end

allparticipants =sVBM_participant.empty(size(d,1),0); % initialize array of participants

for i = 1:size(d,1)
    allparticipants(i) = sVBM_participant(d(i).name, datapath); % fill array with participants data
end

scans_to_process = allparticipants; 
end

