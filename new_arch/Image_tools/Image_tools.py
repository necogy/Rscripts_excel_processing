import sys
import shutil
import logging
import os
import subprocess
import nipype
import nipype.interfaces.fsl as fsl

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
            print inst
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
