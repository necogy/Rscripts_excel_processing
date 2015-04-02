import sys
import shutil
import logging
import os
import zipfile
import hashlib
#
import Image_tools
_log = logging.getLogger("__Scans_management__")

class Scans_management( object ):
    """Scan management processing script.
    
    Attributes:
    protocol_name_:string -  name of the protocol
    setup_:map            - mapping of the setup
    """
    def __init__( self ):
        """Return a new Scans_management instance."""

        #
        #
        self.study_      = "NIFD"       # Where?
        self.sourceID_   = "NIFD151-3"  # Prod by XL Scan Tracking file
        self.PIDN_       = "16781"      # LAVA
        self.First_Name_ = "Dianne"     # LAVA
        self.Last_Name_  = "Graydon"    # LAVA
        self.scan_date_  = "2015-02-24" # Voir python date management
        self.Your_Name_  = "Yann Cobigo"
        #
        self.sourceIDX_   = "NIFD151X3"  # 

        #
        # Dicoms
        self.DICOM_path_ = os.path.join( os.sep, "home","ycobigo","subjects", "%s,%s"%(self.Last_Name_,self.First_Name_) )

        #
        #
        self.projects_ = {"NIFD":"", "PPG":"", "ADRC":"", "HB":"", "FRTNI":"", "HV":"", "EPIL":"", "INF":"", "TPI4RT":"", "TPIAD":"", "RPD":"", "NRS":""}
        self.protocols_ = {"T2":[False,[],[],[]],"T2_3DC":[False,[],[],[]]}

        #
        # Output files
        # self.PID_path_ = os.path.join( "${block}", self.PIDN_, self.scan_date_,"${SOURCEID}_${LASTNAME},${FIRSTNAME}" )
        self.PID_path_ = ""
        self.Q_path_   = os.path.join( os.sep, "Volumes","Imaging432A","images432A","PIDN", self.PID_path_ )
        self.R_path_   = os.path.join( os.sep, "mnt","tank2","macdata","projects","images", self.PID_path_ )




    
    def Diffusion( self ):
        return self.protocol_name_
    
    
    def ASL( self ):
        return self.protocol_name_
    
    
    def DTIV1( self ):
        return self.protocol_name_
    
    
    def DTIV2( self ):
        return self.protocol_name_
    
    
    def NIFD_DTI( self ):
        return self.protocol_name_
    
    
    def Resting_state( self ):
        return self.protocol_name_
    
    
    def T1_long( self ):
        return self.protocol_name_
    
    
    def T1_long_3DC( self ):
        return self.protocol_name_

    
    #
    #
    def T2( self ):
        """T2 protocol"""
        try:
            #
            # Check on T2 directory
            self.protocols_["T2"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( self.DICOM_path_ ):
                if dir_name.startswith("T2_spc") and "DIS3D" not in dir_name:
                    protocol_dir.append( os.path.join(self.DICOM_path_, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["T2"][0] = False
                _log.warning("T2 directory does not exist.")

            #
            # DICOMs zipping and change into nifti
            if self.protocols_["T2"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("T2", dir_name, len(protocol_dir) is 1 )

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
    def T2_3DC( self ):
        """T2_3DC protocol"""
        try:
            #
            # Check on T2_3DC directory
            self.protocols_["T2_3DC"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( self.DICOM_path_ ):
                if dir_name.startswith("T2_spc") and "DIS3D" in dir_name:
                    protocol_dir.append( os.path.join(self.DICOM_path_, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["T2_3DC"][0] = False
                _log.warning("T2_3DC directory does not exist.")

            #
            # DICOMs zipping and change into nifti
            if self.protocols_["T2_3DC"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("T2_3DC", dir_name, len(protocol_dir) is 1 )
            print  self.protocols_
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
    
    
    def FLAIR( self ):
        return self.protocol_name_
    
    
    def FLAIR_3DC( self ):
        return self.protocol_name_
    
    
    def T1_short( self ):
        return self.protocol_name_
    
    
    def T1_short_3DC( self ):
        return self.protocol_name_
    

    #
    #
    def zip_protocol_( self, Protocol, Directory, Dir_num = ""):
        """Zip file function"""
        _log.warning("%s sequence(s) found - zipping DICOM"%(Protocol))

        try:
            #
            # 
            os.chdir( Directory )
            # Gather the DICOMs list
            dicom_list = [];
            for file_name in os.listdir( os.getcwd() ):
                if file_name.endswith('.dcm'):
                    dicom_list.append(file_name)
            # sort the list
            dicom_list.sort()

            #
            # Zip the DICOMs
            if Dir_num:
                zip_file = "%s_%s_%s.zip"%(Protocol, Dir_num, self.sourceIDX_)
            else:
                zip_file = "%s_%s.zip"%(Protocol, self.sourceIDX_)
            # create the zip file
            zf = zipfile.ZipFile( zip_file, mode='w' )
            #
            for file_name in dicom_list:
                zf.write( file_name )
            #
            #if not zf.test(): # check if the zip is valid
            zf.close()
            return zip_file
            #else:
            #    raise Exception( "Zipping process failed for protocol %s."%Protocol )

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
    def dcm2nii_protocol_( self, Protocol, Directory, Dir_num = "" ):
        """Convert dicoms to nifti file function"""
        _log.warning("%s sequence(s) found - convert DICOM to nifti"%(Protocol))

        try:
            #
            #
            os.chdir( Directory )
            #
            nifti_file = ""
            # Gather the dicom list
            cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n *'
            Image_tools.generic_unix_cmd(cmd)
            #
            for file_name in os.listdir( os.getcwd() ):
                if file_name.startswith("o") and file_name.endswith(".nii"):
                    if Dir_num:
                        nifti_file = "%s_%s_%s.nii"%(Protocol, Dir_num, self.sourceIDX_)
                    else:
                        nifti_file = "%s_%s.nii"%(Protocol, self.sourceIDX_)
                    shutil.move( file_name, nifti_file )
                if not file_name.startswith("o") and file_name.endswith(".nii"):
                    os.remove( os.path.join(Directory, file_name) )

            #
            #
            return nifti_file

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
    def process_protocol_( self, Protocol, Directory, Unique = True ):
        """Convert dicoms to nifti file function"""
        _log.warning("%s sequence(s) found - process sequence(s)"%(Protocol))
        
        try:
            #
            # Multiple cases
            dir_num = ""
            if not Unique:
                if Directory[-2:].isdigit():
                    dir_num = Directory[-2:]
                elif Directory[-1:].isdigit():
                    dir_num = Directory[-1:]
                else:
                    raise Exception( "No multiple cases for the protocol %s."%Protocol )

            #
            # Zip dicoms
            zip_file = self.zip_protocol_(Protocol, Directory, dir_num) 
            #
            if not os.path.exists( os.path.join(Directory, zip_file) ):
                raise Exception( "%s file does not exist."%zip_file )
            else:
                target_zip_file = os.path.join(self.DICOM_path_, zip_file)
                shutil.move( os.path.join( Directory, zip_file ), target_zip_file );
                self.protocols_[Protocol][1].append( target_zip_file )
                self.protocols_[Protocol][3].append( "%s %s"%(hashlib.md5(target_zip_file).hexdigest(),
                                                              target_zip_file) )
        
            #
            # nifti file
            # with zip_protocol_ function we should still be in dicom directory 
            nifti_file = self. dcm2nii_protocol_(Protocol, Directory, dir_num)
            #
            if not os.path.exists( os.path.join(Directory, nifti_file) ):
                raise Exception( "%s file does not exist."%nifti_file )
            else:
                target_niftii_file = os.path.join(self.DICOM_path_, nifti_file)
                shutil.move( os.path.join(Directory, nifti_file), target_niftii_file );
                self.protocols_[Protocol][2].append( target_niftii_file )
                self.protocols_[Protocol][3].append( "%s %s"%(hashlib.md5(target_niftii_file).hexdigest(),
                                                              target_niftii_file) )
        
            #
            #
            return nifti_file

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


    def run( self ):
        self.T2()
        self.T2_3DC()

