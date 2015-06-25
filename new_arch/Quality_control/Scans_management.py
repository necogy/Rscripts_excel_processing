import os, sys
import shutil, tempfile, zipfile, csv, json
import logging
import hashlib
#
from functools import partial
#
import neuroimaging_qc as niqc
import Image_tools
import MAC_tools as MAC

_log = logging.getLogger("__Scans_management__")
#
# Color in terminal
# 
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
#
#
#
class Scans_management( object ):
    """Scan management processing script.
    
    Attributes:
    protocol_name_:string -  name of the protocol
    setup_:map            - mapping of the setup
    """
    def __init__( self ):
        """Return a new Scans_management instance."""

        #
        # KNECT API 
        #
        json_data = open( "/home/quality/QC/knect.json" )
        knect_connect = json.load( json_data )
        #
        self.knect_username_ = knect_connect["knect_username"]
        self.knect_password_ = knect_connect["knect_password"]
        #
        # must initialize with LDAP auth credentials, auth service URL, and workspace service URL
        niqc.Init( self.knect_username_, self.knect_password_, 
                   auth_url = 'https://knect.ucsf.edu/auth',
                   service_url = 'https://knect.ucsf.edu/neuroimaging/qc' )
        # successful auth will save a knect_auth_token in the library
        knect_auth_token = niqc.knect_auth_token

        #
        # New scans directory
        self.main_new_scans_directory_ = os.path.join( os.sep, "mnt","macdata","groups","imaging_core","SNC-PACS-GW1-NEWDICOMS")
        self.new_scans_                = []
        #
        # Scan status: Done, Running, Failed
        self.json_scan_status_ = "/home/quality/QC/scan_status.json"
        json_scan_status_file  = open( self.json_scan_status_ , 'r' )
        self.scan_status_      = json.load( json_scan_status_file )
        #
        #
        tempo_file = os.path.join(os.sep, "home","quality","devel","Python","imaging-core","new_arch","Quality_control","SourceID","Scan_Tracking_08_06_2014.csv")
        self.source_id_csv_ = open(tempo_file, 'rt')
        #
        self.study_       = "" # 
        self.sourceID_    = "" # Prod by XL Scan Tracking file
        self.PIDN_        = "" # LAVA
        self.PIDN_block_  = "" # 
        self.First_Name_  = "" # LAVA
        self.Last_Name_   = "" # LAVA
        self.scan_date_   = "" # 
        self.dicoms_date_ = "" # 
        self.Your_Name_   = "Yann Cobigo"

        #
        # Dicoms
        self.R_path_ = os.path.join( os.sep, "home","quality","subjects", "test1" )

        #
        #
        self.projects_ = {"NIFD":"", "PPGAAA":"", "ADRCAAAA":"", "HBAAAA":"", "FRTNIAAAA":"", "HVAAAA":"", "EPILAAAA":"", "INFAAAA":"", "TPI4RTAAAA":"", "TPIADAAAA":"", "RPDAAAA":"", "NRSAAAA":"", "DCAAAAA":"","GeschlabAAAA":""}
        # 
        # protocols dictionary
        # "proto":"True", "zip_file", "nii_file", "md5 signatures"
        self.protocols_ = {}

        #
        # WARNING: this attribute control the output path.
        # The value of this attribute has to be carfully selected.
        self.PRODUCTION_ = False
        #
        if self.PRODUCTION_:
            #
            # PRODUCTION MODE
            print bcolors.OKGREEN + "-----------------------------------------------------------"
            print bcolors.OKGREEN + "-----------------------------------------------------------"
            print bcolors.OKGREEN + "-----          Scan management in production          -----"
            print bcolors.OKGREEN + "-----      Images will be copied in the R: drive      -----"
            print bcolors.OKGREEN + "-----------------------------------------------------------"
            print bcolors.OKGREEN + "-----------------------------------------------------------" + bcolors.ENDC
        else:
            #
            # DEVELOPPEMENT MODE
            print bcolors.WARNING + "-----------------------------------------------------------"
            print bcolors.WARNING + "-----------------------------------------------------------"
            print bcolors.WARNING + "-----                                                 -----"
            print bcolors.WARNING + "-----          THIS IS A DEVELOPMENT VERSION          -----"
            print bcolors.WARNING + "-----                                                 -----"
            print bcolors.WARNING + "-----              TURNE INTO PRODUCTION              -----"
            print bcolors.WARNING + "-----                                                 -----"
            print bcolors.WARNING + "-----------------------------------------------------------"
            print bcolors.WARNING + "-----------------------------------------------------------" + bcolors.ENDC
            
    #
    #
    def new_scans(self):
        """New scans list the new scans arrived in the folder and check if the copy process is over."""
        try:
            #
            # Check for new scans and check the copy is done
            # Here we will have Prob new scan

            
            #
            # Probe the scans label 'New'
            for scan in os.listdir( self.main_new_scans_directory_ ):
                for date in os.listdir( os.path.join(self.main_new_scans_directory_, scan) ):
                    scan_to_check = "%s/%s"%(scan,date)
                    if scan_to_check in self.scan_status_.keys():
                        if self.scan_status_[scan_to_check] == "New":
                            self.scan_status_[scan_to_check] = "Running"
                            self.new_scans_.append( scan_to_check )
            # Update the scan status
            print self.scan_status_
            with open( self.json_scan_status_, 'w') as outfile:
                json.dump( self.scan_status_, outfile,
                           indent = 2, separators = (',',': '), sort_keys = True )
            
            #
            # Is it one of our project?
            for scan in self.new_scans_:
                for project in self.projects_:
                    if project in scan:
                        #
                        # Path for image production
                        if self.PRODUCTION_:
                            self.R_path_ = os.path.join( os.sep, "mnt","images" )
                        else:
                            self.R_path_ = os.path.join( os.sep, "home","quality","prod" )

                        #
                        # project and PIDN. Also the PIDN blocks it belongs
                        # self.study_, self.PIDN_, self.PIDN_block_
                        self.lava_access_( project, scan.split("/")[0] )
                        #
                        # date: PIND/{2013-07-01,2012-10-25,..}
                        level_1 = os.path.join( self.main_new_scans_directory_, scan )
#                        dates   = []
#                        for dirs in os.listdir( level_1 ):
#                            dates.append( dirs )
#                        # loop over the dates
#                        for date in dates:
                        # if date is new, process the scan 20130122
                        self.dicoms_date_ = scan.split("/")[1]
                        self.scan_date_   = "%s-%s-%s"%(self.dicoms_date_[0:4], 
                                                        self.dicoms_date_[4:6], 
                                                        self.dicoms_date_[6:8])
                        print self.scan_date_
                        # Process the scan if we have only one scan
#                        level_2 = os.path.join( level_1, date )
                        # check we have only one file/dir in the date directory
                        files = []
                        for count in os.listdir( level_1 ):
                            files.append(count)
                        if len(files) == 1:
                            # create a Source ID
                            self.sourceID_ = self.create_source_id_()
                            # process the scans
                            self.scan_process( os.path.join(level_1, files[0]) )
                        else:
                            raise Exception( "Directory %s contains more than one directory."%level_1 )
                
                #
                # Update the scan status
                self.scan_status_[scan] = "Done"
                with open( self.json_scan_status_, 'w') as outfile:
                    json.dump( self.scan_status_, outfile,
                               indent = 2, separators = (',',': '), sort_keys = True )


            #
            # Clean temporary directories
            self.clean_tempdir_()
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
    def manual_new_scans_(self, Scan):
        """New scans list the new scans arrived in the folder and check if the copy process is over."""
        try:
            #
            # Probe the new scans
            for scan in os.listdir( self.main_new_scans_directory_ ):
                self.new_scans_.append( scan )

            #
            # Path for image production
            if self.PRODUCTION_:
                self.R_path_ = os.path.join( os.sep, "mnt","images" )
            else:
                self.R_path_ = os.path.join( os.sep, "home","quality","prod" )

            #
            # date: PIND/{2013-07-01,2012-10-25,..}
            level_1 = os.path.join( self.main_new_scans_directory_, Scan )
            print self.scan_date_
            # Process the scan if we have only one scan
            date = self.dicoms_date_
            self.scan_date_ = "%s-%s-%s"%(date[0:4], date[4:6], date[6:8])
            level_2 = os.path.join( level_1, date )
            # check we have only one file/dir in the date directory
            files = []
            for count in os.listdir( level_2 ):
                files.append(count)
            #
            if len(files) == 1:
                # create a Source ID
                self.sourceID_ = self.create_source_id_()
                # process the scans
                self.scan_process( os.path.join(level_2, files[0]) )
            else:
                raise Exception( "Directory %s contains more than one directory."%level_2 )

            #
            # Clean temporary directories
            self.clean_tempdir_()
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
            # create the path for the copy
            if  not os.path.exists( os.path.join( self.R_path_, self.PIDN_block_) ):
                raise Exception( "New major PIND blocks must be built for PIDN %s %s."%(self.PIDN_, 
                                                                                        self.PIDN_block_) )
            #
            self.R_path_ = os.path.join( self.R_path_, self.PIDN_block_, self.PIDN_ )
            # if PIDN does not exist: create
            if not os.path.exists( self.R_path_ ):
                os.mkdir( self.R_path_ )
            # Check the scan date does not already exist
            self.R_path_ = os.path.join( self.R_path_, self.scan_date_ )
            if not os.path.exists( self.R_path_ ):
                os.mkdir( self.R_path_ )
            else:
                raise Exception( "%s scan date already exist for PIDN: %s."%(self.scan_date_,
                                                                             self.PIDN_) )
            # PID path
            self.R_path_ = os.path.join( self.R_path_, "%s_%s,%s"%(self.sourceID_, 
                                                                   self.Last_Name_,
                                                                   self.First_Name_) )
            # Check the PID path does not already exist
            if not os.path.exists( self.R_path_ ):
                os.mkdir( self.R_path_ )
            else:
                raise Exception( "PID path %s already exist for PIDN: %s."%(self.R_path_,
                                                                            self.PIDN_) )

            #
            # QC: json output
            # "proto":"True", "zip_file", "nii_file", "md5 signatures"
            self.protocols_ = {
                "T2":[False,[],[],[]],
                "T2_3DC":[False,[],[],[]],
                "FLAIR":[False,[],[],[]],
                "FLAIR-3DC":[False,[],[],[]],
                "MP-LAS":[False,[],[],[]],
                "MP-LAS-long-3DC":[False,[],[],[]],
                "T1-SHORT":[False,[],[],[]],
                "T1-SHORT-3DC":[False,[],[],[]],
                "ASL-raw-v1":[False,[],[],[]],
                "ASL-MoCo-v1":[False,[],[],[]],
                "DTI-v2":[False,[],[],[]],
                "DTI-v4":[False,[],[],[]],
                "DWI-RPD-ADC":[False,[],[],[]],
                "DWI-RPD-B0":[False,[],[],[]],
                "DWI-RPD-B2000":[False,[],[],[]],
                "RSfMRI":[False,[],[],[]]
            }

            #
            # ToDo make a select on the lava string 
            # "scansSummary"
            # ASL | ASL-MoCo | DTI-v2 | DTI-v4 | DWI-RPD-ADC | DWI-RPD-B0 | DWI-RPD-B2000 | ...
            self.T2( Scans_dir )
            self.T2_3DC( Scans_dir )
            self.FLAIR( Scans_dir )
            self.FLAIR_3DC( Scans_dir )
            self.T1_long( Scans_dir )
            self.T1_long_3DC( Scans_dir )
            self.T1_short( Scans_dir )
            self.T1_short_3DC( Scans_dir )
            self.pulsed_ASL( Scans_dir )
            self.pulsed_ASL_MoCo( Scans_dir )
            self.DTI( Scans_dir )
            self.Resting_state( Scans_dir )

            #
            # Dump QC results
            #

            #
            # JSON
            os.mkdir( os.path.join(self.R_path_, "QC") )
            QC_JSON = os.path.join( self.R_path_, "QC", "QC.json" )
            with open( QC_JSON, 'w') as outfile:
                json.dump( self.protocols_, 
                           outfile, indent=2, separators=(',',': '), sort_keys=True )

            #
            # ToDo remove
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
    def create_source_id_( self ):
        """Create a unique source id."""
        try:
            return "NIFD151X3"
            #
            # make a list out of generator(csv)
            reader    = csv.reader( self.source_id_csv_ )
            your_list = list( reader )
            pre_list  = []
            #
            # creating a short list of same PIDN for the last row
            for row in your_list:
                if row[1] == self.PIDN_:
                    pre_list.append(row)
            
            #
            # Copy the head line of the cvs file for the update list
            new_list = []
            for row in your_list:
                #
                # Header for the new output list
                if "SourceID/ADID" in row[0]:
                    new_list.append( row )
                    count = 0
                #
                # new PIDN created in the output list, attached on the last line
                elif row == your_list[-1] and row[1] != self.PIDN_ and count == 0:
                    # ToDo define item first, otherwise you will have ref problem
                    # items = []
                    match = re.match(r"([a-z]+)([0-9]+)", row[0].split('-')[0], re.I)
                    if match:
                        items = match.groups()
                    else:
                        # ToDo
                        print "if there is no match, do we raise an exception?"
                    # 
                    self.SourceID_ = self.study_ + str( 1 + int(items[1]) ) + '-1' #ToDo ref problem with items
                    new_list.append( row )
                    new_list.append( [self.SourceID_, self.PIDN_, self.scan_date_] )
                #
                # appending the last one
                elif row == pre_list[-1] and row[1] == self.PIDN_ and count == 0:
                    print 'last row', row
                    self.SourceID_ = row[0].split('-')[0] + '-' + str(1+int(row[0].split('-')[1]))
                    new_list.append( row )
                    new_list.append( [self.SourceID_,self.PIDN_,self.scan_date_] )
                    count = row[0].split('-')[1]
                #
                #
                elif row[1] == self.PIDN_:
                    # ToDo: this part has a problem
                    pass
                    # Date format: ['2014-04-14']
                    row_date = row[2].split('/')
                    # manage the row_date for getting rid of '0' of both month/date
                    # do the same to input_date if the input_date contains '0'
                    # ToDo show a model of date you are changing
                    if row_date[1][0] == '0' and row_date[2][0] == '0':
                        row_date[1] = row_date[1][1]
                        row_date[2] = row_date[2][1]
                    elif row_date[1][0] == '0':
                        row_date[1] = row_date[1][1]
                    elif row_date[2][0] == '0':
                        row_date[2] = row_date[2][1]
                    else:
                        pass

                    #ToDo: you don't need to add a try
                    #ToDo: there is, already, a general one
                    #ToDo: just raise an exception
                    try:
                        # ToDo allocate a type to the variable: list string...
                        input_date
                    except NameError:
                        input_date = self.scan_date_.split('/')
                    else:
                        # ToDo which line is important?
                        pass
                    
                    # normal situation: adding the item after the current row
                    if int(row_date[2]) < int(input_date[2]) or \
                       (int(row_date[2]) == int(input_date[2]) and int(row_date[0]) < int(input_date[0])) or \
                       (int(row_date[2]) == int(input_date[2]) and int(row_date[0]) == int(input_date[0]) and int(row_date[1]) < int(input_date[1])):
                        if int(row[0].split('-')[1]) != count:
                            print int(row[0].split('-')[1]), count
                            print 'no insertion', row[0]
                            new_list.append( row )
                        # not quite possible to solve this problem by iterating, no way to go back.
                        elif int(row[0].split('-')[1]) == count:
                            print row[0].split('-')[1],"previous row minus 1"

                    # rare cases: inserting row
                    else:
                        if count == 0:
                            self.SourceID_ = row[0] # taking over the row's source_id
                            print 'new_input self.SourceID',self.SourceID_
                            count = row[0].split('-')[1]
                            # appending twice: the inserting and the current row
                            new_list.append([self.SourceID_,self.PIDN_, self.scan_date_,'','', self.Last_Name_,self.First_Name_])
                            # the current row takes the new created (time point +1) source_id
                            row[0] = row[0].split('-')[0] + '-' + str(1+int(row[0].split('-')[1]))
                            new_list.append(row)
                            print 'updated current-row',row[0]
                        else:
                            # the current row takes the new created source_id
                            row[0] = row[0].split('-')[0] + '-' + str(1+int(row[0].split('-')[1]))
                            new_list.append(row)
                            print 'updated following current row', row[0]
                            # updating the input_date: important
                            input_date = row[2].split('/')
                else:
                    new_list.append(row)

                #
                # write the output
                with open("output.csv", "wb") as f:
                    writer = csv.writer(f)
                    writer.writerows(new_list)
            #
            #
            self.source_id_csv_.close()

            #
            # Return the new Source Id
            
            #return self.SourceID_
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
    #
    #
    def pulsed_ASL( self, Scans ):
        """Pulsed Arterial Spin Labeling (perfusion)"""
        try:
            #
            # Check on ASL directory
            self.protocols_["ASL-raw-v1"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "pASL_" in dir_name and "MoCo" not in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["ASL-raw-v1"][0] = False
                _log.warning("ASL-raw-v1 directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["ASL-raw-v1"][0]:
                for dir_name in protocol_dir:
                    self.zip_protocol_("ASL-raw-v1", dir_name, len(protocol_dir) is 1 )
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
    def pulsed_ASL_MoCo( self, Scans ):
        """Pulsed Arterial Spin Labeling (perfusion) MoCo is a sequence following the ASL-raw-v1 protocol."""
        try:
            #
            # Check on ASL directory
            self.protocols_["ASL-MoCo-v1"][0] = True
            protocol_dir = []

            #
            # Get pASL sequence
            ASL_raw = []
            ASL_seq = 0
            for dir_name in os.listdir( Scans ):
                if "pASL_" in dir_name and "MoCo" not in dir_name:
                    ASL_raw.append(dir_name)
            # Check we have only 1 ASL_raw
            if len(ASL_raw) == 1:
                if ASL_raw[0][:2].isdigit():
                    ASL_seq = int(ASL_raw[0][:2])
                elif ASL_raw[0][:1].isdigit():
                    ASL_seq = int(ASL_raw[0][:1])
#                # increment the sequence to the next sequence
#                ASL_seq += 1
            else:
                raise  Exception( "More than one ASL sequence has been found." )
            
            #
            # Precess ASL MoCo
            for dir_name in os.listdir( Scans ):
                if str( ASL_seq + 1 ) in dir_name and "MoCo" in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["ASL-MoCo-v1"][0] = False
                _log.warning("PASL directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["ASL-MoCo-v1"][0]:
                for dir_name in protocol_dir:
                    self.zip_protocol_("ASL-MoCo-v1", dir_name, len(protocol_dir) is 1 )
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
    def DTI( self, Scans ):
        """Diffusion tensor imaging."""
        try:
            #
            # Check on DTI directory
            self.protocols_["DTI-v2"][0] = True
            self.protocols_["DTI-v4"][0] = True
            self.protocols_["DWI-RPD-ADC"][0] = True
            self.protocols_["DWI-RPD-B0"][0] = True
            self.protocols_["DWI-RPD-B2000"][0] = True
            #
            protocol_dir = {}
            protocol_dir["DTI-v2"] = []
            protocol_dir["DTI-v4"] = []
            protocol_dir["DWI-RPD-ADC"] = []
            protocol_dir["DWI-RPD-B0"] = []
            protocol_dir["DWI-RPD-B2000"] = []
            #
            for dir_name in os.listdir( Scans ):
                if "ep2d-advdiff-511E_b" in dir_name and "ADC" not in dir_name and "FA" not in dir_name and "ColFA" not in dir_name and "TRACEW" not in dir_name:
                    protocol_dir["DTI-v2"].append( os.path.join(Scans, dir_name) )
                #
                if "NIFD" in dir_name and "ADC" not in dir_name and "FA" not in dir_name and "ColFA" not in dir_name and "TRACEW" not in dir_name:
                    protocol_dir["DTI-v4"].append( os.path.join(Scans, dir_name) )
                #
                if "DIFFUSION" in dir_name and "SCAN_TRACE_P2" in dir_name and "ADC" not in dir_name:
                    protocol_dir["DWI-RPD-B0"].append( os.path.join(Scans, dir_name) )
                    protocol_dir["DWI-RPD-B2000"].append( os.path.join(Scans, dir_name) )
                #
                if "DIFFUSION" in dir_name and "SCAN_TRACE_P2" in dir_name and "ADC" in dir_name:
                    protocol_dir["DWI-RPD-ADC"].append( os.path.join(Scans, dir_name) )
            #
            # Check if we found a directory
            if not protocol_dir["DTI-v2"]:
                self.protocols_["DTI-v2"][0] = False
                _log.warning("DTI v2 directory does not exist.")
            #
            if not protocol_dir["DTI-v4"]:
                self.protocols_["DTI-v4"][0] = False
                _log.warning("DTI v4 directory does not exist.")
            #
            if not protocol_dir["DWI-RPD-B0"] or not protocol_dir["DWI-RPD-B2000"]:
                self.protocols_["DWI-RPD-B0"][0]    = False
                self.protocols_["DWI-RPD-B2000"][0] = False
                _log.warning("Diffusion weighted images directory does not exist.")
            #
            if not protocol_dir["DWI-RPD-ADC"]:
                self.protocols_["DWI-RPD-ADC"][0] = False
                _log.warning("Diffusion weighted images with ADC sequence directory does not exist.")

            #
            # DICOMs zipping and change into nifti
            #

            #
            # "DTI-v2" protocol
            if self.protocols_["DTI-v2"][0]:
                files_to_zip = []
                for dir_name in protocol_dir["DTI-v2"]:
                    if "b0" in dir_name:
                        files_to_zip.append( self.zip_DICOMs_("DTI-b0-v2", dir_name, "") )
                    elif "b2000_64" in dir_name:
                        files_to_zip.append( self.zip_DICOMs_("DTI-64-v2", dir_name, "") )
                    else:
                        raise Exception( "Error in the DTI directory selection: %s."%dir_name )
                #
                # create temporary directory to store zip files
                tempo_dir = tempfile.mkdtemp()
                # TODO: log as warning
                print tempo_dir
                # 
                os.chdir( tempo_dir )
                zip_file = "%s_%s.zip"%("DTI-v2", self.sourceID_)
                zip_file = os.path.join(tempo_dir, zip_file)
                # create the zip file
                zf = zipfile.ZipFile( zip_file, mode='w' )
                for file_name in files_to_zip:
                    shutil.move( file_name, tempo_dir );
                    zf.write( os.path.basename(file_name) )
                #
                #if not zf.test(): # check if the zip is valid
                zf.close()
                #
                if not os.path.exists( zip_file ):
                    raise Exception( "%s file does not exist."%zip_file )
                else:
                    target_zip_file = os.path.join( self.R_path_, os.path.basename(zip_file) )
                    shutil.move( zip_file, target_zip_file )
                    self.protocols_["DTI-v2"][1].append( target_zip_file )
                    self.protocols_["DTI-v2"][3].append( "%s %s"%(MAC.Utils().md5sum(target_zip_file),
                                                                  target_zip_file) )
            #
            # "DTI-v4" protocol
            if self.protocols_["DTI-v4"][0]:
                for dir_name in protocol_dir["DTI-v4"]:
                    self.zip_protocol_("DTI-v4", dir_name, len(protocol_dir["DTI-v4"]) is 1 )

            #
            # "DWI-RPD-B0" and "DWI-RPD-B2000" protocols
            if self.protocols_["DWI-RPD-B0"][0]:
                files_to_zip = []
                # Warning those are the same sequence
                files_to_zip.append( self.zip_DICOMs_(Protocol  = "DWI-RPD-B0", 
                                                      Directory = protocol_dir["DWI-RPD-B0"][0], 
                                                      Dir_num   = "",
                                                      Range     = range(0, 21+1)) ) # 22 firsts: 0 - 21
                #
                files_to_zip.append( self.zip_DICOMs_(Protocol  = "DWI-RPD-B2000", 
                                                      Directory = protocol_dir["DWI-RPD-B2000"][0], 
                                                      Dir_num   = "",
                                                      Range     = range(22, 43+1)) ) # 22 - 44
                #
                if not os.path.exists( files_to_zip[0] ) or not os.path.exists( files_to_zip[1] ):
                    raise Exception( "%s and %s files doe not exist."%(files_to_zip[0], 
                                                                       files_to_zip[1]) )
                else:
                    # DWI-RPD-B0
                    target_zip_file = os.path.join( self.R_path_, os.path.basename(files_to_zip[0]) )
                    shutil.move( files_to_zip[0], target_zip_file )
                    self.protocols_["DWI-RPD-B0"][1].append( target_zip_file )
                    self.protocols_["DWI-RPD-B0"][3].append( "%s %s"%(MAC.Utils().md5sum(target_zip_file),
                                                                      target_zip_file) )
                    # DWI-RPD-B2000
                    target_zip_file = os.path.join( self.R_path_, os.path.basename(files_to_zip[1]) )
                    shutil.move( files_to_zip[1], target_zip_file )
                    self.protocols_["DWI-RPD-B2000"][1].append( target_zip_file )
                    self.protocols_["DWI-RPD-B2000"][3].append( "%s %s"%(MAC.Utils().md5sum(target_zip_file),
                                                                         target_zip_file) )
                # Nifti file
#HERE                DWI_RPD_nifti = self.dcm2nii_protocol_()

            #
            # "DWI-RPD-ADC" protocol
            if self.protocols_["DWI-RPD-ADC"][0]:
                for dir_name in protocol_dir["DWI-RPD-ADC"]:
                    self.process_protocol_("DWI-RPD-ADC", dir_name, len(protocol_dir["DTI-v4"]) is 1 )
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
    def Resting_state( self, Scans ):
        """Resting state protocol"""
        try:
            #
            # Check on Resting state and GRE-fields maps directory
            self.protocols_["RSfMRI"][0] = True
            protocol_dir = {}
            protocol_dir["RS"]        = []
            protocol_dir["GRE-Field"] = []
            # 
            for dir_name in os.listdir( Scans ):
                # 8-RestingStatePHYSIO_eyesclosed_wholebrain
                if "Resting" in dir_name and "hole" in dir_name and "rain" in dir_name:
                    protocol_dir["RS"].append( os.path.join(Scans, dir_name) )
                # 13-gre_field_mapping_RS
                # 14-gre_field_mapping_RS
                if "gre_field_mapping" in dir_name and "RS" in dir_name:
                    protocol_dir["GRE-Field"].append( os.path.join(Scans, dir_name) )
                #
            # Check if we found a directory
            if not protocol_dir["RS"] or not protocol_dir["GRE-Field"] :
                self.protocols_["RSfMRI"][0] = False
                _log.warning("Resting state directory does not exist.")

            #
            # DICOMs zipping
            #

            if self.protocols_["RSfMRI"][0]:
                #
                # rsfMRI-raw
                rsfMRI = self.zip_DICOMs_( "rsfMRI-raw-v1", 
                                           protocol_dir["RS"][0], "")

                #
                # GRE-fields
                files_to_zip = []
                # Phase map
                files_to_zip.append( self.zip_DICOMs_( "GRE-Field-Map-Phase-raw-v1", 
                                                       protocol_dir["GRE-Field"][0], "") )
                # Magnitude map
                files_to_zip.append( self.zip_DICOMs_( "GRE-Field-Map-Magnitude-raw-v1", 
                                                       protocol_dir["GRE-Field"][1], "") )

                #
                # create temporary directory to store zip files
                tempo_dir = tempfile.mkdtemp()
                # TODO: log as warning
                print tempo_dir
                # 
                os.chdir( tempo_dir )
                zip_file = "%s_%s.zip"%("GRE-Field-Map-raw-v1", self.sourceID_)
                zip_file = os.path.join(tempo_dir, zip_file)
                # create the zip file
                zf = zipfile.ZipFile( zip_file, mode='w' )
                for file_name in files_to_zip:
                    shutil.move( file_name, tempo_dir );
                    zf.write( os.path.basename(file_name) )
                #
                #if not zf.test(): # check if the zip is valid
                zf.close()
                
                #
                # Record results
                if not os.path.exists( zip_file ):
                    raise Exception( "%s file does not exist."%zip_file )
                else:
                    target_zip_files = []
                    target_zip_files.append( os.path.join(self.R_path_, os.path.basename(rsfMRI)) )
                    target_zip_files.append( os.path.join(self.R_path_, os.path.basename(zip_file)) )
                    #
                    shutil.move( rsfMRI,   target_zip_files[0] )
                    shutil.move( zip_file, target_zip_files[1] )
                    #
                    for zip_file in target_zip_files:
                        self.protocols_["RSfMRI"][1].append( zip_file )
                        self.protocols_["RSfMRI"][3].append( "%s %s"%(MAC.Utils().md5sum(zip_file),
                                                                      zip_file) )
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
    
    
    def T1_long( self, Scans ):
        """T1 long protocol"""
        try:
            #
            # Check on T1 directory
            self.protocols_["MP-LAS"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T1_mprage" in dir_name and "DIS3D" not in dir_name and "short" not in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["MP-LAS"][0] = False
                _log.warning("MP-LAS directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["MP-LAS"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("MP-LAS", dir_name, len(protocol_dir) is 1 )
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
    def T1_long_3DC( self, Scans ):
        """T1 3DC protocol"""
        try:
            #
            # Check on T1 directory
            self.protocols_["MP-LAS-long-3DC"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T1_mprage_S" in dir_name and "DIS3D" in dir_name and "short" not in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["MP-LAS-long-3DC"][0] = False
                _log.warning("MP-LAS-long-3DC directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["MP-LAS-long-3DC"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("MP-LAS-long-3DC", dir_name, len(protocol_dir) is 1 )
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
    def FLAIR( self, Scans ):
        """FLAIR protocol"""
        try:
            #
            # Check on FLAIR directory
            self.protocols_["FLAIR"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T2_flair" in dir_name and "DIS3D" not in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["FLAIR"][0] = False
                _log.warning("FLAIR directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["FLAIR"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("FLAIR", dir_name, len(protocol_dir) is 1 )
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
    def FLAIR_3DC( self, Scans ):
        """FLAIR 3DC protocol"""
        try:
            #
            # Check on FLAIR directory
            self.protocols_["FLAIR-3DC"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T2_flair" in dir_name and "DIS3D" in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["FLAIR-3DC"][0] = False
                _log.warning("FLAIR 3DC directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["FLAIR-3DC"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("FLAIR-3DC", dir_name, len(protocol_dir) is 1 )
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
    def T1_short( self, Scans ):
        """T1 short protocol"""
        try:
            #
            # Check on T1 directory
            self.protocols_["T1-SHORT"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T1_mprage_short_" in dir_name and "DIS3D" not in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["T1-SHORT"][0] = False
                _log.warning("T1-SHORT directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["T1-SHORT"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("T1-SHORT", dir_name, len(protocol_dir) is 1 )
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
    def T1_short_3DC( self, Scans ):
        """T1 3DC protocol"""
        try:
            #
            # Check on T1 directory
            self.protocols_["T1-SHORT-3DC"][0] = True
            protocol_dir = []
            #
            for dir_name in os.listdir( Scans ):
                if "T1_mprage_short_" in dir_name and "DIS3D" in dir_name:
                    protocol_dir.append( os.path.join(Scans, dir_name) )
            # Check if we found a directory
            if not protocol_dir:
                self.protocols_["T1-SHORT-3DC"][0] = False
                _log.warning("T1-SHORT-3DC directory does not exist.")
            #
            # DICOMs zipping and change into nifti
            if self.protocols_["T1-SHORT-3DC"][0]:
                for dir_name in protocol_dir:
                    self.process_protocol_("T1-SHORT-3DC", dir_name, len(protocol_dir) is 1 )
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
    def zip_DICOMs_( self, Protocol, Directory, Dir_num = "", Range = range(0)):
        """Zip file function for DICOM files."""
        _log.info("%s sequence(s) found - zipping DICOM"%(Protocol))
        #
        try:
            #
            # Get the target directory name
            Up_directory = os.path.split( Directory )
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
            # TODO: log as warning
            print tempo_dir
            # Name the zip file
            if Dir_num:
                zip_file = "%s_%s_%s.zip"%(Protocol, Dir_num, self.sourceID_)
            else:
                zip_file = "%s_%s.zip"%(Protocol, self.sourceID_)
            # create in the temporary directory
            zip_file = os.path.join(tempo_dir, zip_file)
            # create the zip file
            zf = zipfile.ZipFile( zip_file, mode='w' )

            #
            # Recreate the directory structure
            #
            
            #
            # Create the dicom directoy in the temp directory
            os.mkdir( os.path.join(tempo_dir, Up_directory[1]) )
            #
            os.chdir( tempo_dir )
            # If no Range is given create the Range
            if not Range:
                Range = range( len(dicom_list) )
            # Copy DICOM files in the new directory and zip within a range
            for i in Range:
                file_name = dicom_list[i]
                shutil.copy( os.path.join(Directory, file_name), 
                             os.path.join(tempo_dir, Up_directory[1]) )
                zf.write( os.path.join(Up_directory[1], file_name) )
            #
            #if not zf.test(): # check if the zip is valid
            zf.close()
            return zip_file
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
        _log.info("%s sequence(s) found - convert DICOM to nifti"%(Protocol))
        #
        try:
            #
            # create temporary directory to store zip files
            niftis     = []
            nifti_file = ""
            tempo_dir = tempfile.mkdtemp()
            # TODO: log as warning
            print tempo_dir
            os.chdir( tempo_dir )
            # Gather the dicom in the temporary directory
            for dicom in os.listdir( Directory ):
                shutil.copy( os.path.join(Directory, dicom), os.path.join(tempo_dir, dicom) )
            #
            cmd = "dcm2nii -a n -d n -e n -g n -i n -p n -f y -v n -o %s *"%( tempo_dir )
            Image_tools.generic_unix_cmd(cmd)
            #
            for file_name in os.listdir( tempo_dir ):
                if file_name.endswith(".nii"):
                    niftis.append(file_name)
            #
            #
            if len( niftis ) > 1:
                for file_name in niftis:
                    if file_name.startswith("o") and file_name.endswith(".nii"):
                        if Dir_num:
                            nifti_file = "%s_%s_%s.nii"%(Protocol, Dir_num, self.sourceID_)
                        else:
                            nifti_file = "%s_%s.nii"%(Protocol, self.sourceID_)
                        #
                        shutil.move( file_name, nifti_file )
                    if not file_name.startswith("o") and file_name.endswith(".nii"):
                        os.remove( os.path.join(tempo_dir, file_name) )
            elif len( niftis ) == 1:
                if Dir_num:
                    nifti_file = "%s_%s_%s.nii"%(Protocol, Dir_num, self.sourceID_)
                else:
                    nifti_file = "%s_%s.nii"%(Protocol, self.sourceID_)
                #
                shutil.move( niftis[0], nifti_file )
            else:
                raise Exception( "No nifti was generated for %s in %s."%(Protocol, tempo_dir) )
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
    def zip_protocol_( self, Protocol, Directory, Unique ):
        """Convert dicoms to zip file function"""
        _log.info("%s sequence(s) found - zip sequence(s)"%(Protocol))
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
            zip_file = self.zip_DICOMs_(Protocol, Directory, dir_num) 
            #
            if not os.path.exists( zip_file ):
                raise Exception( "%s file does not exist."%zip_file )
            else:
                target_zip_file = os.path.join( self.R_path_, os.path.basename(zip_file) )
                shutil.move( zip_file, target_zip_file );
                self.protocols_[Protocol][1].append( target_zip_file )
                self.protocols_[Protocol][3].append( "%s %s"%(MAC.Utils().md5sum(target_zip_file),
                                                              target_zip_file) )
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
        """Convert dicoms to nifti file and dicoms zip function"""
        _log.info("%s sequence(s) found - process sequence(s)"%(Protocol))
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
            zip_file = self.zip_DICOMs_(Protocol, Directory, dir_num) 
            #
            if not os.path.exists( zip_file ):
                raise Exception( "%s file does not exist."%zip_file )
            else:
                target_zip_file = os.path.join( self.R_path_, os.path.basename(zip_file) )
                shutil.move( zip_file, target_zip_file );
                self.protocols_[Protocol][1].append( target_zip_file )
                self.protocols_[Protocol][3].append( "%s %s"%(MAC.Utils().md5sum(target_zip_file),
                                                              target_zip_file) )
        
            #
            # nifti file
            nifti_file = self.dcm2nii_protocol_(Protocol, Directory, dir_num)
            #
            if not os.path.exists( nifti_file ):
                raise Exception( "%s file does not exist."%nifti_file )
            else:
                target_niftii_file = os.path.join( self.R_path_, os.path.basename(nifti_file) )
                shutil.move( nifti_file, target_niftii_file );
                self.protocols_[Protocol][2].append( target_niftii_file )
                self.protocols_[Protocol][3].append( "%s %s"%(MAC.Utils().md5sum(target_niftii_file),
                                                              target_niftii_file) )
        
            #
            #
            return nifti_file
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
    def process_EPI_( self, Protocol, Directory, Unique, DCM_list = [] ):
        """Convert dicoms to nifti file and dicoms zip function using a list of DICOMs."""
        _log.info("%s sequence(s) found - process sequence(s)"%(Protocol))
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
            zip_file = self.zip_DICOMs_(Protocol, Directory, dir_num) 
            #
            if not os.path.exists( zip_file ):
                raise Exception( "%s file does not exist."%zip_file )
            else:
                target_zip_file = os.path.join( self.R_path_, os.path.basename(zip_file) )
                shutil.move( zip_file, target_zip_file );
                self.protocols_[Protocol][1].append( target_zip_file )
                self.protocols_[Protocol][3].append( "%s %s"%(MAC.Utils().md5sum(target_zip_file),
                                                              target_zip_file) )
        
            #
            # nifti only the dicom 1
            nifti_file = self.dcm2nii_protocol_(Protocol, Directory, dir_num )
            #
            if not os.path.exists( nifti_file ):
                raise Exception( "%s file does not exist."%nifti_file )
            else:
                target_niftii_file = os.path.join( self.R_path_, os.path.basename(nifti_file) )
                shutil.move( nifti_file, target_niftii_file );
                self.protocols_[Protocol][2].append( target_niftii_file )
                self.protocols_[Protocol][3].append( "%s %s"%(MAC.Utils().md5sum(target_niftii_file),
                                                              target_niftii_file) )
        
            #
            #
            return nifti_file
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
    def lava_access_( self, Project, Scan ):
        """KNECT API for LAVA queries. This function queries data from LAVA and create the PID_path where to save the data"""
        #
        try:
            #
            #
            self.study_ = Project
            self.PIDN_  = Scan[len(Project):]
            print self.study_, " ", self.PIDN_
            
            #
            # lava query 
            #

            #
            # Name of the patient
            inquiry_params = {'service_username':self.knect_username_, 'pidn':self.PIDN_}
            # load in json
            patient_lava = json.loads( niqc.get_patient(inquiry_params) )
            # name of the patient
            firstName = patient_lava["patient"]["firstName"]
            lastName  = patient_lava["patient"]["lastName"]
            # formating the name
            self.First_Name_ = "%s%s"%(firstName[0],firstName[1:].lower())
            self.Last_Name_  = "%s%s"%(lastName[0],lastName[1:].lower())

            #
            # PIDN block
            if self.PIDN_ < 10000.:
                self.PIDN_block_ = "%s000-%s999"%( self.PIDN_[0:1], self.PIDN_[0:1] )
            else:
                self.PIDN_block_ = "%s000-%s999"%( self.PIDN_[0:2], self.PIDN_[0:2] )
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
    def clean_tempdir_( self ):
        """Clean temporary (/tmp) area."""
        try:
            #
            #
            pass
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
        self.new_scans()
    #
    #
    #
    def manual( self, Scan ):
        self.manual_new_scans_(Scan)
