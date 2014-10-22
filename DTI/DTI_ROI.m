%imagesdir=directory with all co-registered FA images in MNI space
%sheetname=path to excel spreadsheet with three columns - 1. PIDN
%2.SourceID 3. FA file name (no path) 4. MD file name 5. RD file name 6. AD
%file name
%roipath=directory with all binary ROI masks (in MNI space)



function mean_dti_values=DTI_ROI(imagesdir, sheetname, roipath)
[num,txt,raw] = xlsread(sheetname);

[K,~] = size(raw);

K

numsubjs = K - 1;

numsubjs

numROI=48;

mean_dti_values = cell(numsubjs+1,numROI+2);

for i = 1:numsubjs
    mean_dti_values{i+1,1} = raw{i+1,1};
    mean_dti_values{i+1,2} = raw{i+1,2};
end

clear i

ValueTypes = {'FA';'MD';'RD';'AD'};
JHUROIs = {'Middle_cerebellar_peduncle';'Pontine_crossing_tract';'Genu_of_corpus_callosum';'Body_of_corpus_callosum';'Splenium_of_corpus_callosum';'Fornix';'Corticospinal_tract_R';'Corticospinal_tract_L';'Medial_lemniscus_R';'Medial_lemniscus_L';'Inferior_cerebellar_peduncle_R';'Inferior_cerebellar_peduncle_L';'Superior_cerebellar_peduncle_R';'Superior_cerebellar_peduncle_L';'Cerebral_peduncle_R';'Cerebral_peduncle_L';'Anterior_limb_of_internal_capsule_R';'Anterior_limb_of_internal_capsule_L';'Posterior_limb_of_internal_capsule_R';'Posterior_limb_of_internal_capsule_L';'Retrolenticular_part_of_internal_capsule_R';'Retrolenticular_part_of_internal_capsule_L';'Anterior_corona_radiata_R';'Anterior_corona_radiata_L';'Superior_corona_radiata_R';'Superior_corona_radiata_L';'Posterior_corona_radiata_R';'Posterior_corona_radiata_L';'Posterior_thalamic_radiation_R';'Posterior_thalamic_radiation_L';'Sagittal_stratum_R';'Sagittal_stratum_L';'External_capsule_R';'External_capsule_L';'Cingulum_cingulate_gyrus_R';'Cingulum_cingulate_gyrus_L';'Cingulum_hippocampus_R';'Cingulum_hippocampus_L';'Fornix_cres_Stria_terminalis_R';'Fornix_cres_Stria_terminalis_L';'Superior_longitudinal_fasciculus_R';'Superior_longitudinal_fasciculus_L';'Superior_fronto_occipital_fasciculus_R';'Superior_fronto_occipital_fasciculus_L';'Uncinate_fasciculus_R';'Uncinate_fasciculus_L';'Tapetum_R';'Tapetum_L'}
mean_dti_values{1,1} = 'PIDN';
mean_dti_values{1,2} = 'SCANID'; 

for i = 1:48;
    for j = 1:4
        name = strcat(ValueTypes{j,1},'_',JHUROIs{i,1});
        k = 2 + i + 48*(j-1);
        mean_dti_values{1,k} = name; 
    end
end



for i = 1:numsubjs
    i
    %% Get FA vol
    
    FApath = strcat(imagesdir,'/',raw{i+1,3});
    W = spm_vol(FApath);
    FAimg = spm_read_vols(W);
    FAimg(isnan(FAimg))=0;
    %% Get MD vol
    
    MDpath = strcat(imagesdir,'/',raw{i+1,4});
    X = spm_vol(MDpath);
    MDimg = spm_read_vols(X);
    MDimg(isnan(MDimg))=0;
    
    %% Get RD vol
    
    RDpath = strcat(imagesdir,'/',raw{i+1,5});
    Y = spm_vol(RDpath);
    RDimg = spm_read_vols(Y);
    RDimg(isnan(RDimg))=0;
    
    %% Get AD vol
    
    ADpath = strcat(imagesdir,'/',raw{i+1,6});
    Z = spm_vol(ADpath);
    ADimg = spm_read_vols(Z);
    ADimg(isnan(ADimg))=0;

    %%
    for nROI = 3:numROI+2
        
        %Load ROI image
        
        ROI = strcat(roipath,'/',JHUROIs{(nROI-2),1},'.nii');
        A = spm_vol(ROI);
        ROIimg = spm_read_vols(A);
        ROIimg(isnan(ROIimg))=0;
        roiones = ~ROIimg==0;
        
        %%
        
        % Mask FA image with ROI and take average
        
 
       
        includedFAvalues = FAimg(roiones);
        mean_dti_values{i+1,nROI} = mean(includedFAvalues); 
        includedMDvalues = MDimg(roiones);
        mean_dti_values{i+1,nROI+48} = 1000*mean(includedMDvalues);
        includedRDvalues = RDimg(roiones);
        mean_dti_values{i+1,nROI+96} = 1000*mean(includedRDvalues);
        includedADvalues = ADimg(roiones);
        mean_dti_values{i+1,nROI+144} = 1000*mean(includedADvalues);


    end
end
