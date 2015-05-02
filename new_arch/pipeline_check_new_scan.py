#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
logging.basicConfig(filename='Quality_control.log',level=logging.DEBUG)
#
import Probe_new_scan as Pns
#

fullpath = os.path.join(os.path.sep,'home','quality','subjects', 'scans')

pns = Pns.Probe_new_scan( fullpath )
pns.run()
