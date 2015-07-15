#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
logging.basicConfig(filename='Scan_management.log',level=logging.DEBUG)
#
import Scans_management as Sm

scans_management = Sm.Scans_management()
scans_management.study_       = "NIFD" 
scans_management.PIDN_        = "15508" 
scans_management.PIDN_block_  = "15000-15999" 
scans_management.First_Name_  = "Grasser" 
scans_management.Last_Name_   = "Lynda" 
scans_management.dicoms_date_ = "20130122" 
scans_management.Your_Name_   = "Yann Cobigo"

scans_management.manual("NIFD15508")
