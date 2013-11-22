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



if strcmp(listname, 'Oct2013_3T_onlyT1T2')
    datapath= fullfile(SAreturnDriveMap('R'),'groups','rosen','gene_carrier_imaging_all','VBM','sa_longitudinal', 'images','images_dir');
    
    
    participants = getFoldersAndDates(datapath);
end

if strcmp(listname, 'Oct2013_3T')
    datapath= fullfile(SAreturnDriveMap('R'),'groups','rosen','gene_carrier_imaging_all','VBM','sa_longitudinal', 'images','images_dir');
    
    
    participants = getFoldersAndDates(datapath);
    
end

if strcmp(listname,'casestudy1')
    datapath= fullfile(SAreturnDriveMap('R'),'groups','rosen','gene_carrier_imaging_all','VBM','familiarcases','images_dir');
    participants = getFoldersAndDates(datapath);
    % participants(1).PIDN = 14710;
    % participants(1).MRI = {'ADRC0047-1','NIFD094-1','NIFD094-2'};
    % participants(1).MRIdate = {'07/23/2012', '11/07/2012', '06/24/2013'};
    % participants(1).MRIdatenum= cellfun(@datenum, participants(1).MRIdate);
    
    % participants(2).PIDN = 12633;
    % participants(2).MRI = {'NIFD033-1','NIFD033-2'};
    % participants(2).MRIdate = {'05/03/2011', '11/30/2011'};
    % participants(2).MRIdatenum= cellfun(@datenum, participants(2).MRIdate);
    
    % participants(3).PIDN = 11442;
    % participants(3).MRI = {'NIFD003-1','NIFD003-2','NIFD003-3','NRS097-1' };
    % participants(3).MRIdate = {'09/14/2010', '03/10/2011','09/21/11','09/15/2010'};
    % participants(3).MRIdatenum= cellfun(@datenum, participants(3).MRIdate);
    
    % participants(4).PIDN = 10880;
    % participants(4).MRI = {'NIFD012-1','NIFD012-2','NIFD012-3','NIFD012-4','PPG0228-1'};
    % participants(4).MRIdate = {'11/02/2010', '07/15/2011','03/15/2012','03/15/2012', '10/16/2013' };
    % participants(4).MRIdatenum= cellfun(@datenum, participants(4).MRIdate);
    
    % participants(5).PIDN = 11028;
    % participants(5).MRI = {'NIC177-1','PPG0143-2'};
    % participants(5).MRIdate = {'09/07/10', '09/10/2013'};
    % participants(5).MRIdatenum= cellfun(@datenum, participants(5).MRIdate);
    
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