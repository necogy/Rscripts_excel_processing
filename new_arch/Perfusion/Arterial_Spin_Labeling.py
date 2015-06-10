import logging
import inspect
import sys, os, shutil
import tempfile
import subprocess
import numpy
import nifti as ni
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
            # Acquisition data
            self.TR_    = 2522.1
            self.TE_    = 11.
            self.TI1_   = 700.
            self.TI2_   = 1800.
            # delay of the acquisition slice by slice
            self.tau_   = 22.
            # Efficientcy of the spin inversion process 
            self.alpha_ = 0.95

            #
            # Physical data
            # T1 relaxation time
            self.T1_gm_  = 1110.
            self.T1_wm_  = 1600.
            self.T1_csf_ = 4136.
            # T1 relaxation time for blood
            self.T1a_    = 1684.
            # T2 relaxation time
            self.T2_gm_  = 60.
            self.T2_wm_  = 80.
            self.T2_csf_ = 1442.
            # The water content in the tissue
            self.rho_gm_  = 0.82
            self.rho_wm_  = 0.72
            self.rho_csf_ = 1.
            # Tissue-blood ratio
            self.lambda_  = 0.90  
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
            _log.error(inst)
            _log.error("Protocol ASL - check environment -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.erro("Protocol ASL - check environment -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - check environment -- failed")
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
            seeker = Image_tools.Seek_files( self.patient_dir_ )

            #
            # T2 file
            # 

            #
            # Find the T2 nifti file
            if seeker.seek_nifti( "T2_" ):
                self.T2_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T2_file_[0]), self.ACPC_Alignment_ )
                #
                self.T2_file_[0] = os.path.join( self.ACPC_Alignment_, self.T2_file_[0] )
            # Find the T2 analyze file
            elif seeker.seek_analyze( "T2_" ):
                self.T2_file_ = seeker.get_files()
                # change into nifti format 
                Image_tools.run_ana2nii( os.path.join(self.patient_dir_, self.T2_file_[0]),
                                         os.path.join(self.patient_dir_, self.T2_file_[0]),
                                         os.path.join(self.ACPC_Alignment_, "%s.nii.gz"%(self.T2_file_[0][:-4])) )
                #
                self.T2_file_[0] = os.path.join( self.ACPC_Alignment_, "%s.nii.gz"%(self.T2_file_[0][:-4]) )
                self.T2_file_[1] = ""
            else:
                raise Exception( "T2 file does not exist in %s."%(self.patient_dir_) )
                
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
            # ASL
            #

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
            _log.error(inst)
            _log.error("Protocol ASL - initialization -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol ASL - initialization -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - initialization -- failed")
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
            nii_all = os.path.join( self.ASL_dicom_, "nii_all" )
            os.mkdir( nii_all )
            # DICOM to nifti again ...
            for file_name in os.listdir( self.ASL_dicom_ ):
                if not "nii_all" in file_name:
                    dicom = os.path.join( self.ASL_dicom_, file_name )
                    cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n %s' %dicom
                    Image_tools.generic_unix_cmd(cmd)
            #
            # move nifti files into the nii_all dir
            for nii_file in os.listdir( self.ASL_dicom_ ):
                if nii_file.endswith('.nii'):
                    shutil.move( os.path.join(self.ASL_dicom_, nii_file), nii_all );


            #
            # Create 4D asl image
            # asl.nii.gz file
            realigned_stripped_dir = os.path.join( self.ASL_dicom_, 'nii_all', 'realigned_stripped')
            os.mkdir( realigned_stripped_dir );
            asl_4D   = os.path.join( realigned_stripped_dir, "asl_4D.nii.gz")
            asl_file = os.path.join( realigned_stripped_dir, "asl.nii.gz")
            m0_roi   = os.path.join( realigned_stripped_dir, "m0_brain.nii.gz")
            # Get list of all EPIs
            stripped_list = [];
            for file_name in os.listdir( nii_all ):
                if file_name.endswith('.nii'):
                    stripped_list.append(  os.path.join(nii_all, file_name) );
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
            mc.MC_flirt( Output_file = asl_file )

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
            head_T2_m0       = os.path.join( realigned_stripped_dir, "head_T2_m0.nii.gz" )
            brain_T2_mask_m0 = os.path.join( realigned_stripped_dir, "brain_T2_mask_m0.nii.gz" )
            #
            head_m0        = m0_roi #"r%s"%( stripped_list.pop(0) )
            head_T2_m0_mat = os.path.join( realigned_stripped_dir, "head_T2_m0.mat" )
            #
            # Register T2 and mask in EPI framwork
            # T2 head
            flt = fsl.FLIRT()
            flt.inputs.in_file         = self.T2_file_[0]
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
            asl_file      = os.path.join( realigned_stripped_dir, "asl.nii.gz")
            diffdata      = os.path.join( realigned_stripped_dir, "diffdata.nii.gz")
            diffdata_mean = os.path.join( realigned_stripped_dir, "diffdata_mean.nii.gz")
            cmd='asl_file --data=%s --ntis=1 --iaf=tc --diff --out=%s --mean=%s'%("%s_brain.nii.gz"%(asl_file[:-7]), 
                                                                                  diffdata, diffdata_mean)
            Image_tools.generic_unix_cmd(cmd)
            os.system( 'gunzip %s'%diffdata_mean )
            # copy m0 frame
            shutil.copy( m0_roi, os.path.join(self.ASL_dicom_, 'nii_all') );
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol ASL - perfusion weighted imaging -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol ASL - perfusion weighted imaging -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - perfusion weighted imaging -- failed")
            self.status_ = False
    #
    #
    #
    def CBFscale_PWI_data( self ):
        """Scale PWI for time lag and compute CBF. CBF_Scaled_PWI.nii don't provide CBF. To produce CBF the map as to be normalized with m0 map"""
        try: 
            #
            #
            all_aligned_dir = os.path.join( self.ASL_dicom_, 'nii_all/realigned_stripped' )
            #
            delta = ni.NiftiImage( os.path.join(all_aligned_dir, "diffdata_mean.nii") )
            M0    = ni.NiftiImage( os.path.join(all_aligned_dir, "m0_brain.nii.gz") )
            # Extract volume data
            volume = delta.data

            #
            # Process PWI data
            K = 100 * 60 * 1000 # Per 100 gram * sec per min * msec per sec
            # delta.header['dim'] -> [3,  64, 56, 16, 1, 1, 1, 1] 
            #                       dim, X,  Y,  Z, ...
            for slice in range( 0, delta.header['dim'][3] ):
                TI2_delay = self.TI2_ + self.tau_ * slice
                volume[slice,:,:] *= K *  self.lambda_ * numpy.exp(TI2_delay/self.T1a_)
                volume[slice,:,:] /= ( 2 * self.alpha_ * self.TI1_ )
            #
            # Save the result
            delta.data   = volume
            delta.header = M0.header
            #
            delta.save( os.path.join(all_aligned_dir, "CBF_Scaled_PWI.nii") )
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol ASL - perfusion weighted imaging -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol ASL - perfusion weighted imaging -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - perfusion weighted imaging -- failed")
            self.status_ = False
#    #
#    #
#    #
#    def EPI_realignment_( self ):
#        """Realigning the EPIs to the non-perfusion weighted m0 using spm_realign. """
#        try: 
#            #
#            #
#            tagg_stripped_list = []
#            tagged_untagged_directory = {'tagged':   os.path.join(self.ASL_dicom_, 'tagged'),
#                                         'untagged': os.path.join(self.ASL_dicom_, 'untagged') }
#            #
#            for pref, directory in tagged_untagged_directory.iteritems():
#                os.mkdir( os.path.join(directory, 'skull_stripped') )
#                os.chdir(directory)
#                # Convert tagged and untagged EPIs to .nii and extract brain
#                for file_name in os.listdir(directory):
#                    if file_name.startswith(pref):
#                        cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n %s' %file_name
#                        Image_tools.generic_unix_cmd(cmd)
#                    elif file_name.startswith('m0'):
#                        cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n %s' %file_name
#                        Image_tools.generic_unix_cmd(cmd)
#                Image_tools.run_bet( directory, 0.7 )
#                # Realign the brain files
#                for file_name in os.listdir(directory):
#                    if file_name.endswith('brain.nii.gz'):
#                        shutil.move( os.path.join(directory, file_name), 
#                                     os.path.join( directory, 'skull_stripped') )
#                        os.system( 'gunzip %s' %(os.path.join( directory, 'skull_stripped', 
#                                                               file_name)) )
#                        # Get final list of unzipped skull-stripped files
#                        tagg_stripped_list.append(file_name[:-3])
#                # Run spm realign on un/tagged skull stripped images
#                self.run_spm_realign( os.path.join( directory, 'skull_stripped'), 
#                                      tagg_stripped_list )
#                # reset the lists
#                tagg_stripped_list = []
#        #
#        #
#        except Exception as inst:
#            print inst
#            _log.error(inst)
#            self.status_ = False
#        except IOError as e:
#            print "I/O error({0}): {1}".format(e.errno, e.strerror)
#            self.status_ = False
#        except:
#            print "Unexpected error:", sys.exc_info()[0]
#            self.status_ = False
#    #
#    #
#    #
#    def perfusion_calculation( self ):
#        """Function sums and avgs skull stripped/aligned EPIs for tagged and untagged aquisitions."""
#        try: 
#            #
#            # sort/rename even numbered (untagged), odd numbered (tagged), and m0 EPIs
#            os.mkdir( os.path.join(self.ASL_dicom_, 'tagged') )
#            os.mkdir( os.path.join(self.ASL_dicom_, 'untagged') )
#            # Place even numbered acquistions in untagged folder, 
#            # and odd acquisitions in tagged folder
#            for file_name in os.listdir( self.ASL_dicom_ ):
#                if file_name == 'tagged' or file_name == 'untagged':
#                    pass; # skipp dir names
#                elif float(file_name[9:12])%2 == 0 and file_name[9:12] != '001':
#                    # copy odd file
#                    shutil.copy( os.path.join(self.ASL_dicom_, file_name), 
#                                 os.path.join(self.ASL_dicom_, 'untagged','untagged_' + file_name[9:12]) );
#                elif float(file_name[9:12])%2 != 0 and file_name[9:12] != '001':
#                    # copy even file
#                    shutil.copy( os.path.join(self.ASL_dicom_, file_name), 
#                                 os.path.join(self.ASL_dicom_, 'tagged','tagged_' + file_name[9:12]) );
#                elif file_name[9:12] == '001':
#                    # create m0 from first non-perfusion weighted EPI
#                    shutil.copy( os.path.join(self.ASL_dicom_, file_name), 
#                                 os.path.join(self.ASL_dicom_, 'm0') );
#            # Store variables for tagged and untagged dirs, move a copy of m0 to each
#            shutil.copy( os.path.join(self.ASL_dicom_, 'm0'),  
#                         os.path.join(self.ASL_dicom_, 'tagged') )
#            shutil.copy( os.path.join(self.ASL_dicom_, 'm0'),  
#                         os.path.join(self.ASL_dicom_, 'untagged') )
#
#            #
#            # Realigned the EPI on m0
#            self.EPI_realignment_()
#
#            #
#            #
#            aligned_list =[]
#            tagg_directory = {'tagged':   os.path.join(self.ASL_dicom_, 'tagged', 'skull_stripped'), 
#                              'untagged': os.path.join(self.ASL_dicom_, 'untagged', 'skull_stripped')}
#            #
#            raw_perfusion_dir = os.path.join(self.patient_dir_, 'Raw_Perfusion')
#            os.mkdir( raw_perfusion_dir )
#            #
#            # sums skull stripped/aligned EPIs
#            for pref, directory in tagg_directory.iteritems():
#                os.chdir(directory);
#                #
#                for file_name in os.listdir(directory):
#                    if file_name.startswith('r' + pref):
#                        aligned_list.append(file_name);
#                # Sum of all aligned {tagged,untagged} files
#                aligned_list.sort();
#                maths = fsl.ImageMaths(in_file = aligned_list[0], 
#                                       op_string = '-add %s' %(aligned_list[1]), 
#                                       out_file = pref + '_sum.nii.gz')
#                maths.run();
#                # decomposition into two sums does not make sens ...
#                for fname in aligned_list[2:]:
#                    print 'Summing EPI %s' %(fname)
#                    maths = fsl.ImageMaths(in_file = fname, 
#                                           op_string = '-add %s' %(pref + '_sum.nii.gz'), 
#                                           out_file = pref + '_sum.nii.gz')
#                    maths.run();
#                #
#                # avgs skull stripped/aligned EPIs
#                denom = len(aligned_list);
#                maths = fsl.ImageMaths(in_file = pref + '_sum.nii.gz', 
#                                       op_string = '-div %s' %(denom), 
#                                       out_file = pref + '_avg.nii.gz')
#                maths.run();
#                #
#                shutil.move( pref + '_avg.nii.gz', raw_perfusion_dir )
#                #
#                aligned_list = [];
#            #
#            #
#            os.chdir(raw_perfusion_dir);
#            maths = fsl.ImageMaths(in_file = 'tagged_avg.nii.gz', 
#                                   op_string = '-sub %s' %('untagged_avg.nii.gz'), 
#                                   out_file = 'mean_perfusion_raw.nii.gz')
#            maths.run();
#        #
#        #
#        except Exception as inst:
#            print inst
#            _log.error(inst)
#            self.status_ = False
#        except IOError as e:
#            print "I/O error({0}): {1}".format(e.errno, e.strerror)
#        except:
#            print "Unexpected error:", sys.exc_info()[0]
    #
    #
    #
    def segmentation_T1( self ):
        """Run SPM new segmentation. The results will be aligned within the T2 framework for the partial volume estimation (PVE) and the partial volume correction of the cerebral blood flow analysise. """
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
                T1_file = "%s"%(self.T1_file_[0][:-3])

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
            # Need T2 for the registration: next step
            T2_file =  self.T2_file_[0]

            #
            # T1, c1, c2, c3 Rigid registration on T2; degree of freedom = 6 (rotation, translation)
            matrix_T1_in_T2 = os.path.join( self.PVE_Segmentation_, "T1_in_T2.mat" )
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
            c1_in_T2 = "%s_T2.nii.gz"%(c1_file[:-7])
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
            self.brain_prob_ = os.path.join( self.PVE_Segmentation_, "brain_map.nii.gz" )
            maths = fsl.ImageMaths( in_file   = c1_in_T2,
                                    op_string = '-add %s '%(c2_in_T2), 
                                    out_file  = self.brain_prob_ )
            maths.run();

            #
            # Add c1 (GM), c2 (WM) and c3 (CSF) and create a binary mask
            self.brain_mask_ = os.path.join( self.PVE_Segmentation_, "brain_mask.nii.gz" )
            maths = fsl.ImageMaths( in_file   = c1_in_T2,
                                    op_string = '-add %s '%(c2_in_T2), 
                                    out_file  = self.brain_mask_ )
            maths.run();
            #
            maths = fsl.ImageMaths( in_file   = self.brain_mask_,
                                    op_string = '-add %s'%(c3_in_T2), 
                                    out_file  = self.brain_mask_ )
            maths.run();
            # TODO: somehow hang calculation ...
            maths = fsl.ImageMaths( in_file       = self.brain_mask_,
                                    op_string     = '-thr 0.3 -bin',
                                    out_file      =  self.brain_mask_,
                                    out_data_type = "char" )
            maths.run();

            #
            # This filter will remove 0 +- epsilon values from the flow spectrum
            if True:
                self.gm_mask_ = os.path.join( self.PVE_Segmentation_, "c1_T2_mask.nii.gz" )
                Image_tools.natural_gray_matter( self.gm_mask_, c1_in_T2, c2_in_T2, c3_in_T2, self.brain_mask_)
            else:
                self.gm_mask_ = os.path.join( self.PVE_Segmentation_, "c1_T2_mask.nii.gz" )
                maths = fsl.ImageMaths( in_file       = c1_in_T2,
                                        op_string     = "-thr 0.3  -fillh26 -bin",
                                        out_data_type = "char",
                                        out_file      = self.gm_mask_)
                maths.run()

            #
            # Create a mask only for the gray matter
            # WARNING: visualization purposes
            #

            if False:
                #
                # extraction of T1 brain
                maths = fsl.ImageMaths( in_file   = T1_in_T2,
                                        op_string = '-mas %s'%(self.brain_mask_), 
                                        out_file  = os.path.join( self.PVE_Segmentation_, 
                                                                  "T1_brain.nii.gz") )
                maths.run();

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
            _log.error(inst)
            _log.error("Protocol ASL - run spm segmentT1 -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol ASL - run spm segmentT1 -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - run spm segmentT1 -- failed")
            self.status_ = False
    #
    #
    #
    def T2_PWI_registration( self ):
        """registration between T2 and PWI."""
        try: 
            #
            # Extract skull from T2 and the mask. Using the T1 brain mask
            # cut around the mask
            T2_skull_stripped = os.path.join( self.ACPC_Alignment_, "T2_brain.nii.gz" )
            #
            maths = fsl.ImageMaths( in_file   = self.T2_file_[0],
                                    op_string = '-mas %s'%(self.brain_mask_), 
                                    out_file  = T2_skull_stripped )
            maths.run();

            #
            # Create PWI.nii
            PWI_dir = os.path.join( self.ACPC_Alignment_, "PWI")
            os.mkdir( PWI_dir )
            # Distortion will be done on m0, and th correction will be done on CBF_Scaled_PWI.nii
            DeltaM   = os.path.join( PWI_dir, "CBF_Scaled_PWI.nii" )
            shutil.copy( os.path.join(self.ASL_dicom_, "nii_all", "realigned_stripped", "CBF_Scaled_PWI.nii"), 
                         DeltaM )
            #
            M0_brain = os.path.join( PWI_dir, "m0_brain.nii.gz" )
            shutil.copy( os.path.join(self.ASL_dicom_, "nii_all", "m0_brain.nii.gz"), 
                         M0_brain )
            # Gunzip for EPI deformation algo
            os.system( "gunzip %s"%M0_brain )
            M0_brain = os.path.join( PWI_dir, "m0_brain.nii" )

            #
            # Rigid registration of T2 (or mask) in m0 with repading; degree of freedom = 12
            T2_registration = os.path.join( PWI_dir, "T2_registration.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, T2_skull_stripped)
            flt.inputs.reference       = M0_brain
            flt.inputs.out_file        = T2_registration
            flt.inputs.out_matrix_file = os.path.join( PWI_dir, "T22m0.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 
            # Gunzip for EPI deformation algo
            os.system( "gunzip %s"%T2_registration )
            T2_registration = os.path.join( PWI_dir, "T2_registration.nii" )

#            #
#            # MNI atlas registration 
#            #
#            
#            #
#            # MNI atlas selected
#            MNI_atlas = ""
#            if os.environ.get('FSLDIR'):
#                MNI_atlas = os.path.join( os.environ.get('FSLDIR'), 
#                                          "data","atlases","MNI","MNI-maxprob-thr0-1mm.nii.gz" )
#            else:
#                raise Exception( "$FSLDIR env variable is not setup on your system" )
#            #
#            MNI_LD = os.path.join( self.ACPC_Alignment_, "MNI_T2_m0.nii.gz" )
#            MNI_HD = os.path.join( self.ACPC_Alignment_, "MNI_T2.nii.gz" )
#
#            #
#            # Registration high resolution
#            flt = fsl.FLIRT()
#            flt.inputs.in_file         = MNI_atlas
#            flt.inputs.reference       = os.path.join( self.ACPC_Alignment_, T2_skull_stripped )
#            flt.inputs.out_file        = MNI_HD
#            flt.inputs.out_matrix_file = os.path.join( self.ACPC_Alignment_, "MNI2T2.mat" )
#            flt.inputs.args            = "-dof 12"
#            res = flt.run() 
#
#            #
#            # Registration low resolution
#            flt = fsl.FLIRT()
#            flt.inputs.in_file         = MNI_atlas
#            flt.inputs.reference       = T2_registration
#            flt.inputs.out_file        = MNI_LD
#            flt.inputs.out_matrix_file = os.path.join( self.ACPC_Alignment_, "MNI2m0.mat" )
#            flt.inputs.args            = "-dof 12"
#            res = flt.run() 

            # 
            # EPI distortion correction
            #

            #
            # m0 and DeltaM correction
            distortion = EPI_distortion_correction.EPI_distortion_correction()
            distortion.working_dir_ = os.path.join( self.ACPC_Alignment_, "test_wd" )
            distortion.control_     = M0_brain
            distortion.t2_          = T2_registration
            distortion.transform_   = os.path.join( self.ACPC_Alignment_, "field_correction.nii" )
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
            distortion.control_corrected_ = os.path.join( self.ACPC_Alignment_, "PWI_corrected.nii" )
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
                if file_name.startswith("c1") and file_name.endswith("T2.nii.gz"):
                    c1_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c2") and file_name.endswith("T2.nii.gz"):
                    c2_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c3") and file_name.endswith("T2.nii.gz"):
                    c3_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("m") and file_name.endswith("T2.nii.gz"):
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
            flt.inputs.reference       = T2_skull_stripped
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
            maths.run();

            #
            # Rigid registration of PWI in T2 with repading; degree of freedom = 12
            PWI_corrected_T2 = os.path.join(self.ACPC_Alignment_, "PWI_corrected_T2.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "PWI_corrected.nii")
            flt.inputs.reference       = T2_skull_stripped
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
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol ASL - registration between T2 and PWI -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol ASL - registration between T2 and PWI -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - registration between T2 and PWI -- failed")
            self.status_ = False
    #
    #
    #
    def Cerebral_blood_flow( self ):
        """Cerebral blood flow processing."""
        try: 
            
            #
            # Cerebral blood flow within gray matter
            #

            #
            # CBF low resolution
            maths = fsl.ImageMaths( in_file   = os.path.join( self.ACPC_Alignment_, "PWI_corrected_3D.nii.gz"), 
                                    op_string = "-div %s"%( os.path.join( self.ACPC_Alignment_, "m0_brain_corrected_3D.nii.gz") ),
                                    out_file  = os.path.join( self.ACPC_Alignment_, "CBF.nii.gz") )
            maths.run();
            
            #
            # CBF, PWI and CBF filter on GM in high resolution
            maths = fsl.ImageMaths( in_file   = os.path.join( self.ACPC_Alignment_, "PWI_corrected_T2_3D.nii.gz" ), 
                                    op_string = "-div %s"%os.path.join(self.ACPC_Alignment_,"m0_brain_corrected_T2_3D.nii.gz"), 
                                    out_file  = os.path.join( self.ACPC_Alignment_, "CBF_T2.nii.gz" ) )
            maths.run();
            # CBF estimator around the brain prob 
            maths = fsl.ImageMaths( in_file   = os.path.join( self.ACPC_Alignment_, "CBF_T2.nii.gz" ),
                                    op_string = '-mul %s'%(self.brain_prob_), 
                                    out_file  = os.path.join( self.ACPC_Alignment_, "CBF_brain_T2.nii.gz") )
            maths.run();

            if False:
                #
                # Partial Volume Estimation
                #
                
                #
                # Gather GM, WM and CSF registered with T2
                c1_file = "" # GM
                c2_file = "" # WM
                c3_file = "" # CSF
                for file_name in os.listdir( self.PVE_Segmentation_ ):
                    if file_name.startswith("c1") and file_name.endswith("T2.nii.gz"):
                        c1_file = os.path.join( self.PVE_Segmentation_, file_name )
                    if file_name.startswith("c2") and file_name.endswith("T2.nii.gz"):
                        c2_file = os.path.join( self.PVE_Segmentation_, file_name )
                    if file_name.startswith("c3") and file_name.endswith("T2.nii.gz"):
                        c3_file = os.path.join( self.PVE_Segmentation_, file_name )
                    if file_name.startswith("m") and file_name.endswith("T2.nii.gz"):
                        T1_file = os.path.join( self.PVE_Segmentation_, file_name )
                # Rigid registration of GM in m0/T2_registration with repading; degree of freedom = 12
                if not ( os.path.isfile( c1_file ) or 
                         os.path.isfile( c2_file ) or 
                         os.path.isfile( c3_file ) ):
                    raise Exception( "Missing partial volumes." )

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
            _log.error(inst)
            _log.error("Protocol ASL - Cerebral blood flow -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol ASL - Cerebral blood flow -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - Cerebral blood flow -- failed")
            self.status_ = False
    #
    #
    #
    def Partial_volume_correction( self ):
        """Partial_volume_correction."""
        try: 
            
            #
            # Partial Volume Estimation (PVE)
            #
           
            #
            # Gather GM, WM and CSF registered with T2
            c1_file = "" # GM
            c2_file = "" # WM
            c3_file = "" # CSF
            for file_name in os.listdir( self.PVE_Segmentation_ ):
                if file_name.startswith("c1") and file_name.endswith("T2.nii.gz"):
                    c1_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c2") and file_name.endswith("T2.nii.gz"):
                    c2_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("c3") and file_name.endswith("T2.nii.gz"):
                    c3_file = os.path.join( self.PVE_Segmentation_, file_name )
                if file_name.startswith("m") and file_name.endswith("T2.nii.gz"):
                    T1_file = os.path.join( self.PVE_Segmentation_, file_name )
            # Rigid registration of GM in m0/T2_registration with repading; degree of freedom = 12
            if not ( os.path.isfile( c1_file ) or 
                     os.path.isfile( c2_file ) or 
                     os.path.isfile( c3_file ) ):
                raise Exception( "Missing partial volumes." )
            #
            reference     = os.path.join( self.ACPC_Alignment_, "PWI", "T2_registration.nii" )
            GM_warped_m0  = os.path.join( self.ACPC_Alignment_, "GM_warped_m0.nii.gz" )
            WM_warped_m0  = os.path.join( self.ACPC_Alignment_, "WM_warped_m0.nii.gz" )
            CSF_warped_m0 = os.path.join( self.ACPC_Alignment_, "CSF_warped_m0.nii.gz" )
            #
            self.partial_volume_warping_( c1_file, reference, GM_warped_m0 )
            self.partial_volume_warping_( c2_file, reference, WM_warped_m0 )
            self.partial_volume_warping_( c3_file, reference, CSF_warped_m0 )
            # create a low resolution mask of the gray matter
            maths = fsl.ImageMaths( in_file       = GM_warped_m0,
                                    op_string     = '-thr 0.3 -bin',
                                    out_file      =  os.path.join( self.ACPC_Alignment_, "GM_mask_m0.nii.gz" ),
                                    out_data_type = "char" )
            maths.run();


            #
            # Correction map
            # 

            # 
            # parameters
            parameters = "%(rho_gm)s %(rho_wm)s %(rho_csf)s %(T1_gm)s %(T1_wm)s %(T1_csf)s %(T2_gm)s %(T2_wm)s %(T2_csf)s %(TE)s %(TR)s"%{"rho_gm": self.rho_gm_, 
                                                                                                                                          "rho_wm": self.rho_wm_, 
                                                                                                                                          "rho_csf":self.rho_csf_, 
                                                                                                                                          "T1_gm":  self.T1_gm_, 
                                                                                                                                          "T1_wm":  self.T1_wm_, 
                                                                                                                                          "T1_csf": self.T1_csf_, 
                                                                                                                                          "T2_gm":  self.T2_gm_, 
                                                                                                                                          "T2_wm":  self.T2_wm_, 
                                                                                                                                          "T2_csf": self.T2_csf_, 
                                                                                                                                          "TE":     self.TE_, 
                                                                                                                                          "TR":     self.TR_}


            #
            # Correction ratio from the partial volume correction for the gray matter
            PVC_LR = os.path.join( self.ACPC_Alignment_, "PVC_LR.nii.gz" )
            PVC_HR = os.path.join( self.ACPC_Alignment_, "PVC_HR.nii.gz" )
            brain_mask_m0 = os.path.join( self.ASL_dicom_, 
                                          "nii_all", "realigned_stripped", 
                                          "brain_T2_mask_m0.nii.gz" )
            # Low resolution
            Image_tools.CBF_gm_ratio( PVC_LR, parameters, GM_warped_m0, WM_warped_m0, CSF_warped_m0, brain_mask_m0)

#            maths = fsl.ImageMaths( in_file   =  WM_warped_m0, 
#                                    op_string = "-mul 0.4",
#                                    out_file  =  PVC_LR )
#            maths.run()
#            #
#            maths = fsl.ImageMaths( in_file   =  PVC_LR, 
#                                    op_string = "-add %s"%GM_warped_m0,
#                                    out_file  =  PVC_LR )
#            maths.run()

            #
            # High resolution
            Image_tools.CBF_gm_ratio( PVC_HR, parameters, c1_file, c2_file, c3_file, self.brain_mask_)
#
#            maths = fsl.ImageMaths( in_file   =  c2_file, 
#                                    op_string = "-mul 0.4",
#                                    out_file  =  PVC_HR )
#            maths.run()
#            #
#            maths = fsl.ImageMaths( in_file   =  PVC_HR, 
#                                    op_string = "-add %s"%c1_file,
#                                    out_file  =  PVC_HR )
#            maths.run()

#            #
#            # M0 ratio
#            #
#            
#            #
#            # Low resolution
#            M0_PVC_LR     = os.path.join( self.ACPC_Alignment_, "m0_PVC_LR.nii.gz" )
#            #
#            self.Ratio_M0_( Image_output = M0_PVC_LR, Mask = brain_mask_m0,
#                            GM = GM_warped_m0, WM = WM_warped_m0, CSF = CSF_warped_m0 )
#
#            #
#            # High resolution
#            M0_PVC_HR = os.path.join( self.ACPC_Alignment_, "m0_PVC_HR.nii.gz" )
#            #
#            self.Ratio_M0_( Image_output = M0_PVC_HR, Mask = self.brain_mask_,
#                            GM = c1_file, WM = c2_file, CSF = c2_file )

            #
            # Cerebral blood flow within the gray matter
            #

            #
            # CBF GM low resolution
            # PWI GM partial volume effect
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "PWI_corrected.nii" ), 
                                    op_string = "-mul %s"%(PVC_LR), 
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_LR.nii.gz" ) )
            maths.run();
            # PWI GM partial volume effect smoothed
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_LR.nii.gz" ), 
                                    op_string = "-s 3", 
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_s3_LR.nii.gz" ) )
            maths.run();
            # CBF GM partial volume effect
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_s3_LR.nii.gz" ), 
                                    op_string = "-div %s"%os.path.join(self.ACPC_Alignment_,"m0_brain_corrected_3D.nii.gz"), 
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "CBF_GM.nii.gz" ) )
            maths.run();
            # CBF in GM 
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "CBF_GM.nii.gz" ), 
                                    op_string = "-mul %s"%os.path.join( self.ACPC_Alignment_, "GM_mask_m0.nii.gz" ),
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "CBF_GM.nii.gz" ) )
            maths.run();
            
            #
            # CBF GM high resolution
            # PWI GM partial volume effect
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "PWI_corrected_T2.nii.gz" ), 
                                    op_string = "-mul %s"%(PVC_HR), 
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_HR.nii.gz" ) )
            maths.run();
            # PWI GM partial volume effect smoothed
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_HR.nii.gz" ), 
                                    op_string = "-s 3", 
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_s3_HR.nii.gz" ) )
            maths.run();
            # CBF GM partial volume effect
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "PWI_GM_PVC_s3_HR.nii.gz" ), 
                                    op_string = "-div %s"%os.path.join(self.ACPC_Alignment_,"m0_brain_corrected_T2_3D.nii.gz"), 
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "CBF_GM_T2.nii.gz" ) )
            maths.run();
            # CBF in GM HD
            maths = fsl.ImageMaths( in_file   =   os.path.join( self.ACPC_Alignment_, "CBF_GM_T2.nii.gz" ), 
                                    op_string = "-mul %s"%self.gm_mask_,
                                    out_file  =   os.path.join( self.ACPC_Alignment_, "CBF_GM_T2.nii.gz" ) )
            maths.run();
        #
        #
        except Exception as inst:
            _log.error(inst)
            _log.error("Protocol ASL - Cerebral blood flow -- failed")
            self.status_ = False
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            _log.error("Protocol ASL - Cerebral blood flow -- failed")
            self.status_ = False
        except:
            print "Unexpected error:", sys.exc_info()[0]
            _log.error("Protocol ASL - Cerebral blood flow -- failed")
            self.status_ = False
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
    def Ratio_M0_( self, Image_output, Mask, GM, WM, CSF ):
        """ Compute the M0 partial volume correction."""
        try: 
            #
            # 
            brain_mask = ni.NiftiImage( Mask )
            # 
            #GM_proba   = ni.NiftiImage( GM )
            WM_proba   = ni.NiftiImage( WM )
            CSF_proba  = ni.NiftiImage( CSF )
            #
            ratio = ni.NiftiImage( GM )
            #
            for z in range( 0, ratio.header['dim'][1] - 1 ):
                for y in range( 0, ratio.header['dim'][2] - 1 ):
                    for x in range( 0, ratio.header['dim'][3] - 1 ):
                        if brain_mask.data[x,y,z] == 1:
                            Mgm  = self.magnetization_(self.rho_gm_, self.T1_gm_, self.T2_gm_)
                            Mwm  = self.magnetization_(self.rho_wm_, self.T1_wm_, self.T2_wm_)
                            Mcsf = self.magnetization_(self.rho_csf_, self.T1_csf_, self.T2_csf_)
                            #
                            ratio.data[x,y,z] += WM_proba.data[x,y,z]  * Mwm / Mgm
                            ratio.data[x,y,z] += CSF_proba.data[x,y,z] * Mcsf / Mgm
                        else:
                            ratio.data[x,y,z] = 0.
                            
            #
            # Save image
            ratio.save( Image_output )
        #
        #
        except Exception as inst:
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
    def magnetization_( self, Rho, T2, T1 ):
        """ Compute magnetization of a tissue i."""
        try: 
            #
            # 
            return Rho * numpy.exp( - self.TE_ / T2 ) * (1 - numpy.exp( - self.TR_ / T1 ))
        #
        #
        except Exception as inst:
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
        self.check_environment()
        #
        if self.status_:
            _log.info("Protocol ASL - check environment -- pass")
            self.initialization()
        #
        if self.status_:
            _log.info("Protocol ASL - initialization -- pass")
            self.segmentation_T1()
        #
        if self.status_:
            _log.info("Protocol ASL - segmentation T1 -- pass")
            self.perfusion_weighted_imaging()
        #
        if self.status_:
            _log.info("Protocol ASL - perfusion weighted imaging -- pass")
            self.CBFscale_PWI_data()
        #
        if self.status_:
            _log.info("Protocol ASL - CBFscale PWI data -- pass")
            self.T2_PWI_registration()
        #
        if self.status_:
            _log.info("Protocol ASL - registration between T2 and PWI -- pass")
            self.Cerebral_blood_flow()
        #
        if self.status_:
            _log.info("Protocol ASL - Cerebral blood flow -- pass")
            self.Partial_volume_correction()
        #
        if self.status_:
            _log.info("Protocol ASL - Partial volume correction -- pass")
            
