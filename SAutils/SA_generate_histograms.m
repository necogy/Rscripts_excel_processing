function SA_generate_histograms(path, filepattern)
%SA_generate_histograms generate histograms for QC
%   Detailed explanation goes here
% Syntax:
%
% Inputs:
%
% Outputs:
%
% Other m-files required:
% Subfunctions:
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author:
% Created 06/16/2015
%
% Revisions:

%filepattern = 'Ow*c1*.nii';
filelist= getAllFiles(path, filepattern, 1) ;

for numfile = 1:size(filelist,1)
    nii =load_nii(filelist{numfile});
    image = nii.img;
    nonzeroimage = image(image~=0);
    f=figure;
    hist(nonzeroimage,100);
    
    %axis([-0.15 0.15 0 inf])
    
    [~, file, ~]= fileparts(filelist{numfile});
    print(f, fullfile(path,[file '_hist']), '-dpng');
    close(f)
end




