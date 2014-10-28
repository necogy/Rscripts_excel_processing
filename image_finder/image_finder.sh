#/bin/bash

#AUTHOR: JONATHAN ELOFSON
#EMAIL: JELOFSON@MEMORY.UCSF.EDU
#DATE OF LAST EDIT: 03/04/2014

echo "IMAGE TYPE?:"
read TYPE

NOW=$(date +"%Y%m%d%H%M%S")

#Error messages_______________________________________________________________________________________________________________________
if [ "$1" = "" ]; then
	echo "SYNTAX: image_finder.sh input.txt"
  echo "IMAGE TYPES: T1-LONG, T1-LONG-3DC, ADNI-T1, T1-SHORT, T1-SHORT-3DC, T2, T2-3DC, FLAIR, FLAIR-3DC, rsfMRI, DTI-v1, DTI-v2, DTI-v4, ASL";
  echo "INPUT TEXT FILE FORMAT: PIDN-YYYY-MM-DD"
	exit 
fi

if [ "$#" != "1" ]; then
	echo "Too many arguments"
	echo "SYNTAX: image_finder.sh input.txt"
	exit 
fi

if [[ $1 != *.txt ]] && [ "$1" != "help" ]; then
  echo "Text file required"
  echo "SYNTAX: image_finder.sh input.txt"
  exit 
fi

if [ "$1" = "help" ]; then
  echo "SYNTAX: image_finder.sh input.txt";
  echo "IMAGE TYPES: T1-LONG, T1-LONG-3DC, ADNI-T1, T1-SHORT, T1-SHORT-3DC, T2, T2-3DC, FLAIR, FLAIR-3DC, rsfMRI, DTI-v1, DTI-v2, DTI-v4, ASL";
  echo "INPUT TEXT FILE FORMAT: PIDN-YYYY-MM-DD"
  exit 
fi

if [ "$TYPE" != "DTI-v1" ] && [ "$TYPE" != "DTI-v2" ] && [ "$TYPE" != "DTI-v5" ] && [ "$TYPE" != "ADNI-T1" ] && [ "$TYPE" != "T1-LONG" ] && [ "$TYPE" != "T1-LONG-3DC" ] && [ "$TYPE" != "T2" ] && [ "$TYPE" != "T2-3DC" ] && [ "$TYPE" != "rsfMRI" ] && [ "$TYPE" != "FLAIR" ] && [ "$TYPE" != "FLAIR-3DC" ] && [ "$TYPE" != "ASL" ] && [ "$TYPE" != "T1-SHORT" ] && [ "$TYPE" != "T1-SHORT-3DC" ] && [ "$TYPE" != "DTI-v4" ]; then
	echo "Image type not recognized";
	echo "IMAGE TYPES: T1-LONG, T1-LONG-3DC, ADNI-T1, T1-SHORT, T1-SHORT-3DC, T2, T2-3DC, FLAIR, FLAIR-3DC, rsfMRI, DTI-v1, DTI-v2, DTI-v4, DTI-v5, ASL";
	exit;
fi

mkdir -p ./pidn_dir
mkdir -p  ./all_${TYPE}_images;

red='\e[0;31m'
NC='\e[0m' # No Color


#Determine scan date, pidn from input_____________________________________________________________________________________________________________________

for a in $(cat $1);
        do 	dash=`echo $a | cut -c 5`
        	if [ "$dash" = "-" ]; then
				DATE=`echo $a | cut -c 6-15`
	        	PIDN=`echo $a | cut -c 1-4`
	    else DATE=`echo $a | cut -c 7-16`
	    	 PIDN=`echo $a | cut -c 1-5`
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

   			if [ -d "/mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/" ]; then
   					
   					#DTI__________________________________________________________________________________________________
   					if [ "$TYPE" == "DTI-v2" ] || [ "$TYPE" == "DTI-v1" ] || [ "$TYPE" == "DTI-v4" ] || [ "$TYPE" == "DTI-v5" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 2 -name "${TYPE}*zip" | head -1)
              if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}";
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt;
   						mkdir -p  ./pidn_dir/${PIDN};
   						mkdir -p  ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                      cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                        echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt;
                    	fi
                    fi

					#T1__________________________________________________________________________________________________
   					if [ "$TYPE" == "T1-LONG" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS_*nii" | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt;
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p  ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                    	elif [[ ! -f "$FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS_*img" | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS_*hdr" | head -1)
                    		if [ -f "$IMAGE" ] && [ -f "$HEADER" ] ; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt;
   							        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE  ./pidn_dir/${PIDN}/${DATE};
                    		cp $HEADER  ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE ./all_${TYPE}_images;
                        cp $HEADER ./all_${TYPE}_images;
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                             echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt;

                        fi
                    	fi
                    fi
          #ADNI-T1__________________________________________________________________________________________________
            if [ "$TYPE" == "ADNI-T1" ]; then
              FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T1-ADNI_*nii" | head -1)
              if [ -f "$FILE" ]; then 
              echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt;
              mkdir -p ./pidn_dir/${PIDN};
              mkdir -p  ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                      elif [[ ! -f "FILE" ]];  then
                        IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T1-ADNI_*img" | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T1-ADNI_*hdr" | head -1)
                        if [ -f "$IMAGE" ] && [ -f "$HEADER" ] ; then
                        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt;
                        mkdir -p ./pidn_dir/${PIDN};
                        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE  ./pidn_dir/${PIDN}/${DATE};
                        cp $HEADER  ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE ./all_${TYPE}_images;
                        cp $HEADER ./all_${TYPE}_images;
                        else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                             echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt;
                        fi
                      fi
                    fi

   					#FLAIR__________________________________________________________________________________________________
   						if [ "$TYPE" == "FLAIR" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "FLAIR_*nii" | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp  $FILE ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "FLAIR_*img" | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "FLAIR_*hdr" | head -1)
                    		if [ -f "$IMAGE" ] && [ -f "$HEADER" ]; then
   							echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
                mkdir -p ./pidn_dir/${PIDN};
   							mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE ./pidn_dir/${PIDN}/${DATE};
                    		cp $HEADER ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE ./all_${TYPE}_images;
                        cp $HEADER ./all_${TYPE}_images;
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                        echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt
                        fi
                    	fi
                    fi

            #T2__________________________________________________________________________________________________
   						if [ "$TYPE" == "T2" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2_*nii" | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled"
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2_*img" | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2_*hdr" | head -1)
                    		if [ -f "$IMAGE" ] && [ -f "$HEADER" ] ; then
   							        echo -e "${TYPE} exists for ${PIDN} on ${DATE} and has been pulled"
   							        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
                        mkdir -p -v ./pidn_dir/${PIDN};
   							        mkdir -p -v ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE ./pidn_dir/${PIDN}/${DATE};
                    		cp $HEADER ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE ./all_${TYPE}_images;
                        cp $HEADER ./all_${TYPE}_images;
                        elif [[ ! -f "$IMAGE" ]]; then
                        IMAGE2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2-LAS_*img" | head -1)
                        HEADER2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2-LAS_*hdr" | head -1)
                        if [ -f "$IMAGE2" ] && [ -f "$HEADER2" ]; then
                        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        mkdir -p ./pidn_dir/${PIDN};
                        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 ./pidn_dir/${PIDN}/${DATE};
                        cp $HEADER2 ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 ./all_${TYPE}_images;
                        cp $HEADER2 ./all_${TYPE}_images;
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                             echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt
                        fi
                      fi
                    	fi
                    fi
                  	
            #T1 LONG 3DC__________________________________________________________________________________________________
   						if [ "$TYPE" == "T1-LONG-3DC" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-long-3DC_*nii" | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                    	elif [[ ! -f "$FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-long-3DC_*img" | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-long-3DC_*hdr" | head -1)
                        if [ -f "$IMAGE" ]; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
                        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE ./pidn_dir/${PIDN}/${DATE};
                    		cp $HEADER ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE ./all_${TYPE}_images;
                        cp $HEADER ./all_${TYPE}_images;
                    		elif [[ ! -f "$IMAGE" ]]; then
                        IMAGE2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-3DC_*img" | head -1)
                        HEADER2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-3DC_*hdr" | head -1)
                        if [ -f "$IMAGE2" ]; then
                        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
                        mkdir -p ./pidn_dir/${PIDN};
                        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 ./pidn_dir/${PIDN}/${DATE};
                        cp $HEADER2 ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 ./all_${TYPE}_images;
                        cp $HEADER2 ./all_${TYPE}_images;
                        else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                        echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt
                        fi
                        fi
                    	fi
                    	fi
            #T2 3DC__________________________________________________________________________________________________
   						if [ "$TYPE" == "T2-3DC" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2-3DC_*nii" | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
   						mkdir -p -v ./pidn_dir/${PIDN};
   						mkdir -p -v ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2-3DC_*img" | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2-3DC_*hdr" | head -1)
                    		if [ -f "$IMAGE" ]; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
                        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE $HEADER ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE $HEADER ./all_${TYPE}_images;
                        elif [[ ! -f "$IMAGE" ]]; then
                        IMAGE2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2-LAS-3DC_*img" | head -1)
                        HEADER2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "T2-LAS-3DC_*hdr" | head -1)
                        if [ -f "$IMAGE2" ]; then
                        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
                        mkdir -p ./pidn_dir/${PIDN};
                        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 $HEADER2 ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 $HEADER2 ./all_${TYPE}_images;
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                        echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt
                        fi
                      fi
                      fi
                    fi
#FLAIR 3DC__________________________________________________________________________________________________
   						if [ "$TYPE" == "FLAIR-3DC" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "FLAIR-3DC_*nii" | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
              echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./all_${TYPE}_images;
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "FLAIR-3DC_*img" | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "FLAIR-3DC_*hdr" | head -1)
                    		if [ -f "$IMAGE" ]; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							        echo -e "${PIDN} ${DATE} PULLED" >> ./${TYPE}_${NOW}.txt
                        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE $HEADER ./pidn_dir/${PIDN}/${DATE}
                        cp $IMAGE $HEADER ./all_${TYPE}_images;
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                             echo -e "${PIDN} ${DATE} NOT_FOUND" >> ./${TYPE}_${NOW}.txt
                        fi;
                    	fi
                    fi

                   	#frmi__________________________________________________________________________________________________
   					if [ "$TYPE" == "rsfMRI" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "rsfMRI*" | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p -v ./pidn_dir/${PIDN};
   						mkdir -p -v ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                    	fi
                    fi
          #T1-SHORT____________________________________________________________________________________________________
             if [ "$TYPE" == "T1-SHORT" ]; then
                  FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-short_*nii" | head -1)
                  if [ -f "$FILE" ]; then
                  echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                  mkdir -p ./pidn_dir/${PIDN};
                  mkdir -p ./pidn_dir/${PIDN}/${DATE};
                  cp $FILE ./pidn_dir/${PIDN}/${DATE};
                  elif [[ ! -f "$FILE" ]];  then
                        IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-short_*img" | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-short_*hdr" | head -1)
                        if [ -f "$IMAGE" ]; then
                            echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                            mkdir -p ./pidn_dir/${PIDN};
                            mkdir -p ./pidn_dir/${PIDN}/${DATE};
                            cp $IMAGE ./pidn_dir/${PIDN}/${DATE}
                            cp $HEADER ./pidn_dir/${PIDN}/${DATE};
                        else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                        fi
                  fi
            fi

          #T1-SHORT-3DC____________________________________________________________________________________________________
             if [ "$TYPE" == "T1-SHORT-3DC" ]; then
                  FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-short-3DC_*nii" | head -1)
                  if [ -f "$FILE" ]; then
                  echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                  mkdir -p ./pidn_dir/${PIDN};
                  mkdir -p ./pidn_dir/${PIDN}/${DATE};
                  cp $FILE ./pidn_dir/${PIDN}/${DATE};
                  elif [[ ! -f "$FILE" ]];  then
                        IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-short-3DC_*img" | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name "MP-LAS-short-3DC_*hdr" | head -1)
                        if [ -f "$IMAGE" ]; then
                            echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                            mkdir -p ./pidn_dir/${PIDN};
                            mkdir -p ./pidn_dir/${PIDN}/${DATE};
                            cp $IMAGE ./pidn_dir/${PIDN}/${DATE}
                            cp $HEADER ./pidn_dir/${PIDN}/${DATE};
                        else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                        fi
                  fi
            fi



           else	echo -e "${red}${PIDN} has no scan on ${DATE}${NC}";
                echo -e "${PIDN} ${DATE} NO_SCAN" >> ./${TYPE}_${NOW}.txt;
           fi;

done 



