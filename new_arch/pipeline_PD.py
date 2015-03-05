#!/usr/bin/python

import sys
import dicom
import logging
#
import Probe_DICOM

logging.basicConfig(filename='Probe_DICOM.log',level=logging.DEBUG)

proto = Probe_DICOM.Probe_DICOM("PPG", "ASL", "/home/ycobigo/subjects/Graydon,Dianne/pASL_700_1700_1800_aah_12/IM-0006-0001.dcm")
proto.check_protocol()

#proto = Protocol.ADNI2('ADNI2')
#print proto.protocol_name()
#print proto.setup_['gallahad']
#
#print proto
#print str(proto)
#print repr(proto)
#
#ds = dicom.read_file("/home/cobigo/subjects/MEMPRAGE_4e_p2_1mm_isoRMS_12/IM-0012-0001.dcm")
#
#print ds.dir("pat")
#print ds.PatientName
#print ds[0x0010,0x0010].value
#
#print ds
