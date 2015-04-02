#dtiproc
#script for dti pre-preprocessing
#specify dti zip files containing raw dicoms
#syntax dtiproc.sh {zip files}
#works for both dti V1 and V2 - does not yet process DTI V4

mkdir -p ./5_allAD ./4_allRD ./3_allMD ./2_allFA ./1_preproc/

DATE=$(date +"%Y%m%d%H%M%S")

red='\e[0;31m'
cyan='\e[0;36m'
NC='\e[0m' # No Color

#error messages
if [ "$1" = "help" ]; then
  echo "SYNTAX: dtiproc.sh {zip files}";
  echo "Zip files must be located in the present working directory"
  exit 
fi

if [ "$1" = "" ]; then
  echo "No input files specified"
  echo "SYNTAX: dtiproc.sh {zip files}";
  echo "Zip files must be located in the present working directory"
  exit 
fi

#read version and source id
for i in ${@};
	do if [ ! -f ${i} ] || [[ ${i} != *.zip ]] || [ "${i}" = "help" ]; then
  		echo -e "${red}${i} is not a .zip file${NC}"
  		else sourceid=`echo ${i} | cut -c 8-21 |rev | cut -c 5-21 | rev`
		  version=`echo ${i} | cut -c 5-6`
		  sourceidv=`echo ${sourceid}_${version}`
		
#make preprocessing directories and copy zip files into subject directories
		echo -e "${cyan}${sourceidv}${NC}"
			mkdir -p ./1_preproc/${sourceidv}
			mkdir -p  ./1_preproc/${sourceidv}/bet ./1_preproc/${sourceidv}/nifti ./1_preproc/${sourceidv}/eddy_correct ./1_preproc/${sourceidv}/dtifit ./1_preproc/${sourceidv}/unzipped ./1_preproc/${sourceidv}/b0_images;
			cp ${i} ./1_preproc/${sourceidv};
			ZIP=$(find ./1_preproc/${sourceidv}/*${sourceid}*zip)

#unzip dti files and check number of dicoms
		echo "Unzipping ${i}"
			if [ -d ./1_preproc/${sourceidv}/unzipped/ ]; then
				rm -r ./1_preproc/${sourceidv}/unzipped
				mkdir ./1_preproc/${sourceidv}/unzipped
			fi
			unzip -qq -o $ZIP -d ./1_preproc/${sourceidv}/unzipped/;
			unzip -qq -o ./1_preproc/${sourceidv}/unzipped/DTI-64-v*.zip -d ./1_preproc/${sourceidv}/unzipped/;
			sixtyfourdir=$(ls ./1_preproc/${sourceidv}/unzipped/ --group-directories-first -I ${sourceid} | head -1)
			imageno64=$( ls ./1_preproc/${sourceidv}/unzipped/$sixtyfourdir/*dcm | wc -w)
			if [ $imageno64 == 65 ]; then
			mv ./1_preproc/${sourceidv}/unzipped/$sixtyfourdir ./1_preproc/${sourceidv}/unzipped/${sourceidv}_64dir
			if [ -f ./1_preproc/${sourceidv}/unzipped/DTI-b0-v*zip ]; then
				unzip -qq -o ./1_preproc/${sourceidv}/unzipped/DTI-b0-v*.zip -d ./1_preproc/${sourceidv}/unzipped/;
				bdir=$(ls ./1_preproc/${sourceidv}/unzipped/ --group-directories-first -I ${sourceidv}* | head -1)
				imagenob0=$( ls ./1_preproc/${sourceidv}/unzipped/$bdir/*dcm | wc -w)
				mv -u ./1_preproc/${sourceidv}/unzipped/$bdir ./1_preproc/${sourceidv}/unzipped/${sourceidv}_b0	

			   #10 B0 images present____________________________________________________________________________
			      
            #generate NITFI images for DTI files with 10 B0 images
  				  if  [ $imagenob0 == 550 ] || [[ "$version" = "v2" && $imagenob0 == 600 ]]; then
  				  echo "Generating NIFTI images from raw DICOMS for ${sourceidv}"
  				  dcm2nii -v N ./1_preproc/${sourceidv}/unzipped/*64dir/* 1>/dev/null;
            gunzip ./1_preproc/${sourceidv}/unzipped/*64dir/*gz
  				  mv ./1_preproc/${sourceidv}/unzipped/*64dir/*nii ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.nii 
  				  mv ./1_preproc/${sourceidv}/unzipped/*64dir/*bval ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.bval
  				  mv ./1_preproc/${sourceidv}/unzipped/*64dir/*bvec ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.bvec
  				  dcm2nii -v N ./1_preproc/${sourceidv}/unzipped/*b0/* 1>/dev/null;
            gunzip ./1_preproc/${sourceidv}/unzipped/*b0/*gz
  				  mv ./1_preproc/${sourceidv}/unzipped/${sourceidv}_b0/*nii ./1_preproc/${sourceidv}/nifti/${sourceidv}_b0images.nii 
  				  
            #split b0 and 64dir images
            fslsplit ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.nii ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir_ -t
  				  fslsplit ./1_preproc/${sourceidv}/nifti/${sourceidv}_b0images.nii ./1_preproc/${sourceidv}/nifti/${sourceidv}_b0_ -t
  				  mkdir -p ./1_preproc/${sourceidv}/nifti/_excluded
  				  mv ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir_0000.nii.gz ./1_preproc/${sourceidv}/nifti/_excluded
  				  
            #merge 10 b0 images and 64dir images and edit bvec file
            fslmerge -t ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir10b0 ./1_preproc/${sourceidv}/nifti/${sourceidv}_b0_*.nii.gz ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir_*.nii.gz
  				  sed -i '1s/^/0 0 0 0 0 0 0 0 0 /' ./1_preproc/${sourceidv}/nifti/*bval
  				  sed -i '1s/^/0 0 0 0 0 0 0 0 0 /' ./1_preproc/${sourceidv}/nifti/*bvec
  				  sed -i '2s/^/0 0 0 0 0 0 0 0 0 /' ./1_preproc/${sourceidv}/nifti/*bvec
  				  sed -i '3s/^/0 0 0 0 0 0 0 0 0 /' ./1_preproc/${sourceidv}/nifti/*bvec
  				  BIMAGE=$(find ./1_preproc/${sourceidv}/nifti -type f -name *b0_scan.nii | head -1);
  				  IMAGE=$(find ./1_preproc/${sourceidv}/nifti/ -type f -name ${sourceidv}_64dir10b0.nii.gz | head -1);
  			
  			    #eddy correct the 64 direction DTI images
  			    echo "Running eddy_correct for ${sourceidv}"
  				 # eddy_correct ${IMAGE} ./1_preproc/${sourceidv}/eddy_correct/${sourceidv}_64dir10b0_ecc.nii.gz 0 1>/dev/null;
  			
  			    #average 10 b0 images to create B0 mean image
  			    echo "Generating b0 mean image for ${sourceidv}"
  				  cp ./1_preproc/${sourceidv}/nifti/${sourceidv}_b0_000* ./1_preproc/${sourceidv}/b0_images
  				  cd ./1_preproc/${sourceidv}/b0_images
  				  fslmaths ${sourceidv}_b0_0000.nii.gz -add ${sourceidv}_b0_0001.nii.gz -add ${sourceidv}_b0_0002.nii.gz -add ${sourceidv}_b0_0003.nii.gz -add ${sourceidv}_b0_0004.nii.gz -add ${sourceidv}_b0_0005.nii.gz -add ${sourceidv}_b0_0006.nii.gz -add ${sourceidv}_b0_0007.nii.gz -add ${sourceidv}_b0_0008.nii.gz -add ${sourceidv}_b0_0009.nii.gz added.nii
  				  fslmaths added.nii.gz -div 10 ${sourceidv}_mean_b0_image.nii
  				  rm added.nii.gz
  				  cd ../../..
  			
  			    #skull strip the mean B0 image with BET
  			    echo "Running BET on ${sourceidv}'s b0 mean image"
  				  bet ./1_preproc/${sourceidv}/b0_images/${sourceidv}_mean_b0_image.nii  ./1_preproc/${sourceidv}/bet/${sourceidv}_bet_mean_b0_image.nii  -m -R -B -f 0.1;
            
            #run dtifit on the eddy corrected 64 direction image using the skull stripped B0 mean image as a mask			
  			    echo "Running dtifit for ${sourceidv}"
  				  dtifit -k ./1_preproc/${sourceidv}/eddy_correct/${sourceidv}_64dir10b0_ecc.nii.gz -o ./1_preproc/${sourceidv}/dtifit/${sourceidv} -m ./1_preproc/${sourceidv}/bet/${sourceidv}_bet_mean_b0_image.nii.gz -r ./1_preproc/${sourceidv}/nifti/*64dir*bvec* -b ./1_preproc/${sourceidv}/nifti/*64dir*bval* 1>/dev/null;
  				  
  				  #generate the RD image
  				  fslmaths ./1_preproc/${sourceidv}/dtifit/*L2* -add ./1_preproc/${sourceidv}/dtifit/*L3* -div 2 ./1_preproc/${sourceidv}/dtifit/${sourceidv}_RD
  				  
  				  #copy FA, MD, RD, and AD images to overall group directories
  				  cp ./1_preproc/${sourceidv}/dtifit/*FA* ./2_allFA;
  				  cp ./1_preproc/${sourceidv}/dtifit/*MD* ./3_allMD;
  				  cp ./1_preproc/${sourceidv}/dtifit/*RD* ./4_allRD;
  				  cp ./1_preproc/${sourceidv}/dtifit/*L1* ./5_allAD;
  				  
  				  #update processing text file  
  				  if [ -f ./1_preproc/${sourceidv}/dtifit/*FA* ]; then
  			  	  echo "${sourceidv} COMPLETE_WITH_B0" >> ./1_preproc/dtiproc_$DATE.txt
  				  fi
  			    else echo -e "${red}${sourceidv}'s 10 b0 images have a total of only $imagenob0 dicoms${NC}"
  				    echo "${sourceidv} FAILED" >> ./1_preproc/dtiproc_$DATE.txt
  			    fi
		
		  #1 B0 image present_____________________________________________________________________________
            
            #generate NITFI images for DTI files with 1 B0 image
            else echo -e "${red}${sourceidv} has only one b0 image${NC}"
				    echo "Generating NIFTI images from raw DICOMS for ${sourceidv}"
				    dcm2nii -g N ./1_preproc/${sourceidv}/unzipped/*64dir/* 1>/dev/null;
				    mv ./1_preproc/${sourceidv}/unzipped/*64dir/*nii ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.nii 
				    mv ./1_preproc/${sourceidv}/unzipped/*64dir/*bval ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.bval
				    mv ./1_preproc/${sourceidv}/unzipped/*64dir/*bvec ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.bvec
			   	  
            #extract b0 image from 64dir image
            fslsplit ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir.nii ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir_ -t
				    mv ./1_preproc/${sourceidv}/nifti/${sourceidv}_64dir_0000.nii.gz ./1_preproc/${sourceidv}/b0_images/${sourceidv}_b0_image.nii.gz
				    IMAGE=$(find ./1_preproc/${sourceidv}/nifti/ -type f -name ${sourceidv}_64dir.nii | head -1);
			
			     #eddy correct the 64 direction DTI image
            echo "Running eddy_correct for ${sourceidv}"
				    #eddy_correct ${IMAGE} ./1_preproc/${sourceidv}/eddy_correct/${sourceidv}_64dir1b0_ecc.nii.gz 0 1>/dev/null;
			
           #skull strip single B0 image with BET
			     echo "Running BET on ${sourceidv}'s b0 image"
				   bet ./1_preproc/${sourceidv}/b0_images/${sourceidv}_b0_image.nii.gz  ./1_preproc/${sourceidv}/bet/${sourceidv}_bet_b0_image.nii  -R -B -m -f 0.1;
		    
           #run dtifit on the eddy corrected 64 direction image using the skull stripped B0 mean image as a mask        
		       echo "Running dtifit for ${sourceidv}"
				   dtifit -k ./1_preproc/${sourceidv}/eddy_correct/${sourceidv}_64dir1b0_ecc.nii.gz -o ./1_preproc/${sourceidv}/dtifit/${sourceidv} -m ./1_preproc/${sourceidv}/bet/${sourceidv}_bet_b0_image.nii.gz -r ./1_preproc/${sourceidv}/nifti/*64dir*bvec* -b ./1_preproc/${sourceidv}/nifti/*64dir*bval* 1>/dev/null;
				  
           #generate the RD image
           fslmaths ./1_preproc/${sourceidv}/dtifit/*L2* -add ./1_preproc/${sourceidv}/dtifit/*L3* -div 2 ./1_preproc/${sourceidv}/dtifit/${sourceidv}_RD
				
           #copy FA, MD, RD, and AD images to overall group directories
           cp ./1_preproc/${sourceidv}/dtifit/*FA* ./2_allFA;
  				 cp ./1_preproc/${sourceidv}/dtifit/*MD* ./3_allMD;
  				 cp ./1_preproc/${sourceidv}/dtifit/*RD* ./4_allRD;
  				 cp ./1_preproc/${sourceidv}/dtifit/*L1* ./5_allAD;
				
          #update processing text file
          if [ -f ./1_preproc/${sourceidv}/dtifit/*FA* ]; then
				  echo "${sourceidv} COMPLETE_NO_B0" >> ./1_preproc/dtiproc_$DATE.txt
				  fi
			    fi
			   else echo -e "${red}${sourceidv}'s 64 direction image has $imageno64 dicoms, instead of 65${NC}"
			        echo "${sourceidv} FAILED" >> ./1_preproc/dtiproc_$DATE.txt
		     fi
	fi;
done