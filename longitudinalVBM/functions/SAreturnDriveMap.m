function drivemap = SAreturnDriveMap(driveletter)
%function drivemap =  SAreturnDriveMap(driveletter)
%FUNCTION_NAME - Give correct mount point for a MAC drive
%This is useful for scripts that might be run on the cloud or on your local
%windows machine
%
% Syntax:  drivemap = drive(driveletter)
%
% Inputs:  a string driveletter = 'R' for macdata, etc
%
% Outputs:
%    drivemap - will give a string based on the current operating system
%    that has the correct path to the mounted drive
%
% Example: 
%
% To Do:
%
% Author: Suneth Attygalle
% Created 10/24/13
% 
% Revisions:

drivenames={'images' , 'macdata' ,'macfiles'};
driveletters={'I:' , 'R:' ,'M:'};

for i = 1:size(drivenames,2)
   drives(i).name = drivenames{i};
   drives(i).letter = driveletters{i};
end

 driveind = strncmpi(driveletters, driveletter,1);
 driveind= find(driveind)   ;
 
if ispc
    drivemap = drives(driveind).letter;
elseif isunix
    drivemap = ['/mnt/' drives(driveind).name] ;
else

end

