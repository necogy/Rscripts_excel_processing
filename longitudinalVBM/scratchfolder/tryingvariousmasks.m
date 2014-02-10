%generate binary masks at various thresholds for each subject

%paths
%R:\groups\rosen\longitudinalVBM\3T_byPIDN_ACTIVE
%R:\groups\rosen\longitudinalVBM\15T_byPIDN_ACTIVE

%path = 'R:\groups\rosen\longitudinalVBM\3T_byPIDN_ACTIVE';
paths ={  'R:\groups\rosen\longitudinalVBM\3T_byPIDN_ACTIVE', 'R:\groups\rosen\longitudinalVBM\15T_byPIDN_ACTIVE' };
jobspath = ('C:\Users\SAttygalle\Documents\GitHub\imaging-core\longitudinalVBM\jobs');
%d = SAdir(path,'\d');

createmasks =0;
domultiplications=0;
normalise_to_MNI =0;
do_extractions = 1;
doneLSDPIDN = [10114];
LSDPIDNS = [10880;14213;14427;2275;2711;5042;5830;6110;11735;11965;12555;13512;588;1004;1176;1319;1340;1463;2500;3521;4160;4375;4379;4471;5468];
propyears = [84,1.04383561600000;98,0.668493151000000;121,0.846575342000000;278,0.846575342000000;588,1.10684931500000;663,0.893150685000000;841,1;951,1.07397260300000;1004,0.758904110000000;1124,0.884931507000000;1176,0.989041096000000;1279,0.821917808000000;1319,1.07397260300000;1340,1.01369863000000;1362,1.02465753400000;1416,1.38082191800000;1418,1.05753424700000;1463,1.02465753400000;1586,1.01369863000000;1615,2.12054794500000;1728,0.969863014000000;1813,1.18904109600000;2046,1.15616438400000;2062,1.35890411000000;2125,0.860273973000000;2275,1.12602739700000;2496,1.20547945200000;2500,0.849315068000000;2522,1.34520547900000;2557,0.953424658000000;2582,1.05205479500000;2679,1.02739726000000;2680,0.989041096000000;2688,0.843835616000000;2692,0.843835616000000;2699,1;2702,0.901369863000000;2703,0.901369863000000;2711,1.00273972600000;2715,1.01643835600000;2720,0.898630137000000;2732,1.01643835600000;2735,1.03561643800000;2743,1.06849315100000;2744,0.978082192000000;2774,1;2795,0.997260274000000;2801,1.37260274000000;3015,1.22739726000000;3027,1.09315068500000;3399,2.27123287700000;3521,0.890410959000000;3530,1.07397260300000;3673,1.05205479500000;3683,1.43835616400000;3690,1.30410958900000;3773,1.05479452100000;3824,1.06027397300000;4062,1.19726027400000;4063,0.994520548000000;4160,1.27397260300000;4348,1.40547945200000;4375,1.00821917800000;4379,1.29863013700000;4471,1.02191780800000;4477,1.01643835600000;4494,1.25205479500000;4718,1.30410958900000;4747,1.46027397300000;4943,1.05479452100000;5042,1.05479452100000;5061,1.40000000000000;5064,1.29041095900000;5436,0.720547945000000;5468,1.06027397300000;5595,0.978082192000000;5627,0.810958904000000;5830,1.09315068500000;5844,0.890410959000000;6110,1.01917808200000;6609,1.16986301400000;65,1.16666666700000;1641,1.11111111100000;3700,1.16388888900000;3884,1.02777777800000;5133,1.01666666700000;5888,1.02777777800000;6248,1.21944444400000;6600,1;6741,1.00833333300000;6838,0.905555556000000;6842,0.797222222000000;6857,1.00833333300000;6860,1.01666666700000;6867,1.35000000000000;6868,0.913888889000000;6908,1.08888888900000;6909,0.636111111000000;6922,0.902777778000000;6934,0.991666667000000;6935,0.788888889000000;6976,1.27222222200000;6977,1.20277777800000;7065,0.873972603000000;7142,0.750000000000000;7162,0.991780822000000;7396,1.06111111100000;7397,1.06111111100000;7411,1.38055555600000;7418,1.22500000000000;7428,1.29895833300000;7444,1.03333333300000;7749,1.33888888900000;7792,0.988888889000000;7793,1.13611111100000;7802,1.10277777800000;7811,1.12222222200000;7813,1.15555555600000;7837,0.869444444000000;7838,0.869444444000000;7850,1.15156250000000;7851,1.23611111100000;7938,1.15555555600000;8182,1.21111111100000;8193,1.49444444400000;8510,1.16388888900000;8533,1.12500000000000;8538,1.30277777800000;8545,1.40277777800000;8565,0.950000000000000;8590,1.14444444400000;8592,1.07500000000000;8593,1.07500000000000;8594,1.02500000000000;8601,0.816666667000000;8619,1.00555555600000;8627,1.14722222200000;8698,1.23888888900000;8704,1.05479452100000;8706,1.15555555600000;8913,1.12054794500000;8966,1.03333333300000;9186,0.789041096000000;9265,0.909589041000000;9283,1.03888888900000;9320,0.827777778000000;9440,1.22777777800000;9621,1.08888888900000;9757,1.07222222200000;10032,1.18611111100000;10114,1.28493150700000;10177,1.41666666700000;10434,1.34444444400000;10445,1.38333333300000;10683,1.49166666700000;10769,1.36986301400000;10880,0.666666667000000;11028,1.01369863000000;11241,0.536111111000000;11247,0.700000000000000;11296,0.680555556000000;11329,0.513888889000000;11442,1.03013698600000;11463,0.741666667000000;11657,1.04383561600000;11704,1.04931506800000;11727,0.586111111000000;11735,1.01369863000000;11773,0.688888889000000;11965,0.649315068000000;12322,0.677777778000000;12474,1.77260274000000;12555,0.569444444000000;12627,0.652777778000000;13054,0.613698630000000;13106,0.610958904000000;13115,0.972602740000000;13138,1.04931506800000;13185,1.37808219200000;13213,1.07397260300000;13272,1.40000000000000;13512,1.15068493200000;13580,1.11506849300000;13651,0.813698630000000;13683,1.16438356200000;13919,1.20821917800000;13962,0.767123288000000;13938,0.572602740000000;14213,0.808219178000000;14427,0.608219178000000;13976,1.03560000000000];

%% create masks
if createmasks == 1
    
    thresholds = [ 0.5] ;
    for p = 1 :size(paths,2)
        path = paths{p};
        d = SAdir(path,'\d');
        
        for i = 1:size(d,1)
            if ismember(str2num(d(i).name ), LSDPIDNS)
                %get c1 image
                clear folder;
                folder =SAdir(fullfile(path,d(i).name), '^c1avg\w*time1.nii');
                file1=folder.name ;
                clear inputs;
                inputs = cell(3,1);
                inputs{1, 1} = {fullfile(path, d(i).name, file1) };% c1 dv
                
                for t=1:size(thresholds,2) %loop through different thresholds
                    outfile = [file1(1:end-4) '_binarized_' num2str(thresholds(t)) '.nii' ] ;
                    inputs{2, 1} = [fullfile(path, d(i).name,outfile)] ; % output filename c1dv
                    inputs{3, 1} = ['i1>' num2str(thresholds(t))];
                    spm('defaults', 'PET');
                    spm_jobman('initcfg');
                    spm_jobman('run', fullfile( jobspath, 'SPM12_imcalc_job.m'), inputs{:});
                end
            end
        end
        
    end
end


%% multiply masks with change images

if domultiplications == 1
    changeimages= {'dv', 'jd'};
    thresholdsstring = {'00percent','10percent', '30percent', '60percent', '90percent', '100percent'}  ;
    
    thresholdsstring = {'50percent'}  ;
    
    for p =1:size(paths,2)
        path = paths{p};
        d = SAdir(path,'\d');
        for dvjd= 1:2
            for i = 1:size(d,1)
                if ismember(str2num(d(i).name ), LSDPIDNS)
                    %get c1 image
                    clear file2;
                    d(i).name
                    getfile =SAdir(fullfile(path,d(i).name), '^dv_');
                    file2 = fullfile(path, d(i).name, getfile.name) ;% dv
                    for t=1:size(thresholdsstring,2) %loop through different thresholds
                        
                        clear file1;
                        clear outfile;
                        getfile = SAdir(fullfile(path,d(i).name), ['_binarized_' num2str(thresholds(t)) '.nii'] );
                        file1 = fullfile(path, d(i).name, getfile.name) ;
                        outfile = fullfile(path, d(i).name, ['c1' changeimages{dvjd} '_' d(i).name '_binarymaskat_' thresholdsstring{t} ] );
                        
                        SAmultiply2Images(file1, file2, outfile)
                    end
                end
            end
        end
    end
    
end




%% #warp images to template and MNI
%Run DARTEL Normalise to MNI with Zero Smoothing and no modulation (all subjects at once)

if normalise_to_MNI ==1
    thresholds = [ 0.3 0.5];
    thresholdsstring = {'30percent','50percent'} ;
    prefixes = {'u_rc1avg','^avg_\w*.nii', 'c1avg\w*_0.3','c1avg\w*_0.5', 'c1jd\w*30percent','c1dv\w*30percent','c1jd\w*50percent','c1dv\w*50percent'};
    
    for p =1:size(paths,2)
        path = paths{p};
        d = SAdir(path,'\d');
        for i = 1:size(d,1)
            if ismember(str2num(d(i).name ), LSDPIDNS)
                clear inputswarp
                inputswarp = cell(8,1);
                for n = 1:size(prefixes,2)
                    clear file2;
                    
                    getfile =SAdir(fullfile(path,d(i).name), [ prefixes{n} ]);
                    file2 = fullfile(path, d(i).name, getfile.name) ;% dv
                    inputswarp{n,1} = file2;
                    
                    if ismember(n, 5:8) %divide jd/dv by prop year
                        clear propyear;
                        clear expression;
                        propyear = propyears(ismember(propyears(:,1), str2num(d(i).name)),2);
                        expression = strcat('i1./',num2str(propyear));% enter prop-year into expression
                        clear inputs;
                        inputs = cell(3,1);
                        inputs{1, 1} = cellstr(file2);% c1.*jd file (from above)
                        [PATHSTR,NAME,EXT] = fileparts(file2);
                        inputs{2, 1} = fullfile(fileparts(file2), ['PROP' NAME EXT] );% outputfile name - PROPc1jd
                        inputs{3, 1} = expression; % imcalc expression = i1./prop_year
                        spm('defaults', 'PET');
                        spm_jobman('initcfg');
                        spm_jobman('run',  fullfile( jobspath, 'SPM12_imcalc_job.m'), inputs{:});
                        
                        inputswarp{n,1} = inputs{2, 1};
                        clear inputs;
                    end
                    
                end
  
                spm('defaults', 'PET');
                spm_jobman('initcfg');
                dartpath = 'R:\groups\rosen\longitudinalVBM\darteltemplates\Template_binney\Template_6.nii'
                matlabbatch{1}.spm.tools.dartel.mni_norm.template = cellstr(dartpath);
                matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = cellstr(inputswarp{1,1});
                images = {};
                for j =1: size(inputswarp(2:end),1)
                   images{j} = cellstr(inputswarp(1+j));
                end
                
                matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images = images;
                matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
                matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                    NaN NaN NaN];
                matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
                matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];
                
                spm_jobman('run',matlabbatch)
            end
        end
    end
end



%% #do extractions
if do_extractions == 1
    clear labels
    clear allvals
    roipath = 'C:\Users\SAttygalle\Desktop\FLOOR_analysis\ROIs';
    rois_to_extract = {'1_L_medpoletemp.nii','1h_R_medpoletemp.nii','2_L_midmedialtemp.nii', ...
        '2h_R_midmedialtemp.nii', '3_L_lattemp.nii','3h_R_lattemp.nii','4_L_postcing.nii' ,'4h_R_postcing.nii' , ...
        '5_L_ventlatfrontal.nii', '5h_R_ventlatfrontal.nii' ,'6_L_midcing.nii','6h_R_midcing.nii' ,'7_L_parietal.nii', ...
        '7h_R_parietal.nii','ACC.nii','Amygdala.nii','Ant_FG.nii','Insula.nii','Lentiform.nii'}; 
    prefixes = {'^wPROPc1jd_\d*.nii','^wPROPc1jd\w*30percent','^wPROPc1jd\w*50percent'};
    headerlabelcat = {'nonbin' ,'30bin' ,'50bin'};
    
    for p =1:size(paths,2) %for each subject, for each threshold (0, 30 , 50 ) and for each roi , extract change
        path = paths{p};
        d = SAdir(path,'\d');
        for i = 1:size(d,1)
            if ismember(str2num(d(i).name ), LSDPIDNS)
                labels(i) = str2num(d(i).name);
                for n = 1:size(prefixes,2)
                    getfile =SAdir(fullfile(path,d(i).name), [ prefixes{n} ]);
                    changeimagepath = fullfile(path, d(i).name, getfile.name);
                    X = spm_vol(changeimagepath);
                    CHANGEimg = spm_read_vols(X);
                    CHANGEimg(isnan(CHANGEimg))=0;
                    
                    for r = 1:size(rois_to_extract,2)
                        
                        %mask change image by roi
                        getfile = SAdir(roipath, [ rois_to_extract{r} ]);
                        roiimagepath= fullfile(roipath, getfile.name);
                        X = spm_vol(roiimagepath);
                        ROIimg = spm_read_vols(X);
                        ROIimg(isnan(ROIimg))=0;
                        
                        CHANGEimgR = CHANGEimg.*ROIimg;
                        CHANGEimgR(CHANGEimgR==0) = NaN;
                        
                        CHANGEimgRneg = CHANGEimgR;
                       % CHANGEimgRneg(CHANGEimgR>0) = NaN;
                        %allvals(i, r+ size(rois_to_extract,2)*(n-1) ) = nanmedian(CHANGEimgR(:));
                        allvals(i, r+ size(rois_to_extract,2)*(n-1) ) = nanmean(CHANGEimgR(:));

                        %allvals(2, n*r) = nanmedian(CHANGEimgRneg(:))
                        %allvals(3, n*r) = nanmean(CHANGEimgR(:))
                       % allvals(4, n*r) = nanmean(CHANGEimgRneg(:))
                    end
                end
            end
        end
    end   
    
    allvalstrim=allvals;
    allvalstrim(allvals(:,1)==0,:)=[];
    labels(labels==0)=[];
    labels =labels'
    
    output = [labels allvalstrim];
    headerlab = cell(1,size(prefixes,2)*size(rois_to_extract,2));
    for n = 1:size(prefixes,2)
        for r = 1:size(rois_to_extract,2)
    headerlabel{r + (n-1)*size(rois_to_extract,2) } = strcat(rois_to_extract{r}(1:end-4), headerlabelcat{n} )
        end
    end
    


end

set(0, 'defaultTextInterpreter', 'none') % changed from 'tex' so underscores are not treated as subscript
figureoutputfolder= 'C:\Users\SAttygalle\Desktop\FLOOR_analysis\comparebinarize\mean\'
legendtitles = {'non-binarized c1', 'c1>0.3', 'c1>0.5'}
  for r = 1:size(rois_to_extract,2)
      f=figure()
      bar(allvalstrim(:,[r r+size(rois_to_extract,2) r+2*size(rois_to_extract,2)])) 
      
      ylabel('mean change in ROI')
    xlabel('PIDN')
    legend(legendtitles, 'Location', 'SouthEast')
    title( rois_to_extract{r}(1:end-4))
    set(gca,'FontSize',5)
    set(gca,'XTickLabel',labels)
      set(gca,'XTick', 1:size(labels,1))
      
   print(f, '-dpdf', [figureoutputfolder '/'  rois_to_extract{r}(1:end-4) '.pdf']);
  end
  


%% get average maps
    prefixes = {'^wPROPc1jd_\d*.nii','^wPROPc1jd\w*30percent','^wPROPc1jd\w*50percent'};
    titles = {'^wPROPc1jd','^wPROPc1jd30percent','^wPROPc1jd50percent'};
    clear inputs
    inputs = cell(1,1)
    for n = 2:size(prefixes,2)
        for p =1:size(paths,2) %for each subject, for each threshold (0, 30 , 50 ) and for each roi , extract change
            path = paths{p};
            d = SAdir(path,'\d');
            for i = 1:size(d,1)
                if ismember(str2num(d(i).name ), LSDPIDNS)
                   % labels(i) = str2num(d(i).name);
                    getfile =SAdir(fullfile(path,d(i).name), [ prefixes{n} ]);
                    file2 = fullfile(path, d(i).name, getfile.name) ;% dv
                    inputs = [inputs file2];
                    
                    
                    
                end
            end
        end
        inputs(1) = [];
        clear matlabbatch
        spm('defaults', 'PET');
        spm_jobman('initcfg');
        images = {}
        for j =1:size(inputs(1:end),2)
          images{j} = cellstr(inputs{j});
        end
                
        matlabbatch{1}.spm.util.imcalc.input = inputs';
        matlabbatch{1}.spm.util.imcalc.output = ['mean_' titles{n}(2:end)];
        matlabbatch{1}.spm.util.imcalc.outdir = {'R:\groups\rosen\longitudinalVBM'}; 
        matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
      matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
        spm_jobman('run',matlabbatch)


        
        
        
    end
 
       
 
               




