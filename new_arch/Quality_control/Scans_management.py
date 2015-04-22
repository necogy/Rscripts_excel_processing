import os, sys
import shutil, tempfile, zipfile, csv
import logging
_log = logging.getLogger("__Scans_management__")
import hashlib
#
import Image_tools

class Scans_management( object ):
    """Scan management processing script.
    
    Attributes:
    protocol_name_:string -  name of the protocol
    setup_:map            - mapping of the setup
    """
    def __init__( self ):
        """Return a new Scans_management instance."""
        #
        # New scans directory
        self.main_new_scans_directory_ = os.path.join( os.sep, "mnt","macdata","groups","imaging_core","SNC-PACS-GW1-NEWDICOMS")
        self.new_scans_                = []
        #
        #
        tempo_file = os.path.join(os.sep, "home","quality","devel","Python","imaging-core","new_arch","Quality_control","SourceID","Scan_Tracking_08_06_2014.csv")
        self.source_id_csv_ = open(tempo_file, 'rt')
        #
        self.study_      = "NIFD"       # 
        self.sourceID_   = "NIFD151-3"  # Prod by XL Scan Tracking file
        self.PIDN_       = "16781"      # LAVA
        self.First_Name_ = "Dianne"     # LAVA
        self.Last_Name_  = "Graydon"    # LAVA
        self.scan_date_  = "2015-02-24" # 
        self.Your_Name_  = "Yann Cobigo"
        #
        self.sourceIDX_   = "NIFD151X3"  # 

        #
        # Dicoms
#        self.DICOM_path_ = os.path.join( os.sep, "home","ycobigo","subjects", "%s,%s"%(self.Last_Name_,self.First_Name_) )
        self.DICOM_path_ = os.path.join( os.sep, "home","quality","subjects", "test1" )

        #
        #
        self.projects_ = {"NIFD":"", "PPGAAAA":"", "ADRC":"", "HB":"", "FRTNI":"", "HV":"", "EPIL":"", "INF":"", "TPI4RT":"", "TPIAD":"", "RPD":"", "NRS":""}
        # 
        # protocols dictionary
        # "proto":"True", "zip_file", "nii_file", "md5 signatures"
        self.protocols_ = {"T2":[False,[],[],[]],"T2_3DC":[False,[],[],[]]}

        #
        # Output files
        # self.PID_path_ = os.path.join( "${block}", self.PIDN_, self.scan_date_,"${SOURCEID}_${LASTNAME},${FIRSTNAME}" )
        self.PID_path_ = ""
        self.Q_path_   = os.path.join( os.sep, "Volumes","Imaging432A","images432A","PIDN", self.PID_path_ )
        self.R_path_   = os.path.join( os.sep, "mnt","tank2","macdata","projects","images", self.PID_path_ )
    #
    #
    def new_scans(self):
        """New scans list the new scans arrived in the folder and check if the copy process is over."""
        try:
            #
            # Probe the new scans
            for scan in os.listdir( self.main_new_scans_directory_ ):
                self.new_scans_.append( scan )

            #
            # Is it one of our project?
            for scan in self.new_scans_:
                for project in self.projects_:
                    if project in scan:
                        # project and PIDN
                        self.study_ = project
                        self.PIDN_  = scan[len(project):]
                        print self.study_, " ", self.PIDN_
                        # date
                        dates   = []
                        level_1 = os.path.join( self.main_new_scans_directory_, scan )
                        for dirs in os.listdir( level_1 ):
                            dates.append( dirs )
                        # loop over the dates
                        for date in dates:
                            # if date is new process the scan 20130122
                            if True:
                                self.scan_date_ = "%s-%s-%s"%(date[0:4],date[4:6],date[6:8])
                                print self.scan_date_
                                # Process the scan if we have only one scan
                                level_2 = os.path.join( level_1, date )
                                # check we have only one file/dir in the date directory
                                files = []
                                for count in os.listdir( level_2 ):
                                    files.append(count)
                                if len(files) == 1:
                                    # create a Source ID
                                    self.sourceIDX_ = self.create_source_id_()
                                    # process the scans
                                    self.scan_process( os.path.join(level_2, files[0]) )
                                else:
                                    raise Exception( "Directory %s contain more than one directory."%level_2 )
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
    def scan_process( self, Scans_dir ):
        """Scan process the new scans listed from self.new_scans."""
        try:
            #
            #
            self.T2( Scans_dir )
            self.T2_3DC( Scans_dir )
            

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
    def create_source_id_( self ):
        """Create a unique source id."""
        try:
            #
            # Load csv file
            reader = csv.reader( self.source_id_csv_ )
            # 
            for row in reader:
                if "SourceID" in row[0]:
                    pass
                if row[1] == self.PIDN_:
                    # check if the scan date exist
                    # generate a new source ID
                    # add the new line in the CSV file
                    print row
            #

            #
            #
            self.source_id_csv_.close()

            #
            #
            return "NIFD151X3"
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
    def Diffusion( self, Scans ):
        return self.protocol_name_
    
    
    def ASL( self, Scans ):
        return self.protocol_name_
    
    
    def DTIV1( self, Scans ):
        return self.protocol_name_
    
    
    def DTIV2( self, Scans ):
        return self.protocol_name_
    
    
    def NIFD_DTI( self, Scans ):
        return self.protocol_name_
    
    
    def Resting_state( self, Scans ):
        return self.protocol_name_
    
    
    def T1_long( self, Scans ):
        return self.protocol_name_
    
    
    def T1_long_3DC( self, Scans ):
        return self.protocol_name_

    
    #
    #
    def T2( self, Scans ):
        """T2 protocol"""
        try:
            #
            # Check on T2 directory
            self.protocols_["T2"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T2_spc" in dir_name and "DIS3D" not in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["T2"][0] = False
                _log.warning("T2 directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["T2"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("T2", dir_name, len(protocol_dir) is 1 )
            print  self.protocols_
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
    def T2_3DC( self, Scans ):
        """T2_3DC protocol"""
        try:
            #
            # Check on T2_3DC directory
            self.protocols_["T2_3DC"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T2_spc" in dir_name and "DIS3D" in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
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
    
    
    def FLAIR( self, Scans ):
        return self.protocol_name_
    
    
    def FLAIR_3DC( self, Scans ):
        return self.protocol_name_
    
    
    def T1_short( self, Scans ):
        return self.protocol_name_
    
    
    def T1_short_3DC( self, Scans ):
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
            #
            
            #
            # create temporary directory to store zip files
            tempo_dir = tempfile.mkdtemp()
            # Name the zip file
            if Dir_num:
                zip_file = "%s_%s_%s.zip"%(Protocol, Dir_num, self.sourceIDX_)
            else:
                zip_file = "%s_%s.zip"%(Protocol, self.sourceIDX_)
            # create in the temporary directory
            zip_file = os.path.join(tempo_dir, zip_file)
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
        #
        try:
            #
            # create temporary directory to store zip files
            nifti_file = ""
            tempo_dir = tempfile.mkdtemp()
            print tempo_dir
            os.chdir( tempo_dir )
            # Gather the dicom in the temporary directory
            for dicom in os.listdir( Directory ):
                shutil.copy( os.path.join(Directory, dicom), os.path.join(tempo_dir, dicom) )
            #
            cmd = 'dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n *'
            Image_tools.generic_unix_cmd(cmd)
            #
            for file_name in os.listdir( tempo_dir ):
                if file_name.startswith("o") and file_name.endswith(".nii"):
                    if Dir_num:
                        nifti_file = "%s_%s_%s.nii"%(Protocol, Dir_num, self.sourceIDX_)
                    else:
                        nifti_file = "%s_%s.nii"%(Protocol, self.sourceIDX_)
                    shutil.move( file_name, nifti_file )
                if not file_name.startswith("o") and file_name.endswith(".nii"):
                    os.remove( os.path.join(tempo_dir, file_name) )
            #
            #
            return os.path.join( tempo_dir, nifti_file )
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
    def process_protocol_( self, Protocol, Directory, Unique ):
        """Convert dicoms to nifti file function"""
        _log.warning("%s sequence(s) found - process sequence(s)"%(Protocol))
        #
        try:
            #
            # Multiple cases
            dir_num = ""
            base_name = os.path.basename( Directory )
            #
            if not Unique:
                if base_name[:2].isdigit():
                    dir_num = base_name[:2]
                elif base_name[:1].isdigit():
                    dir_num = base_name[:1]
                else:
                    raise Exception( "No multiple cases for the protocol %s."%Protocol )

            #
            # Zip dicoms
            zip_file = self.zip_protocol_(Protocol, Directory, dir_num) 
            #
            if not os.path.exists( zip_file ):
                raise Exception( "%s file does not exist."%zip_file )
            else:
                target_zip_file = os.path.join( self.DICOM_path_, os.path.basename(zip_file) )
                shutil.move( zip_file, target_zip_file );
                self.protocols_[Protocol][1].append( target_zip_file )
                self.protocols_[Protocol][3].append( "%s %s"%(hashlib.md5(target_zip_file).hexdigest(),
                                                              target_zip_file) )
        
            #
            # nifti file
            nifti_file = self. dcm2nii_protocol_(Protocol, Directory, dir_num)
            #
            if not os.path.exists( nifti_file ):
                raise Exception( "%s file does not exist."%nifti_file )
            else:
                target_niftii_file = os.path.join( self.DICOM_path_, os.path.basename(nifti_file) )
                shutil.move( nifti_file, target_niftii_file );
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
        self.new_scans()

