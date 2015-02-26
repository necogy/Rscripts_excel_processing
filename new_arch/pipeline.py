#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
import Arterial_Spin_Labeling
#
logging.basicConfig(filename='perfusion_pipeline.log',level=logging.DEBUG)

fullpath = os.path.join(os.path.sep,'mnt','macdata','groups', 'imaging_core', 'yann')
#'PPG0246-1' for test;
asl = Arterial_Spin_Labeling.Protocol()
asl.patient_dir_ = os.path.join(fullpath, "PPG0246-1_Shearer,Robert")
asl.run()
