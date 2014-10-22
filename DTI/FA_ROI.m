%imagesdir=directory with all co-registered FA images in MNI space
%sheetname=path to excel spreadsheet with three columns - 1. PIDN
%2.SourceID 3. FA file name (no path)
%roipath=directory with all binary ROI masks (in MNI space)



function mean_FA=FA_ROI(imagesdir, sheetname, roipath)
[num,txt,raw] = xlsread(sheetname);

[K,~] = size(raw);

K

numsubjs = K - 1;

numsubjs

numROI=48;

mean_FA = cell(numsubjs+1,numROI+2);

for i = 1:numsubjs
    mean_FA{i+1,1} = raw{i+1,1};
    mean_FA{i+1,2} = raw{i+1,2};
end

clear i

mean_FA{1,1} = 'PIDN';
mean_FA{1,2} = 'SCANID';
mean_FA{1,3} = 'Middle_cerebellar_peduncle';
mean_FA{1,4} = 'Pontine_crossing_tract';
mean_FA{1,5} = 'Genu_of_corpus_callosum';
mean_FA{1,6} = 'Body_of_corpus_callosum';
mean_FA{1,7} = 'Splenium_of_corpus_callosum';
mean_FA{1,8} = 'Fornix';
mean_FA{1,9} = 'Corticospinal_tract_R';
mean_FA{1,10} = 'Corticospinal_tract_L';
mean_FA{1,11} = 'Medial_lemniscus_R';
mean_FA{1,12} = 'Medial_lemniscus_L';
mean_FA{1,13} = 'Inferior_cerebellar_peduncle_R';
mean_FA{1,14} = 'Inferior_cerebellar_peduncle_L';
mean_FA{1,15} = 'Superior_cerebellar_peduncle_R';
mean_FA{1,16} = 'Superior_cerebellar_peduncle_L';
mean_FA{1,17} = 'Cerebral_peduncle_R';
mean_FA{1,18} = 'Cerebral_peduncle_L';
mean_FA{1,19} = 'Anterior_limb_of_internal_capsule_R';
mean_FA{1,20} = 'Anterior_limb_of_internal_capsule_L';
mean_FA{1,21} = 'Posterior_limb_of_internal_capsule_R';
mean_FA{1,22} = 'Posterior_limb_of_internal_capsule_L';
mean_FA{1,23} = 'Retrolenticular_part_of_internal_capsule_R';
mean_FA{1,24} = 'Retrolenticular_part_of_internal_capsule_L';
mean_FA{1,25} = 'Anterior_corona_radiata_R';
mean_FA{1,26} = 'Anterior_corona_radiata_L';
mean_FA{1,27} = 'Superior_corona_radiata_R';
mean_FA{1,28} = 'Superior_corona_radiata_L';
mean_FA{1,29} = 'Posterior_corona_radiata_R';
mean_FA{1,30} = 'Posterior_corona_radiata_L';
mean_FA{1,31} = 'Posterior_thalamic_radiation_R';
mean_FA{1,32} = 'Posterior_thalamic_radiation_L';
mean_FA{1,33} = 'Sagittal_stratum_R';
mean_FA{1,34} = 'Sagittal_stratum_L';
mean_FA{1,35} = 'External_capsule_R';
mean_FA{1,36} = 'External_capsule_L';
mean_FA{1,37} = 'Cingulum_cingulate_gyrus_R';
mean_FA{1,38} = 'Cingulum_cingulate_gyrus_L';
mean_FA{1,39} = 'Cingulum_hippocampus_R';
mean_FA{1,40} = 'Cingulum_hippocampus_L';
mean_FA{1,41} = 'Fornix_cres_Stria_terminalis_R';
mean_FA{1,42} = 'Fornix_cres_Stria_terminalis_L';
mean_FA{1,43} = 'Superior_longitudinal_fasciculus_R';
mean_FA{1,44} = 'Superior_longitudinal_fasciculus_L';
mean_FA{1,45} = 'Superior_fronto_occipital_fasciculus_R';
mean_FA{1,46} = 'Superior_fronto_occipital_fasciculus_L';
mean_FA{1,47} = 'Uncinate_fasciculus_R';
mean_FA{1,48} = 'Uncinate_fasciculus_L';
mean_FA{1,49} = 'Tapetum_R';
mean_FA{1,50} = 'Tapetum_L';



for i = 1:numsubjs
    
    %% Get all GM vol
    i
    FApath = strcat(imagesdir,'/',raw{i+1,3});
    X = spm_vol(FApath);
    FAimg = spm_read_vols(X);
    FAimg(isnan(FAimg))=0;

    %%
    for nROI = 3:numROI+2
        
        %Load ROI image
        
        ROI = strcat(roipath,'/skeleton_',mean_FA{1,nROI},'.nii');
        A = spm_vol(ROI);
        ROIimg = spm_read_vols(A);
        ROIimg(isnan(ROIimg))=0;
        roiones = ~ROIimg==0;
        
        %%
        
        % Mask FA image with ROI and take average
        
        includedvalues = FAimg(roiones);
        mean_FA{i+1,nROI} = mean(includedvalues);


    end
end
