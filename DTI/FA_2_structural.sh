


# FA_2_structural.sh
# use after segmenting T1 images and checking quality
# specify location of FA images and segmented images
# text file should contain a list of source IDs
# will bring FA into structural space by using the hessian of the FA image


#ERROR_MESSAGES______________________________________________________________

if [ "$1" = "" ]; then
	echo "SYNTAX: FA_2_structural.sh {input.txt} {T1_images_dir} {FA_images_dir} {spm_path}"
    echo "Input text file should contain list of source IDs"
	exit 
fi

if [ $# -lt 4 ]; then
	echo "Too few arguments"
	echo "SYNTAX: FA_2_structural.sh {input.txt} {T1_images_dir} {FA_images_dir} {spm_path}"
	exit 
fi

if [ $# -gt 4 ]; then
	echo "Too many arguments"
	echo "SYNTAX: FA_2_structural.sh {input.txt} {T1_images_dir} {FA_images_dir} {spm_path}"
	exit 
fi

if [[ $1 != *.txt ]] && [ "$1" != "help" ]; then
  echo "Text file required"
  echo "SYNTAX: FA_2_structural.sh {input.txt} {T1_images_dir} {FA_images_dir} {spm_path}"
  exit 
fi

for i in $(cat ${1});

#SEGMENT_T1_IMAGE___________________________________________________

	do T1=$( basename `ls ${2}/MP*${i}*` );
	echo ${i}
	echo "Segmenting ${T1}";
	mkdir -p ./${i};
	cp ./${2}/${T1} ./${i};
	home=$(pwd)
	cd ${4}
	spmdir=$(pwd)
	cd $home
	matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath('${spmdir}'),addpath('${spmdir}/spm12'),spm12_segment('./${i}/${T1}','${4}/spm12/'),quit()" 1>/dev/null

#CREATE_SKULL_STRIPPED_T1_IMAGE___________________________________________________

	echo "Creating skull-stripped T1 image"
	fslmaths ./${i}/c1${T1} -add ./${i}/c2${T1} -add ./${i}/c3${T1} -bin -kernel boxv 3x3x3 -dilD -mul ./${i}/${T1} ./${i}/spmstrpt1_${i}
	gunzip ./${i}/spmstrpt1_${i}.nii.gz
	spmstrpt1=$(basename `ls ${i}/spmstrpt1*${i}*` )

#GENERATE_HESSIAN_OF_FA_IMAGES___________________________________________________

	FA=$( basename `ls ${3}/*${i}*` );
	cp ${3}/$FA ./${i}
	echo "Generating hessian for ${FA}";
	matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath(genpath('${4}')),matNI_DTI_hessian_cardan('${i}/${FA}',2),quit()" 1>/dev/null;
	hess=$( basename `ls ./${i}/hess*${i}*` )

#COREGISTER_T1_IMAGE_TO_HESSIAN_IMAGE_____________________________________________

	echo "Coregistering ${spmstrpt1} to ${hess}";
	flirt \
		  -in ./${i}/$hess \
		  -ref ${i}/${spmstrpt1} \
	      -out ./${i}/xfm_hess2t1_${i}.nii.gz \
		  -omat ./${i}/xfm_hess2t1_${i}.mat \
		  -cost mutualinfo -dof 6 -nosearch

#APPLY_HESS2C2_XFM_TO_FA_IMAGE______________________________________________________
	
	echo "Applying transform to $FA";
		flirt \
		  -in ${i}/$FA \
		  -ref ${i}/$spmstrpt1 \
	      -out ./${i}/FA_xfm_hess2t1_${i}.nii.gz \
		  -init ./${i}/xfm_hess2t1_${i}.mat \
		  -applyxfm \
		  -interp nearestneighbour
		  gunzip ./${i}/*gz
done
