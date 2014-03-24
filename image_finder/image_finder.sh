#/bin/bash

if [ "$1" = "" ]; then
	echo "SYNTAX: image_finder.sh input.txt"
  echo "IMAGE TYPES: T1-LONG, T1-LONG-3DC, T1-SHORT, T1-SHORT-3DC, T2, T2-3DC, FLAIR, FLAIR-3DC, rsfMRI, DTI-V1, DTI-V2, DTI-V4, ASL";
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
  echo "IMAGE TYPES: T1-LONG, T1-LONG-3DC, T1-SHORT, T1-SHORT-3DC, T2, T2-3DC, FLAIR, FLAIR-3DC, rsfMRI, DTI-V1, DTI-V2, DTI-V4, ASL";
  echo "INPUT TEXT FILE FORMAT: PIDN-YYYY-MM-DD"
  exit 
fi

echo "IMAGE TYPE?:"
read TYPE

if [ "$TYPE" != "DTI-V1" ] && [ "$TYPE" != "DTI-V2" ] && [ "$TYPE" != "T1-LONG" ] && [ "$TYPE" != "T1-LONG-3DC" ] && [ "$TYPE" != "T2" ] && [ "$TYPE" != "T2-3DC" ] && [ "$TYPE" != "rsfMRI" ] && [ "$TYPE" != "FLAIR" ] && [ "$TYPE" != "FLAIR-3DC" ] && [ "$TYPE" != "ASL" ] && [ "$TYPE" != "T1-SHORT" ] && [ "$TYPE" != "T1-SHORT-3DC" ] && [ "$TYPE" != "DTI-V4" ]; then
	echo "Image type not recognized";
	echo "IMAGE TYPES: T1-LONG, T1-LONG-3DC, T1-SHORT, T1-SHORT-3DC, T2, T2-3DC, FLAIR, FLAIR-3DC, rsfMRI, DTI-V1, DTI-V2, DTI-V4, ASL";
	exit;
fi

mkdir -p ./pidn_dir

red='\e[0;31m'
NC='\e[0m' # No Color

for a in $(cat $1);
        do 	dash=`echo $a | cut -c 5`
        	if [ "$dash" = "-" ]; then
				DATE=`echo $a | cut -c 6-15`
	        	PIDN=`echo $a | cut -c 1-4`
	        	trail=`echo $a | cut -c 1`
	    else DATE=`echo $a | cut -c 7-16`
	    	 PIDN=`echo $a | cut -c 1-5`
	    	 trail=`echo $a | cut -c 1-2`
	    	fi	
   			if [ "$trail" = "0" ] ; then
	                block="0000-0999"
	        fi
			    if [ "$trail" = "1" ] ; then
	                block="1000-1999"
	        fi
	        if [ "$trail" = "2" ] ; then
	                block="2000-2999"
	        fi
	        if [ "$trail" = "3" ] ; then
	                block="3000-3999"
	        fi
	        if [ "$trail" = "4" ] ; then
	                block="4000-4999"
	        fi
	        if [ "$trail" = "5" ] ; then
	                block="5000-5999"
	        fi
	        if [ "$trail" = "6" ] ; then
	                block="6000-6999"
	        fi
	        if [ "$trail" = "7" ] ; then
	                block="7000-7999"
	        fi
	        if [ "$trail" = "8" ] ; then
	                block="8000-8999"
	        fi
	        if [ "$trail" = "9" ] ; then
	                block="9000-9999"
	        fi
	        if [ "$trail" = "10" ] ; then
	                block="10000-10999"
	        fi
	        if [ "$trail" = "11" ] ; then
	                block="11000-11999"
	        fi
	        if [ "$trail" = "12" ] ; then
	                block="12000-12999"
	        fi
	        if [ "$trail" = "13" ] ; then
	                block="13000-13999"
	        fi
	        if [ "$trail" = "14" ] ; then
	                block="14000-14999"
	        fi
	        if [ "$trail" = "15" ] ; then
	                block="15000-15999"
	        fi
	        if [ "$trail" = "16" ] ; then
	                block="16000-16999"
	        fi
	        if [ "$trail" = "17" ] ; then
	                block="17000-17999"
	        fi
	        if [ "$trail" = "18" ] ; then
	                block="18000-18999"
	        fi
	        if [ "$trail" = "19" ] ; then
	                block="19000-19999"
	        fi

   			if [ -d "/mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/" ]; then
   					
   					#DTI-V2__________________________________________________________________________________________________
   					if [ "$TYPE" == "DTI-V2" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 2 -name DTI-v2* | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p  ./pidn_dir/${PIDN};
   						mkdir -p  ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                    	fi
                    fi

					#T1__________________________________________________________________________________________________
   					if [ "$TYPE" == "T1-LONG" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS_*nii | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p  ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS_*img | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS_*hdr | head -1)
                    		if [ -f "$IMAGE" ]; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE  ./pidn_dir/${PIDN}/${DATE};
                    		cp $HEADER  ./pidn_dir/${PIDN}/${DATE};
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"

                        fi
                    	fi
                    fi
            #DTI-V1__________________________________________________________________________________________________
            if [ "$TYPE" == "DTI-V1" ]; then
              FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name DTI-v1* | head -1)
              if [ -f "$FILE" ]; then
              echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
              mkdir -p ./pidn_dir/${PIDN};
              mkdir -p ./pidn_dir/${PIDN}/${DATE};
                      cp $FILE ./pidn_dir/${PIDN}/${DATE};
                      else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                      fi
                    fi

            #DTI-V4__________________________________________________________________________________________________
   					if [ "$TYPE" == "DTI-V4" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name DTI-v4* | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                    	fi
                    fi

   					#FLAIR__________________________________________________________________________________________________
   						if [ "$TYPE" == "FLAIR" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name FLAIR_*nii | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp  $FILE ./pidn_dir/${PIDN}/${DATE};
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name FLAIR_*img | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name FLAIR_*hdr | head -1)
                    		if [ -f "$IMAGE" ]; then
   							echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							mkdir -p ./pidn_dir/${PIDN};
   							mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE ./pidn_dir/${PIDN}/${DATE}
                    		cp $HEADER ./pidn_dir/${PIDN}/${DATE}
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                        fi
                    	fi
                    fi

            #T2__________________________________________________________________________________________________
   						if [ "$TYPE" == "T2" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2_*nii | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled"
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2_*img | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2_*hdr | head -1)
                    		if [ -f "$IMAGE" ]; then
   							        echo -e "${TYPE} exists for ${PIDN} on ${DATE} and has been pulled"
   							        mkdir -p -v ./pidn_dir/${PIDN};
   							        mkdir -p -v ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE ./pidn_dir/${PIDN}/${DATE}
                    		cp $HEADER ./pidn_dir/${PIDN}/${DATE}
                        elif [[ ! -f "$IMAGE" ]]; then
                        IMAGE2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2-LAS_*img | head -1)
                        HEADER2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2-LAS_*hdr | head -1)
                        if [ -f "$IMAGE2" ]; then
                        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        mkdir -p ./pidn_dir/${PIDN};
                        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 ./pidn_dir/${PIDN}/${DATE};
                        cp $HEADER2 ./pidn_dir/${PIDN}/${DATE};
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                        fi
                      fi
                    	fi
                    fi
                  	
            #T1 LONG 3DC__________________________________________________________________________________________________
   						if [ "$TYPE" == "T1-LONG-3DC" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-long-3DC_*nii | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	elif [[ ! -f "$FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-long-3DC_*img | head -1)
                    		HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-long-3DC_*hdr | head -1)
                        if [ -f "$IMAGE" ]; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE ./pidn_dir/${PIDN}/${DATE};
                    		cp $HEADER ./pidn_dir/${PIDN}/${DATE};
                    		elif [[ ! -f "$IMAGE" ]]; then
                        IMAGE2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-3DC_*img | head -1)
                        HEADER2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-3DC_*hdr | head -1)
                        if [ -f "$IMAGE2" ]; then
                        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        mkdir -p ./pidn_dir/${PIDN};
                        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 ./pidn_dir/${PIDN}/${DATE};
                        cp $HEADER2 ./pidn_dir/${PIDN}/${DATE};
                        else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                        fi
                        fi
                    	fi
                    	fi
            #T2 3DC__________________________________________________________________________________________________
   						if [ "$TYPE" == "T2-3DC" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2-3DC_*nii | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p -v ./pidn_dir/${PIDN};
   						mkdir -p -v ./pidn_dir/${PIDN}/${DATE};
                    	cp $FILE ./pidn_dir/${PIDN}/${DATE};
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2-3DC_*img | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2-3DC_*hdr | head -1)
                    		if [ -f "$IMAGE" ]; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp $IMAGE ./pidn_dir/${PIDN}/${DATE}
                    		cp $HEADER ./pidn_dir/${PIDN}/${DATE}
                        elif [[ ! -f "$IMAGE" ]]; then
                        IMAGE2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2-LAS-3DC_*img | head -1)
                        HEADER2=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name T2-LAS-3DC_*hdr | head -1)
                        if [ -f "$IMAGE2" ]; then
                        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                        mkdir -p ./pidn_dir/${PIDN};
                        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                        cp $IMAGE2 ./pidn_dir/${PIDN}/${DATE};
                        cp $HEADER2 ./pidn_dir/${PIDN}/${DATE};
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}";
                        fi
                      fi
                      fi
                    fi

                        #FLAIR 3DC__________________________________________________________________________________________________
   						if [ "$TYPE" == "FLAIR-3DC" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name FLAIR-3DC_*nii | head -1)
   						if [ -f "$FILE" ]; then
   						echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   						mkdir -p ./pidn_dir/${PIDN};
   						mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    	cp -v $FILE ./pidn_dir/${PIDN}/${DATE};
                    	elif [[ ! -f "FILE" ]];  then
                    		IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name FLAIR-3DC_*img | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name FLAIR-3DC_*hdr | head -1)
                    		if [ -f "$IMAGE" ]; then
   							        echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
   							        mkdir -p ./pidn_dir/${PIDN};
   							        mkdir -p ./pidn_dir/${PIDN}/${DATE};
                    		cp -v $IMAGE ./pidn_dir/${PIDN}/${DATE}
                    		cp -v $HEADER ./pidn_dir/${PIDN}/${DATE}
                    		else echo -e "${red}${PIDN} has no ${TYPE} on ${DATE}${NC}"
                        fi;
                    	fi
                    fi

                   	#frmi__________________________________________________________________________________________________
   					if [ "$TYPE" == "rsfMRI" ]; then
   						FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name rsfMRI* | head -1)
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
                  FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-short_*nii | head -1)
                  if [ -f "$FILE" ]; then
                  echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                  mkdir -p ./pidn_dir/${PIDN};
                  mkdir -p ./pidn_dir/${PIDN}/${DATE};
                  cp $FILE ./pidn_dir/${PIDN}/${DATE};
                  elif [[ ! -f "$FILE" ]];  then
                        IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-short_*img | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-short_*hdr | head -1)
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
                  FILE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-short-3DC_*nii | head -1)
                  if [ -f "$FILE" ]; then
                  echo -e "${NC}${TYPE} exists for ${PIDN} on ${DATE} and has been pulled${NC}"
                  mkdir -p ./pidn_dir/${PIDN};
                  mkdir -p ./pidn_dir/${PIDN}/${DATE};
                  cp $FILE ./pidn_dir/${PIDN}/${DATE};
                  elif [[ ! -f "$FILE" ]];  then
                        IMAGE=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-short-3DC_*img | head -1)
                        HEADER=$(find /mnt/macdata/projects/images/${block}/${PIDN}/${DATE}/ -maxdepth 3 -name MP-LAS-short-3DC_*hdr | head -1)
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
           fi;

done 



