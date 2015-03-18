#single_subject_vbm
#SYNTAX: singvbm.sh PIDN-yyyy-mm-dd

#scannoext=`echo ${1} | rev | cut -c 5-200 | rev`

red='\e[1;31m'
NC='\e[0m'  
lightblue='\e[1;34m'


#Error messages_______________________________________________________________________________________________________________________
if [ "$1" = "" ]; then
	echo "SYNTAX: singvbm.sh pidn-yyyy-mm-dd"
	exit 
fi

if [ "$#" != "1" ]; then
	echo "Too many arguments"
	echo "SYNTAX: singvbm.sh pidn-yyyy-mm-dd"
	exit 
fi

if [ "$1" = "help" ]; then
	echo "SYNTAX: singvbm.sh pidn-yyyy-mm-dd"
	exit 
fi

if [ ! -d "./singvbm" ]; then
  echo "singvbm folder must be located in present working directory"
  exit
fi


#User Prompts_________________________________________________________________________________________________________________________

echo ""
echo -e "${lightblue}AGE?${NC}"
read AGE

if [ "$AGE" -eq "$AGE" ] 2>/dev/null; then
  echo ""
  else echo "Age must be an integer"
  exit
fi


echo -e "${lightblue}SEX? (1=M, 2=F)${NC}"
read SEX

if [ "$SEX" -eq "$SEX" ] 2>/dev/null; then
  echo ""
  else echo "Sex must be either 1 or 2"
  exit
fi

if [ "$SEX" -ne "1" ] && [ "$SEX" -ne "2" ] 2>/dev/null; then
  echo "Sex must be either 1 or 2"
  exit
fi


echo -e "${lightblue}NUMBER OF CONTROLS?${NC}"
read CONNUM

if [ "$CONNUM" -eq "$CONNUM" ] 2>/dev/null; then
  echo ""
  else echo "Number of controls must be an integer"
  exit
fi

if [ "$CONNUM" -gt 100 ] 2>/dev/null; then
  echo "Number of controls cannot exceed 350"
  exit
fi

if [ "$CONNUM" -lt 0 ] 2>/dev/null; then
  echo "Number of controls must be greater than 0"
  exit
fi

echo -e "${lightblue}MATCH FOR SEX? (Y/N)${NC}"
read SEXMATCH


if [ "$SEXMATCH" != "Y" ] && [ "$SEXMATCH" != "N" ] && [ "$SEXMATCH" != "n" ] && [ "$SEXMATCH" != "y" ] && [ "$SEXMATCH" != "NO" ] && [ "$SEXMATCH" != "YES" ] && [ "$SEXMATCH" != "yes" ] && [ "$SEXMATCH" != "no" ] ; then
  echo "Response must be Y or N"
  exit
  else SEXMATCH=`echo $SEXMATCH | cut -c 1`
fi

#PULLING-T1-LONG-IMAGE______________________________________________________

dash=`echo $1 | cut -c 5`
    if [ "$dash" = "-" ]; then
    DATE=`echo $1 | cut -c 6-15`
    PIDN=`echo $1 | cut -c 1-4`
    else DATE=`echo $1 | cut -c 7-16`
         PIDN=`echo $1 | cut -c 1-5`
        fi  
    if [ $PIDN -lt 1000 ]; then
        block="0000-0999"
    fi
    if [ $PIDN -ge 1000 ] && [ $PIDN -lt 10000 ]; then
        first=`echo $PIDN | cut -c 1`
        block="${first}000-${first}999"
    fi
    if [ $PIDN -ge 10000 ]; then
        firsttwo=`echo $PIDN | cut -c 1-2`
        block="${firsttwo}000-${firsttwo}999"
    fi
    if [ $PIDN -lt 1000 ]; then
        block="0000-0999"
    fi
    if [ $PIDN -ge 1000 ] && [ $PIDN -lt 10000 ]; then
        first=`echo $PIDN | cut -c 1`
        block="${first}000-${first}999"
    fi
    if [ $PIDN -ge 10000 ]; then
        firsttwo=`echo $PIDN | cut -c 1-2`
        block="${firsttwo}000-${firsttwo}999"
    fi
echo ""
echo -e "${lightblue}Pulling T1-LONG image for ${PIDN} on ${DATE}${NC}"

if [ -d "/mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/" ]; then
  mkdir -p ./${1}
  cd ./${1}
FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS_*nii" | head -1)
              if [ -f "$FILE" ]; then
              echo -e "${NC}T1-LONG exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                      cp $FILE .;
                      elif [[ ! -f "$FILE" ]];  then
                        FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS_*img" | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS_*hdr" | head -1)
                        if [ -f "$FILE" ] && [ -f "$HEADER" ] ; then
                        echo -e "${NC}T1-LONG exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        cp $FILE .;
                        cp $HEADER .;
                        else echo -e "${red}${PIDN} has no T1-LONG on ${DATE}${NC}"
                            exit
                        fi
                      fi
                    else echo ""
                         echo -e "${red}${PIDN} has no scan on ${DATE}${NC}";
                         exit
                    fi

#___________________________________________________________________________

 if [ -f ./MP-LAS*hdr ]; then
 FILE=$(ls MP-LAS*img);
else FILE=$(ls MP-LAS*nii);
fi
 scanID=`echo ${FILE} | cut -c 8-200 | rev | cut -c 5-200 | rev`
 scannoext=`echo ${FILE} | rev | cut -c 5-200 | rev`
 NOW=$(date +"%Y%m%d%H%M")
 home=$(pwd)

# #Determine best control group________________________________________
    echo ""
    echo -e "${lightblue}Determining best control group for ${scannoext}${NC}"
    mkdir -p ./controls_$NOW
    if [ "$SEXMATCH" == 'Y' ] || [ "$SEXMATCH" == 'y' ]; then 
    for i in $(ls ../singvbm/all_controls/[0-9]*_${SEX}_*nii | xargs -n1 basename); 
      do age=`echo ${i} | cut -c 1-2`; 
      diff=`expr ${AGE} - ${age}`; 
      if [ $diff -lt 0 ]; 
      then diff=`expr ${diff} \* -1`;
      fi; 
      echo ${diff}-${i} >> ./temp.txt; 
      done
    else for i in $(ls ../singvbm/all_controls/[0-9]*nii | xargs -n1 basename); 
      do age=`echo ${i} | cut -c 1-2`; 
      diff=`expr ${AGE} - ${age}`; 
    if [ $diff -lt 0 ]; 
      then diff=`expr ${diff} \* -1`;
    fi; 
    echo ${diff}-${i} >> ./temp.txt; 
    done
  fi

  for i in $(cat temp.txt | sort -n | head -${CONNUM}); 
    do dash=`echo ${i} | cut -c 2`; 
      if [ $dash = "-" ]; 
        then diff=`echo ${i} | cut -c 1`; 
        file=`echo ${i} | cut -c 3-200`; 
      else diff=`echo ${i} | cut -c 1-2`; 
        file=`echo ${i} | cut -c 4-200`; 
      fi; 
      cp ../singvbm/all_controls/${file} ./controls_$NOW; 
      done
  rm temp.txt

  cd ./controls_$NOW
  ls [0-9]*nii | cut -c 1-2 >> ./age.txt;
  mean_age=$(awk '{ total += $1; count++ } END { print total/count }' ./age.txt)
  min=`cat age.txt | sort -n | head -1`
  max=`cat age.txt | sort -n | tail -1`
  echo "Control group has a mean age of $mean_age, with a range of $min to $max"
  min=`cat age.txt | head -1`
  echo ${AGE} >> ./age.txt;
  ls [0-9]*nii | cut -c 4 >> ./sex.txt
    avg_sex=$(awk '{ total += $1; count++ } END { print total/count }' ./sex.txt)
    avg_sex=$(echo ${avg_sex} - 1 | bc)
    avg_sex=$(echo ${avg_sex} \* 100 | bc | cut -c 1-4)
    echo "${avg_sex}% of the control group is female"
  echo ${SEX} >> ./sex.txt
  ls [0-9]*nii | cut -c 6-12 >> ./tivs.txt
  cd ..

echo "Proceed? (Y/N)"
read PROCEED 
PROCEED=`echo $PROCEED | cut -c 1`
if [ $PROCEED != "n" ] && [ $PROCEED != "N" ] && [ $PROCEED != "y" ] && [ $PROCEED != "Y" ]; then
  echo "Proceed? (Y/N)"
  read PROCEED 
  PROCEED=`echo $PROCEED | cut -c 1`
fi
if [ $PROCEED == "n" ] || [ $PROCEED == "N" ]; then
  exit
fi

PROCEED='Y'



#Segment the scan_______________________________________________________________________________________
      
      if [ $PROCEED = 'Y' ] || [ $PROCEED = 'y' ]; then
      echo ""
      echo -e "${lightblue}Segmenting ${scannoext}${NC}"
      matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),spm12_segment('./${FILE}','../singvbm/spm12b'),quit()" 1>/dev/null;
      echo "Check segmentation quality"
      LD_LIBRARY_PATH=/usr/lib 
      fslview ${FILE} c1${scannoext}.nii -l Red -t 0.5 c2${scannoext}.nii -l Blue -t 0.5
      fi

      echo "Proceed? (Y/N)"
      read PROCEED 
      PROCEED=`echo $PROCEED | cut -c 1`
      if [ $PROCEED != "n" ] && [ $PROCEED != "N" ] && [ $PROCEED != "y" ] && [ $PROCEED != "Y" ]; then
        echo "Proceed? (Y/N)"
        read PROCEED 
        PROCEED=`echo $PROCEED | cut -c 1`
      fi
      if [ $PROCEED == "n" ] || [ $PROCEED == "N" ]; then
      exit
      fi
      
      if [ $PROCEED = 'Y' ] || [ $PROCEED = 'y' ]; then
      echo ""
      echo -e "${lightblue}Calculating TIV for ${scannoext}${NC}"
      LD_LIBRARY_PATH=/usr/local/MATLAB/R2013a/bin/glnxa64:/usr/local/MNE-2.7.3-3268-Linux-x86_64/lib:/usr/lib/fsl/5.0;
      volGM=`fslstats c1${scannoext}.nii -V -M | awk '{ vol = $2 * $3 ; print vol }'`
      echo ${scannoext} >> ./tiv_${scannoext}.txt
      echo "Gray matter volume = ${volGM}"
      echo "Gray matter volume = ${volGM}" >> ./tiv_${scannoext}.txt
      volWM=`fslstats c2${scannoext}.nii -V -M | awk '{ vol = $2 * $3 ; print vol }'`
      echo "White matter volume = ${volWM}"
      echo "White matter volume = ${volWM}" >> ./tiv_${scannoext}.txt
      volCSF=`fslstats c3${scannoext}.nii -V -M | awk '{ vol = $2 * $3 ; print vol }'`
      echo "CSF volume = ${volCSF}"
      echo "CSF volume = ${volCSF}" >> ./tiv_${scannoext}.txt
      TIV=`expr ${volGM} + ${volCSF} + ${volWM}`
      echo "TIV = ${TIV}"
      echo "TIV = ${TIV}" >> ./tiv_${scannoext}.txt
      echo ${TIV} >> ./controls_$NOW/tivs.txt
      cd $home
#Register to pre-existing dartel template__________________________________________________________________
      echo ""
      echo -e "${lightblue}Registering rc1${scannoext}.nii and rc2${scannoext}.nii to pre-existing DARTEL template${NC}"
      rc1image=$(ls rc1${scannoext}.nii)
      rc2image=$(ls rc2${scannoext}.nii)
      matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),spm12_dartel('./${rc1image}','./${rc2image}','../singvbm'),quit()" 1>/dev/null;
      cd $home

#Normalize to MNI space and smooth with 8 mm kernel________________________________________________________
      
      echo ""
      echo -e "${lightblue}Normalizing c1_${scannoext}.nii to MNI space and smoothing with 8mm kernel${NC}"
      c1image=$(ls c1${scannoext}.nii)
      uimage=$(ls u_rc1${scannoext}.nii)
      matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),spm12_mnidartelreg('./${c1image}','./${uimage}','../singvbm'),quit()" 1>/dev/null
      cd $home
      fi

#Run VBM analysis
      echo ""
      echo -e "${lightblue}Running VBM...${NC}"
      echo "Generating model"
      mkdir ./results_$NOW
      smwc1image=$(ls smwc1${scannoext}.nii)
      matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),spm12_model_build('./${smwc1image}','./controls_$NOW','./results_$NOW','./controls_$NOW/age.txt','./controls_$NOW/tivs.txt'),quit()" 1>/dev/null
      cd $home
      echo "Estimating model"
      matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),spm12_model_estimate('./results_$NOW/SPM.mat'),quit()" 1>/dev/null
      echo "Creating contrasts"
      matlab -nojvm -nodesktop -nodisplay -nosplash -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),spm12_contrasts('./results_$NOW/SPM.mat'),quit()" 1>/dev/null
      echo "Generating results..."
      matlab -nosplash -nodesktop -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),spm12_results('./results_$NOW/SPM.mat'),quit()" 1>/dev/null
      matlab -nojvm -nosplash -nodesktop -nodisplay -r "addpath(strcat(pwd,'/../singvbm')),addpath(strcat(pwd,'/../singvbm/spm12b')),calculate_T_value('./results_$NOW'),quit()" 1>/dev/null
      tvalue=$(cat ./results_$NOW/tvalue.txt | cut -c 1-5)
      fslmaths ./results_$NOW/spmT_0001.nii -thr $tvalue ./results_$NOW/thr001_spmT_0001.nii; 
      gunzip ./results_$NOW/thr001*gz
      LD_LIBRARY_PATH=/usr/lib; fslview $smwc1image ./results_$NOW/thr001_spmT_0001.nii -l Red -t 0.8;
exit
