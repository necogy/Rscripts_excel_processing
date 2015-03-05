import sys
import shutil
import logging
import os
import subprocess
import nipype
import nipype.interfaces.fsl as fsl
#import nipype.interfaces.spm as spm
#import nipype.interfaces.matlab as mlab

_log = logging.getLogger("__Image_tools__")
#
# Global function
# 
def generic_unix_cmd( Command ):
    #
    #
    try:
        #
        # 
        _log.debug( Command )
        #
        proc = subprocess.Popen( Command, shell = True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE )
        (output, error) = proc.communicate()
        if error: 
            raise Exception(error)
        if output: 
            _log.info(output)
        if proc.returncode != 0:
            raise Exception( Command + ': exited with error\n' + error )
            #
            #
    except Exception as inst:
        print inst
        _log.error(inst)
        quit(-1)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        quit(-1)
    except:
        print "Unexpected error:", sys.exc_info()[0]
        quit(-1)


#
# FSL
#
def run_bet(Directory, Frac = 0.6, Robust = True, Mask = False):
    """ Function uses FSL Bet to skullstrip all the niftii files."""
    os.chdir( Directory );
    for file_name in os.listdir( os.getcwd() ):
        if file_name.endswith(".nii"):
            btr = fsl.BET();
            btr.inputs.in_file = file_name;
            btr.inputs.frac    = Frac;
            btr.inputs.robust  = Robust;
            btr.inputs.mask    = Mask;
            print "Extracting brain from %s......" %(file_name)
            res = btr.run();
