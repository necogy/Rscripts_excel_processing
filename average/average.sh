#average.sh

if [ $# = 0 ]; then
	echo "SYNTAX: average.sh [images]"
	exit
fi

for i in ${@};
	do if [[ ${i} != *.nii ]] && [[ ${i} != *.img ]]; then
		echo "Only input .img and .nii files"
		exit
	fi
done

number=$#;

NOW=$(date +"%Y%m%d%H%M%S")

echo "Averaging $number images..."

for i in ${@};
	do echo ${i};
	if [ ${i} == ${1} ]; then 
	fslmaths ${1} -add 0 average_${NOW}.nii
	else fslmaths average_${NOW}.nii -add ${i} average_${NOW}.nii
	fi
 done

fslmaths average_$NOW.nii.gz -div $# average_$NOW.nii.gz

gunzip average_$NOW.nii.gz
