#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
import Arterial_Spin_Labeling
#
logging.basicConfig(filename='perfusion_pipeline.log',level=logging.DEBUG)

print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)

fullpath = sys.argv[1]
#
asl = Arterial_Spin_Labeling.Protocol()
asl.patient_dir_ = os.path.join( fullpath, sys.argv[2] )
#asl.patient_dir_ = os.path.join( fullpath )
asl.run()
