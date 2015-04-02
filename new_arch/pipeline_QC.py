#!/usr/bin/python

#import pdb; pdb.set_trace()
import sys
import os
import logging
import Signal_to_noise_ratio as SNR
#
logging.basicConfig(filename='Quality_control.log',level=logging.DEBUG)

#fullpath = os.path.join(os.path.sep,'mnt','macdata','groups', 'imaging_core', 'yann',
#                        'PPG0246-1_Shearer,Robert','PVE_Segmentation','IM-0001-0001.nii')
#fullpath = os.path.join("/mnt/macdata/groups/imaging_core/yann/PPG0246-1_Shearer,Robert/PVE_Segmentation/IM-0001-0001.nii")
fullpath = os.path.join("/home/ycobigo/Images_test/MP-LAS_NIFD040X2_500.nii")
#fullpath = os.path.join("/mnt/macdata/groups/imaging_core/yann/PPG0246-1_Shearer,Robert/ACPC_Alignment/T2_PPG0246X1.nii")
#'PPG0246-1' for test;

snr = SNR.Signal_to_noise_ratio( fullpath )
snr.roi_selection_()
snr.average_signal_()
print snr.process()

#asl = Arterial_Spin_Labeling.Protocol()
#asl.patient_dir_ = os.path.join(fullpath, "PPG0246-1_Shearer,Robert")
#asl.run()
