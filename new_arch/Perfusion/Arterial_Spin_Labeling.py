import sys
import inspect
import shutil
import os
import subprocess
import logging
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
            # private variables
            # T2
            self.ACPC_Alignment_   = ""
            self.T2_file_          = []
            # T1
            self.PVE_Segmentation_ = ""
            self.T1_file_          = []
            # ASL
            self.ASL_dicom_        = "";
            self.ASL_file_         = []
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
    def initialization( self ):
        """Initialize all the data. This function convert DICOMs images (T1, T2, ASL) into niftii. The ASL images are sorted/renamed following their even number (untagged -- control) and odd number (tagged). Then, images are brain extracted using BET.
        """
        try:
            #
            # Check on the requiered files
            #
            seeker = Image_tools.Seek_files( self.patient_dir_ )

            #
            # Find the T2 nifti file
            if seeker.seek_nifti( "T2_" ):
                self.T2_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T2_file_[0]), self.ACPC_Alignment_ )
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
            # Find the T1 nifti file
            if seeker.seek_nifti( "MP-LAS-long" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
            elif seeker.seek_nifti( "MP-LAS-3DC" ):
                self.T1_file_ = seeker.get_files()
                shutil.copy( os.path.join(self.patient_dir_, self.T1_file_[0]), self.PVE_Segmentation_ )
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
            os.chdir( self.ASL_dicom_ )
            os.mkdir('nii_all');
            # dcm to nifti again ...
            for file_name in os.listdir( os.getcwd() ):
                if file_name != "tagged" and file_name != "untagged" and file_name != "nii_all":
                    cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n %s' %file_name
                    Image_tools.generic_unix_cmd(cmd)

            #
            # move into the nii_all dir and skull-strip/realign
            for nii_file in os.listdir( self.ASL_dicom_ ):
                if nii_file.endswith('.nii'):
                    shutil.move( os.path.join(self.ASL_dicom_, nii_file), 
                                 os.path.join(self.ASL_dicom_, 'nii_all') );

            #
            # Run FSL BET() again
            os.chdir( os.path.join(self.ASL_dicom_, 'nii_all') );
            Image_tools.run_bet( os.path.join(self.ASL_dicom_, 'nii_all') )
            os.system('gunzip *brain.nii.gz');
            # Make skull-stripped_realigned dir
            os.mkdir(os.path.join( self.ASL_dicom_, 'nii_all', 'realigned_stripped') );
            # Get list of all stripped EPIs in dir
            stripped_list = [];
            for file_name in os.listdir(os.getcwd()):
                if file_name.endswith('brain.nii'):
                    stripped_list.append(file_name);
            # Sort the list to be realigned on m0
            stripped_list.sort();
#            m0 = stripped_list.pop();
#            # because m0 = file-0001,nii
#            if m0 != "m0_brain.nii":
#                raise Exception("Error: EPI %s was incorectly excluded from realignment" %m0 )
            #
            # Run spm_realign to realign EPIs to first 'm0' in sequence 
            # TODO: check it is a rigid registration
            self.run_spm_realign(os.getcwd(), stripped_list)
            # Move the stripped and realigned EPIs to seperate dir
            for realigned_file in os.listdir( os.path.join(self.ASL_dicom_, 'nii_all') ):
                if realigned_file.startswith('r'):
                    shutil.move( os.path.join(self.ASL_dicom_, 'nii_all', realigned_file), 
                                 os.path.join(self.ASL_dicom_, 'nii_all', 'realigned_stripped') )

            #
            # Rename first EPI aquisition m0 (non PWI image) and create 4D nii 
            # to run asl_subtract on: (subtracts even-untagged from odd-tagged volumes).
            for brain_file in os.listdir(os.path.join(self.ASL_dicom_,'nii_all','realigned_stripped')):
                # Remove first volume (m0) before performing subtraction
                if brain_file.endswith('001_brain.nii'):
                    os.remove( os.path.join(self.ASL_dicom_, 'nii_all','realigned_stripped', 
                                             brain_file) ); 
                # Remove text file before combining all nii into 4d
                elif brain_file.endswith('.txt'):
                    os.remove( os.path.join( self.ASL_dicom_, 'nii_all','realigned_stripped', 
                                             brain_file) ); 
            #
            os.chdir('realigned_stripped');
            # merge the files with fslmerge. Option '-t' preserve the temporality
            os.system('fslmerge -t asl.nii r*');
            # asl_file
            # --data
            # --ntis we have X repeats all at single inflow-time 'asl.nii': ntis=1
            # --iaf inflow-time contains 
            #   * 'tc' tag-control pairs (with tag coming as the first volume)
            #   * 'ct' control-tag pairs (with control coming as the first volume)
            # --out diff between tag-control
            # --mean average of diff between tag-control
            cmd='asl_file --data=asl.nii --ntis=1 --iaf=tc --diff --out=diffdata --mean=diffdata_mean'
            Image_tools.generic_unix_cmd(cmd)
            os.system('gunzip *.nii.gz')
            all_aligned_dir = os.getcwd()
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
                # Run spm realign on un/tagged skull stripepd images
                self.run_spm_realign( os.path.join( directory, 'skull_stripped'), 
                                      tagg_stripped_list )
                # reset the lists
                tagg_stripped_list = []
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
            quit(-1)
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
            # T1, c1, c2, c2 Rigid registration on T2; degree of freedom = 6 (rotation, translation)
            matrix_T1_in_T2 = os.path.join(self.PVE_Segmentation_, "T1_in_T2.mat")
            # T1
            T1_in_T2 = "%s_T2.nii.gz"%(T1_file[:-4])
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = T1_file
            flt.inputs.reference       = T2_file
            flt.inputs.out_file        = T1_in_T2
            flt.inputs.out_matrix_file = matrix_T1_in_T2
            flt.inputs.args            = "-dof 6"
            res = flt.run() 
            # c1
            c1_in_T2 = "%s_T2.nii.gz"%(c1_file[:-4])
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = c1_file
            flt.inputs.reference       = T2_file
            flt.inputs.out_file        = c1_in_T2
            flt.inputs.apply_xfm       = True
            flt.inputs.in_matrix_file  = matrix_T1_in_T2
            flt.inputs.args            = "-dof 6"
            res = flt.run()
            # c2
            c2_in_T2 = "%s_T2.nii.gz"%(c2_file[:-4])
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = c2_file
            flt.inputs.reference       = T2_file
            flt.inputs.out_file        = c2_in_T2
            flt.inputs.apply_xfm       = True
            flt.inputs.in_matrix_file  = matrix_T1_in_T2
            flt.inputs.args            = "-dof 6"
            res = flt.run() 
            #
            os.system("gunzip %s"%(T1_in_T2))
            os.system("gunzip %s"%(c1_in_T2))
            os.system("gunzip %s"%(c2_in_T2))

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
    def T2_PWI_registration( self ):
        """registration between T2 and PWI."""
        try: 
            #
            # Start in Anterior/Posterior Commissure
            os.chdir( self.ACPC_Alignment_ )
            #
            # Extract skull from T2 and the mask. TODO, some tests can be done with the mask instead.
            Image_tools.run_bet( self.ACPC_Alignment_, 0.6, True, True)
            #
            T2_skull_stripped = ""
            for file_name in os.listdir( self.ACPC_Alignment_ ):
                if file_name.endswith("brain.nii") or file_name.endswith("brain.nii.gz"):
                    T2_skull_stripped = file_name
            #
            os.system( "gunzip %s"%T2_skull_stripped ) 

            #
            # Create PWI.nii
            os.mkdir("PWI")
            # Distortion will be done on m0, and th correction will be done on CBF_Scaled_PWI.nii
            DeltaM   = os.path.join(self.ACPC_Alignment_, "PWI", "CBF_Scaled_PWI.nii")
            shutil.copy( os.path.join(self.ASL_dicom_, "nii_all", "realigned_stripped","CBF_Scaled_PWI.nii"), DeltaM )
            #
            M0_brain = os.path.join(self.ACPC_Alignment_, "PWI", "m0_brain.nii")
            for file_name in os.listdir( os.path.join(self.ASL_dicom_, "nii_all") ):
                if file_name[9:12] == "001" and file_name.endswith("brain.nii"):
                    shutil.copy( os.path.join(self.ASL_dicom_, "nii_all", file_name), 
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
            # Distortion correction
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
            # Filter the maps. Using 3D filter, we assume the blood flow being the same in the neighboring voxels
            maths = fsl.ImageMaths( in_file   = distortion.control_corrected_, 
                                    op_string = '-fmean -kernel 3D ', 
                                    out_file  = "%s_3D.nii.gz" %(distortion.control_corrected_[:-4]) )
            maths.run();
            #
            # Apply transform on DeltaM
            distortion.control_ = DeltaM
            distortion.control_corrected_ = os.path.join(self.ACPC_Alignment_, "PWI_corrected.nii")
            distortion.apply_transform()
            # Filter the maps. Using 3D filter, we assume the blood flow being the same in the neighboring voxels
            maths = fsl.ImageMaths( in_file   = distortion.control_corrected_, 
                                    op_string = '-fmean -kernel 3D ', 
                                    out_file  = "%s_3D.nii.gz" %(distortion.control_corrected_[:-4]) )
            maths.run();
            
            #
            # Production of high definition (HD) map
            #

            #
            # Rigid registration of m0 in T2 with repading; degree of freedom = 12
            m0_brain_corrected_T2 = os.path.join(self.ACPC_Alignment_, "m0_brain_corrected_T2.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "m0_brain_corrected.nii")
            flt.inputs.reference       = T2_skull_stripped[:-3]
            flt.inputs.out_file        = m0_brain_corrected_T2
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "m02T2.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 
            # Filter the maps. Using 3D filter, we assume the blood flow being the same 
            # in the neighboring voxels
            maths = fsl.ImageMaths( in_file   = m0_brain_corrected_T2, 
                                    op_string = '-fmean -kernel 3D ', 
                                    out_file  = "%s_3D.nii.gz" %(m0_brain_corrected_T2[:-7]) )
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
            flt.inputs.args            = "-dof 12"
            res = flt.run() 
            # Filter the maps. Using 3D filter, we assume the blood flow being the same 
            # in the neighboring voxels
            maths = fsl.ImageMaths( in_file   = PWI_corrected_T2, 
                                    op_string = '-fmean -kernel 3D ', 
                                    out_file  = "%s_3D.nii.gz" %(PWI_corrected_T2[:-7]) )
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
    def Cerebral_blood_flow( self ):
        """Cerebral blood flow processing."""
        try: 
            #
            # realigne PWI with m0
            os.chdir( self.ACPC_Alignment_ )
            # Rigid registration of PWI in m0; degree of freedom = 12
            PWI_corrected_m0 = os.path.join(self.ACPC_Alignment_, "PWI_corrected_3D_m0.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = os.path.join(self.ACPC_Alignment_, "PWI_corrected_3D.nii.gz" )
            flt.inputs.reference       = os.path.join(self.ACPC_Alignment_, "m0_brain_corrected_3D.nii.gz" )
            flt.inputs.out_file        = PWI_corrected_m0
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "PWI2m0.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 
            #
            #os.system("gunzip %s")%(PWI_corrected_m0)
            
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
                if file_name.startswith("c2"):
                    c2_file = file_name
                if file_name.startswith("c3"):
                    c3_file = file_name
                if file_name.startswith("m"):
                    T1_file = os.path.join( self.PVE_Segmentation_, file_name )

            #
            # Rigid registration of GM in m0 with repading; degree of freedom = 12
            if not os.path.isfile( c1_file ):
                raise Exception( "No gray matter found." )
            #
            GM_m0 = os.path.join(self.ACPC_Alignment_, "GM_m0.nii.gz" )
            #
            flt = fsl.FLIRT()
            flt.inputs.in_file         = c1_file
            flt.inputs.reference       = os.path.join( self.ACPC_Alignment_, "m0_brain_corrected.nii" )
            flt.inputs.out_file        = GM_m0
            flt.inputs.out_matrix_file = os.path.join(self.ACPC_Alignment_, "GM2m0.mat")
            flt.inputs.args            = "-dof 12"
            res = flt.run() 
            #
            GM_m0_warped = os.path.join(self.ACPC_Alignment_, "GM_warped_m0.nii.gz" )
            # warp GW in m0 framework (low resolution)
            aw = fsl.ApplyWarp()
            aw.inputs.in_file    = c1_file
            aw.inputs.ref_file   = os.path.join( self.ACPC_Alignment_, "m0_brain_corrected.nii" )
            aw.inputs.out_file   = GM_m0_warped
            aw.inputs.premat     = os.path.join(self.ACPC_Alignment_, "GM2m0.mat")
            aw.inputs.args       = "--super --interp=spline --superlevel=4"
            res = aw.run()

            #
            # Cerebral blood flow within gray matter
            #
            
            #
            # CBF
            maths = fsl.ImageMaths( in_file   = "PWI_corrected_3D.nii.gz", 
                                    op_string = "-div m0_brain_corrected_3D.nii.gz",
                                    out_file  = "CBF.nii.gz")
            maths.run();
            #
            maths = fsl.ImageMaths( in_file   = "CBF.nii.gz", 
                                    op_string = "-mul GM_m0",
                                    out_file  = "CBF_GM.nii.gz")
            maths.run();
            
            #
            # CBF and PWI HD
            # CBF HD
            maths = fsl.ImageMaths( in_file   = "PWI_corrected_T2_3D.nii.gz", 
                                    op_string = "-div m0_brain_corrected_T2_3D.nii.gz",
                                    out_file  = "CBF_T2.nii.gz")
            maths.run();
            # CBF in GM HD
            maths = fsl.ImageMaths( in_file   = "CBF_T2.nii.gz", 
                                    op_string = "-mul %s"%(c1_file),
                                    out_file  = "CBF_GM_T2.nii.gz")
            maths.run();
            # PWI in GM HD
            maths = fsl.ImageMaths( in_file   = "PWI_corrected_T2_3D.nii.gz", 
                                    op_string = "-mul %s"%(c1_file),
                                    out_file  = "PWI_GM_T2.nii.gz")
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
    def run_spm_realign( self, Directory, List_files, Register_to_mean = False):
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
    def run( self ):
        """ Run the complete Arterial Spin Labeling process"""
        self.check_environment()
        _log.debug("Protocol ASL - check environment -- pass")
        self.initialization()
        _log.debug("Protocol ASL - initialization -- pass")
        self.perfusion_weighted_imaging()
        _log.debug("Protocol ASL - perfusion weighted imaging -- pass")
        self.CBFscale_PWI_data()
        _log.debug("Protocol ASL - CBFscale PWI data -- pass")
#        self.perfusion_calculation()
#        _log.debug("Protocol ASL - perfusion calculation -- pass")
        self.run_spm_segmentT1()
        _log.debug("Protocol ASL - run spm segmentT1 -- pass")
        self.T2_PWI_registration()
        _log.debug("Protocol ASL - registration between T2 and PWI -- pass")
        self.Cerebral_blood_flow()
        _log.debug("Protocol ASL - Cerebral blood flow -- pass")
