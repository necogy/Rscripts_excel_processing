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
##    - 
##    - 
##    - 
## 
#
# Argument: CVS file is the base of analysis
prod = ana.Perfusion("/home/ycobigo/study/EPI/ASL-pipeline/Tools/asl.csv", 
                     Procs = 8)

################################################################################
## Image extraction
##
## The user choses a destination directory for local copy of analysises images
## 
##    - Perfusion: ignore_patterns_ = ( "ASL-MoCo*","DTI*","FLAIR*","GRE*",
##                                      "rsfMRI*","DWI*" )
## 
## 
#
#
if False:
    # Pattern to ignore within extraction
    prod.ignore_patterns_ = ( "ASL-MoCo*","DTI*","FLAIR*",
                              "GRE*","rsfMRI*","DWI*" )
    # extract directory
    Copy_dir = "/mnt/macdata/groups/imaging_core/yann/study/ASL/Raw-ASL"
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
if True:
    # Where the extraction was done
    Copy_dir = "/mnt/macdata/groups/imaging_core/yann/study/ASL/Raw-ASL"
    # Study: ["BV","NORM (BV)","SD","R_SD","L_SD","NORM (SD)","PNFA","NORM (PNFA)"]
    prod.VBM_X_sectional( Copy_dir, "SD" )
