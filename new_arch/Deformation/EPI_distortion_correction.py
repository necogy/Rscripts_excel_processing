from os import path
import StringIO
import os
import shutil
import sys
import tempfile
import subprocess
import logging
#
import Deformation

#
_log = logging.getLogger("__EPI_distortion_correction__")
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
# Class EPI_distortion_correction
#
class EPI_distortion_correction( Deformation.Deformation ):
    """ Echo planar imaging distortion correction. This algorithm is using 'A variational image-based approach to the correction of susceptibility artifacts in the alignment of diffusion weighted and structural MRI' (PMID: 19694302).
    
    Attributes:
    parameters_:File        - file with EPI_distortion correction program parameters
    affine_iterations_:int  - parameter for EPI_distortion correction program
    scale_levels_:int       - parameter for EPI_distortion correction program
    diff_eq_iterations_:int - parameter for EPI_distortion correction program
    alpha_:int              - parameter for EPI_distortion correction program
    delta_affine_:int       - parameter for EPI_distortion correction program
    delta_diffeo_:int       - parameter for EPI_distortion correction program
    #
    working_dir_:File - tempo directory for tempo output
    control_:File     - EPI file to correct
    t2_:File          - T2 reference for the transformation
    transform_:File   - v field deformation
    #
    control_corrected_:File - final output
    
    """
    def __init__( self, Parameters_file = None ):
        """Return a new EPI_distortion_correction instance."""
        super( EPI_distortion_correction, self ).__init__( )
        try:
            #
            #
            _log.warning("You are using EPI distortion correction")
            #
            # Configuration file for EPI distortion correction program
            if Parameters_file == None:
                self.parameters_         = None
                self.affine_iterations_  = 500    
                self.scale_levels_       = 3        
                self.diff_eq_iterations_ = 2000
                self.alpha_              = 0.1    
                self.delta_affine_       = 0.1
                self.delta_diffeo_       = 0.05
            else:
                self.read_configuration( Parameters_file )
            #
            # Arguments
            self.working_dir_  = tempfile.mkdtemp() # tempo directory for tempo output
            self.control_      = "" # EPI file to correct
            self.t2_           = "" # T2 reference for the transformation
            self.control_nhdr_ = "" # EPI file to correct nhdr
            self.t2_nhdr_      = "" # T2 reference for the transformation nhdr
            self.transform_    = "" # v field deformation
            # final output
            self.control_corrected_ = ""
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
    def calculate_transform( self ):
        """The call to tom fletcher routine.
        NOTE: control and t2 should have identical dimensions and orientation and be roughly aligned
        """
        #
        #
        try:
            #
            #
            if not path.exists( self.working_dir_ ):
                os.makedirs( self.working_dir_ )
            #
            if path.isfile( self.control_ ):
                if not os.path.isabs( self.control_):
                    raise Exception( "control has to be a full path: " + self.control_ )
            else:
                raise Exception( "control image does not exist: " + self.control_ )
            #
            if path.isfile( self.t2_ ):
                if not os.path.isabs( self.t2_):
                    raise Exception( "t2 has to be a full path: " + self.t2_ )
            else:
                raise Exception( "t2 image does not exist: " + self.t2_ )
            #
            if path.isfile( self.transform_ ):
                raise Exception( "transform file already exists: " + self.transform_ )
            # change input file format from nii to nhdr
            self.control_nhdr_ = path.join( self.working_dir_,
                                           path.basename(self.control_).replace('.nii','.nhdr'))
            self.t2_nhdr_      = path.join( self.working_dir_, 
                                           path.basename(self.t2_).replace('.nii','.nrrd'))
            # get orig dim of control image, fslhd is used in get image dimension
            orig_dim = self.get_image_dimensions_(self.control_)
            # convert to nrrd/nhdr
            self.convert_between_file_formats_(self.control_, self.control_nhdr_)
            self.convert_between_file_formats_(self.t2_, self.t2_nhdr_)
            #
            # now done in nrrd with unu, padding is 'in place'
            self.compute_and_apply_pad_( self.t2_nhdr_, orig_dim )
            # return pad_dim since we need it later to unpad
            pad_dim = self.compute_and_apply_pad_( self.control_nhdr_, orig_dim )
            self.write_config_file_( path.join(self.working_dir_,'config.txt') )
            #
            # Run EPI distortion correction
            self.EPI_distortion_correction_prog_( path.join( self.working_dir_,'config.txt') )
            #
            # unpad operation is done on nrrd transform file
            if pad_dim['i'] != 0 or pad_dim['j'] != 0 or pad_dim['k'] != 0:
                self.unpad_image_( pad_dim, path.join(self.working_dir_, 'v.nhdr'), 
                              path.join(self.working_dir_, 'v.nhdr'))
            #
            self.convert_between_file_formats_( path.join(self.working_dir_, 'v.nhdr'), 
                                                self.transform_ )
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
    def apply_transform( self ):
        """Apply an EPI Distortion Correction transform to an DWI image 
        """
        try:
            if not path.exists(self.working_dir_):
                os.makedirs(self.working_dir_)
            #
            input_nhdr =  path.join(self.working_dir_, 
                                    path.basename(self.control_).replace('.nii','.nhdr'))
            output_nhdr = path.join(self.working_dir_, 
                                    path.basename(self.control_corrected_).replace('.nii','.nhdr'))
            self.convert_between_file_formats_(self.control_, input_nhdr)
            #
            if self.transform_.endswith('.nhdr'):
                transform_nhdr = self.transform_
            else:
                transform_nhdr = path.join(self.working_dir_, "transform.nhdr")
                self.convert_between_file_formats_(self.transform_, transform_nhdr)
            #
            # Apply the correction field
            self.EPI_distortion_application_prog_( input_nhdr, transform_nhdr, output_nhdr )
            #
            #
            self.convert_between_file_formats_(output_nhdr, self.control_corrected_)
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
    def get_image_dimensions_( self, file_name ):
        try:
            #
            #
            if not ( file_name.endswith(".nii") or file_name.endswith(".nii.gz") ):
                raise Exception("get_image_dimaension needs nifti file format.") 
            #
            # extract XLM information from input file using fslhd
            cmd = '%s -x %s' % ('fslhd', file_name)
            proc = subprocess.Popen(cmd, shell=True,
                                    stdout = subprocess.PIPE,
                                    stderr = subprocess.PIPE )
            (output, error) = proc.communicate()
            #
            if error: 
                raise Exception(error)
            if output: 
                _log.debug("fslhd image info extraction pass")
                _log.info(output)
            if proc.returncode != 0:
                raise Exception( cmd + ': exited with error\n' + error )
            #
            # Extract required variables
            image_vars = {}
            for line in StringIO.StringIO(output):
                name, var = line.partition("=")[::2]
                image_vars[name.strip()] = var
            #
            orig_dim = {}
            # remove single quotes on results
            orig_dim['i'] = int( image_vars['nx'].replace('\'','') )
            orig_dim['j'] = int( image_vars['ny'].replace('\'','') )
            orig_dim['k'] = int( image_vars['nz'].replace('\'','') )
            #
            return orig_dim
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except ValueError:
            print "Could not convert data to an integer."
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
    #
    #
    #
    def convert_between_file_formats_( self, input, output, datatype = '' ):
        #
        #
        try:
            #
            # Check we have ITK convert between file executable
            #        ConvertBetweenFileFormats = which("ConvertBetweenFileFormats")
            ConvertBetweenFileFormats = which("/home/ycobigo/devel/CPP/ITK/InsightApplications-3.20.0/build/ConvertBetweenFileFormats/ConvertBetweenFileFormats")
            if ConvertBetweenFileFormats is None:
                raise Exception("Missing ConvertBetweenFileFormats in the path")
            _log.debug(ConvertBetweenFileFormats)
            #
            cmd = '%s %s %s %s' %(ConvertBetweenFileFormats, input, output, datatype)
            proc = subprocess.Popen( cmd, shell=True,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE )
            (output, error) = proc.communicate()
            if error: 
                raise Exception(error)
            if output: 
                _log.debug("ConvertBetweenFileFormats ITK tool pass")
                _log.info(output)
            if proc.returncode != 0:
                raise Exception( cmd + ': exited with error\n' + error )
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
    def compute_and_apply_pad_( self, image, orig_dim ):
        max_res = 2**( self.scale_levels_ - 1)
        # calculate padding
        pad_dim = {}
        for key, value in orig_dim.iteritems():
            if (value % max_res) == 0:
                pad_dim[key] = 0
            else :
                pad_dim[key] = 0
                while (pad_dim[key] + value) % max_res != 0:
                    pad_dim[key] += 1
        #
        #
        if pad_dim['i'] != 0 or pad_dim['j'] != 0 or pad_dim['k'] != 0 :
            # apply padding in place
            pad_image_( pad_dim, image, image)
        #
        #
        return pad_dim
    #
    #
    #
    def pad_image_( self, pad_dim, input, output ):
        """Pads an image by amount specified in pad_dim.
        pad_dim should be a dictionary with keys i, j, k which specify how much to pad by.
        ie: pad_dim = { 'i': 0, 'j': 0, 'k': 1 } will pad an image by 1 in the third dimension.
        padding is added to the end of the dimension.
        """
 
        cmd = 'unu pad -min 0 0 0 -max M+%(i)s M+%(j)s M+%(k)s -b pad -v 0.0  -i %(input)s -o %(output)s' % {
            'i':pad_dim['i'],
            'j':pad_dim['j'],
            'k':pad_dim['k'],
            'input':input,
            'output':output
        }
        proc = subprocess.Popen(cmd, shell=True,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                                cwd=os.path.dirname(output)
                            )
        _log.debug(cmd)
        (output, error) = proc.communicate()
        if error: _log.error(error)
        if output: _log.info(output)
 
        if  proc.returncode != 0:
            raise Exception, error
    #
    #
    #
    def unpad_image( self, pad_dim, input, output ): 
        """Unpad an image by amount specified in pad_dim.
        pad_dim should be a dictionary with keys i, j, k which specify how much to unpad by.
        ie: pad_dim = { 'i': 0, 'j': 0, 'k': 1 } will unpad an image by 1 in the third dimension.
        padding is removed from the end of the dimension.
        """
 
        cmd = 'unu crop -min 0 0 0 -max M-%(i)s M-%(j)s M-%(k)s -i %(input)s -o %(output)s' % {
            'i':pad_dim['i'],
            'j':pad_dim['j'],
            'k':pad_dim['k'],
            'input':input,
            'output':output
        }
        proc = subprocess.Popen(cmd, shell=True,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                            )
        _log.debug(cmd)
        (output, error) = proc.communicate()
        if error:
            _log.error(error)
        if output: 
            _log.info(output)
        if  proc.returncode != 0:
            raise Exception, error
    #
    #
    #
    def read_configuration( self, Parameters_file ):
        """ TO DO """
    #
    #
    #
    def write_config_file_( self, filepath ):
        """ Parameters for the distortion correction algorithm

        affine_iterations  - Gradient descent first over a partial affine transform
        scale_levels       - level of granularity
        diff_eq_iterations - Diffeomorphism gradient descentaffine_iterations
        alpha              - lambda???
        delta_affine       - multiplication factor for images intensity
        delta_diffeo       - multiplication factor for images intensity
        Control_nhdr       - Control image (deformation template)
        T2_nhdr            - T2 target image
        """
        config_body = """%(affine_iterations)s
%(scale_levels)s
%(diff_eq_iterations)s
%(alpha)s
%(delta_affine)s
%(delta_diffeo)s
%(Control_nhdr)s 0 0
%(T2_nhdr)s 0 0
""" % { 'affine_iterations': self.affine_iterations_,
        'scale_levels':      self.scale_levels_,
        'diff_eq_iterations':self.diff_eq_iterations_,
        'alpha':             self.alpha_,
        'delta_affine':      self.delta_affine_,
        'delta_diffeo':      self.delta_diffeo_,
        'Control_nhdr' :     self.control_nhdr_,
        'T2_nhdr':           self.t2_nhdr_
            }
        #
        _log.debug("configuration file for EPIDistortionCorrection")
        _log.debug(config_body)
        #
        config_file = open(filepath, 'w')
        config_file.write(config_body)
        config_file.close()
    #
    #
    #
    def EPI_distortion_correction_prog_( self, config_file ):
        #
        #
        try:
            #
            # Check we have the Utha algorithm between file executable
            EPIDistortionCorrection = which("/home/ycobigo/devel/CPP/UtahDiffusionProcessing/bin/bin/EPIDistortionCorrection")
            if EPIDistortionCorrection is None:
                raise Exception("Missing EPIDistortionCorrection in the path")
            _log.debug(EPIDistortionCorrection)
            # Check for EPIDistortionCorrection config file
            if not os.path.isfile( config_file ):
                raise Exception("Missing EPIDistortionCorrection's configuration file (config.txt)")
            #
            #
            cmd = '%s %s' %( EPIDistortionCorrection, config_file )
            proc = subprocess.Popen( cmd, shell=True,
                                     stdout = subprocess.PIPE,
                                     stderr = subprocess.PIPE,
                                     cwd    = self.working_dir_ )
            (output, error) = proc.communicate()
            if error: 
                _log.debug("EPIDistortionCorrection algorithm -- fail")
                raise Exception(error)
            if output: 
                _log.debug("EPIDistortionCorrection algorithm -- pass")
                _log.info(output)
            if proc.returncode != 0:
                raise Exception( cmd + ': exited with error\n' + error )
            #
            # Check on the output
            if not os.path.isfile( os.path.join(self.working_dir_, 'epiCorr.nhdr') ):
                raise Exception("EPIDistortionCorrection's output not found")
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
    def EPI_distortion_application_prog_( self, input_nhdr, transform_nhdr, output_nhdr ):
        #
        #
        try:
            #
            # Check we have the Utha algorithm between file executable
            TransformDWI = which("/home/ycobigo/devel/CPP/UtahDiffusionProcessing/bin/bin/TransformDWI")
            if TransformDWI is None:
                raise Exception("Missing TransformDWI in the path")
            _log.debug(TransformDWI)
            #
            #
            cmd = '%s %s %s %s' %( TransformDWI, input_nhdr, transform_nhdr, output_nhdr )
            proc = subprocess.Popen( cmd, shell = True,
                                     stdout = subprocess.PIPE,
                                     stderr = subprocess.PIPE,
                                     cwd = self.working_dir_ )
            (output, error) = proc.communicate()
            if error: 
                _log.debug("TransformDWI algorithm -- fail")
                raise Exception(error)
            if output: 
                _log.debug("TransformDWI algorithm -- pass")
                _log.info(output)
            if proc.returncode != 0:
                raise Exception( cmd + ': exited with error\n' + error )
            ##
            ## Check on the output
            #if not os.path.isfile( self.control_corrected_ ):
            #    raise Exception("TransformDWI's output not found")
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
    def run( self ):
        self.calculate_transform()
        self.apply_transform()
    #
    #
    #
    def __repr__( self ):
        return "{__class__.__name__}(protocol_name_ = {protocol_name_!r}, setup_={setup_!r})".format( __class__ = self.__class__, **self.__dict__ )
    #
    #
    #
    def __str__( self ):
        "Overriding srt"
        string = "The protocol is: {protocol_name_}\n {setup_}"
        return string.format(**self.__dict__)
