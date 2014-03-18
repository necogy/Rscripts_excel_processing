function [participants, datapath] = SA_load_participant_info_longreg(listname)
%FUNCTION_NAME - Set up patient dataset to input into longitudinal processing
%more details
%
% Syntax:  participantstructure = SA_load_participant_info_longreg(listname)
%
% Inputs:
%    listname - a string that specifies which part of this function to use
%    to generate participant structure
% Outputs:
%    participantstructure - Description
%    datapath - path to data
%
% Example:
%
% Other m-files required: none
% Subfunctions:
%   participants = getFoldersAndDates(datapath) %gets folder name and dates from folder names
% MAT-files required: none
%
% See also:
%
% To Do:
% Populate this from a query/file/input instead
%
% Author: Suneth Attygalle
% Created 10/24/13
%
% Revisions:
% 11/18/13 SA: added datapath output
% 11/21/13 SA: added getFoldersAndDates subfunction

if strcmp(listname, 'Nov2013_NIFDcontrols')
    datapath= fullfile(SAreturnDriveMap('R'),'groups','rosen','gene_carrier_imaging_all','VBM','NIFD_controls','images_dir');
    participants = getFoldersAndDates(datapath);
end


end % end main function

function participants = getFoldersAndDates(datapath)
d = SAdir(datapath,'^[0-9]'); %get PIDN folders
d([d.isdir]==0) = []; %remove nondirectories
% go through each PIDN folder
participants(size(d,1)).PIDN = ''; %initialize structure
for p = 1:size(d, 1)
    participants(p).PIDN = d(p).name; %PIDN
    subd= SAdir( fullfile(datapath, d(p).name),'[0-9]{4}-[0-9]{2}-[0-9]{2}'); %enter date folder
    
    for s = 1:size(subd,1)
        participants(p).MRIdate{s} = subd(s).name; % get date
        participants(p).MRIdatenum{s} = datenum(participants(p).MRIdate{s}); %save datenum as well
    end
    
end
end % end subfunction