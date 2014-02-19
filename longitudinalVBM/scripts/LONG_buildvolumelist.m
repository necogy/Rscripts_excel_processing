function volumepaths = LONG_buildvolumelist( scans_to_process, prefixes )
%LONG_buildvolumelist - Generate list of volume paths for longitudinal
%processing
%
% Syntax:  volumepaths = LONG_buildvolumelist( scans_to_process )
% Inputs: scans_to_process
% Outputs: volumepaths
%
% Other m-files required: SPM12b
% Subfunctions:
%
% MAT-files required: none
% See also:
% To Do:
%
% Author: Suneth Attygalle
% Created 02/18/2014
%
% Revisions:

a = {scans_to_process.Datapath};
b = {scans_to_process.PIDN};
c = {scans_to_process.Date1};
d = {scans_to_process.Time1file};
e = cellfun(@(x) strcat(prefixes, x) , cellstr(d), 'UniformOutput', false); % add prefix to file
  
volumepaths(:,1)=  fullfile(a,b,c,e);

c = {scans_to_process.Date2};
d = {scans_to_process.Time2file};
e = cellfun(@(x) strcat(prefixes, x) , cellstr(d), 'UniformOutput', false); % add prefix to file

volumepaths(:,2) = fullfile(a,b,c, e);
%volumepaths(:,3) = {scans_to_process.DeltaTime};


end