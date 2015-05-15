#!/usr/bin/python

#
# Usage
# pipeline.py /mnt/macdata/groups/imaging_core/yann/study/ASL/Raw-ASL/1416/2010-09-07 GHB034-3_Wartman,Sammy
#

#import pdb; pdb.set_trace()
import logging
# Create a log file
logging.basicConfig(filename='white_matter_hyperintensity.log',level=logging.DEBUG)
#
import sys
import os
#
import White_matter_hyperintensity

print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)

fullpath = sys.argv[1]
#
wmh = White_matter_hyperintensity.Protocol()
wmh.patient_dir_ = os.path.join( fullpath, sys.argv[2] )
#asl.patient_dir_ = os.path.join( fullpath )
wmh.run()
