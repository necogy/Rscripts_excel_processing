import sys
import shutil
import os
from nifti import *
#
import Image_tools as tools

class Quality_control( object ):
    """Quality control setting.
    
    Attributes:
    image_:NiftiImage      - full head image data
    brain_:NiftiImage      - brain image data
    brain_mask_:NiftiImage - brain mask image data
    """
    def __init__( self, Image_name ):
        """Return a new Quality control instance."""
        image_name = Image_name
        #
        # Please notice the order in which the dimensions are specified: (t, z, y, x).
        self.image_  = NiftiImage( Image_name )

        #
        # FSL BET: Brain extraction
        #
        brain_file      = ""
        brain_mask_file = ""
        # Brain extraction
        tools.run_bet(os.path.dirname( self.image_.filename ), 0.6, True, True)
        # 
        for file_name in os.listdir( os.path.dirname( self.image_.filename ) ):
            if file_name.endswith("mask.nii.gz"):
                 brain_mask_file = file_name
            if file_name.endswith("brain.nii.gz"):
                 brain_file = file_name
        #
        self.brain_      = NiftiImage(brain_file)
        self.brain_mask_ = NiftiImage(brain_mask_file)

                 

        print self.image_
        print self.image_.filename
        print self.image_.header
        volume = self.image_.data[80][128][120]
        test = (range(80,82),range(128,130),120)
        print volume
        print self.image_.data[test]
        print test[0]


