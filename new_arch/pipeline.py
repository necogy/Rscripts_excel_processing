#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
import Arterial_Spin_Labeling
#
logging.basicConfig(filename='perfusion_pipeline.log',level=logging.DEBUG)

fullpath = os.path.join(os.path.sep,"home","ycobigo","study","EPI","ASL-pipeline","Raw-data","6764","2012-06-18")
#fullpath = os.path.join(os.path.sep,"mnt","macdata","groups","imaging_core","yann")
#fullpath = os.path.join(os.path.sep,"home","ycobigo","study","EPI","ASL-pipeline","Raw-data","9757","2011-12-20")
#'PPG0246-1' for test;
asl = Arterial_Spin_Labeling.Protocol()
asl.patient_dir_ = os.path.join(fullpath, "NIFD077-1_Forsythe,Joe")
#asl.patient_dir_ = os.path.join(fullpath, "PPG0246-1_Shearer,Robert")
#asl.patient_dir_ = os.path.join(fullpath, "NIFD018-3_Sasaki,Yasushi")
asl.run()
