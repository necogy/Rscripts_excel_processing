#crossectional_dti.sh {FAIMAGES}
#Call the script and specify the FA images you would like to analyze

NOW=$(date +"%Y%m%d")
home=$(pwd)

#STEP1: Reorganize images & copy files 
	mkdir -p ./orig_FA_${NOW}
	for i in ${@};
		do echo ${i}
		sourceidv=`echo ${i} | rev | cut -c 5-200 | rev`
		cp ${i} ./orig_FA_${NOW}
#STEP2: Run FLIRT to linearly register raw FA image to template 	 
		echo "Running FLIRT to linearly register ${i} to FMRIB58_FA_1mm"
		flirt -ref ${FSLDIR}/data/standard/FMRIB58_FA_1mm.nii.gz -in ${i} -omat ${sourceidv}_affine.mat
#STEP3: Run FNIRT to nonlinearly register raw FA image to template 	
		echo "Running FNIRT to nonlinearly register ${i} to FMRIB58_FA_1mm"
		fnirt --ref=${FSLDIR}/data/standard/FMRIB58_FA_1mm.nii.gz --in=${i} --aff=${sourceidv}_affine.mat --cout=${sourceidv}_nonlinear --config=FA_2_FMRIB58_1mm
#STEP4: Run FNIRT to nonlinearly register raw FA image to template 
		echo "Applying warp to ${i}"
		applywarp --ref=${FSLDIR}/data/standard/FMRIB58_FA_1mm.nii.gz --in=${i} --warp=${sourceidv}_nonlinear --out=${sourceidv}_warped
	done
#STEP5: Take an average of all the warped FA images
	echo "Generating average of warped images"
	for i in ${@};
		do sourceidv=`echo ${i} | rev | cut -c 5-200 | rev`;
			if [ ${i} == ${1} ]; then 
		fslmaths ${sourceidv}_warped.nii.gz -add 0 average_warped_${NOW}.nii
		else fslmaths average_warped_${NOW}.nii -add ${sourceidv}_warped.nii.gz average_warped_${NOW}.nii
		fi
 	done
	fslmaths average_warped_$NOW.nii.gz -div $# average_warped_$NOW.nii.gz
#STEP6: Run FLIRT to linearly register raw FA images to warped average
	for i in ${@};
		do echo ${i}
		sourceidv=`echo ${i} | rev | cut -c 5-200 | rev` 
		echo "Running FLIRT to linearly register ${i} to average"
		flirt -ref average_warped_$NOW.nii -in ${i} -omat ${sourceidv}_avgw_affine.mat
#STEP7: Run FNIRT to nonlinearly register raw FA image to warped average
		echo "Running FNIRT to nonlinearly register ${i} to average"
		fnirt --ref=average_warped_$NOW.nii --in=${i} --aff=${sourceidv}_avgw_affine.mat --cout=${sourceidv}_avg_nonlinear --subsamp=8,4,2,2 --infwhm=12,6,2,2 --reffwhm=12,6,2,2 --lambda=300,75,30,30 --estint=1,1,1,0 --intmod=global_linear
#STEP8: Run FNIRT to nonlinearly register raw FA image to template 
		echo "Applying warp to average to ${i}"
		applywarp --ref=average_warped_$NOW.nii --in=${i} --warp=${sourceidv}_avg_nonlinear --out=${sourceidv}_avg_warped
	done

