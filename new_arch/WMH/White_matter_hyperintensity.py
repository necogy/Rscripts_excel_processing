import logging
import inspect
import sys, os, shutil, tempfile
import subprocess
import numpy
import nipype
import nipype.interfaces.fsl  as fsl
import nipype.interfaces.spm  as spm
import nipype.interfaces.ants as ants
import nipype.interfaces.matlab as mlab
#
#
#
import Image_tools
#import EPI_distortion_correction
#import Quality_control
#import Motion_control as Mc
#
#
#
_log = logging.getLogger("__White_Matter_hyperintensity__")
#
#
#
class Protocol( object ):
    """Hyperintense white matter protocol
    
    Description: This script imports a set of python modules to be used
    for processing white matter hyperintense data from the UCSF Neuroimaging Center and 
    the UCSF Memory and Aging Center. The script should be run on the cloud at:
    /mnt/macdata/groups/XXXX/. 

    1.) 
    2.) 
    3.) 
    4.) 
    5.) 
    6.) 

    
    Attributes:
    patient_dir_     :string - WMH-pipe directory
    FLAIR_directory_ :string - ACPC aligned T2 directory
    PVE_Segmentation_:string - PVE T1 directory 
    FLAIR_file_      :list   - FLAIR list. 0 nii; or (0,1) = (hdr,img)
    T1_file_         :list   - T1 list. 0 nii; or (0,1) = (hdr,img)     
    brain_mask_      :string - brain binary mask
    brain_prob_      :string - brain probability mask
    priors_          :list   - prior probqbilities: 0 - gm; 1 - wm; 2 - CSF; 3 - WMH     
    """
    def __init__( self ):
        """Return a new Protocol instance (constructor)."""
        try:
            #
            # public variables
            self.patient_dir_ = "" # Patient directory
            self.status_      = True
           # private variables
            # Fluid-attenuated inversion recovery
            self.FLAIR_directory_   = ""
            self.FLAIR_file_        = []
            # T1
            self.PVE_Segmentation_ = ""
            self.T1_file_          = []
            # Masks
            self.brain_mask_       = ""
            self.brain_prob_       = ""
            # Prior probqbilities
            self.priors_           = [] 
            self.priors_directory_ = tempfile.mkdtemp()
            os.mkdir( os.path.join(self.priors_directory_, "priors") ) # Turn around R: drive symbolic links issue
            print self.priors_directory_
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
            if not os.path.exists(self.patient_dir_):
                raise Exception( "User must set _ variable, or directory %s not found." 
                                 %self.patient_dir_ )
            
            #
            # Check ANTs environment vairable is set up
            if os.environ.get(''):
                raise Exception( "$FSLDIR env variable is not setup on your system" )


            #
            # make a directory for the FLAIR        
            self.FLAIR_directory_ = os.path.join(self.patient_dir_, 'FLAIR_processing')
            os.mkdir( self.FLAIR_directory_ )
            os.mkdir( os.path.join(self.FLAIR_directory_, "priors") )
            
            # make a directory for the Partial Volume Extraction (PVE) T1
            self.PVE_Segmentation_ = os.path.join(self.patient_dir_, 'PVE_Segmentation')
            os.mkdir( self.PVE_Segmentation_ )
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol WMH - check environment -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.erro("Protocol WMH - check environment -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol WMH - check environment -- failed")
            self.status_ = False
    #
    #
    #
    def initialization( self ):
        """Initialize all the data. This function convert DICOMs images (T1, FALIR) into niftii. 
        """
        try:
            #
            # Check on the requiered files
            #
            seeker = Image_tools.Seek_files( self.patient_dir_ )

            #
            # FLAIR file
            # 

            #
            # Find the FLAIR nifti file
            if seeker.seek_nifti( "FLAIR_" ):
                self.FLAIR_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.FLAIR_file_[0]), 
                             self.FLAIR_directory_ )
            # Find the FLAIR analyze file
            elif seeker.seek_analyze( "FLAIR_" ):
                self.FLAIR_file_ = seeker.get_files()
                # change into nifti format
                Image_tools.run_ana2nii( os.path.join(self.patient_dir_, self.FLAIR_file_[0]), # input
                                         os.path.join(self.patient_dir_, self.FLAIR_file_[0]), # ref
                                         os.path.join(self.FLAIR_directory_, 
                                                      "%s.nii.gz"%(self.FLAIR_file_[0][:-4])) )# output
                #
                self.FLAIR_file_[0] = os.path.join(self.FLAIR_directory_, "%s.nii.gz"%(self.FLAIR_file_[0][:-4]))
                self.FLAIR_file_[1] = ""
            else:
                raise Exception("FLAIR file does not exist.")
                

            #
            # T1 file
            # 

            #
            # Find the T1 nifti file
            if seeker.seek_nifti( "MP-LAS-long" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
                #
                self.T1_file_[0] = os.path.join( self.PVE_Segmentation_, self.T1_file_[0] )
            elif seeker.seek_nifti( "MP-LAS-3DC" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
                #
                self.T1_file_[0] = os.path.join( self.PVE_Segmentation_, self.T1_file_[0] )
            elif seeker.seek_nifti( "MP-LAS_" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
                #
                self.T1_file_[0] = os.path.join( self.PVE_Segmentation_, self.T1_file_[0] )
            elif seeker.seek_analyze( "MP-LAS-long" ):
                self.T1_file_ = seeker.get_files()
                # change into nifti
                Image_tools.run_ana2nii( os.path.join( self.patient_dir_, self.T1_file_[0] ),
                                         os.path.join( self.patient_dir_, self.T1_file_[0] ),
                                         os.path.join( self.PVE_Segmentation_, "%s.nii.gz"%(self.T1_file_[0][:-4])) )
                self.T1_file_[0] = os.path.join( self.PVE_Segmentation_, "%s.nii.gz"%(self.T1_file_[0][:-4]))
                self.T1_file_[1] = ""
            elif seeker.seek_analyze( "MP-LAS-3DC" ):
                self.T1_file_ = seeker.get_files()
                # change into nifti
                Image_tools.run_ana2nii( os.path.join( self.patient_dir_, self.T1_file_[0] ),
                                         os.path.join( self.patient_dir_, self.T1_file_[0] ),
                                         os.path.join( self.PVE_Segmentation_, "%s.nii.gz"%(self.T1_file_[0][:-4])) )
                self.T1_file_[0] = os.path.join( self.PVE_Segmentation_, "%s.nii.gz"%(self.T1_file_[0][:-4]))
                self.T1_file_[1] = ""
            elif seeker.seek_analyze( "MP-LAS_" ):
                self.T1_file_ = seeker.get_files()
                # change into nifti
                Image_tools.run_ana2nii( os.path.join( self.patient_dir_, self.T1_file_[0] ),
                                         os.path.join( self.patient_dir_, self.T1_file_[0] ),
                                         os.path.join( self.PVE_Segmentation_, "%s.nii.gz"%(self.T1_file_[0][:-4])) )
                self.T1_file_[0] = os.path.join( self.PVE_Segmentation_, "%s.nii.gz"%(self.T1_file_[0][:-4]))
                self.T1_file_[1] = ""
            else:
                raise Exception("T1 file does not exist.")
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol WMH - initialization -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol WMH - initialization -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol WMH - initialization -- failed")
            self.status_ = False
    #
    #
    #
    def segmentation_T1( self ):
        """Run SPM new segmentation. This function produces probability map for the main tisues and creates the brain mask. """
        try: 
            #
            # 
            T1_file = self.T1_file_[0]
            #
            if not os.path.isfile( T1_file ):
                raise Exception( "No T1 nifti file found in %s"%self.PVE_Segmentation_ )
            #
            if T1_file.endswith(".nii.gz"):
                os.system('gunzip %s'%self.T1_file_[0] )
                self.T1_file_[0] = "%s"%(self.T1_file_[0][:-3])
                T1_file          = self.T1_file_[0]

            #
            # Run Spm_NewSegment on the T1 
            mlc = mlab.MatlabCommand()
            cmd = """
            if isempty(which(\'spm\')),
              throw(MException(\'SPMCheck:NotFound\', \'SPM not in matlab path\'));
            end;
            [name, version] = spm(\'ver\');
            spm(\'Defaults\',\'fMRI\');
            if strcmp(name, \'SPM8\') || strcmp(name, \'SPM12b\'),
              spm_jobman(\'initcfg\');
              spm_get_defaults(\'cmdline\', 1);
            end;
            jobs{1}.spm.tools.preproc8.channel(1).biasreg  = 0.0001;
            jobs{1}.spm.tools.preproc8.channel(1).write(1) = 1;
            jobs{1}.spm.tools.preproc8.channel(1).write(2) = 1;
            jobs{1}.spm.tools.preproc8.channel(1).biasfwhm = 60.0;
            jobs{1}.spm.tools.preproc8.channel(1).vols = {\'%(T1)s'};
            spm_jobman(\'run\', jobs);"""%{'T1':T1_file}
            # 
            mlc.inputs.script = cmd
            mlc.inputs.mfile  = False
            mlc.run()

            #
            # Gather GM, WM and CSF
            c1_file = "" # GM
            c2_file = "" # WM
            c3_file = "" # CSF
            for file_name in os.listdir( self.PVE_Segmentation_ ):
                if file_name.startswith("c1"):
                    c1_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c2"):
                    c2_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c3"):
                    c3_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("m"):
                    T1_file = os.path.join( self.PVE_Segmentation_, file_name )

            #
            # Binary brain mask
            self.brain_mask_ = os.path.join( self.PVE_Segmentation_, "brain_mask.nii.gz" )
            # Add c1 (GM), c2 (WM) and c3 (CSF) and create a binary mask
            maths = fsl.ImageMaths( in_file   = c1_file,
                                    op_string = '-add %s -add %s'%(c2_file, c3_file), 
                                    out_file  = self.brain_mask_ )
            maths.run();
            # TODO: somehow hang calculation ...
            maths = fsl.ImageMaths( in_file       = self.brain_mask_,
                                    op_string     = '-thr 0.25',
                                    out_data_type = "char",
                                    out_file      = self.brain_mask_ )
            maths.run();
            #

            #
            # copy probability maps in FLAIR prior directory
            self.priors_.append(  os.path.join(self.priors_directory_, "priors", "POSTERIOR_01.nii.gz") )
            self.priors_.append(  os.path.join(self.priors_directory_, "priors", "POSTERIOR_02.nii.gz") )
            self.priors_.append(  os.path.join(self.priors_directory_, "priors", "POSTERIOR_03.nii.gz") )
            #
            shutil.copy( c1_file, self.priors_[0] )
            shutil.copy( c2_file, self.priors_[1] )
            shutil.copy( c3_file, self.priors_[2] )
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol WMH - run spm segmentT1 -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol WMH - run spm segmentT1 -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol WMH - run spm segmentT1 -- failed")
            self.status_ = False
    #
    #
    #
    def wmh_probability( self ):
        """White matter hyperintensity probability map.  """
        try: 
            #
            # Allign FLAIR with T1
            matrix_FLAIR_in_T1 = os.path.join(self.FLAIR_directory_, "F_in_T1.mat")
            FLAIR_in_T1        = os.path.join(self.FLAIR_directory_, "FLAIR_T1.nii.gz")
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join( self.FLAIR_directory_, self.FLAIR_file_[0] )
            flt.inputs.reference       = os.path.join( self.PVE_Segmentation_, self.T1_file_[0] )
            flt.inputs.out_file        = FLAIR_in_T1
            flt.inputs.out_matrix_file = matrix_FLAIR_in_T1
            flt.inputs.dof             = 6
            res = flt.run() 

            #
            # Run N4 alorithm to remove bias field
            FLAIR_in_T1_unb = os.path.join(self.FLAIR_directory_, "FLAIR_T1_unbiased.nii.gz")
            #
            n4 = ants.N4BiasFieldCorrection()
            n4.inputs.dimension                = 3
            n4.inputs.input_image              = FLAIR_in_T1
            n4.inputs.output_image             = FLAIR_in_T1_unb
            n4.inputs.mask_image               = self.brain_mask_
            n4.inputs.bspline_fitting_distance = 200
            n4.inputs.shrink_factor            = 2
            n4.inputs.n_iterations             = [50,50,30,20]
            n4.inputs.convergence_threshold    = 1.e-6
            n4.run()

            #
            # Segment FLAIR image to isolate WMH probability density
            os.mkdir( os.path.join(self.FLAIR_directory_,  "Seg_n_tissues") )
            os.mkdir( os.path.join(self.priors_directory_, "Seg_n_tissues") )
            #
            N = 15 # number of tissues in segmentation
            at = ants.Atropos()
            at.inputs.dimension                       = 3
            at.inputs.intensity_images                = FLAIR_in_T1_unb
            at.inputs.mask_image                      = self.brain_mask_
            at.inputs.output_posteriors_name_template =  os.path.join(self.priors_directory_, 
                                                                      "Seg_n_tissues", 
                                                                      "POSTERIOR_%02d.nii.gz")
            # initialization
            at.inputs.number_of_tissue_classes = N
            at.inputs.initialization           = 'KMeans'
            # -c [5,1.e-4]
            at.inputs.convergence_threshold    = 1.e-4
            at.inputs.n_iterations             = 5
            #  -m [0.5,1x1x1]
            at.inputs.mrf_smoothing_factor     = 0.5
            at.inputs.mrf_radius               = [1, 1, 1]
            #
            at.inputs.posterior_formulation         = 'Socrates'
            at.inputs.use_mixture_model_proportions =  True
            at.inputs.likelihood_model              = 'Gaussian'
            at.inputs.save_posteriors               =  True
            #
            at.run()

            #
            # Selects the WMH probability map 
            self.priors_.append( os.path.join(self.priors_directory_, "priors", "POSTERIOR_04.nii.gz") )
            # Sorts the ntissues segmentation probability maps
            for posterior in os.listdir( os.path.join(self.priors_directory_, "Seg_n_tissues") ):
                # select white matter hyperintensity probability map
                shutil.copy( os.path.join(self.priors_directory_, "Seg_n_tissues", posterior), 
                             os.path.join(self.FLAIR_directory_,  "Seg_n_tissues", posterior))
                if "POSTERIOR" in posterior and str(N) in posterior:
                    # Add the wmh prior in the set of prior for next step
                    shutil.copy( os.path.join(self.FLAIR_directory_, "Seg_n_tissues", posterior), self.priors_[3] )

            #
            # Run four tissues segmentation (GM, WM, CSF, WMH) to process balanced WMH probability map
            # Turn around R: drive symbolic links issue
            os.mkdir( os.path.join(self.FLAIR_directory_,  "output") )
            os.mkdir( os.path.join(self.priors_directory_, "output") )
            # Implementation of MAC ANTs function
            # turn around the thread-not-safe nipype implementation
            Image_tools.ANTs_Atropos( Input = FLAIR_in_T1_unb, 
                                      Mask = self.brain_mask_, 
                                      Number_of_tissue_classes = 4, 
                                      Prior_probability_format = os.path.join(self.priors_directory_, 
                                                                              "priors", "POSTERIOR_%02d.nii.gz"), 
                                      Prior_weighting = 0.3, 
                                      MRF_smoothing_factor = 0.3, 
                                      MRF_radius = "1x1x1", 
                                      Output_labeled = os.path.join(self.priors_directory_,  
                                                                    "output", "FLAIR_labeled.nii.gz"), 
                                      Output_posterior_format = os.path.join(self.priors_directory_, 
                                                                             "output", 
                                                                             "POSTERIOR_%02d.nii.gz") )
            # Copy back the results
            for res in os.listdir( os.path.join(self.priors_directory_, "output") ):
                shutil.copy( os.path.join(self.priors_directory_, "output", res), 
                             os.path.join(self.FLAIR_directory_, "output") )
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol WMH - wmh probability -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol WMH - run spm segmentT1 -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol WMH - run spm segmentT1 -- failed")
            self.status_ = False
    #
    #
    #
    def run( self ):
        """ Run the complete Hyperintense white matter process"""
        self.check_environment()
        #
        if self.status_:
            _log.info("Protocol WMH - check environment -- pass")
            self.initialization()
        #
        if self.status_:
            _log.info("Protocol WMH - initialization -- pass")
            self.segmentation_T1()
        #
        if self.status_:
            _log.info("Protocol WMH - run spm segmentT1 -- pass")
            self.wmh_probability()
        #
        if self.status_:
            _log.info("Protocol WMH - white matter probability maps -- pass")
