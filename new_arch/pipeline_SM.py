#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
#
logging.basicConfig(filename='Scan_management.log',level=logging.DEBUG)
import Scans_management as Sm

scans_management = Sm.Scans_management()

scans_management.run()
