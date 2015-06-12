#!/usr/bin/python
#import pdb; pdb.set_trace()
import sys, os
import logging
logging.basicConfig(filename='Analysis_pipeline.log',level=logging.DEBUG)

#
# Usage:
# ./pipeline_analysis.py
#
import Analysis_framework as ana

################################################################################
## Pipeline selection
##
## The user choses the pipeline for analysis. Available:
##    - Perfusion: Arterial Spin Labeling perfusion (ASL)
##      * /home/ycobigo/study/EPI/ASL-pipeline/Tools/asl.csv
##    - WM_hyperintensity: white matter hyper-intensity
##      * 
##    - 
##    - 
## 
#
# Argument: CVS file is the base of analysis
prod = ana.WM_hyperintensity("/home/ycobigo/study/Structural/WhiteMatterHyperintensity/wmh.csv", 
                             Procs = 8)

################################################################################
## Image extraction
##
## The user choses a destination directory for local copy of analysises images
## 
##    - Perfusion: ignore_patterns_ = ( "ASL-MoCo*","DTI*","FLAIR*","GRE*",
##                                      "rsfMRI*","DWI*" )
## 
##    - WMH: ignore_patterns_ = ( "ASL*","DTI*","GRE*","rsfMRI*","DWI*" )
## 
## 
#
#
if True:
    # Pattern to ignore within extraction
    prod.ignore_patterns_ = ( "ASL*","DTI*","GRE*","rsfMRI*","DWI*" )
    # extract directory
    Copy_dir = "/mnt/macdata/groups/imaging_core/yann/study/WMH/Raw-WMH"
    # run
    prod.extrac_images_to( Copy_dir )

################################################################################
## Run pipeline
##
## The user runs the pipeline selected
##
#
#
if False:
    # Where the extraction was done
    Copy_dir = "/mnt/macdata/groups/imaging_core/yann/study/ASL/Raw-ASL"
    # run
    prod.run_pipeline( Copy_dir )

################################################################################
## Run VBM analysis
##
## The user runs the pipeline selected
##
#
#
if False:
    # Where the extraction was done
    Copy_dir = "/mnt/macdata/groups/imaging_core/yann/study/ASL/Raw-ASL"
    # Study: ["BV","NORM (BV)","SD","R_SD","L_SD","NORM (SD)","PNFA","NORM (PNFA)"]
    prod.VBM_X_sectional( Copy_dir, "PNFA" )
