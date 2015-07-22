#transform C1s in native space to ICBM space
#c1toICBM.sh listofsourceids.txt path_to_c1s path_to_flowfields path_to_t1s path_to_dartel_template_6 path_to_y_deformation output_path
home=$(pwd)
template=$(ls $home/${5})
ydeform=$(ls $home/${6})
mkdir -p $home/${7}
outpath=$(ls -d $home/${7})
for i in $(cat ${1}); do
 	c1=$(ls $home/${2}/c1*${i}*);
 	uimage=$(ls $home/${3}/u*${i}*);
 	if [ -f $home/${4}/MP*${i}*hdr ]; then
 	t1image=$(ls $home/${4}/MP*${i}*img)
    else t1image=$(ls $home/${4}/MP*${i}*nii)
    fi
 	matlab -nojvm -nodesktop -nodisplay -nosplash -r "c12icbm('${c1}','${uimage}','${t1image}','${template}','${ydeform}','${outpath}'),quit()" | tail -n +17;
 done

