#!/usr/bin/python

#
# Usage:
# ./pipeline_ASL_ana.py /home/ycobigo/study/EPI/ASL-pipeline/Tools/asl.csv
#

#import pdb; pdb.set_trace()
import logging
import csv
import sys, getopt
import os, shutil
import datetime

#
# Preamble
#

#
# Date and log
date  = []
today = datetime.date.today()
date.append(today)
#print date[0]

#
# Arguments
#study_list = sys.argv[1]
if len(sys.argv) > 1:
    csv_file   = open(sys.argv[1], 'rt')
else:
    print "Usage pipeline_ASL_ana.pl /path/to/file.csv"
    quit(-1)

#
# Create a log file
if not os.path.exists( "log_ASL_ana-%s"%(date[0]) ):
    os.mkdir( "log_ASL_ana-%s"%(date[0]) )
# Log file
log_file = os.path.join( os.getcwd(), "log_ASL_ana-%s"%(date[0]), "analysis.log" )
print log_file
logging.basicConfig( filename = log_file, level = logging.DEBUG )
logging.info("__Analysis_pipeline__")

#
# Start the study
# import later for log issues ...
#
import Analysis_tools


#
# Study specifics
ASL_study = os.path.join(os.sep, 
                         "mnt","macdata","groups","imaging_core","yann","study","ASL", "Raw-ASL" )
#
if not os.path.exists( os.path.join(ASL_study, "ana_res-%s"%(date[0])) ):
    os.mkdir( os.path.join(ASL_study, "ana_res-%s"%(date[0])) )
ana_res = os.path.join( ASL_study, "ana_res-%s"%(date[0]) )
# Study specific diseases
study = ["BV","NORM (BV)","SD","R_SD","L_SD","NORM (SD)","PNFA","NORM (PNFA)"]

#
# Copy 
#
try:
    #
    # csv format
    # PIDN, Diagnosis, DCDate,     AgeAtDC, InstrID, ScannerID, SourceID, ProjName, ProjPercent,PIDN,DX
    # 1416, NORM (BV), 2010-09-07, 65,      179680,  NIC 3T,    GHB034-3, HILLBLOM, 100,7266,PNFA
    # 1416, NORM (BV), 2013-09-26, 68,      287565,  NIC 3T,    GHB034-4, HILLBLOM, 100,12640,PNFA
    #
    # We are building a list of gray matter files in to create a template

    #
    # Load csv file
    reader = csv.reader( csv_file )
    # loop over csv file for study specific
    estimators        = {}
    production_failed = []
    for row in reader:
        if study[0] in row[1]:
            #
            # create estimators if PIDN does not exist
            if not estimators.has_key(row[0]):
                estimators[row[0]] = {}
                # acquisition date list
                acquisition_dates = []
                estimators[row[0]]["dates"] = acquisition_dates
                # GM list
                acquisition_GM_T2 = []
                estimators[row[0]]["GM_T2"] = acquisition_GM_T2
                # CBF GM list
                acquisition_CBF_GM_T2 = []
                estimators[row[0]]["CBF_GM_T2"] = acquisition_CBF_GM_T2
            #
            dir = os.path.join( ASL_study, row[0], row[2])

            #
            # Checks patient dir exit
            if os.path.exists( dir ):
                # record the date
                estimators[row[0]]["dates"].append( row[2] )
                # 
                for patient in os.listdir( dir ):
                    # Checks production happened
                    patient_dir = os.path.join(dir, patient)
                    
                    # 
                    # Check the production happened
                    if os.path.exists( os.path.join(patient_dir, "ACPC_Alignment", "CBF.nii.gz") ):
                        
                        #
                        # file - 1: gray matter registered T2
                        PVE = os.path.join(patient_dir, "PVE_Segmentation")
                        GM_T2 = ""
                        if os.path.exists( PVE ):
                            for gm in os.listdir( PVE ):
                                if gm.startswith("c1") and gm.endswith("T2.nii"):
                                    GM_T2 = os.path.join(PVE, gm)
                            #
                            if os.path.exists( GM_T2 ):
                                estimators[row[0]]["GM_T2"].append( GM_T2 ) 
                            else:
                                production_failed.append( patient_dir )
                        
                        #
                        # file - 2: CBF gray matter registered T2
                        CBF_GM_T2 = os.path.join(patient_dir, "ACPC_Alignment", "CBF_GM_T2.nii.gz")
                        if os.path.exists( CBF_GM_T2 ):
                            estimators[row[0]]["CBF_GM_T2"].append( CBF_GM_T2 ) 
                        else:
                            production_failed.append( patient_dir )
                    #
                    else:
                        production_failed.append( patient_dir )
                        
    #
    # Sort and unique the the gray matter list
    # Create the template based on th first time scan
    #

    #
    # Lists for GM template construction
    GM_1_list  = []
    CBF_1_list = []
    
    #
    # 
    for PIDN in estimators:
        # print PIDN
        # check we have result
        if len( estimators[PIDN]["CBF_GM_T2"] ) > 0:
            #
            # GM
            # destination: GM_"PIDN"_"multiplicity"
            dstname_GM = "GM_%s_%s.nii"%(PIDN,"1")
            shutil.copy( estimators[PIDN]["GM_T2"][0], 
                         os.path.join(ana_res, dstname_GM) )
            #
            GM_1_list.append( dstname_GM )
            #
            # CBF
            # destination: CBF_"PIDN"_"multiplicity"
            dstname_CBF = "CBF_%s_%s.nii.gz"%(PIDN,"1")
            shutil.copy( estimators[PIDN]["CBF_GM_T2"][0], 
                         os.path.join(ana_res, dstname_CBF) )
            #
            CBF_1_list.append( dstname_CBF )


    #
    # Create the study specific template and warp images
    #

    #
    # Create the study case template and apply
    template = Analysis_tools.Make_template( "FSL", ana_res, GM_1_list )
    template.run()
    # Warp the CBF maps
    template.warp_CBF_map( CBF_1_list )
    

    #
    # Relaunch material
    #

    #
    # Check if some cases could be launch again
    production_failed.sort()
    production_set = set( production_failed )
    #
    for case in production_set:
        print "%s "%case
    
    #
    #
finally:
    csv_file.close()
