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
    """ Make template for Voxel-based morphometry analysise
    
    Description: This class will produce templates using FSL, SPM directives
    
    Attributes:
    code_           :string - FSL, SPM
    procs_          :int - number of processors
    ana_dir_        :string - analysise directory
    template_       :string - location of the template
    queue_          :Queue - stack of tasks

    """
    def __init__( self, Code, Ana_dir, Procs ):
        """Return a new Protocol instance (constructor)."""
        try:
            #
            # public variables
            self.code_      = Code
            self.procs_     = Procs
            #
            self.ana_dir_       = Ana_dir
            self.template_dir_  = ""
            #
            self.template_ = ""
            #
            # 0. linear_registration_
            # 1. non_linear_registration_
            # 2. modulation_
            self.queue_     = [Queue.Queue(), Queue.Queue(), Queue.Queue()]
            #
            self.linear_MNI_             = []
            self.non_linear_MNI_         = []
            self.warped_template_        = []
            self.modulated_template_     = []
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
    def average_template_( self, Template_4D, List, Template ):
        """Merge the list in a 4D image; average the 4D imge in a 3D image; flip the image and and average the flipped and unflipped iamges."""
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
       
#####################################
###
###
### Gray matter template
###
###
#####################################

#
#
#
class Make_GM_template( Make_template ):
    """ Make template for Voxel-based morphometry analysise
    
    Description: This class will produce templates using FSL, SPM directives


    
    Attributes:
    list_maps_      :list - list of gray matter probability maps
    maps_dir_       :string - maps directory
    template_dir_   :string - template directory
    linear_MNI_     :list - list of linear transformation
    non_linear_MNI_ :list - list of non-linear transformation

    """
    def __init__( self, Code, Ana_dir, Dir_maps, List_maps, Procs = 8 ):
        """Return a new Protocol instance (constructor)."""
        super( Make_GM_template, self ).__init__( Code, Ana_dir, Procs )
        try:
            #
            # public variables
            self.list_maps_ = List_maps
            #
            # thread management
            self.queue_CBF_ =  Queue.Queue()
            #
            self.maps_dir_      = Dir_maps
            self.template_dir_  = os.path.join(self.ana_dir_, "template_GM")
            #
            self.CBF_warped_template_    = []
            self.CBF_modulated_template_ = []
            #
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
                flt.inputs.in_file         = os.path.join( self.maps_dir_, item )
                flt.inputs.reference       = avg152T1_gray
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_li_MNI.nii.gz"%item[:-4] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_li_MNI.mat"%item[:-4] )
                flt.inputs.dof             = 12
                res = flt.run()
                # apply registration 
                flt = fsl.FLIRT()
                flt.inputs.in_file         = os.path.join( self.maps_dir_, item )
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
                flt.inputs.in_file         = os.path.join(self.maps_dir_, item )
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
                fnt.inputs.in_file         = os.path.join(self.maps_dir_, item )
                fnt.inputs.ref_file        = template_linear
                fnt.inputs.warped_file     = os.path.join( self.template_dir_, "%s_non_li_MNI_fnirt.nii.gz"%item[:-4] )
                fnt.inputs.affine_file     = os.path.join( self.template_dir_, "%s_non_li_MNI.mat"%item[:-4] )
                fnt.inputs.config_file     = GM_2_MNI152GM_2mm
                fnt.inputs.fieldcoeff_file = os.path.join( self.template_dir_, "%s_non_li_MNI_coeff.nii.gz"%item[:-4] )
                res = fnt.run()
                # apply warp
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.maps_dir_, item )
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
                flt.inputs.in_file         = os.path.join(self.maps_dir_, item )
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
                fnt.inputs.in_file         = os.path.join(self.maps_dir_, item )
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
                aw.inputs.in_file    = os.path.join(self.maps_dir_, item )
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
    def CBF_modulation_( self, CBF_dir ):
        """CBF applyed GM Modulation."""
        try:
            #
            #
            # Loop on the tasks
            while True:
                # get the item
                item = self.queue_CBF_.get()
                # find the corresponding GM
                GM_warp_coeff = "%s_non_li_template_coeff.nii.gz"%(item[4:-7])
                GM_warp_jac   = "%s_non_li_template_jac.nii.gz"%(item[4:-7])
                # apply the GM warp
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(CBF_dir, item )
                aw.inputs.ref_file   = self.template_
                aw.inputs.out_file   = os.path.join( self.template_dir_, 
                                                     "%s_non_li_template_warped.nii.gz"%item[:-7] )
                aw.inputs.field_file = os.path.join( self.template_dir_, GM_warp_coeff )
                res = aw.run()
                # Modulate with the GM jacobian
                maths = fsl.ImageMaths() 
                maths.inputs.in_file       =  os.path.join(self.template_dir_,
                                                           "%s_non_li_template_warped.nii.gz"%item[:-7])
                maths.inputs.op_string     = '-mul %s'%( os.path.join(self.template_dir_, GM_warp_jac) )
                maths.inputs.out_file      =  os.path.join( self.template_dir_, 
                                                            "%s_modulated.nii.gz"%item[:-7] )
                maths.inputs.out_data_type = "float"
                maths.run();
                # lock and add the file
                singlelock.acquire()
                self.CBF_warped_template_.append( aw.inputs.out_file )
                self.CBF_modulated_template_.append( maths.inputs.out_file )
                singlelock.release()
                # job is done
                self.queue_CBF_.task_done()
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
            # Second template (non-linear template): final template
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
            # Smooth the 4D image
            for sigma in [2, 3, 4]:
                GM_mod_smooth_4D = os.path.join(self.ana_dir_, "GM_modulated_template_4D_%s_sigma.nii.gz"%sigma)
                #
                maths = fsl.ImageMaths()
                maths.inputs.in_file       =   GM_modulated_template_4D
                maths.inputs.op_string     = "-fmean -kernel gauss %s"%sigma
                maths.inputs.out_file      =   GM_mod_smooth_4D
                maths.run()
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
    def warp_CBF_map( self, CBF_dir, CBF_list ):
        """Apply warp to the CBF map and smooth."""
        try:
        #
        #
            #
            # create the pool of threads
            for i in range( self.procs_ ):
                t = threading.Thread( target = self.CBF_modulation_, args=[CBF_dir] )
                t.daemon = True
                t.start()
            # Stack the items
            for item in CBF_list:
                self.queue_CBF_.put(item)
            # block until all tasks are done
            self.queue_CBF_.join()

            #
            # 4D image with modulated CBF
            CBF_modulated_template_4D = os.path.join(self.ana_dir_, "CBF_modulated_template_4D.nii.gz")
            #
            merger = fsl.Merge()
            merger.inputs.in_files     =  self.CBF_modulated_template_
            merger.inputs.dimension    = 't'
            merger.inputs.output_type  = 'NIFTI_GZ'
            merger.inputs.merged_file  =  CBF_modulated_template_4D
            merger.run()

            #
            # Smooth the 4D image
            for sigma in [2, 3, 4]:
                CBF_mod_smooth_4D = os.path.join(self.ana_dir_, "CBF_modulated_template_4D_%s_sigma.nii.gz"%sigma)
                #
                maths = fsl.ImageMaths()
                maths.inputs.in_file       =   CBF_modulated_template_4D
                maths.inputs.op_string     = "-fmean -kernel gauss %s"%sigma
                maths.inputs.out_file      =   CBF_mod_smooth_4D
                maths.run()
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
            
        
#####################################
###
###
### T1 template
###
###
#####################################

#
#
#
class Make_brain_template( Make_template ):
    """ Make template for Voxel-based morphometry analysise
    
    Description: This class will produce templates using FSL, SPM directives


    
    Attributes:
    list_maps_      :list - list of gray matter probability maps
    maps_dir_       :string - maps directory
    template_dir_   :string - template directory
    queue_          :Queue - stack of tasks
    linear_MNI_     :list - list of linear transformation
    non_linear_MNI_ :list - list of non-linear transformation
    template_       :string - location of the template

    """
    def __init__( self, Code, Ana_dir, Dir_T1_brain, List_T1_brain, Procs = 8  ):
        """Return a new Protocol instance (constructor)."""
        super( Make_brain_template, self ).__init__( Code, Ana_dir, Procs )
        try:
            #
            # public variables
            self.list_T1_brain_ = List_T1_brain
            #
            # thread management
            self.queue_CBF_ =  Queue.Queue()
            #
            self.T1_brain_dir_  = Dir_T1_brain
            self.template_dir_  = os.path.join(self.ana_dir_, "template_brain")
            #
            self.CBF_warped_template_    = []
            self.CBF_modulated_template_ = []
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
        """Linear registration. First part in the study template creation. Estimation of the registration parameters of T1 to 152 standard template."""
        try:
        #
        #
            #
            # MNI selected
            MNI_T1_brain_2mm = ""
            if os.environ.get('FSLDIR'):
                MNI_T1_brain_2mm = os.path.join( os.environ.get('FSLDIR'), 
                                                 "data","standard","MNI152_T1_2mm_brain.nii.gz" )
            else:
                raise Exception( "$FSLDIR env variable is not setup on your system" )

            #
            # Loop on the tasks
            while True:
                # get the item
                item = self.queue_[0].get()
                # registration estimation
                flt = fsl.FLIRT()
                flt.inputs.in_file         = os.path.join( self.T1_brain_dir_, item )
                flt.inputs.reference       = MNI_T1_brain_2mm
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_li_MNI.nii.gz"%item[:-7] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_li_MNI.mat"%item[:-7] )
                flt.inputs.dof             = 12
                res = flt.run()
                # apply registration 
                flt = fsl.FLIRT()
                flt.inputs.in_file         = os.path.join( self.T1_brain_dir_, item )
                flt.inputs.reference       = MNI_T1_brain_2mm
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_li_MNI.nii.gz"%item[:-7] )
                flt.inputs.in_matrix_file  = os.path.join( self.template_dir_, "%s_li_MNI.mat"%item[:-7] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_li_MNI_apply.mat"%item[:-7] )
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
        """Non-linear registration. Second part in the study template creation. Estimation of the registration parameters of brain to study oriented standard brain template."""
        try:
        #
        #
            #
            # Use the linear template built in the linear_registration_ funstion
            template_linear = os.path.join(self.ana_dir_, "temp_brain_lin.nii.gz")
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
                flt.inputs.in_file         = os.path.join(self.T1_brain_dir_, item )
                flt.inputs.reference       = template_linear
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_non_li_MNI.nii.gz"%item[:-7] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_non_li_MNI.mat"%item[:-7] )
                flt.inputs.dof             = 12
                res = flt.run()
                # apply registration using T1_2_MNI152_2mm.cnf configuration file
                T1_2_MNI152_2mm = ""
                if os.environ.get('FSLDIR'):
                    T1_2_MNI152_2mm = os.path.join( os.environ.get('FSLDIR'), 
                                                    "etc","flirtsch","T1_2_MNI152_2mm.cnf" )
                #
                fnt = fsl.FNIRT()
                fnt.inputs.in_file         = os.path.join(self.T1_brain_dir_, item )
                fnt.inputs.ref_file        = template_linear
                fnt.inputs.warped_file     = os.path.join( self.template_dir_, "%s_non_li_MNI_fnirt.nii.gz"%item[:-7] )
                fnt.inputs.affine_file     = os.path.join( self.template_dir_, "%s_non_li_MNI.mat"%item[:-7] )
                fnt.inputs.config_file     = T1_2_MNI152_2mm
                fnt.inputs.fieldcoeff_file = os.path.join( self.template_dir_, "%s_non_li_MNI_coeff.nii.gz"%item[:-7] )
                res = fnt.run()
                # apply warp
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.T1_brain_dir_, item )
                aw.inputs.ref_file   = template_linear
                aw.inputs.out_file   = os.path.join( self.template_dir_, "%s_non_li_MNI_warped.nii.gz"%item[:-7] )
                aw.inputs.field_file = os.path.join( self.template_dir_, "%s_non_li_MNI_coeff.nii.gz"%item[:-7] )
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
                flt.inputs.in_file         = os.path.join(self.T1_brain_dir_, item )
                flt.inputs.reference       = self.template_
                flt.inputs.out_file        = os.path.join( self.template_dir_, "%s_li_template.nii.gz"%item[:-7] )
                flt.inputs.out_matrix_file = os.path.join( self.template_dir_, "%s_li_template.mat"%item[:-7] )
                flt.inputs.dof             = 12
                res = flt.run()
                # apply registration using T1_2_MNI152_2mm configuration file
                T1_2_MNI152_2mm = ""
                if os.environ.get('FSLDIR'):
                    T1_2_MNI152_2mm = os.path.join( os.environ.get('FSLDIR'), 
                                                    "etc","flirtsch","T1_2_MNI152_2mm.cnf" )
                #
                fnt = fsl.FNIRT()
                fnt.inputs.in_file         = os.path.join(self.T1_brain_dir_, item )
                fnt.inputs.ref_file        = self.template_
                fnt.inputs.warped_file     = os.path.join( self.template_dir_, 
                                                           "%s_non_li_template_fnirt.nii.gz"%item[:-7] )
                fnt.inputs.affine_file     = os.path.join( self.template_dir_, 
                                                           "%s_li_template.mat"%item[:-7] )
                fnt.inputs.config_file     = T1_2_MNI152_2mm
                fnt.inputs.fieldcoeff_file = os.path.join( self.template_dir_, 
                                                           "%s_non_li_template_coeff.nii.gz"%item[:-7] )
                fnt.inputs.jacobian_file   = os.path.join( self.template_dir_, 
                                                           "%s_non_li_template_jac.nii.gz"%item[:-7] )
                res = fnt.run()
                # apply warp
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.T1_brain_dir_, item )
                aw.inputs.ref_file   = self.template_
                aw.inputs.out_file   = os.path.join( self.template_dir_, 
                                                     "%s_non_li_template_warped.nii.gz"%item[:-7] )
                aw.inputs.field_file = os.path.join( self.template_dir_, 
                                                     "%s_non_li_template_coeff.nii.gz"%item[:-7] )
                res = aw.run()
                # modulation
                maths = fsl.ImageMaths()
                maths.inputs.in_file       =  os.path.join(self.template_dir_,
                                                           "%s_non_li_template_warped.nii.gz"%item[:-7])
                maths.inputs.op_string     = '-mul %s'%(os.path.join(self.template_dir_,
                                                                     "%s_non_li_template_jac.nii.gz"%item[:-7]))
                maths.inputs.out_file      =  os.path.join( self.template_dir_, 
                                                            "%s_modulated.nii.gz"%item[:-7] )
                maths.inputs.out_data_type = "float"
                maths.run();
                # lock and add the file
                singlelock.acquire()
                self.warped_template_.append( aw.inputs.out_file )
                self.modulated_template_.append(  os.path.join(self.template_dir_, 
                                                               "%s_modulated.nii.gz"%item[:-7]) )
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
            for item in self.list_T1_brain_:
                self.queue_[0].put(item)
            # block until all tasks are done
            self.queue_[0].join()
            
            #
            # First template (linear template)
            template_linear_4D = os.path.join(self.template_dir_, "temp_brain_lin_4D.nii.gz")
            template_linear    = os.path.join(self.ana_dir_, "temp_brain_lin.nii.gz")
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
            for item in self.list_T1_brain_:
                self.queue_[1].put(item)
            # block until all tasks are done
            self.queue_[1].join()
           
            #
            # Second template (non-linear template): final template
            template_non_linear_4D = os.path.join(self.template_dir_, "temp_nlin_4D.nii.gz")
            self.template_         = os.path.join(self.ana_dir_, "temp_nlin.nii.gz")
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
            for item in self.list_T1_brain_:
                self.queue_[2].put(item)
            # block until all tasks are done
            self.queue_[2].join()

            #
            # Production of the mask
            brain_warped_4D = os.path.join(self.template_dir_, "brain_warped_4D.nii.gz")
            brain_mask      = os.path.join(self.ana_dir_, "brain_mask.nii.gz")
            #
            merger = fsl.Merge()
            merger.inputs.in_files     =  self.warped_template_
            merger.inputs.dimension    = 't'
            merger.inputs.output_type  = 'NIFTI_GZ'
            merger.inputs.merged_file  = brain_warped_4D
            merger.run()
            # average over frames
            maths = fsl.ImageMaths()
            maths.inputs.in_file       =  self.template_
            maths.inputs.op_string     = "-Tmean -thr 50. -bin"
            maths.inputs.out_file      =  brain_mask
            maths.inputs.out_data_type = "char"
            maths.run()

            #
            # 4D image with modulated GM
            brain_modulated_4D = os.path.join(self.ana_dir_, "brain_modulated_4D.nii.gz")
            #
            merger = fsl.Merge()
            merger.inputs.in_files     =  self.modulated_template_
            merger.inputs.dimension    = 't'
            merger.inputs.output_type  = 'NIFTI_GZ'
            merger.inputs.merged_file  =  brain_modulated_4D
            merger.run()

            #
            # Smooth the 4D image
            for sigma in [2, 3, 4]:
                brain_mod_smooth_4D = os.path.join(self.ana_dir_, "brain_modulated_4D_%s_sigma.nii.gz"%sigma)
                #
                maths = fsl.ImageMaths()
                maths.inputs.in_file       =   brain_modulated_4D
                maths.inputs.op_string     = "-fmean -kernel gauss %s"%sigma
                maths.inputs.out_file      =   brain_mod_smooth_4D
                maths.run()
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
