function index = SA_FindStringInStructArray(f, fieldname, stringtofind)
%SA_arrayFind Find a match within a structure fieldname
%  Use this to find matches for a PIDN in a scans_to_process structure
% Suneth Attygalle 11/3/14

index = arrayfun(@(x)strcmp(x.(fieldname),stringtofind),f);
end

