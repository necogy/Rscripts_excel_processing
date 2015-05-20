import logging
import inspect
import sys, os, shutil
import tempfile
import subprocess
import numpy
import nipype
import nipype.interfaces.fsl as fsl
import nipype.interfaces.spm as spm
import nipype.interfaces.matlab as mlab
# !!! SPM should be in the startup.m for nipype.interfaces.spm !!!
#
from zipfile import ZipFile as zf
#
#
#
import Image_tools
import EPI_distortion_correction
import Quality_control
import Motion_control as Mc
#
#
#
_log = logging.getLogger("__Arterial_Spin_Labeling__")
#
#
#
class Protocol( object ):
    """ Arterial Spin Labeling protocol
    
    Description: This script imports a set of python modules to be used
    for processing pulsed ASL perfusion data from the UCSF Neuroimaging Center and 
    the UCSF Memory and Aging Center. The script should be run on the cloud at:
    /mnt/macdata/groups/ASL_pipe/. If you drop your data in that directory
    and call the fallowing commands, this script will run: 

    1.) dicom to niftii conversion (dcm2nii)
    2.) Sorting of tagged (perfusion weighted) and untagged EPIs
    3.) Skull stripping (FSL BET)
    4.) Realigning the EPIs to the non-perfusion weighted m0 (i.e., first aquisition in EPI sequence) (SPM)
    5.) Calculate ASL perfusion maps via subtraction of mean images from tagged and untagged (FSL)
    6.) Register Ac-Pc aligned T2 weighted image to EPIs (SPM)
    7.) Run distortion correction of perfusion maps using T2 image (MATLAB)
    8.) Register ASL maps to T2, and T2 to T1, then combine the affine transforms (SPM)
    9.) Run Partial Volume Correction (MATLAB)
    10.) Calculate and Normalize CBF maps (CBF/m0) (MATLAB)
    11.) Extract mean CBF from freesurfer defined ROIs (FREESURFER)

    
    Attributes:
    patient_dir_     :string - ASL-pipe directory
    ACPC_Alignment_  :string - ACPC aligned T2 directory
    PVE_Segmentation_:string - PVE T1 directory 
    ASL_dicom_       :string - ASL dicom directory
    exec_path_       :string - path where the pipeline is run

    """
    def __init__( self ):
        """Return a new Protocol instance (constructor)."""
        try:
            #
            # public variables
            self.patient_dir_ = "" # Patient directory
            self.status_      = True
            # private variables
            # T2
            self.ACPC_Alignment_   = ""
            self.T2_file_          = []
            # T1
            self.PVE_Segmentation_ = ""
            self.T1_file_          = []
            # ASL
            self.ASL_dicom_        = ""
            self.ASL_file_         = []
            # Masks
            self.brain_mask_       = ""
            self.brain_prob_       = ""
            self.gm_mask_          = ""
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
            # make a directory for the Anterior- Posterior-Commissure (ACPC) aligned T2        
            self.ACPC_Alignment_ = os.path.join(self.patient_dir_, 'ACPC_Alignment')
            os.mkdir(self.ACPC_Alignment_)
            # make a directory for the Partial Volume Extraction (PVE) T1
            self.PVE_Segmentation_ = os.path.join(self.patient_dir_, 'PVE_Segmentation')
            os.mkdir(self.PVE_Segmentation_)
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
    #
    #
    #
    def initialization( self ):
        """Initialize all the data. This function convert DICOMs images (T1, T2, ASL) into niftii. The ASL images are sorted/renamed following their even number (untagged -- control) and odd number (tagged). Then, images are brain extracted using BET.
        """
        try:
            #
            # Check on the requiered files
            #
            seeker = Image_tools.Seek_files( self.patient_dir_ )

            #
            # T2 file
            # 

            #
            # Find the T2 nifti file
            if seeker.seek_nifti( "T2_" ):
                self.T2_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T2_file_[0]), self.ACPC_Alignment_ )
            # Find the T2 analyze file
            elif seeker.seek_analyze( "T2_" ):
                self.T2_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T2_file_[0]), self.ACPC_Alignment_ )
                shutil.copy( os.path.join(self.patient_dir_, self.T2_file_[1]), self.ACPC_Alignment_ )
                # change into nifti
                os.chdir(self.ACPC_Alignment_)
                ana2nii = spm.Analyze2nii();
                ana2nii.inputs.analyze_file = self.T2_file_[0]
                ana2nii.nifti_file          = "%s.nii"%(self.T2_file_[0][:-4])
                ana2nii.run();
                #
                os.remove( os.path.join(self.ACPC_Alignment_, self.T2_file_[0]) )
                os.remove( os.path.join(self.ACPC_Alignment_, self.T2_file_[1]) )
                self.T2_file_[0] = ana2nii.nifti_file
                self.T2_file_[1] = ""
                #
                os.chdir(self.patient_dir_)
            else:
                raise Exception("T2 file does not exist.")
                

            #
            # T2 file
            # 

            #
            # Find the T1 nifti file
            if seeker.seek_nifti( "MP-LAS-long" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
            elif seeker.seek_nifti( "MP-LAS-3DC" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
            elif seeker.seek_nifti( "MP-LAS_" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
            # Find the T1 zip file
            elif seeker.seek_zip( "MP-LAS-long" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
                # unzip
                os.chdir(self.PVE_Segmentation_);
                with zf( self.T1_file_[0] ) as zf_name:
                    zf_name.extractall();
                # change into nifti
                cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n *'
                Image_tools.generic_unix_cmd(cmd)
                cmd = 'rm c*.nii o*.nii'
                Image_tools.generic_unix_cmd(cmd)
                # replace extention
                for fname in os.listdir(  self.PVE_Segmentation_ ):
                    if fname.endswith( "nii" ):
                        self.T1_file_[0] = fname
                # Back to the orignal directory
                os.chdir(self.patient_dir_);
            #  Find the T1 analyze file
            elif seeker.seek_analyze( "MP-LAS-long" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[1]), self.PVE_Segmentation_ )
                # change into nifti
                os.chdir(self.PVE_Segmentation_);
                ana2nii = spm.Analyze2nii();
                ana2nii.inputs.analyze_file = self.T1_file_[0]
                ana2nii.nifti_file          = "%s.nii"%(self.T1_file_[0][:-4])
                ana2nii.run();
                #
                os.remove( os.path.join(self.PVE_Segmentation_, self.T1_file_[0]) )
                os.remove( os.path.join(self.PVE_Segmentation_, self.T1_file_[1]) )
                self.T1_file_[0] = ana2nii.nifti_file
                self.T1_file_[1] = ""
                #
                os.chdir(self.patient_dir_);
            elif seeker.seek_analyze( "MP-LAS-3DC" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[1]), self.PVE_Segmentation_ )
                 # change into nifti
                os.chdir(self.PVE_Segmentation_);
                ana2nii = spm.Analyze2nii();
                ana2nii.inputs.analyze_file = self.T1_file_[0]
                ana2nii.nifti_file          = "%s.nii"%(self.T1_file_[0][:-4])
                ana2nii.run();
                #
                os.remove( os.path.join(self.PVE_Segmentation_, self.T1_file_[0]) )
                os.remove( os.path.join(self.PVE_Segmentation_, self.T1_file_[1]) )
                self.T1_file_[0] = ana2nii.nifti_file
                self.T1_file_[1] = ""
                #
                os.chdir(self.patient_dir_);
            elif seeker.seek_analyze( "MP-LAS_" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[1]), self.PVE_Segmentation_ )
                # change into nifti
                os.chdir(self.PVE_Segmentation_);
                ana2nii = spm.Analyze2nii();
                ana2nii.inputs.analyze_file = self.T1_file_[0]
                ana2nii.nifti_file          = "%s.nii"%(self.T1_file_[0][:-4])
                ana2nii.run();
                #
                os.remove( os.path.join(self.PVE_Segmentation_, self.T1_file_[0]) )
                os.remove( os.path.join(self.PVE_Segmentation_, self.T1_file_[1]) )
                self.T1_file_[0] = ana2nii.nifti_file
                self.T1_file_[1] = ""
                #
                os.chdir(self.patient_dir_);
            else:
                raise Exception("T1 file does not exist.")

            #
            # Set the ASL-raw folder
            if seeker.seek_zip( "ASL-raw" ):
                self.ASL_file_ = seeker.get_files()
                with zf( os.path.join(self.patient_dir_, self.ASL_file_[0]) ) as zf_dir:
                    zf_dir.extractall( os.path.join(self.patient_dir_, 'ASL-raw') )
                # Create subdirectories
                asl_sub_dir = ""
                for fname in os.listdir( os.path.join(self.patient_dir_, 'ASL-raw') ):
                    asl_sub_dir = fname;
                #
                if not os.path.exists( os.path.join(self.patient_dir_, 'ASL-raw', asl_sub_dir) ):
                    raise Exception("ASL-raw sub-directory does not exist." )
                else:
                    # Create a variable for the dicom directory
                    self.ASL_dicom_ = os.path.join(self.patient_dir_, 'ASL-raw', asl_sub_dir)
            else:
                raise Exception("ASL file does not exist.")
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
            self.status_ = False
    #
    #
    #
    def perfusion_weighted_imaging( self ):
        """perfusion-weighted magnetic resonance images (PWI) processing. 
        1 - Make a directory for all nifitis 'ni_all'
        2 - Convert all the dcms to nii and move them to the nii_all directory
        3 - Skull-strip and realign them to first EPI
        4 - List the brain files and pop out m0, and realign the brain files with smp
        5 - Merge the files into asl.nii and run asl_file
        
        So we can use them in fsl's asl-subtract to get perfusion weighted image (PWI avg).

        """
        try:
            #
            #
            os.chdir( self.ASL_dicom_ )
            os.mkdir('nii_all');
            # DICOM to nifti again ...
            for file_name in os.listdir( os.getcwd() ):
                if file_name != "tagged" and file_name != "untagged" and file_name != "nii_all":
                    cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n %s' %file_name
                    Image_tools.generic_unix_cmd(cmd)
            #
            # move nifti files into the nii_all dir
            for nii_file in os.listdir( self.ASL_dicom_ ):
                if nii_file.endswith('.nii'):
                    shutil.move( os.path.join(self.ASL_dicom_, nii_file), 
                                 os.path.join(self.ASL_dicom_, 'nii_all') );


            #
            # Create 4D asl image
            os.chdir( os.path.join(self.ASL_dicom_, 'nii_all') );
            # asl.nii.gz file
            realigned_stripped_dir = os.path.join( self.ASL_dicom_, 'nii_all', 'realigned_stripped')
            os.mkdir( realigned_stripped_dir );
            asl_4D   = os.path.join( realigned_stripped_dir, "asl_4D.nii.gz")
            asl_file = os.path.join( realigned_stripped_dir, "asl.nii.gz")
            m0_roi   = os.path.join( realigned_stripped_dir, "m0_brain.nii.gz")
            # Get list of all EPIs
            stripped_list = [];
            for file_name in os.listdir( os.path.join(self.ASL_dicom_, 'nii_all') ):
                if file_name.endswith('.nii'):
                    stripped_list.append( file_name );
            # Sort the list to be realigned on m0
            stripped_list.sort();
            #
            merger = fsl.Merge()
            merger.inputs.in_files     =  stripped_list
            merger.inputs.dimension    = 't'
            merger.inputs.output_type  = 'NIFTI_GZ'
            merger.inputs.merged_file  =  asl_4D
            merger.run()
            # Motion correction
            mc = Mc.Motion_control( asl_4D )
            mc.MC_flirt( asl_file )

            #
            # splite asl.nii into m0 and asl.nii
            # how many frames do we have in asl.nii
            cmd = 'fslnvols %s' %asl_file
            num_of_frame = Image_tools.generic_unix_cmd(cmd)
            # M0 frame
            fslroi = fsl.ExtractROI()
            fslroi.inputs.in_file  = asl_file
            fslroi.inputs.roi_file = m0_roi
            fslroi.inputs.t_min    = 0
            fslroi.inputs.t_size   = 1
            fslroi.run()
            # asl.nii frames, m0 extracted
            fslroi = fsl.ExtractROI()
            fslroi.inputs.in_file  = asl_file
            fslroi.inputs.roi_file = asl_file
            fslroi.inputs.t_min    = 1
            fslroi.inputs.t_size   = int(num_of_frame) - 1
            fslroi.run()

            #
            # Skull stripping using SPM mask
            os.chdir( os.path.join(self.ASL_dicom_,'nii_all','realigned_stripped') )
            #
            head_T2_m0       = os.path.join(self.ASL_dicom_,"nii_all","realigned_stripped",
                                            "head_T2_m0.nii.gz")
            brain_T2_mask_m0 = os.path.join(self.ASL_dicom_,"nii_all","realigned_stripped",
                                            "brain_T2_mask_m0.nii.gz")
            #
            head_m0        = m0_roi #"r%s"%( stripped_list.pop(0) )
            head_T2_m0_mat = os.path.join(self.ASL_dicom_,"nii_all","realigned_stripped",
                                          "head_T2_m0.mat")
            #
            # Register T2 and mask in EPI framwork
            # T2 head
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join( self.ACPC_Alignment_, self.T2_file_[0] )
            flt.inputs.reference       = head_m0
            flt.inputs.out_file        = head_T2_m0
            flt.inputs.out_matrix_file = head_T2_m0_mat
            flt.inputs.args            = "-dof 6"
            res = flt.run()
            # Qulity control: load the matrix and quit if matrix is not Id
            self.QC_registration_matrix_( head_T2_m0_mat )
            # T2 mask
            flt = fsl.FLIRT()
            flt.inputs.in_file         = self.brain_mask_
            flt.inputs.reference       = head_m0
            flt.inputs.out_file        = brain_T2_mask_m0
            flt.inputs.in_matrix_file  = head_T2_m0_mat
            flt.inputs.apply_xfm       = True
            flt.inputs.args            = "-dof 6"
            res = flt.run()
            # Re-binarise the mask in low resolution
            maths = fsl.ImageMaths( in_file       = brain_T2_mask_m0,
                                    op_string     = "-bin",
                                    out_data_type = "char",
                                    out_file      = brain_T2_mask_m0 )
            maths.run();
            #
            # Skull stripping
            # m0
            maths = fsl.ImageMaths( in_file   =  m0_roi,
                                    op_string = "-mas %s"%(brain_T2_mask_m0), 
                                    out_file  =  m0_roi )
            maths.run()
            # asl.nii
            maths = fsl.ImageMaths( in_file   = asl_file,
                                    op_string = "-mas %s"%(brain_T2_mask_m0), 
                                    out_file  =  "%s_brain.nii.gz"%(asl_file[:-7]) )
            maths.run()

            #
            # filter ASL file
            # asl_file
            # --data
            # --ntis we have X repeats all at single inflow-time 'asl.nii': ntis=1
            # --iaf inflow-time contains 
            #   * 'tc' tag-control pairs (with tag coming as the first volume)
            #   * 'ct' control-tag pairs (with control coming as the first volume)
            # --out diff between tag-control
            # --mean average of diff between tag-control
            cmd='asl_file --data=asl_brain.nii.gz --ntis=1 --iaf=tc --diff --out=diffdata --mean=diffdata_mean'
            Image_tools.generic_unix_cmd(cmd)
            os.system('gunzip *.nii.gz')
            # copy m0 frame
            shutil.copy( m0_roi[:-3], 
                         os.path.join(self.ASL_dicom_, 'nii_all') );
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
    #
    #
    #
    def CBFscale_PWI_data( self ):
        """Scale PWI for time lag and compute CBF. CBF_Scaled_PWI.nii don't provide CBF. To produce CBF the map as to be normalized with m0 map"""
        #
        #
        all_aligned_dir = os.path.join( self.ASL_dicom_, 'nii_all/realigned_stripped' )
        #
        mlc = mlab.MatlabCommand()
        cmd = "cd('%s'); raw_pwi = spm_vol('diffdata_mean.nii'); scaled_pwi = raw_pwi; scaled_pwi.fname = 'CBF_Scaled_PWI.nii'; scaled_pwi.descript = 'Scaled from the PWI Image'; pwi_data = spm_read_vols(raw_pwi); Lamda = 0.9000; Alpha = 0.9500; Tau = 22.50; R1A = (1684)^-1; PER100G = 100; SEC_PER_MIN = 60; MSEC_PER_SEC = 1000; TI1 = 700; TI2 = 1800; PWI_scale = zeros(size(pwi_data)); sliceNumbers = (1:size(pwi_data, 3))'; Constant = Lamda / (2 * Alpha * TI1) * (PER100G * SEC_PER_MIN * MSEC_PER_SEC); Slice_based_const = exp(R1A * (TI2 + (sliceNumbers - 1) * Tau)); Numerator = pwi_data; for n =1:size(sliceNumbers);    PWI_scale(:,:,n) = Constant * Slice_based_const(n) * Numerator(:,:,n); end;  spm_write_vol(scaled_pwi, PWI_scale);" %all_aligned_dir
        #
        mlc.inputs.script = cmd
        mlc.run()
    #
    #
    #
    def EPI_realignment_( self ):
        """Realigning the EPIs to the non-perfusion weighted m0 using spm_realign. """
        try: 
            #
            #
            tagg_stripped_list = []
            tagged_untagged_directory = {'tagged':   os.path.join(self.ASL_dicom_, 'tagged'),
                                         'untagged': os.path.join(self.ASL_dicom_, 'untagged') }
            #
            for pref, directory in tagged_untagged_directory.iteritems():
                os.mkdir( os.path.join(directory, 'skull_stripped') )
                os.chdir(directory)
                # Convert tagged and untagged EPIs to .nii and extract brain
                for file_name in os.listdir(directory):
                    if file_name.startswith(pref):
                        cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n %s' %file_name
                        Image_tools.generic_unix_cmd(cmd)
                    elif file_name.startswith('m0'):
                        cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n %s' %file_name
                        Image_tools.generic_unix_cmd(cmd)
                Image_tools.run_bet( directory, 0.7 )
                # Realign the brain files
                for file_name in os.listdir(directory):
                    if file_name.endswith('brain.nii.gz'):
                        shutil.move( os.path.join(directory, file_name), 
                                     os.path.join( directory, 'skull_stripped') )
                        os.system( 'gunzip %s' %(os.path.join( directory, 'skull_stripped', 
                                                               file_name)) )
                        # Get final list of unzipped skull-stripped files
                        tagg_stripped_list.append(file_name[:-3])
                # Run spm realign on un/tagged skull stripped images
                self.run_spm_realign( os.path.join( directory, 'skull_stripped'), 
                                      tagg_stripped_list )
                # reset the lists
                tagg_stripped_list = []
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
    #
    #
    #
    def perfusion_calculation( self ):
        """Function sums and avgs skull stripped/aligned EPIs for tagged and untagged aquisitions."""
        try: 
            #
            # sort/rename even numbered (untagged), odd numbered (tagged), and m0 EPIs
            os.mkdir( os.path.join(self.ASL_dicom_, 'tagged') )
            os.mkdir( os.path.join(self.ASL_dicom_, 'untagged') )
            # Place even numbered acquistions in untagged folder, 
            # and odd acquisitions in tagged folder
            for file_name in os.listdir( self.ASL_dicom_ ):
                if file_name == 'tagged' or file_name == 'untagged':
                    pass; # skipp dir names
                elif float(file_name[9:12])%2 == 0 and file_name[9:12] != '001':
                    # copy odd file
                    shutil.copy( os.path.join(self.ASL_dicom_, file_name), 
                                 os.path.join(self.ASL_dicom_, 'untagged','untagged_' + file_name[9:12]) );
                elif float(file_name[9:12])%2 != 0 and file_name[9:12] != '001':
                    # copy even file
                    shutil.copy( os.path.join(self.ASL_dicom_, file_name), 
                                 os.path.join(self.ASL_dicom_, 'tagged','tagged_' + file_name[9:12]) );
                elif file_name[9:12] == '001':
                    # create m0 from first non-perfusion weighted EPI
                    shutil.copy( os.path.join(self.ASL_dicom_, file_name), 
                                 os.path.join(self.ASL_dicom_, 'm0') );
            # Store variables for tagged and untagged dirs, move a copy of m0 to each
            shutil.copy( os.path.join(self.ASL_dicom_, 'm0'),  
                         os.path.join(self.ASL_dicom_, 'tagged') )
            shutil.copy( os.path.join(self.ASL_dicom_, 'm0'),  
                         os.path.join(self.ASL_dicom_, 'untagged') )

            #
            # Realigned the EPI on m0
            self.EPI_realignment_()

            #
            #
            aligned_list =[]
            tagg_directory = {'tagged':   os.path.join(self.ASL_dicom_, 'tagged', 'skull_stripped'), 
                              'untagged': os.path.join(self.ASL_dicom_, 'untagged', 'skull_stripped')}
            #
            raw_perfusion_dir = os.path.join(self.patient_dir_, 'Raw_Perfusion')
            os.mkdir( raw_perfusion_dir )
            #
            # sums skull stripped/aligned EPIs
            for pref, directory in tagg_directory.iteritems():
                os.chdir(directory);
                #
                for file_name in os.listdir(directory):
                    if file_name.startswith('r' + pref):
                        aligned_list.append(file_name);
                # Sum of all aligned {tagged,untagged} files
                aligned_list.sort();
                maths = fsl.ImageMaths(in_file = aligned_list[0], 
                                       op_string = '-add %s' %(aligned_list[1]), 
                                       out_file = pref + '_sum.nii.gz')
                maths.run();
                # decomposition into two sums does not make sens ...
                for fname in aligned_list[2:]:
                    print 'Summing EPI %s' %(fname)
                    maths = fsl.ImageMaths(in_file = fname, 
                                           op_string = '-add %s' %(pref + '_sum.nii.gz'), 
                                           out_file = pref + '_sum.nii.gz')
                    maths.run();
                #
                # avgs skull stripped/aligned EPIs
                denom = len(aligned_list);
                maths = fsl.ImageMaths(in_file = pref + '_sum.nii.gz', 
                                       op_string = '-div %s' %(denom), 
                                       out_file = pref + '_avg.nii.gz')
                maths.run();
                #
                shutil.move( pref + '_avg.nii.gz', raw_perfusion_dir )
                #
                aligned_list = [];
            #
            #
            os.chdir(raw_perfusion_dir);
            maths = fsl.ImageMaths(in_file = 'tagged_avg.nii.gz', 
                                   op_string = '-sub %s' %('untagged_avg.nii.gz'), 
                                   out_file = 'mean_perfusion_raw.nii.gz')
            maths.run();
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
        except:
            print "Unexpected error:", sys.exc_info()[0]
    #
    #
    #
    def run_spm_segmentT1( self ):
        """Run SPM new segmentation. The results will be aligned within the T2 framework for the partial volume estimation (PVE) and the partial volume correction of the cerebral blood flow analysise. """
        try: 
            #
            # Go into dir with PVE t1 and find the t1 filename
            os.chdir( self.PVE_Segmentation_ )
            # 
            T1_file = self.T1_file_[0]
            if T1_file.endswith(".nii.gz"):
                os.system('gunzip %s'%self.T1_file_[0] )
                T1_file = "%s.nii"%(self.T1_file_[0][:-4])
            #
            if not os.path.isfile( os.path.join(self.PVE_Segmentation_, T1_file) ):
                raise Exception( "No T1 nifti file found" )
            else:
                T1_file = os.path.join(self.PVE_Segmentation_, T1_file)

            #
            # Run Spm_NewSegment on the T1 to get GM,WM,ventricles
            seg = spm.NewSegment();
            seg.inputs.channel_files = T1_file;
            seg.inputs.channel_info  = (0.0001, 60, (True, True))
            seg.run();

            #
            # Gather GM, WM and CSF
            c1_file = "" # GM
            c2_file = "" # WM
            c3_file = "" # CSF
            for file_name in os.listdir( self.PVE_Segmentation_ ):
                if file_name.startswith("c1"):
                    c1_file = file_name
                if file_name.startswith("c2"):
                    c2_file = file_name
                if file_name.startswith("c3"):
                    c3_file = file_name
                if file_name.startswith("m"):
                    T1_file = os.path.join( self.PVE_Segmentation_, file_name )

            #
            # Need T2 for the registration: next step
            T2_file = ""
            for file_name in os.listdir( self.ACPC_Alignment_ ):
                if file_name.startswith("T2") and file_name.endswith("nii") and "brain" not in file_name:
                    T2_file = os.path.join( self.ACPC_Alignment_, file_name ) 
            # check we have the file
            if not os.path.isfile( T2_file ):
                raise Exception( "No T2 nifti file found" )

            #
            # T1, c1, c2, c3 Rigid registration on T2; degree of freedom = 6 (rotation, translation)
            matrix_T1_in_T2 = os.path.join(self.PVE_Segmentation_, "T1_in_T2.mat")
            # T1
            T1_in_T2 = "%s_T2.nii.gz"%(T1_file[:-4])
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = T1_file
            flt.inputs.reference       = T2_file
            flt.inputs.out_file        = T1_in_T2
            flt.inputs.out_matrix_file = matrix_T1_in_T2
            flt.inputs.dof             = 6
            res = flt.run() 
            # c1
            c1_in_T2 = "%s_T2.nii.gz"%(c1_file[:-4])
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = c1_file
            flt.inputs.reference       = T2_file
            flt.inputs.out_file        = c1_in_T2
            flt.inputs.in_matrix_file  = matrix_T1_in_T2
            flt.inputs.apply_xfm       = True
            flt.inputs.dof             = 6
            res = flt.run()
            # c2
            c2_in_T2 = "%s_T2.nii.gz"%(c2_file[:-4])
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = c2_file
            flt.inputs.reference       = T2_file
            flt.inputs.out_file        = c2_in_T2
            flt.inputs.in_matrix_file  = matrix_T1_in_T2
            flt.inputs.apply_xfm       = True
            flt.inputs.dof             = 6
            res = flt.run() 
            # c3
            c3_in_T2 = "%s_T2.nii.gz"%(c3_file[:-4])
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = c3_file
            flt.inputs.reference       = T2_file
            flt.inputs.out_file        = c3_in_T2
            flt.inputs.in_matrix_file  = matrix_T1_in_T2
            flt.inputs.apply_xfm       = True
            flt.inputs.dof             = 6
            res = flt.run()

            #
            # Create a mask for T2 brain extraction
            #

            #
            # Create brain probability map
            maths = fsl.ImageMaths( in_file   = c1_in_T2,
                                    op_string = '-add %s '%(c2_in_T2), 
                                    out_file  = "brain_map.nii.gz" )
            maths.run();
            #
            self.brain_prob_ = os.path.join( self.PVE_Segmentation_, "brain_map.nii.gz" )

            #
            # Add c1 (GM), c2 (WM) and c3 (CSF) and create a binary mask
            maths = fsl.ImageMaths( in_file   = c1_in_T2,
                                    op_string = '-add %s '%(c2_in_T2), 
                                    out_file  = "brain_mask.nii.gz" )
            maths.run();
            #
            maths = fsl.ImageMaths( in_file   = "brain_mask.nii.gz",
                                    op_string = '-add %s'%(c3_in_T2), 
                                    out_file  = "brain_mask.nii.gz" )
            maths.run();
            # TODO: somehow hang calculation ...
            maths = fsl.ImageMaths( in_file       = "brain_mask.nii.gz",
                                    op_string     = '-thr 0.3 -fillh26 -bin',
                                    out_data_type = "char",
                                    out_file      = "brain_mask.nii.gz" )
            maths.run();
            self.brain_mask_ = os.path.join( self.PVE_Segmentation_, "brain_mask.nii.gz" )


            #
            # Create a mask only for the gray matter
            # WARNING: visualization purposes
            #
            
            #
            # This filter will remove 0 +- epsilon values from the flow spectrum
            maths = fsl.ImageMaths( in_file       = c1_in_T2,
                                    op_string     = "-thr 0.3  -fillh26 -bin",
                                    out_data_type = "char",
                                    out_file      = "c1_T2_mask.nii.gz")
            maths.run();
            self.gm_mask_ = os.path.join( self.PVE_Segmentation_, "c1_T2_mask.nii.gz" )
            #
            os.system("gunzip %s"%(T1_in_T2))
            os.system("gunzip %s"%(c1_in_T2))
            os.system("gunzip %s"%(c2_in_T2))
            os.system("gunzip %s"%(c3_in_T2))

            #
            # extraction of T1 brain
            maths = fsl.ImageMaths( in_file   = T1_in_T2[:-3],
                                    op_string = '-mas %s'%(self.brain_mask_), 
                                    out_file  = "T1_brain.nii.gz" )
            maths.run();

            if False:
                #
                # Mapping of T1 within MNI152
                #
            
                #
                # MNI selected
                MNI_T1_2mm       = ""
                MNI_T1_brain_1mm = ""
                MNI_T1_brain_2mm = ""
                if os.environ.get('FSLDIR'):
                    MNI_T1_2mm = os.path.join( os.environ.get('FSLDIR'), 
                                               "data","standard","MNI152_T1_2mm.nii.gz" )
                    MNI_T1_brain_1mm = os.path.join( os.environ.get('FSLDIR'), 
                                                     "data","standard","MNI152_T1_1mm_brain.nii.gz" )
                    MNI_T1_brain_2mm = os.path.join( os.environ.get('FSLDIR'), 
                                                     "data","standard","MNI152_T1_2mm_brain.nii.gz" )
                else:
                    raise Exception( "$FSLDIR env variable is not setup on your system" )
 
                #
                # Linear registration from T2 to MNI 152
                T1_MNI_mat = os.path.join(self.PVE_Segmentation_, "T1_MNI.mat")
                #
                flt = fsl.FLIRT()
                flt.inputs.in_file         = "T1_brain.nii.gz"
                flt.inputs.reference       =  MNI_T1_brain_1mm
                flt.inputs.out_file        = "T1_brain_MNI_flirt.nii.gz"
                flt.inputs.out_matrix_file =  T1_MNI_mat
                flt.inputs.dof             =  12
                res = flt.run()
 
                #
                # Non-linear registration from T2 to MNI 152
                T1_MNI_mat = os.path.join(self.PVE_Segmentation_, "T1_MNI.mat")
                #
                fnt = fsl.FNIRT()
                fnt.inputs.in_file         =  T1_in_T2[:-3]
                fnt.inputs.ref_file        =  MNI_T1_2mm
                fnt.inputs.warped_file     = "T1_MNI_fnirt.nii.gz"
                fnt.inputs.affine_file     =  T1_MNI_mat
                fnt.inputs.config_file     = "T1_2_MNI152_2mm"
                fnt.inputs.field_file      = "T1_to_MNI_nonlin_field.nii.gz" 
                fnt.inputs.fieldcoeff_file = "T1_to_MNI_nonlin_coeff.nii.gz" 
                fnt.inputs.jacobian_file   = "T1_to_MNI_nonlin_jac.nii.gz"  
                res = fnt.run()
                
                # 
                # Warp the brain
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = "T1_brain.nii.gz"
                aw.inputs.ref_file   =  MNI_T1_2mm
                aw.inputs.out_file   = "T1_brain_MNI.nii.gz"
                aw.inputs.field_file = "T1_to_MNI_nonlin_coeff.nii.gz"
                res = aw.run()
                # 
                # Warp the GM
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = c1_in_T2[:-3]
                aw.inputs.ref_file   =  MNI_T1_2mm
                aw.inputs.out_file   = "T1_GM_MNI.nii.gz"
                aw.inputs.field_file = "T1_to_MNI_nonlin_coeff.nii.gz"
                res = aw.run()
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
    #
    #
    #
    def T2_PWI_registration( self ):
        """registration between T2 and PWI."""
        try: 
            #
            # Start in Anterior/Posterior Commissures directory
            os.chdir( self.ACPC_Alignment_ )
            #
            # Extract skull from T2 and the mask. Using the T1 brain mask
            # cut around the mask
            maths = fsl.ImageMaths( in_file   = self.T2_file_[0],
                                    op_string = '-mas %s'%(self.brain_mask_), 
                                    out_file  = "T2_brain.nii.gz" )
            maths.run();
            #
            T2_skull_stripped = "T2_brain.nii.gz"
            #
            os.system( "gunzip %s"%T2_skull_stripped ) 

            #
            # Create PWI.nii
            os.mkdir("PWI")
            # Distortion will be done on m0, and th correction will be done on CBF_Scaled_PWI.nii
            DeltaM   = os.path.join(self.ACPC_Alignment_, "PWI", "CBF_Scaled_PWI.nii")
            shutil.copy( os.path.join(self.ASL_dicom_, "nii_all", "realigned_stripped",
                                      "CBF_Scaled_PWI.nii"), DeltaM )
            #
            M0_brain = os.path.join(self.ACPC_Alignment_, "PWI", "m0_brain.nii")
            shutil.copy( os.path.join(self.ASL_dicom_, "nii_all", "m0_brain.nii"), 
                         M0_brain );

            #
            # Rigid registration of T2 (or mask) in m0 with repading; degree of freedom = 12
            T2_registration = os.path.join(self.ACPC_Alignment_, "PWI", "T2_registration.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, T2_skull_stripped[:-3])
            flt.inputs.reference       = M0_brain
            flt.inputs.out_file        = T2_registration
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "PWI", "T22m0.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 
            #
            os.system("gunzip PWI/T2_registration.nii.gz")

            #
            # MNI atlas registration 
            #
            
            #
            # MNI atlas selected
            MNI_atlas = ""
            if os.environ.get('FSLDIR'):
                MNI_atlas = os.path.join( os.environ.get('FSLDIR'), 
                                          "data","atlases","MNI","MNI-maxprob-thr0-1mm.nii.gz" )
            else:
                raise Exception( "$FSLDIR env variable is not setup on your system" )
            #
            MNI_LD = os.path.join( self.ACPC_Alignment_, "MNI_T2_m0.nii.gz" )
            MNI_HD = os.path.join( self.ACPC_Alignment_, "MNI_T2.nii.gz" )

            #
            # Registration high resolution
            flt = fsl.FLIRT()
            flt.inputs.in_file         = MNI_atlas
            flt.inputs.reference       = os.path.join(self.ACPC_Alignment_, T2_skull_stripped[:-3])
            flt.inputs.out_file        = MNI_HD
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "MNI2T2.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 

            #
            # Registration low resolution
            flt = fsl.FLIRT()
            flt.inputs.in_file         = MNI_atlas
            flt.inputs.reference       = T2_registration[:-3]
            flt.inputs.out_file        = MNI_LD
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "MNI2m0.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 

            # 
            # EPI distortion correction
            #

            #
            # m0 and DeltaM correction
            distortion = EPI_distortion_correction.EPI_distortion_correction()
            distortion.working_dir_ = os.path.join(self.ACPC_Alignment_, "test_wd")
            distortion.control_     = M0_brain
            distortion.t2_          = T2_registration[:-3]
            distortion.transform_   = os.path.join(self.ACPC_Alignment_, "field_correction.nii")
            distortion.control_corrected_ = os.path.join(self.ACPC_Alignment_, "m0_brain_corrected.nii")
            distortion.calculate_transform()
            #
            # Apply transform on m0
            distortion.apply_transform()
            # Smooth the maps. Using 3D filter, we assume the blood flow being the same in the neighboring voxels
            maths = fsl.ImageMaths( in_file   = distortion.control_corrected_, 
                                    op_string = '-fmean -kernel 3D ', 
                                    out_file  = "%s_3D.nii.gz" %(distortion.control_corrected_[:-4]) )
            maths.run();
            #
            # Apply transform on DeltaM
            distortion.control_ = DeltaM
            distortion.control_corrected_ = os.path.join(self.ACPC_Alignment_, "PWI_corrected.nii")
            distortion.apply_transform()
            # Smooth the maps. Using 3D filter, we assume the blood flow being the same in the neighboring voxels
            maths = fsl.ImageMaths( in_file   = distortion.control_corrected_, 
                                    op_string = '-fmean -kernel 3D', 
                                    out_file  = "%s_3D.nii.gz" %(distortion.control_corrected_[:-4]) )
            maths.run();
            
            #
            # Production of high resolution (HD) map
            #

            #
            # Gather GM, WM and CSF registered with T2
            T1_file = "" # T1  registered T2
            c1_file = "" # GM  registered T2
            c2_file = "" # WM  registered T2
            c3_file = "" # CSF registered T2
            for file_name in os.listdir( self.PVE_Segmentation_ ):
                if file_name.startswith("c1") and file_name.endswith("T2.nii"):
                    c1_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c2") and file_name.endswith("T2.nii"):
                    c2_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c3") and file_name.endswith("T2.nii"):
                    c3_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("m") and file_name.endswith("T2.nii"):
                    T1_file = os.path.join( self.PVE_Segmentation_, file_name )
            # Check we have the maps
            if not ( os.path.isfile( c1_file ) or 
                     os.path.isfile( c2_file ) or 
                     os.path.isfile( c3_file ) ):
                raise Exception( "Missing partial volumes." )

            #
            # Rigid registration of m0 in T2 with repading; degree of freedom = 12
            m0_brain_corrected_T2 = os.path.join(self.ACPC_Alignment_, "m0_brain_corrected_T2.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "m0_brain_corrected.nii")
            flt.inputs.reference       = T2_skull_stripped[:-3]
            flt.inputs.out_file        = m0_brain_corrected_T2
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "m02T2.mat")
            flt.inputs.dof             = 6
            res = flt.run() 
            # Registration of EPI to structural using Boundary-based Registration (BBR)
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "m0_brain_corrected.nii")
            flt.inputs.reference       = T1_file
            flt.inputs.out_file        = m0_brain_corrected_T2
            flt.inputs.in_matrix_file  = os.path.join(self.ACPC_Alignment_, "m02T2.mat")
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "m0BBR.mat")
            flt.inputs.cost            = "bbr"
            flt.inputs.wm_seg          = c2_file
            flt.inputs.dof             = 6
            flt.inputs.schedule        = os.path.join( os.environ.get('FSLDIR'), 
                                                       "etc","flirtsch","bbr.sch" )
            res = flt.run() 
            # Filter the maps. Using FWHM filter, we assume the blood flow being the same 
            # in neighboring voxels. FWHM = 2.3548 * 3.121
            maths = fsl.ImageMaths( in_file   = m0_brain_corrected_T2, 
                                    op_string = '-fmean -kernel gauss 3.121 ', 
                                    out_file  = "%s_3D.nii.gz" %(m0_brain_corrected_T2[:-7]) )
#            maths.run();
#            # Filter the result with brain mask
#            maths = fsl.ImageMaths( in_file   = "%s_3D.nii.gz" %(m0_brain_corrected_T2[:-7]),
#                                    op_string = "-mas %s"%(self.brain_mask_), 
#                                    out_file  = "%s_3D.nii.gz" %(m0_brain_corrected_T2[:-7]) )
            maths.run();

            #
            # Rigid registration of PWI in T2 with repading; degree of freedom = 12
            PWI_corrected_T2 = os.path.join(self.ACPC_Alignment_, "PWI_corrected_T2.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "PWI_corrected.nii")
            flt.inputs.reference       = T2_skull_stripped[:-3]
            flt.inputs.out_file        = PWI_corrected_T2
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "PWI2T2.mat")
            flt.inputs.dof             = 6
            res = flt.run() 
            # Registration of EPI to structural using Boundary-based Registration (BBR)
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "PWI_corrected.nii")
            flt.inputs.reference       = T1_file
            flt.inputs.out_file        = PWI_corrected_T2
            flt.inputs.in_matrix_file  = os.path.join(self.ACPC_Alignment_, "m02T2.mat")
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "PWIBBR.mat")
            flt.inputs.cost            = "bbr"
            flt.inputs.wm_seg          = c2_file
            flt.inputs.dof             = 6
            flt.inputs.schedule        = os.path.join( os.environ.get('FSLDIR'), 
                                                       "etc","flirtsch","bbr.sch" )
            res = flt.run() 
            # Filter the maps. Using FWHM filter, we assume the blood flow being the same 
            # in neighboring voxels. FWHM = 2.3548 * 3.121
            maths = fsl.ImageMaths( in_file   = PWI_corrected_T2, 
                                    op_string = '-fmean -kernel gauss 3.121 ', 
                                    out_file  = "%s_3D.nii.gz" %(PWI_corrected_T2[:-7]) )
            maths.run();
#            # Filter the result with brain mask
#            maths = fsl.ImageMaths( in_file   = "%s_3D.nii.gz" %(PWI_corrected_T2[:-7]),
#                                    op_string = "-mas %s"%(self.brain_mask_), 
#                                    out_file  = "%s_3D.nii.gz" %(PWI_corrected_T2[:-7]) )
#            maths.run();
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
    #
    #
    #
    def Cerebral_blood_flow( self ):
        """Cerebral blood flow processing."""
        try: 
            #
            # realigne PWI with m0
            os.chdir( self.ACPC_Alignment_ )
            # brain and GM mask
            # Rigid registration of PWI in m0; degree of freedom = 12
            PWI_corrected_m0 = os.path.join(self.ACPC_Alignment_, "PWI_corrected_3D_m0.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "PWI_corrected_3D.nii.gz" )
            flt.inputs.reference       = os.path.join(self.ACPC_Alignment_, "PWI", "T2_registration.nii" )
            flt.inputs.out_file        = PWI_corrected_m0
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "PWI2T2.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 
            
            #
            # Partial Volume Estimation (PVE)
            #
           
            #
            # Gather GM, WM and CSF registered with T2
            c1_file = "" # GM
            c2_file = "" # WM
            c3_file = "" # CSF
            for file_name in os.listdir( self.PVE_Segmentation_ ):
                if file_name.startswith("c1") and file_name.endswith("T2.nii"):
                    c1_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c2") and file_name.endswith("T2.nii"):
                    c2_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c3") and file_name.endswith("T2.nii"):
                    c3_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("m") and file_name.endswith("T2.nii"):
                    T1_file = os.path.join( self.PVE_Segmentation_, file_name )

            #
            # Rigid registration of GM in m0/T2_registration with repading; degree of freedom = 12
            if not ( os.path.isfile( c1_file ) or 
                     os.path.isfile( c2_file ) or 
                     os.path.isfile( c3_file ) ):
                raise Exception( "Missing partial volumes." )
            #
            reference     = os.path.join( self.ACPC_Alignment_, "PWI", "T2_registration.nii" )
            #
            GM_warped_m0  = os.path.join( self.ACPC_Alignment_, "GM_warped_m0.nii.gz" )
            self.partial_volume_warping_( c1_file, reference, GM_warped_m0 )
            #
            WM_warped_m0  = os.path.join( self.ACPC_Alignment_, "WM_warped_m0.nii.gz" )
            self.partial_volume_warping_( c2_file, reference, WM_warped_m0 )
            #
            CSF_warped_m0 = os.path.join( self.ACPC_Alignment_, "CSF_warped_m0.nii.gz" )
            self.partial_volume_warping_( c3_file, reference, CSF_warped_m0 )

            #
            # Cerebral blood flow within gray matter
            #
            
            #
            # CBF low resolution
            maths = fsl.ImageMaths( in_file   = "PWI_corrected_3D.nii.gz", 
                                    op_string = "-div m0_brain_corrected_3D.nii.gz",
                                    out_file  = "CBF.nii.gz")
            maths.run();
            # CBF and GM
            maths = fsl.ImageMaths( in_file   = "CBF.nii.gz", 
                                    op_string = "-mul %s"%(GM_warped_m0),
                                    out_file  = "CBF_GM.nii.gz")
            maths.run();
            
            #
            # CBF, PWI and CBF filter on GM in high resolution
            maths = fsl.ImageMaths( in_file   = "PWI_corrected_T2_3D.nii.gz", 
                                    op_string = "-div m0_brain_corrected_T2_3D.nii.gz",
                                    out_file  = "CBF_T2.nii.gz")
            maths.run();
            # CBF in GM HD
            maths = fsl.ImageMaths( in_file   = "CBF_T2.nii.gz", 
                                    op_string = "-mul %s"%(c1_file),
                                    out_file  = "CBF_GM_T2.nii.gz")
            maths.run();
            # CBF^2 for standard deviation purposes
            maths = fsl.ImageMaths( in_file   = "CBF_T2.nii.gz",
                                    op_string = '-mul %s -mul %s'%("CBF_T2.nii.gz", self.brain_prob_), 
                                    out_file  = "CBF2_T2.nii.gz")
            maths.run();
            # CBF estimator around the brain prob 
            maths = fsl.ImageMaths( in_file   = "CBF_T2.nii.gz",
                                    op_string = '-mul %s'%(self.brain_prob_), 
                                    out_file  = "CBF_brain_T2.nii.gz")
            maths.run();
            # filtering with the GM mask 
            maths = fsl.ImageMaths( in_file   = "CBF_GM_T2.nii.gz",
                                    op_string = '-mas %s'%(self.gm_mask_), 
                                    out_file  = "CBF_GM_filtered_T2.nii.gz")
            maths.run();
            # PWI in GM HD
            maths = fsl.ImageMaths( in_file   = "PWI_corrected_T2_3D.nii.gz", 
                                    op_string = "-mul %s"%(c1_file),
                                    out_file  = "PWI_GM_T2.nii.gz")
            maths.run();

            if False:
                #
                # Standard space registration (MNI152)
                #

                #
                # Warpping coefficients
                MNI_ceoff = os.path.join( self.PVE_Segmentation_, "T1_to_MNI_nonlin_coeff.nii.gz" )
                MNI       = os.path.join( os.environ.get('FSLDIR'), 
                                          "data","standard","MNI152_T1_2mm.nii.gz" )
            
                #
                # T2 brain
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.ACPC_Alignment_, "T2_brain.nii")
                aw.inputs.ref_file   = MNI
                aw.inputs.out_file   = os.path.join(self.ACPC_Alignment_, "T2_brain_MNI.nii.gz")
                aw.inputs.field_file = MNI_ceoff
                res = aw.run()

                #
                # CBF
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.ACPC_Alignment_, "CBF_T2.nii.gz")
                aw.inputs.ref_file   = MNI
                aw.inputs.out_file   = os.path.join(self.ACPC_Alignment_, "CBF_MNI.nii.gz")
                aw.inputs.field_file = MNI_ceoff
                res = aw.run()
                
                #
                # CBF in gray matter
                aw = fsl.ApplyWarp()
                aw.inputs.in_file    = os.path.join(self.ACPC_Alignment_, "CBF_GM_filtered_T2.nii.gz")
                aw.inputs.ref_file   = MNI
                aw.inputs.out_file   = os.path.join(self.ACPC_Alignment_, "CBF_GM_MNI.nii.gz")
                aw.inputs.field_file = MNI_ceoff
                res = aw.run()

                #
                # Maps production
                #
            
                #
                # Images directory
                os.mkdir( os.path.join(self.ACPC_Alignment_, "images") )

                #
                # T2 brain and CBF map
                # overlay 0 0 PWI/T2_registration.nii -A CBF_GM.nii.gz 1. 65. test
                cmd = "overlay 0 0 %s -A %s 1. 65. images/%s"%("PWI/T2_registration.nii", "CBF_GM.nii.gz", "CBF_GM_LD.nii.gz")
                Image_tools.generic_unix_cmd(cmd)
            
                #
                # T1 head and CBF map
                # overlay 0 0 ../PVE_Segmentation/mMP-LAS-long-3DC_NIFD092X4_T2.nii -A CBF_T2.nii.gz 1. 65. test
                cmd = "overlay 0 0 %s -A %s 1. 65. images/%s"%(T1_file,"CBF_T2.nii.gz","T1_CBF_HD.nii.gz")
                Image_tools.generic_unix_cmd(cmd)

                # 
                # T1 head and CBF in GM map
                # overlay 0 0 ../PVE_Segmentation/mMP-LAS-long-3DC_NIFD092X4_T2.nii -A CBF_GM_filtered_T2.nii.gz 1. 65. test
                cmd = "overlay 0 0 %s -A %s 1. 65. images/%s"%(T1_file,"CBF_GM_filtered_T2.nii.gz","T1_CBF_GM_HD.nii.gz")
                Image_tools.generic_unix_cmd(cmd)

                # 
                # T1 brain and CBF in GM map
                T1_brain = os.path.join(self.PVE_Segmentation_, "T1_brain.nii.gz")
                # overlay 0 0 ../PVE_Segmentation/mMP-LAS-long-3DC_NIFD092X4_T2.nii -A CBF_GM_filtered_T2.nii.gz 1. 65. test
                cmd = "overlay 0 0 %s -A %s 1. 65. images/%s"%(T1_brain,"CBF_GM_filtered_T2.nii.gz","T1_brain_CBF_GM_HD.nii.gz")
                Image_tools.generic_unix_cmd(cmd)
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
    #
    #
    #
    def run_spm_realign( self, Directory, List_files, Register_to_mean = False ):
        """ Function uses SPM realigne with the first run sequence."""
        os.chdir(Directory)
        List_files.sort()
        realign = spm.Realign()
        realign.inputs.in_files         = List_files
        realign.inputs.register_to_mean = Register_to_mean
        realign.inputs.paths            = Directory
        print "Realigning list of files ..."
        realign.run()
    #
    #
    #
    def partial_volume_warping_( self, In_file, Ref_file, Out_file ):
        #
        mat           = tempfile.NamedTemporaryFile(delete = False)
        intermed_file = tempfile.NamedTemporaryFile(delete = False)
        #
        flt = fsl.FLIRT()
        flt.inputs.in_file         = In_file
        flt.inputs.reference       = Ref_file
        flt.inputs.out_file        = intermed_file.name #GM_m0
        flt.inputs.out_matrix_file = mat.name
        flt.inputs.args            = "-dof 12"
        res = flt.run() 
        # warp PVE in m0 framework (low resolution)
        aw = fsl.ApplyWarp()
        aw.inputs.in_file    = In_file
        aw.inputs.ref_file   = Ref_file
        aw.inputs.out_file   = Out_file
        aw.inputs.premat     = mat.name
        aw.inputs.args       = "--super --interp=spline --superlevel=4"
        res = aw.run()
    #
    #
    #
    def QC_registration_matrix_( self, Matrix_file ):
        """ This quality control check the input matrix and reject matrices not close enough to the Id matrix."""
        try: 
            #
            # Check if the file exist
            # Load the matrix
            matrix = numpy.loadtxt( Matrix_file ) 
            # Check Rotation matrix diagonal
            if matrix[0][0] < 0.85 or matrix[1][1] < 0.85 or matrix[2][2] < 0.85:
                raise Exception( "Matrix %s should be closer to the Id matrix."%(Matrix_file) )
        #
        #
        except Exception as inst:
            print inst
            _log.error(inst)
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            self.status_ = False
    #
    #
    #
    def run( self ):
        """ Run the complete Arterial Spin Labeling process"""
        if self.status_:
            self.check_environment()
            _log.debug("Protocol ASL - check environment -- pass")
        if self.status_:
            self.initialization()
            _log.debug("Protocol ASL - initialization -- pass")
        if self.status_:
            self.run_spm_segmentT1()
            _log.debug("Protocol ASL - run spm segmentT1 -- pass")
        if self.status_:
            self.perfusion_weighted_imaging()
            _log.debug("Protocol ASL - perfusion weighted imaging -- pass")
        if self.status_:
            self.CBFscale_PWI_data()
            _log.debug("Protocol ASL - CBFscale PWI data -- pass")
#        if self.status_:
#        self.perfusion_calculation()
#        _log.debug("Protocol ASL - perfusion calculation -- pass")
        if self.status_:
            self.T2_PWI_registration()
            _log.debug("Protocol ASL - registration between T2 and PWI -- pass")
        if self.status_:
            self.Cerebral_blood_flow()
            _log.debug("Protocol ASL - Cerebral blood flow -- pass")
            
