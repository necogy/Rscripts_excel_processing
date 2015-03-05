#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
import Scans_management as Sm
#

logging.basicConfig(filename='Scan_management.log',level=logging.DEBUG)

scans_management = Sm.Scans_management()

scans_management.run()
