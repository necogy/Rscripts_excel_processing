echo "STUDY?"
read STUDY
echo "SOURCE ID?"
read SOURCEID
echo "PIDN?"
read PIDN
echo "FIRST NAME?"
read FIRSTNAME
echo "LAST NAME?"
read LASTNAME
echo "SCAN DATE?"
read SCANDATE
echo "YOUR USERNAME?"
read YOURNAME


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


SOURCEIDX=`echo ${SOURCEID/-/X}`
echo $SOURCEIDX

qpath=/Volumes/Imaging432A/images432A/PIDN/${block}/${PIDN}/${SCANDATE}/${SOURCEID}_${LASTNAME},${FIRSTNAME}
rpath=/mnt/tank2/macdata/projects/images/${block}/${PIDN}/${SCANDATE}/${SOURCEID}_${LASTNAME},${FIRSTNAME}

alias dcm2nii='~/scripts/dcm2nii'

if [ $STUDY == "NIFD" ] || [ $STUDY == "PPG" ] || [ $STUDY == "ADRC" ] || [ $STUDY == "HB" ] || [ $STUDY == "FRTNI" ] || [ $STUDY == "HV" ] ; then

#DIFFUSION______________________________________________________
    DWIP2=$(ls -d DIFFUSION_*_SCAN_TRACE_P2_* 2>/dev/null | grep -v "ADC" | head -1 )
    DWIP2NO=$(ls -d DIFFUSION_*_SCAN_TRACE_P2_* 2>/dev/null | grep -v "ADC" | wc -w)
        if [ -d $DWIP2 ] && [ $DWIP2NO -ge 1 ]; then 
        echo "${DWIP2NO} DWI P2 sequence(s) found - zipping DICOMs and generating NIFTI image for $DWIP2" | sed 's/^ *//'
        zip -r -q DWI-RPD-B0_${SOURCEIDX} ${DWIP2} -i *-0001.dcm *-0002.dcm *-0003.dcm *-0004.dcm *-0005.dcm *-0006.dcm *-0007.dcm *-0008.dcm *-0009.dcm *-0010.dcm *-0011.dcm *-0012.dcm *-0013.dcm *-0014.dcm *-0015.dcm *-0016.dcm *-0017.dcm *-0018.dcm *-0019.dcm *-0020.dcm *-0021.dcm *-0022.dcm
        zip -r -q DWI-RPD-B2000_${SOURCEIDX} ${DWIP2} -i *-0023.dcm *-0024.dcm *-0025.dcm *-0026.dcm *-0027.dcm *-0028.dcm *-0029.dcm *-0030.dcm *-0031.dcm *-0032.dcm *-0033.dcm *-0034.dcm *-0035.dcm *-0036.dcm *-0037.dcm *-0038.dcm *-0039.dcm *-0040.dcm *-0041.dcm *-0042.dcm *-0043.dcm *-0044.dcm
        DWIP2IM=$(basename `ls $DWIP2/IM*0001.dcm 2>/dev/null` 2>/dev/null)
        if [ -f ./$DWIP2/$DWIP2IM ]; then 
        cd ./$DWIP2 ; dcm2nii $DWIP2IM 1>/dev/null; rm *.bval ; rm *.bvec ; mv *_1.nii ../DWI-RPD-B0_${SOURCEIDX}.nii ; mv *_2.nii ../DWI-RPD-B2000_${SOURCEIDX}.nii ; cd ..
        else echo "NO DICOMS FOUND FOR $DWIP2"
        fi
        else echo "NO DWI P2 SEQUENCE FOUND"
        fi
    DWIP2ADC=$(ls -d DIFFUSION_*_SCAN_TRACE_P2_ADC* 2>/dev/null | head -1) 
    DWIP2ADCNO=$(ls -d DIFFUSION_*_SCAN_TRACE_P2_ADC* 2>/dev/null | wc -w) 
        if [ -d DIFFUSION_*_SCAN_TRACE_P2_ADC* ] && [ $DWIP2ADCNO -ge 1 2>/dev/null ]; then
        echo "${DWIP2ADCNO} DWI P2 ADC sequence(s) found - zipping DICOMs and generating NIFTI image for $DWIP2ADC" | sed 's/^ *//'
        zip -r -q DWI-RPD-ADC_${SOURCEIDX} ./${DWIP2ADC}/*
        DWIP2ADCIM=$(basename `ls $DWIP2ADC/IM*0001.dcm 2>/dev/null` 2>/dev/null)
        if [[ -f ./$DWIP2ADC/$DWIP2ADCIM ]]; then 
        cd $DWIP2ADC ; dcm2nii $DWIP2ADCIM 1>/dev/null ; mv *.nii ../DWI-RPD-ADC_${SOURCEIDX}.nii ; cd ..
        else echo "DICOMs MISSING FOR $DWIP2ADC"
        fi
        else echo "NO DWI P2 ADC SEQUENCE FOUND"
        fi

#ASL_______________________________________________________________
    PASL=$(ls -d pASL_* 2>/dev/null | head -1)
    PASLNO=$(ls -d pASL_* 2>/dev/null | wc -w)
    underscore=`echo $PASL | rev | cut -c 2`
    if [[ $underscore != "_" ]]; then
    PASLSEQNUM=`echo $PASL | rev | cut -c 1-2 | rev`
    else PASLSEQNUM=`echo $PASL | rev | cut -c 1 | rev`
    fi
    MOCOSEQNUM=`expr $PASLSEQNUM + 1 2>/dev/null` 
    MoCo=$(ls -d MoCo*$MOCOSEQNUM 2>/dev/null)
    MOCONO=$(ls -d MoCo*$MOCOSEQNUM 2>/dev/null | wc -w)
       if [ -d pASL_* ] && [ -d $MoCo ]; then
       echo "${PASLNO} ASL sequence(s) found - zipping DICOMs for $PASL"  | sed 's/^ *//' 
       zip -q ASL-raw-v1_${SOURCEIDX} ./$PASL/* 
       echo "${MOCONO} ASL-MoCo  sequence(s) found - zipping DICOMs for $MoCo"  | sed 's/^ *//'
       zip -q ASL-MoCo-v1_${SOURCEIDX} ./$MoCo/*
       else echo "NO ASL SEQUENCES FOUND"
       fi

#DTIV1_________________________________________________________________
    DTIV1B0=$(find . -type d -name "DTI_b=0_22iso_full_ky__10_acqs*" | head -1 )
    DTIV164=$(find . -type d -name "DTI_64_22iso_full_ky_fov220*" | head -1 )
    DTIV164NO=$(ls -d DTI_64_22iso_full_ky_fov220* 2>/dev/null | wc -w)
       if [ -d ./DTI_b=0_22iso_full_ky__10_acqs* ] && [ -d $DTIV164 ]; then
       echo "${DTIV164NO} DTI-V1 sequence(s) found - zipping DICOMs for $DTIV1B0 and $DTIV164"  | sed 's/^ *//'
       zip DTI-b0-v1_${SOURCEIDX} ./$DTIV1B0/*; 
                 zip -q DTI-64-v1_${SOURCEIDX} ./$DTIV164/*; 
                 zip -q DTI-v1_${SOURCEIDX} DTI-b0-v1_${SOURCEIDX}.zip DTI-64-v1_${SOURCEIDX}.zip; 
                 rm DTI-b0-v1_${SOURCEIDX}.zip;
                 rm DTI-64-v1_${SOURCEIDX}.zip;
       else echo "NO DTI-V1 SEQUENCES FOUND"
       fi

#DTIV2______________________________________________________________
    DTIV2B0=$(ls -d ep2dadvdiff511E_b0_scan_* 2>/dev/null | head -1)
    DTIV2B0NO=$(ls -d ep2dadvdiff511E_b0_scan_* 2>/dev/null | wc -w)
    DTIV2B0SEQNUM=`echo $DTIV2B0 | rev | cut -c 1-2 | rev`
    DTIV264SEQNUM=`expr $DTIV2B0SEQNUM + 1 2>/dev/null`
    DTIV264=$(ls -d ep2dadvdiff511E_b2000_64dir_${DTIV264SEQNUM} 2>/dev/null)
       if [ -d ep2dadvdiff511E_b0_scan_* ] && [ -d $DTIV264 ]; then
       echo "${DTIV2B0NO} DTI-V2 sequence(s) found - zipping DICOMs for $DTIV2B0 and $DTIV264"  | sed 's/^ *//'
       zip -q DTI-b0-v2_${SOURCEIDX} ./$DTIV2B0/* ; 
       zip -q DTI-64-v2_${SOURCEIDX} ./$DTIV264/* ; 
       zip -q DTI-v2_${SOURCEIDX} DTI-b0-v2_${SOURCEIDX}.zip DTI-64-v2_${SOURCEIDX}.zip ;
       rm DTI-b0-v2_${SOURCEIDX}.zip ;
       rm DTI-64-v2_${SOURCEIDX}.zip
       else echo "NO DTI-V2 SEQUENCES FOUND"
       fi

#NIFD-DTI____________________________________________
    NIFDDTI=$(ls -d NIFD* 2>/dev/null | grep -v "ADC" | grep -v "FA" | grep -v "ColFA" | grep -v "TRACEW")
    NIFDDTINO=$(ls -d NIFD* 2>/dev/null | grep -v "ADC" | grep -v "FA" | grep -v "ColFA" | grep -v "TRACEW" | wc -w)
    NIFDDTISEQNUM=`echo $NIFDDTI | rev | cut -c 1-2 | rev`
        if [[ -d NIFD_DTI_b1000_27mm3_511E_${NIFDDTISEQNUM} ]]; then
        echo "${NIFDDTINO} NIFD-DTI sequence(s) found - zipping DICOMs for $NIFDDTI"  | sed 's/^ *//'
        zip -q DTI-v4_${SOURCEIDX} ./$NIFDDTI/*
        else echo "NO NIFD-DTI SEQUENCES FOUND"
        fi

#RESTING_STATE___________________________________________________
    RS=$(ls -d R*hole*rain_* 2>/dev/null | head -1 )
    RSNO=$(ls -d R*hole*rain_* 2>/dev/null | wc -w )
    FMNO=$(ls -d gre_field_mapping*RS* 2>/dev/null | wc -w )
    FM1=$(ls -d gre_field_mapping*RS* 2>/dev/null | head -1)
    underscore=`echo $FM1 | rev | cut -c 2`
    if [[ $underscore != "_" ]]; then
    FM1no=`echo $FM1 | rev | cut -c 1-2 | rev`
    else FM1no=`echo $FM1 | rev | cut -c 1 | rev`
    fi
    FM2no=`expr $FM1no + 1 2>/dev/null` 
    FM2=$(ls -d gre_field_mapping*RS*${FM2no} 2>/dev/null)
       if [[ -d $RS ]] ; then
       echo "${RSNO} RS sequence(s) found - zipping DICOMs for $RS"  | sed 's/^ *//'
       zip -q rsfMRI-raw-vH1_${SOURCEIDX} ./$RS/* ; 
       else echo "NO RESTING STATE SEQUENCE FOUND"
       fi
       if [[ -d $FM1 ]] && [[ -d $FM2 ]]; then
       echo "${FMNO} RS Field Mapping sequence(s) found - zipping DICOMs for $FM1 and $FM2"  | sed 's/^ *//'
       zip -q GRE-Field-Map-Phase-raw-v1_${SOURCEIDX} ./$FM1/* ;
       zip -q GRE-Field-Map-Magnitude-raw-v1_${SOURCEIDX} ./$FM2/*;
       zip -q GRE-Field-Map-raw-v1_${SOURCEIDX} GRE-Field-Map-Phase-raw-v1_${SOURCEIDX}.zip GRE-Field-Map-Magnitude-raw-v1_${SOURCEIDX}.zip ;
       rm GRE-Field-Map-Phase-raw-v1_${SOURCEIDX}.zip ;
       rm GRE-Field-Map-Magnitude-raw-v1_${SOURCEIDX}.zip
     else echo "NO FIELD MAPPING SEQUENCES FOUND"
       fi

#T1-LONG___________________________________________________________
     T1LONG=$(ls -d T1_mprage* 2>/dev/null | grep -v "DIS3D" | grep -v "short" | head -1)
     T1LONGNO=$(ls -d T1_mprage* 2>/dev/null | grep -v "DIS3D" | grep -v "short" | wc -w)
     T1LONGIM=$(basename `ls $T1LONG/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $T1LONG/$T1LONGIM ] && [ $T1LONGNO == 1 ]; then
     echo "${T1LONGNO} T1-LONG sequence(s) found - zipping DICOMs and generating NIFTI images for $T1LONG"  | sed 's/^ *//'
     cd ./$T1LONG ; 
     zip -q -T -9 ../MP-LAS_${SOURCEIDX} * ; 
     dcm2nii $T1LONGIM 1>/dev/null ;
     mv o*.nii ../MP-LAS_${SOURCEIDX}.nii ; 
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
     elif [ -f $T1LONG/$T1LONGIM ] && [ $T1LONGNO -gt 1 ]; then
      for i in  $(ls -d T1_mprage* 2>/dev/null | grep -v "DIS3D" | grep -v "short");
      do T1UND=`echo ${i} | cut -c 11-12`;
   if [ "$T1UND" -lt 10 ]; then
      T1SNO=`echo ${i} | cut -c 11`;
    else T1SNO=`echo ${i} | cut -c 11-12`;
   fi;
     T1LONGIM=$(basename `ls ${i}/IM*0001.dcm`)
      echo "${T1LONGNO} T1-LONG sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$T1LONGIM ]; then
        cd ./${i}; 
        zip -v -T -q ../MP-LAS_${SOURCEIDX}_${T1SNO} * ; 
        dcm2nii $T1LONGIM 1>/dev/null;
        mv o*.nii ../MP-LAS_${SOURCEIDX}_${T1SNO}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
    else echo "NO T1-LONG SEQUENCES FOUND"
      fi
   


#T1-LONG-3DC_____________________________________________________
     T1LONG3DC=$(ls -d T1_mprage_S*_DIS3D* 2>/dev/null | head -1)
     T1LONG3DCNO=$(ls -d T1_mprage_S*_DIS3D* 2>/dev/null | wc -w)
     T1LONG3DCIM=$(basename `ls $T1LONG3DC/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $T1LONG3DC/$T1LONG3DCIM ] && [ $T1LONG3DCNO == 1 ]; then
     echo "${T1LONG3DCNO} T1-LONG-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for $T1LONG3DC"  | sed 's/^ *//'
     cd ./$T1LONG3DC;
     zip -q -T -9 ../MP-LAS-long-3DC_${SOURCEIDX} * ; 
     dcm2nii $T1LONG3DCIM 1>/dev/null; 
     mv o*.nii ../MP-LAS-long-3DC_${SOURCEIDX}.nii ;
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
   elif [ $T1LONG3DCNO -ge 2 ]; then
   for i in  $(ls -d T1_mprage_S*_DIS3D* 2>/dev/null);
   do T13DCUND=`echo ${i} | cut -c 13`;
   if [ $T13DCUND == "_" ]; then
      T13DCSNO_MULT=`echo ${i} | cut -c 12`;
    else T13DCSNO_MULT=`echo ${i} | cut -c 12-13`;
   fi;
     T13DCIM_MULT=$(basename `ls ${i}/IM*0001.dcm 2>/dev/null` 2>/dev/null)
      echo "${T1LONG3DCNO} T1-LONG-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$T13DCIM_MULT ]; then
        cd ./${i}; 
        zip -v -T -q ../MP-LAS-long-3DC_${SOURCEIDX}_S${T13DCSNO_MULT} * ; 
        dcm2nii $T13DCIM_MULT;
        mv o*.nii ../MP-LAS-long-3DC_${SOURCEIDX}_S${T13DCSNO_MULT}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
  else echo "NO T1-LONG-3DC SEQUENCES FOUND"
  fi


#T2_______________________________________________________________
     T2=$(ls -d T2_spc* 2>/dev/null | grep -v "DIS3D" | head -1)
     T2NO=$(ls -d T2_spc* 2>/dev/null | grep -v "DIS3D" | wc -w)
     T2IM=$(basename `ls $T2/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $T2/$T2IM ] && [ $T2NO == 1 ]; then
     echo "${T2NO} T2 sequence(s) found - zipping DICOMs and generating NIFTI images for $T2"  | sed 's/^ *//'
     cd ./$T2 ; 
     zip -q -T -9 ../T2_${SOURCEIDX} * ; 
     dcm2nii $T2IM 1>/dev/null ;
     mv o*.nii ../T2_${SOURCEIDX}.nii ; 
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
     elif [ -f $T2/$T2IM ] && [ $T2NO -gt 1 ]; then
      for i in  $(ls -d T2_spc* 2>/dev/null | grep -v "DIS3D");
      do T2UND=`echo ${i} | cut -c 25-26`;
   if [ "$T2UND" -lt 10 ]; then
      T2SNO=`echo ${i} | cut -c 25`;
    else T2SNO=`echo ${i} | cut -c 25-26`;
   fi;
     T2IM=$(basename `ls ${i}/IM*0001.dcm`)
      echo "${T2NO} T2 sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$T2IM ]; then
        cd ./${i}; 
        zip -v -T -q ../T2_${SOURCEIDX}_${T2SNO} * ; 
        dcm2nii $T2IM 1>/dev/null;
        mv o*.nii ../T2_${SOURCEIDX}_${T2SNO}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
    else echo "NO T2 SEQUENCES FOUND"
      fi




#T2-3DC_______________________________
     T23DC=$(ls -d T2_spc_ns_sag_p2_iso_fs_S*_DIS3D* 2>/dev/null | head -1)
     T23DCNO=$(ls -d T2_spc_ns_sag_p2_iso_fs_S*_DIS3D* 2>/dev/null | wc -w)
     T23DCIM=$(basename `ls $T23DC/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $T23DC/$T23DCIM ] && [ $T23DCNO == 1 ]; then
     echo "${T23DCNO} T2-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for $T23DC"  | sed 's/^ *//'
     cd ./$T23DC;
     zip -q -T -9 ../T2-3DC_${SOURCEIDX} * ; 
     dcm2nii $T23DCIM 1>/dev/null; 
     mv o*.nii ../T2-3DC_${SOURCEIDX}.nii ;
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
   elif [ $T23DCNO -ge 2 ]; then
   for i in  $(ls -d T2_spc_ns_sag_p2_iso_fs_S*_DIS3D* 2>/dev/null );
   do T23DCUND=`echo ${i} | cut -c 27`;
   if [ $T23DCUND == "_" ]; then
      T23DCSNO_MULT=`echo ${i} | cut -c 26`;
    else T23DCSNO_MULT=`echo ${i} | cut -c 26-27`;
   fi;
     T23DCIM_MULT=$(basename `ls ${i}/IM*0001.dcm 2>/dev/null` 2>/dev/null)
      echo "${T23DCNO} T2-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$T23DCIM_MULT ]; then
        cd ./${i}; 
        zip -v -T -q ../T2-3DC_${SOURCEIDX}_S${T23DCSNO_MULT} * ; 
        dcm2nii $T23DCIM_MULT 1>/dev/null;
        mv o*.nii ../T2-3DC_${SOURCEIDX}_S${T23DCSNO_MULT}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
  else echo "NO T2-3DC SEQUENCES FOUND"
  fi


#FLAIR_______________
     FLAIR=$(ls -d T2_flair_* 2>/dev/null | grep -v "DIS3D" | head -1)
     FLAIRNO=$(ls -d T2_flair* 2>/dev/null | grep -v "DIS3D" | wc -w)
     FLAIRIM=$(basename `ls $FLAIR/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $FLAIR/$FLAIRIM ] && [ $FLAIRNO == 1 ]; then
     echo "${FLAIRNO} FLAIR sequence(s) found - zipping DICOMs and generating NIFTI images for $FLAIR"  | sed 's/^ *//'
     cd ./$FLAIR ; 
     zip -q -T -9 ../FLAIR_${SOURCEIDX} * ; 
     dcm2nii $FLAIRIM 1>/dev/null ;
     mv o*.nii ../FLAIR_${SOURCEIDX}.nii ; 
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
     elif [ -f $FLAIR/$FLAIRIM ] && [ $FLAIRNO -gt 1 ]; then
      for i in  $(ls -d T2_flair* 2>/dev/null | grep -v "DIS3D");
      do FLAIRUND=`echo ${i} | cut -c 10-11`;
   if [ "$FLAIRUND" -lt 10 ]; then
      FLAIRSNO=`echo ${i} | cut -c 10`;
    else FLAIRSNO=`echo ${i} | cut -c 10-11`;
   fi;
    FLAIRIM=$(basename `ls ${i}/IM*0001.dcm`)
      echo "${FLAIRNO} FLAIR sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$FLAIRIM ]; then
        cd ./${i}; 
        zip -v -T -q ../FLAIR_${SOURCEIDX}_${FLAIRSNO} * ; 
        dcm2nii $FLAIRIM 1>/dev/null;
        mv o*.nii ../FLAIR_${SOURCEIDX}_${FLAIRSNO}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
    else echo "NO FLAIR SEQUENCES FOUND"
      fi

  #FLAIR-3DC_______________________________
     FLAIR3DC=$(ls -d T2_flair_*DIS3D* 2>/dev/null | head -1)
     FLAIR3DCNO=$(ls -d T2_flair_*DIS3D* 2>/dev/null | wc -w)
     FLAIR3DCIM=$(basename `ls $FLAIR3DC/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $FLAIR3DC/$FLAIR3DCIM ] && [ $FLAIR3DCNO == 1 ]; then
     echo "${FLAIR3DCNO} FLAIR-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for $FLAIR3DC"  | sed 's/^ *//'
     cd ./$FLAIR3DC;
     zip -q -T -9 ../FLAIR-3DC_${SOURCEIDX} * ; 
     dcm2nii $FLAIR3DCIM 1>/dev/null; 
     mv o*.nii ../FLAIR-3DC_${SOURCEIDX}.nii ;
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
   elif [ $FLAIR3DCNO -ge 2 ]; then
   for i in  $(ls -d T2_flair_*DIS3D* 2>/dev/null );
   do FLAIR3DCUND=`echo ${i} | cut -c 12`;
   if [ $FLAIR3DCUND == "_" ]; then
      FLAIR3DCSNO_MULT=`echo ${i} | cut -c 11`;
    else FLAIR3DCSNO_MULT=`echo ${i} | cut -c 11-12`;
   fi;
     FLAIR3DCIM_MULT=$(basename `ls ${i}/IM*0001.dcm 2>/dev/null` 2>/dev/null)
      echo "${FLAIR3DCNO} FLAIR-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$FLAIR3DCIM_MULT ]; then
        cd ./${i}; 
        zip -v -T -q ../FLAIR-3DC_${SOURCEIDX}_S${FLAIR3DCSNO_MULT} * ; 
        dcm2nii $FLAIR3DCIM_MULT 1>/dev/null;
        mv o*.nii ../FLAIR-3DC_${SOURCEIDX}_S${FLAIR3DCSNO_MULT}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
  else echo "NO FLAIR-3DC SEQUENCES FOUND"
  fi
   
#T1-SHORT_________________________________________________________________________
     T1SHORT=$(ls -d T1_mprage_short_* 2>/dev/null | grep -v "DIS3D" | head -1)
     T1SHORTNO=$(ls -d T1_mprage_short_* 2>/dev/null | grep -v "DIS3D" | wc -w)
     T1SHORTIM=$(basename `ls $T1SHORT/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $T1SHORT/$T1SHORTIM ] && [ $T1SHORTNO == 1 ]; then
     echo "${T1SHORTNO} T1-SHORT sequence(s) found - zipping DICOMs and generating NIFTI images for $T1SHORT"  | sed 's/^ *//'
     cd ./$T1SHORT; 
     zip -q -T -9 ../MP-LAS-short_${SOURCEIDX} * ; 
     dcm2nii $T1SHORTIM 1>/dev/null ;
     mv o*.nii ../MP-LAS-short_${SOURCEIDX}.nii ; 
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
     elif [ -f $T1SHORT/$T1SHORTIM ] && [ $T1SHORTNO -gt 1 ]; then
      for i in  $(ls -d T1_mprage_short_* 2>/dev/null | grep -v "DIS3D");
      do T1SHORTUND=`echo ${i} | cut -c 17-18`;
   if [ "$T1SHORTUND" -lt 10 ]; then
      T1SHORTSNO=`echo ${i} | cut -c 17`;
    else T1SHORTSNO=`echo ${i} | cut -c 17-18`;
   fi;
    T1SHORTIM=$(basename `ls ${i}/IM*0001.dcm`)
      echo "${T1SHORTNO} T1-SHORT sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$T1SHORTIM ]; then
        cd ./${i}; 
        zip -v -T -q ../MP-LAS-short_${SOURCEIDX}_${T1SHORTSNO} * ; 
        dcm2nii $T1SHORTIM 1>/dev/null;
        mv o*.nii ../MP-LAS-short_${SOURCEIDX}_${T1SHORTSNO}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
    else echo "NO T1-SHORT SEQUENCES FOUND"
      fi


#T1-SHORT-3DC_______________________________________________
     T1SHORT3DC=$(ls -d T1_mprage_short_*DIS3D* 2>/dev/null | head -1)
     T1SHORT3DCNO=$(ls -d T1_mprage_short_*DIS3D* 2>/dev/null | wc -w)
     T1SHORT3DCIM=$(basename `ls $T1SHORT3DC/IM*0001.dcm 2>/dev/null` 2>/dev/null)
     if [ -f $T1SHORT3DC/$T1SHORT3DCIM ] && [ $T1SHORT3DCNO == 1 ]; then
     echo "${T1SHORT3DCNO} T1-SHORT-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for $T1SHORT3DC"  | sed 's/^ *//'
     cd ./$T1SHORT3DC;
     zip -q -T -9 ../MP-LAS-short-3DC_${SOURCEIDX} * ; 
     dcm2nii $T1SHORT3DCIM 1>/dev/null; 
     mv o*.nii ../MP-LAS-short-3DC_${SOURCEIDX}.nii ;
     rm -r -f c*.nii ; 
     rm -r -f 20*.nii ; 
     cd ../.
   elif [ $T1SHORT3DCNO -ge 2 ]; then
   for i in  $(ls -d T1_mprage_short_*DIS3D* 2>/dev/null );
   do T1SHORT3DCUND=`echo ${i} | cut -c 19`;
   if [ $T1SHORT3DCUND == "_" ]; then
      T1SHORT3DCSNO_MULT=`echo ${i} | cut -c 18`
    else T1SHORT3DCSNO_MULT=`echo ${i} | cut -c 18-19`;
   fi;
     T1SHORT3DCIM_MULT=$(basename `ls ${i}/IM*0001.dcm 2>/dev/null` 2>/dev/null)
      echo "${T1SHORT3DCNO} T1-SHORT-3DC sequence(s) found - zipping DICOMs and generating NIFTI images for ${i}"  | sed 's/^ *//'
        if [ -f ${i}/$T1SHORT3DCIM_MULT ]; then
        cd ./${i}; 
        zip -v -T -q ../MP-LAS-short-3DC_${SOURCEIDX}_S${T1SHORT3DCSNO_MULT} * ; 
        dcm2nii $T1SHORT3DCIM_MULT 1>/dev/null;
        mv o*.nii ../MP-LAS-short-3DC_${SOURCEIDX}_S${T1SHORT3DCSNO_MULT}.nii ; 
        rm -r -f c*.nii ; 
        rm -r -f 20*.nii ; 
        cd ../.
        fi
    done
  else echo "NO T1-SHORT-3DC SEQUENCES FOUND"
  fi

echo "Q Drive"

echo "ssh -oPort=62277 $YOURNAME@169.230.177.64 mkdir -p -v ${qpath}"

ssh -oPort=62277 $YOURNAME@169.230.177.64 mkdir -p -v ${qpath}

echo "scp -P 62277 -r -oUser=$YOURNAME -C -E -q FLAIR*.nii MP-LAS*.nii T2*.nii T1_mprage* T2_spc* T2_flair_* 169.230.177.64:${qpath}"

scp -P 62277 -r -oUser=$YOURNAME -C -E -q FLAIR*.nii MP-LAS*.nii T2*.nii T1_mprage* T2_spc* T2_flair_* 169.230.177.64:${qpath}

echo "R Drive"

echo "ssh $YOURNAME@mac-srv-nas2.ucsf.edu mkdir -p -v ${rpath}"

ssh $YOURNAME@mac-srv-nas2.ucsf.edu mkdir -p -v ${rpath}

echo "scp -P 22 -oUser=$YOURNAME -C -q *.nii *.zip mac-srv-nas2.ucsf.edu:${rpath}/. && rm *.nii *.zip"

scp -P 22 -oUser=$YOURNAME -C -q *.nii *.zip mac-srv-nas2.ucsf.edu:${rpath}/. && rm *.nii *.zip

fi


if [[ $T1LONGNO -gt 1 ]]; then echo "MULTIPLE T1-LONG SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi

if [[ $T1LONG3DCNO -gt 1 ]]; then echo "MULTIPLE T1-LONG-3DC SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi

if [[ $T2NO -gt 1 ]]; then echo "MULTIPLE T2 SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi

if [[ $T23DCNO -gt 1 ]]; then echo "MULTIPLE T2-3DC SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi

if [[ $FLAIRNO -gt 1 ]]; then echo "MULTIPLE FLAIR SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi

if [[ $FLAIR3DCNO -gt 1 ]]; then echo "MULTIPLE FLAIR-3DC SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi

if [[ $T1SHORTNO -gt 1 ]]; then echo "MULTIPLE T1-SHORT SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi

if [[ $T1SHORT3DCNO -gt 1 ]]; then echo "MULTIPLE T1-SHORT-3DC SEQUENCES PRESENT - PLEASE CHECK IMAGE QUALITY AND CHOOSE SCAN TO LINK IN LAVA"; fi



echo "Exam is linked in LAVA and R:"
echo "R:/projects/images/${block}/${PIDN}/${SCANDATE}/${SOURCEID}_${LASTNAME},${FIRSTNAME}"
