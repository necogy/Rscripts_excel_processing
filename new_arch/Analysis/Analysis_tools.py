import logging
import sys, os
import inspect
import shutil
import threading, Queue
singlelock = threading.Lock()
#
#
import nipype
import nipype.interfaces.fsl as fsl
#import nipype.interfaces.spm as spm
#import nipype.interfaces.matlab as mlab
# !!! SPM should be in the startup.m for nipype.interfaces.spm !!!
#
from zipfile import ZipFile as zf
#
#
#
import Image_tools
#
#
#
_log = logging.getLogger("__Analysis_tools__")
#
#
#
class Make_template( object ):
    """ Make template for Voxel-based analysise
    
    Description: This class will produce templates using FSL, SPM directives


    
    Attributes:
    list_maps_      :list - list of gray matter probability maps
    code_           :string - FSL, SPM
    procs_          :int - number of processors
    ana_dir_        :string - analysise directory
    template_dir_   :string - template directory
    queue_          :Queue - stack of tasks
    linear_MNI_     :list - list of linear transformation
    non_linear_MNI_ :list - list of non-linear transformation
    template_       :string - location of the template

    """
    def __init__( self, Code, Ana_dir, List_maps ):
        """Return a new Protocol instance (constructor)."""
        try:
            #
            # public variables
            self.list_maps_  = List_maps
            self.code_       = Code
            self.procs_      = 8
            #
            # thread management
            # 0. linear_registration_
            # 1. non_linear_registration_
            # 2. modulation_
            self.queue_    = [Queue.Queue(), Queue.Queue(), Queue.Queue()]
            #
            self.ana_dir_        = Ana_dir
            self.template_dir_   = os.path.join(self.ana_dir_, "template")
            #
            self.linear_MNI_         = []
            self.non_linear_MNI_     = []
            self.warped_template_    = []
            self.modulated_template_ = []
            #
            self.template_  = ""
            # thread management
            # 0. linear_registration_
            # 1. non_linear_registration_
            # 2. modulation_
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
    def check_environment( self ):
        """Check on the basic environment. All files and directories must be present before performing the protocol. And create private variables."""
        try:
            #
            #
            if not os.path.exists( self.ana_dir_ ):
                raise Exception( "User must set analysise directory, or directory %s not found." 
                                 %self.ana_dir_ )
            else:
                os.mkdir( self.template_dir_ )
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
    def get( self ):
        """Return the template location."""
        try:
        #
        #
            if os.path.exists( self.template_ ):
                return self.template_
            else:
                raise Exception( "Template was not yet produced." )

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
    def linear_registration_( self ):
        """Linear registration. First part in the study template creation. Estimation of the registration parameters of GM to grey matter standard template."""
        try:
        #
        #
            #
            # Retrieve the GM tissue prior
            avg152T1_gray = ""
            if os.environ.get('FSLDIR'):
                avg152T1_gray = os.path.join( os.environ.get('FSLDIR'), 
                                              "data","standard","tissuepriors", "avg152T1_gray.hdr" )
            else:
                raise Exception( "$FSLDIR env variable is not setup on your system" )

            #
            # Loop on the tasks
            while True:
                # get the item
                item = self.queue_[0].get()
                # registration estimation
                flt = fsl.FLIRT()
                flt.inputs.in_file         = os.path.join( self.ana_dir_, item )
                flt.inputs.reference       = avg152T1_gray
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_li_MNI.nii.gz"%item[:-4] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_li_MNI.mat"%item[:-4] )
                flt.inputs.dof             = 12
                res = flt.run()
                # apply registration 
                flt = fsl.FLIRT()
                flt.inputs.in_file         = os.path.join( self.ana_dir_, item )
                flt.inputs.reference       = avg152T1_gray
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_li_MNI.nii.gz"%item[:-4] )
                flt.inputs.in_matrix_file  = os.path.join( self.template_dir_, "%s_li_MNI.mat"%item[:-4] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_li_MNI_apply.mat"%item[:-4] )
                flt.inputs.apply_xfm       = True
                flt.inputs.dof             = 12
                res = flt.run()
                # lock and add the file
                singlelock.acquire()
                self.linear_MNI_.append( flt.inputs.out_file )
                singlelock.release()
                # job is done
                self.queue_[0].task_done()
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
    def non_linear_registration_( self ):
        """Non-linear registration. Second part in the study template creation. Estimation of the registration parameters of GM to grey matter standard template."""
        try:
        #
        #
            #
            # Use the linear template built in the linear_registration_ funstion
            template_linear = os.path.join(self.ana_dir_, "template_linear.nii.gz")
            # check if it has been built
            if not os.path.exists(template_linear):
                raise Exception( "Template %s has not been built yet. User has to process the linear step first"%template_linear )

            #
            # Loop on the tasks
            while True:
                # get the item
                item = self.queue_[1].get()
                # registration estimation
                flt = fsl.FLIRT()
                flt.inputs.in_file         = os.path.join(self.ana_dir_, item )
                flt.inputs.reference       = template_linear
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_non_li_MNI.nii.gz"%item[:-4] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_non_li_MNI.mat"%item[:-4] )
                flt.inputs.dof             = 12
                res = flt.run()
                # apply registration using GM_2_MNI152GM_2mm configuration file
                GM_2_MNI152GM_2mm = ""
                if os.environ.get('FSLDIR'):
                    GM_2_MNI152GM_2mm = os.path.join( os.environ.get('FSLDIR'), 
                                                  "etc","flirtsch","GM_2_MNI152GM_2mm.cnf" )
                #
                fnt = fsl.FNIRT()
                fnt.inputs.in_file         = os.path.join(self.ana_dir_, item )
                fnt.inputs.ref_file        = template_linear
                fnt.inputs.warped_file     = os.path.join( self.template_dir_, "%s_non_li_MNI_fnirt.nii.gz"%item[:-4] )
                fnt.inputs.affine_file     = os.path.join( self.template_dir_, "%s_non_li_MNI.mat"%item[:-4] )
                fnt.inputs.config_file     = GM_2_MNI152GM_2mm
                fnt.inputs.fieldcoeff_file = os.path.join( self.template_dir_, "%s_non_li_MNI_coeff.nii.gz"%item[:-4] )
                res = fnt.run()
                # apply warp
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.ana_dir_, item )
                aw.inputs.ref_file   = template_linear
                aw.inputs.out_file   = os.path.join( self.template_dir_, "%s_non_li_MNI_warped.nii.gz"%item[:-4] )
                aw.inputs.field_file = os.path.join( self.template_dir_, "%s_non_li_MNI_coeff.nii.gz"%item[:-4] )
                res = aw.run()
                # lock and add the file
                singlelock.acquire()
                self.non_linear_MNI_.append( aw.inputs.out_file )
                singlelock.release()
                # job is done
                self.queue_[1].task_done()
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
    def modulation_( self ):
        """Modulation funcion is a correction of the volume change multiplying the voxel by the Jacobian determinant derived from the normalization process."""
        try:
            #
            #
            # Loop on the tasks
            while True:
                # get the item
                item = self.queue_[2].get()
                # registration estimation
                flt = fsl.FLIRT()
                flt.inputs.in_file         = os.path.join(self.ana_dir_, item )
                flt.inputs.reference       = self.template_
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_li_template.nii.gz"%item[:-4] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_li_template.mat"%item[:-4] )
                flt.inputs.dof             = 12
                res = flt.run()
                # apply registration using GM_2_MNI152GM_2mm configuration file
                GM_2_MNI152GM_2mm = ""
                if os.environ.get('FSLDIR'):
                    GM_2_MNI152GM_2mm = os.path.join( os.environ.get('FSLDIR'), 
                                                  "etc","flirtsch","GM_2_MNI152GM_2mm.cnf" )
                #
                fnt = fsl.FNIRT()
                fnt.inputs.in_file         = os.path.join(self.ana_dir_, item )
                fnt.inputs.ref_file        = self.template_
                fnt.inputs.warped_file     = os.path.join( self.template_dir_, 
                                                           "%s_non_li_template_fnirt.nii.gz"%item[:-4] )
                fnt.inputs.affine_file     = os.path.join( self.template_dir_, 
                                                           "%s_li_template.mat"%item[:-4] )
                fnt.inputs.config_file     = GM_2_MNI152GM_2mm
                fnt.inputs.fieldcoeff_file = os.path.join( self.template_dir_, 
                                                           "%s_non_li_template_coeff.nii.gz"%item[:-4] )
                fnt.inputs.jacobian_file   = os.path.join( self.template_dir_, 
                                                           "%s_non_li_template_jac.nii.gz"%item[:-4] )
                res = fnt.run()
                # apply warp
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.ana_dir_, item )
                aw.inputs.ref_file   = self.template_
                aw.inputs.out_file   = os.path.join( self.template_dir_, 
                                                     "%s_non_li_template_warped.nii.gz"%item[:-4] )
                aw.inputs.field_file = os.path.join( self.template_dir_, 
                                                     "%s_non_li_template_coeff.nii.gz"%item[:-4] )
                res = aw.run()
                # modulation
                maths = fsl.ImageMaths()
                maths.inputs.in_file       =  os.path.join(self.template_dir_,
                                                           "%s_non_li_template_warped.nii.gz"%item[:-4])
                maths.inputs.op_string     = '-mul %s'%(os.path.join(self.template_dir_,
                                                                     "%s_non_li_template_jac.nii.gz"%item[:-4]))
                maths.inputs.out_file      =  os.path.join( self.template_dir_, 
                                                            "%s_modulated.nii.gz"%item[:-4] )
                maths.inputs.out_data_type = "float"
                maths.run();
                # lock and add the file
                singlelock.acquire()
                self.warped_template_.append( aw.inputs.out_file )
                self.modulated_template_.append(  os.path.join(self.template_dir_, 
                                                               "%s_modulated.nii.gz"%item[:-4]) )
                singlelock.release()
                # job is done
                self.queue_[2].task_done()
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
    def normalization( self ):
        """Registration and Normalization. Process of normalization creates customized template in the standard space (MNI 152) and register non-linearly the tissues (GM, WM, T1, T2, ...) in the standard space."""
        try:
        #
        #
            #
            # Linear step
            #

            #
            # create the pool of threads
            for i in range( self.procs_ ):
                t = threading.Thread( target = self.linear_registration_ )
                t.daemon = True
                t.start()
            # Stack the items
            for item in self.list_maps_:
                self.queue_[0].put(item)
            # block until all tasks are done
            self.queue_[0].join()
            
            #
            # First template (linear template)
            template_linear_4D = os.path.join(self.template_dir_, "template_linear_4D.nii.gz")
            template_linear    = os.path.join(self.ana_dir_, "template_linear.nii.gz")
            #
            self.average_template_( template_linear_4D, self.linear_MNI_, template_linear )

            #
            # Non-linear step
            #
            
            #
            # create the pool of threads
            for i in range( self.procs_ ):
                t = threading.Thread( target = self.non_linear_registration_ )
                t.daemon = True
                t.start()
            # Stack the items
            for item in self.list_maps_:
                self.queue_[1].put(item)
            # block until all tasks are done
            self.queue_[1].join()
           
            #
            # Second template (non-linear template)
            template_non_linear_4D = os.path.join(self.template_dir_, "template_non_linear_4D.nii.gz")
            self.template_         = os.path.join(self.ana_dir_, "template_non_linear.nii.gz")
            #
            self.average_template_( template_non_linear_4D, self.non_linear_MNI_, 
                                    self.template_ )

            #
            # Modulation step
            #

            #
            # create the pool of threads
            for i in range( self.procs_ ):
                t = threading.Thread( target = self.modulation_ )
                t.daemon = True
                t.start()
            # Stack the items
            for item in self.list_maps_:
                self.queue_[2].put(item)
            # block until all tasks are done
            self.queue_[2].join()

            #
            # Production of the mask
            GM_warped_template_4D = os.path.join(self.template_dir_, "GM_warped_template_4D.nii.gz")
            GM_template_mask      = os.path.join(self.ana_dir_, "GM_template_mask.nii.gz")
            #
            merger = fsl.Merge()
            merger.inputs.in_files     =  self.warped_template_
            merger.inputs.dimension    = 't'
            merger.inputs.output_type  = 'NIFTI_GZ'
            merger.inputs.merged_file  =  GM_warped_template_4D
            merger.run()
            # average over frames
            maths = fsl.ImageMaths()
            maths.inputs.in_file       =  GM_warped_template_4D
            maths.inputs.op_string     = "-Tmean -thr 0.01 -bin"
            maths.inputs.out_file      =  GM_template_mask
            maths.inputs.out_data_type = "char"
            maths.run()

            #
            # 4D image with modulated GM
            GM_modulated_template_4D = os.path.join(self.ana_dir_, "GM_modulated_template_4D.nii.gz")
            #
            merger = fsl.Merge()
            merger.inputs.in_files     =  self.modulated_template_
            merger.inputs.dimension    = 't'
            merger.inputs.output_type  = 'NIFTI_GZ'
            merger.inputs.merged_file  =  GM_modulated_template_4D
            merger.run()
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
    def average_template_( self, Template_4D, List, Template ):
        """Check on the basic environment. All files and directories must be present before performing the protocol. And create private variables."""
        try:
            #
            #
            # merge tissues in a 4D file
            merger = fsl.Merge()
            merger.inputs.in_files     =  List
            merger.inputs.dimension    = 't'
            merger.inputs.output_type  = 'NIFTI_GZ'
            merger.inputs.merged_file  =  Template_4D
            merger.run()
            # average over frames
            maths = fsl.ImageMaths( in_file   =  Template_4D, 
                                    op_string = '-Tmean', 
                                    out_file  =  Template )
            maths.run();
            # Flip the frames
            swap = fsl.SwapDimensions()
            swap.inputs.in_file   = Template
            swap.inputs.new_dims  = ("-x","y","z")
            swap.inputs.out_file  = "%s_flipped.nii.gz"%Template[:-7]
            swap.run()
            # average the frames
            maths = fsl.ImageMaths( in_file   =  Template, 
                                    op_string = '-add %s -div 2'%Template[:-7], 
                                    out_file  =  Template )
            maths.run();
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
        """ Run the complete Arterial Spin Labeling process"""
        self.check_environment()
        _log.debug("ASL ana - check environment -- pass")
        #
        if "FSL" in self.code_:
            self.normalization()
            _log.debug("ASL ana - FSL normalization -- pass")
        else:
            _log.debug("ASL ana - %s normalization not yet implemented -- failed"%self.code_)
            
        
