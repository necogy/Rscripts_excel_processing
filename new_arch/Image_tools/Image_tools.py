import os, sys, shutil, tempfile
import logging
import subprocess
import nipype
import nipype.interfaces.fsl as fsl
#
#
#
import Motion_control as Mc
#
# Global functions
def which(program):
    """ This function meemic the UNIX command 'which' new Python interpretor carries this command in the shutil library"""
    #
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)
    #
    #
    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path     = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe( exe_file ):
                return exe_file
    #
    return None
#
#
#
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
            _log.debug(output)
        if proc.returncode != 0:
            raise Exception( Command + ': exited with error\n' + error )
        
        #
        # return output
        return output
    #
    #
    except Exception as inst:
        _log.error(inst)
        quit(-1)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        quit(-1)
    except:
        print "Unexpected error:", sys.exc_info()[0]
        quit(-1)
#
# 
#
def natural_gray_matter( Output, GM, WM, CSF, Mask ):
    """ Function compute the natural gray matter, between CSF and Wm.

    Output:file       - output file saved after computing
    GM:file           - gray matter probability map
    WM:file           - white matter probability map
    CSF:file          - CSF probability map

    Example:
    ./gray_matter_mask "la_vie_est_belle.nii.gz" c1_file.nii.gz c2_file.nii.gz c3_file.nii.gz mask.nii.gz
    """
    #
    #
    try:
        #
        # 
        # Check we have ITK convert between file executable
        # gray_matter_mask "la_vie_est_belle.nii.gz" c1_file.nii.gz c2_file.nii.gz c3_file.nii.gz mask.nii.gz
        #        gray_matter_mask = which("gray_matter_mask")
        gray_matter_mask = which("gray_matter_mask")
        if gray_matter_mask is None:
            raise Exception("Missing gray_matter_mask in the path")
        _log.debug(gray_matter_mask)
        #
        cmd = '%s \"%s\" %s %s %s %s' %(gray_matter_mask, Output, GM, WM, CSF, Mask)
        proc = subprocess.Popen( cmd, shell=True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE )
        (output, error) = proc.communicate()
        if error: 
            raise Exception(error)
        if output: 
            _log.debug("gray_matter_mask tool pass")
            _log.debug(output)
        if proc.returncode != 0:
            raise Exception( cmd + ': exited with error\n' + error )
    #
    #
    except Exception as inst:
        _log.error(inst)
        quit(-1)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
        quit(-1)
    except:
        print "Unexpected error:", sys.exc_info()[0]
        quit(-1)
#
# 
#
def CBF_gm_ratio( Output, Parameters, GM, WM, CSF, Mask ):
    """ Function computes the CBF gray matter ratio.
    
    Output:file       - output file saved after computing
    Parameters:string - Parameter for computing the CBF gray matter ratio
    GM:file           - gray matter probability map
    WM:file           - white matter probability map
    CSF:file          - CSF probability map

    Example:
    ./CBF_gm_ratio "la_vie_est_belle.nii.gz" "0.82 0.72 1. 1110. 1600. 4136. 60. 80. 1442. 11. 2522.1" c1_file.nii.gz c2_file.nii.gz c3_file.nii.gz mask.nii.
    """
    #
    #
    try:
        #
        # 
        # CBF_gm_ratio "la_vie_est_belle.nii.gz" c1_file.nii.gz c2_file.nii.gz c3_file.nii.gz mask.nii.gz
        #        CBF_gm_ratio = which("CBF_gm_ratio")
        CBF_gm_ratio = which("CBF_gm_ratio")
        if CBF_gm_ratio is None:
            raise Exception("Missing CBF_gm_ratio in the path")
        _log.debug(CBF_gm_ratio)
        #
        cmd = '%s \"%s\" \"%s\" %s %s %s %s' %(CBF_gm_ratio, Output, Parameters, GM, WM, CSF, Mask)
        proc = subprocess.Popen( cmd, shell=True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE )
        (output, error) = proc.communicate()
        if error: 
            raise Exception(error)
        if output: 
            _log.debug("CBF_gm_ratio tool pass")
            _log.debug(output)
        if proc.returncode != 0:
            raise Exception( cmd + ': exited with error\n' + error )
    #
    #
    except Exception as inst:
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
def run_bet( Directory, Frac = 0.6, Robust = True, Mask = False ):
    """ Function uses FSL Bet to skullstrip all the niftii files."""
    os.chdir( Directory )
    for file_name in os.listdir( Directory ):
        if file_name.endswith(".nii"):
            btr = fsl.BET()
            btr.inputs.in_file = os.path.join( Directory, file_name )
            btr.inputs.frac    = Frac
            btr.inputs.robust  = Robust
            btr.inputs.mask    = Mask
            print "Extracting brain from %s......" %(file_name)
            res = btr.run()
#
# FSL
#
def run_ana2nii( File_in, File_ref, File_out ):
    """ Function uses FSL flirt to transform analyze file into nifti."""
    tmpdir = tempfile.mkdtemp()
    out_mat_file = os.path.join(tmpdir, "out_matrix_file.mat")
    #
    flt = fsl.FLIRT()
    flt.inputs.in_file         = File_in
    flt.inputs.reference       = File_ref
    flt.inputs.out_file        = File_out
    flt.inputs.out_matrix_file = out_mat_file
    flt.inputs.args            = "-dof 6"
    res = flt.run()
#
#
#
class Seek_files( object ):
    """ Seek for the good file. """
    def __init__( self, Directory ):
        """Return a new Seek file instance (constructor)."""
        try:
            # public variables
            self.seek_in_dir_ = Directory
            self.file_found_  = False
            self.files_       = []

        #
        #
        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
    #
    #
    #
    def seek_file_( self, Suffix, Prefix, Index ):
        """Return a new Seek file instance (constructor).
        Suffix is the suffix of the image
        Prefix is the prefix of the image
        Index is the file number when the image is composed by several files. Nifti - Index = 0; Analyze - header = 0 and image = 1; ...
        """
        try:
            # Let assume we did not find the file
            self.file_found_ = False
            #
            for fname in os.listdir( self.seek_in_dir_ ):
                if fname.startswith( Suffix ) and fname.endswith( Prefix ):
                    self.files_[Index] = fname
            #
            if os.path.isfile( os.path.join(self.seek_in_dir_, self.files_[Index]) ):
                self.file_found_ = True
                return self.file_found_
            else:
                self.file_found_ = False
                return self.file_found_
        #
        #
        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
    #
    #
    #
    def seek_nifti( self, Suffix ):
        """Return a new Seek file instance (constructor)."""
        try:
            #
            self.files_ = [""]
            #
            if self.seek_file_(Suffix, ".nii", 0):
                return True
            elif self.seek_file_(Suffix, ".nii.gz", 0):
                return True
            else:
                return False
        #
        #
        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
    #
    #
    #
    def seek_zip( self, Suffix ):
        """Return a new Seek file instance (constructor)."""
        try:
            #
            self.files_ = [""]
            #
            if self.seek_file_(Suffix, ".zip", 0):
                return True
            else:
                return False
        #
        #
        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
    #
    #
    #
    def seek_analyze( self, Suffix ):
        """Return a new Seek file instance (constructor)."""
        try:
            #
            self.files_ = ["",""]
            #
            if self.seek_file_(Suffix, ".hdr", 0) and self.seek_file_(Suffix, ".img", 1):
                return True
            else:
                return False
        #
        #
        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
    #
    #
    #
    def get_files( self ):
        """Return a new Seek file instance (constructor)."""
        try:
            #
            if self.file_found_:
                return self.files_
            else:
                raise Exception("File was not found in \n %s")%( self.seek_in_dir_ )
        #
        #
        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
