function scans_to_process = LONG_multiply_segments_with_change( scans_to_process)
%LONG_multiply_segments_with_change - multiple c1/c2 images with jd/dv
%images. Iterates through all the subjects in scans_to_process.
%
%
% Syntax:  participantstructure = LONG_multiply_segments_with_change(scans_to_process )
%
% Inputs: scans_to_process - array of objects of class LONG_participant,
%
% Outputs: scans_to_process - updated array with run status
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also: longitudinal registration should be run first to generate mean
% images
%
% To Do: rewrite this so it doesn't have to reopen spm each time it does a
% multiplication
%
% Author: Suneth Attygalle
% Created 03/04/2014
%
% Revisions:

prefixes = {'c1avg_', 'c2avg_'};
maptypes = {'jd_' ,'dv_'};

for subject = 1:size(scans_to_process,2)
    for p = 1:size(prefixes,2)
        for jdordv = 1:size(maptypes,2)
            
            segpath = LONG_buildvolumelist(scans_to_process(subject), prefixes{p});
            segvolume = strrep(segpath{1}, 'img', 'nii'); %avg filenames sometimes were img not nii
            
            date1path = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1);
            filestruct = SAdir( date1path, ['^' maptypes{jdordv}]) ;
            
            jdpath = fullfile(scans_to_process(subject).Fullpath, scans_to_process(subject).Date1, filestruct.name);
            outpath = SAinsertStr2Paths(jdpath, ['l_' prefixes{p}]);
            
            SAmultiply2Images(segvolume, jdpath, outpath)
        end
    end
    
end

end









