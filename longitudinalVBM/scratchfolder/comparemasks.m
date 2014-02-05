%% generate binary masks at various thresholds for each subject

%paths
%R:\groups\rosen\longitudinalVBM\3T_byPIDN_ACTIVE
%R:\groups\rosen\longitudinalVBM\15T_byPIDN_ACTIVE

%path = 'R:\groups\rosen\longitudinalVBM\3T_byPIDN_ACTIVE';
paths ={  'R:\groups\rosen\longitudinalVBM\3T_byPIDN_ACTIVE', 'R:\groups\rosen\longitudinalVBM\15T_byPIDN_ACTIVE' };
jobspath = ('C:\Users\SAttygalle\Documents\GitHub\imaging-core\longitudinalVBM\jobs');
%d = SAdir(path,'\d');

LSDPIDNS = [
    10114
    10880
    14213
    14427
    2275
    2711
    5042
    5830
    6110
    11735
    11965
    12555
    13512
    588
    1004
    1176
    1319
    1340
    1463
    2500
    3521
    4160
    4375
    4379
    4471
    5468
    ];


%% Count # voxels at different thresholds

thresholds = [ 0 0.1 0.3 0.6 0.9 1 ] ;
for p =1 :size(paths,2)
    path = paths{p};
    d = SAdir(path,'\d');
    d(i).name

    for i = 1:size(d,1)
        if ismember(str2num(d(i).name ), LSDPIDNS)
        %get binarized c1 images
        clear numvoxelsinmask
        for t=1:6 %loop through different thresholds
            f = SAdir(fullfile(path, d(i).name), ['_binarized_' num2str(thresholds(t)) '.nii' ]) ; 
            spmheader= spm_vol(fullfile(path, d(i).name, f.name));
            loadednii = spm_read_vols(spmheader);
            numvoxelsinmask(t) = numel(find(loadednii==1));
                       
            
        end
        
        allsubsvoxelnums(d,1:6)=numvoxelsinmask;
        end
    end
    
end

%% plot histogram of c1 image 

for p = 1 :size(paths,2)
    path = paths{p};
    d = SAdir(path,'\d');
    %d(i).name

    for i = 1:size(d,1)
       %d(i).name
        if ismember(str2num(d(i).name ), LSDPIDNS)
      
        %get binarized c1 images
        f=SAdir(fullfile(path,d(i).name), '^c1avg\w*time1.nii');
          spmheader= spm_vol(fullfile(path, d(i).name, f.name));
            loadednii = spm_read_vols(spmheader);
            fig = figure();
            hist(loadednii(loadednii>0), 0:.05:1)
        title(['Number of voxels with WM probablity >0 for PIDN:'  d(i).name]) ;
        print(fig, '-dpdf', fullfile(fileparts(path), 'WMhistograms', [d(i).name '_WMover0_histogram.pdf']));

         end
    end
    
end




