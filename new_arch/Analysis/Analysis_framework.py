import logging
import sys, os, shutil, datetime
import csv
import inspect
import threading, Queue, time
#
singlelock = threading.Lock()
#
#
#
_log = logging.getLogger("__Analysis_tools__")
#
#
#
import Arterial_Spin_Labeling
import Analysis_tools
#
#
#
class Production( object ):
    """ Common production analysis framework
    
    Description: This class will:
    1 - Extract images from Images directory and build a local copy.
    2 - Run a specific pipeline
    3 - 

    Example of CSV fiel
    PIDN, Diagnosis, DCDate,     AgeAtDC, InstrID, ScannerID,  SourceID, ProjName, ProjPercent,PIDN,DX
    1416, NORM (BV), 2010-09-07, 65,      179680,  NIC 3T MRI, GHB034-3, HILLBLOM, 100,,

    
    Attributes:
    csv_reader_:csv       - CSV reader
    procs_:int            - number of processors
    ignore_patterns_:list - list of reg-exp for files to ignore
    dir_base_:string      - origine of images
    queue_:Queue          - queue of process for the pool of threads
    prod_:Production      - pipeline 

    """
    def __init__( self, CSV_file, Procs = 8 ):
        """Return a new Protocol instance (constructor)."""
        try:
            #
            # public variables
            file_csv = open(CSV_file, 'rt')
            self.csv_reader_ = csv.reader( file_csv )
            #
            self.procs_           = Procs
            self.ignore_patterns_ = ()

            #
            # private variables
            self.dir_base_ = os.path.join(os.sep, 'mnt','macdata','projects','images')
            self.queue_    = Queue.Queue()
            #
            self.prod_     = ""
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
    def extrac_images_to( self, Directory ):
        """Extract images from the Images dierctory. This functionnality is not multi-threaded because of the unreliable connection with the R: drive."""
        try:
            #
            # Check if the directory exist
            if not os.path.exists( Directory ):
                os.mkdir( Directory )
            else:
                raise Exception( "The directory %s already exist. User should use another directory."%(Directory) )

            #
            # Extraction loop
            # creates CSV reader
            for row in self.csv_reader_:
                print "%s - %s - %s"%(row[0], row[2], row[6])
                if not "PIDN" in row[0]:
                    block = ""
                    if int(row[0]) < 10000.:
                        block = "%s000-%s999"%(row[0][0:1],row[0][0:1])
                    else:
                        block = "%s000-%s999"%(row[0][0:2],row[0][0:2])
                    #
                    dir = os.path.join(self.dir_base_, block, row[0], row[2])
                    if os.path.exists( dir ):
                        # create the local PIDN
                        if not os.path.exists( os.path.join( Directory, row[0]) ):
                            os.mkdir( os.path.join( Directory, row[0]) )
                        # create the scan date
                        if not os.path.exists( os.path.join( Directory, row[0], row[2]) ):
                            shutil.copytree( dir, os.path.join(Directory, row[0], row[2]), ignore=shutil.ignore_patterns( *self.ignore_patterns_ ) )
                    else:
                        _log.warning( "Patient missing: %s"%(row[0]) )
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
    def run_pipeline( self, Directory  ):
        """."""
        try:
            #
            # Reinitialize the queue
            self.queue_ =  Queue.Queue()
            # create the pool of threads
            for i in range( self.procs_ ):
                t = threading.Thread( target = self.run_ )
                t.daemon = True
                t.start()
            # Stack the items
            for row in self.csv_reader_:
                dir = os.path.join( Directory, row[0], row[2])
                if os.path.exists( dir ):
                    for patient in os.listdir( dir ):
                        if self.prod_ == "ASL":
                            self.queue_.put( [Arterial_Spin_Labeling.Protocol(),
                                              os.path.join(dir, patient)] )
                        else:
                            raise Exception( "Protocol %s is not yet implemented."%(self.prod_) )

            # block until all tasks are done
            self.queue_.join()
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


################################################################################
## 
## Image treatment pipeline -- Perfusion ASL -- 
## 
################################################################################

class Perfusion( Production ):
    """ This class runs the Arterial Spin Labeling (perfusion) pipeline.
    
    """
    #
    #
    def __init__( self,  CSV_file, Procs = 8 ):
        """Return a new Perfusion instance."""
        super( Perfusion, self ).__init__( CSV_file, Procs )
        # attribute
        # Production pipeline
        self.prod_ = "ASL"
        #
        self.production_failed_ = []

        #
        # VBM Cross-sectional
        #

        #
        #
        self.ana_res_ = ""
        # Lists for template construction and analyse
        self.GM_1_list_           = []
        self.CBF_GM_1_list_       = []
        self.CBF_1_list_          = []
        self.T1_1_list_           = []
        self.T1_brain_1_list_     = []
        self.T1_brain_map_1_list_ = []
    #
    #
    #
    def run_( self ):
        """Run the pipeline."""
        try:

            # 
            # Loop on the tasks
            while True:
                #
                # Strategy pipeline
                [asl, patient_dir] = self.queue_.get()
                asl.patient_dir_   = patient_dir
                asl.run()
                
                #
                # job is done
                self.queue_.task_done()
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
    def VBM_X_sectional( self, Directory, Study ):
        """Voxel based morphometry for cross-sectional analysis."""
        try:
            # 
            # 
            self.setup_space_(Directory, Study)
            #
            # Gray matter analysis
            self.VBM_X_GM_()
            #
            # Gray matter analysis
            self.VBM_X_T1_()
 
            #
            # Relaunch material
            #

            #
            # Check if some cases could be launch again
            self.production_failed_.sort()
            production_set = set( self.production_failed_ )
            #
            for case in production_set:
                print "%s "%case
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
    def setup_space_( self, Directory, Study ):
        """Voxel based morphometry for cross-sectional analysis."""
        try:

            # 
            # Date and log
            date  = []
            today = datetime.date.today()
            date.append(today)
            #
            # Create analysise of result directory
            if not os.path.exists( os.path.join( Directory, "ana_res-%s"%(date[0])) ):
                os.mkdir( os.path.join( Directory, "ana_res-%s"%(date[0])) )
            # 
            self.ana_res_ = os.path.join( Directory, "ana_res-%s"%(date[0]) )

            #
            #
            estimators        = {}
            production_failed = []
            for row in self.csv_reader_:
                if Study in row[1]:
                    #
                    # create estimators if PIDN does not exist
                    if not estimators.has_key(row[0]):
                        estimators[row[0]] = {}
                        # acquisition date list
                        acquisition_dates = []
                        estimators[row[0]]["dates"] = acquisition_dates
                        # GM list
                        acquisition_GM_T2 = []
                        estimators[row[0]]["GM_T2"] = acquisition_GM_T2
                        # CBF GM list
                        acquisition_CBF_GM_T2 = []
                        estimators[row[0]]["CBF_GM_T2"] = acquisition_CBF_GM_T2
                        # CBF registered T2 list
                        acquisition_CBF_T2 = []
                        estimators[row[0]]["CBF_T2"] = acquisition_CBF_T2
                        # T1 registered T2 list
                        acquisition_T1_T2 = []
                        estimators[row[0]]["T1_T2"] = acquisition_T1_T2
                        # T1 brain registered T2 list
                        acquisition_T1_brain_T2 = []
                        estimators[row[0]]["T1_brain_T2"] = acquisition_T1_brain_T2
                        # T1 brain registered T2 list
                        acquisition_T1_brain_map_T2 = []
                        estimators[row[0]]["T1_brain_map_T2"] = acquisition_T1_brain_map_T2
                    #
                    dir = os.path.join( Directory, row[0], row[2])

                    #
                    # Checks patient dir exit
                    if os.path.exists( dir ):
                        # record the date
                        estimators[row[0]]["dates"].append( row[2] )
                        # 
                        for patient in os.listdir( dir ):
                            # Checks production happened
                            patient_dir = os.path.join(dir, patient)
                            
                            # 
                            # Check the production happened
                            if os.path.exists( os.path.join(patient_dir, 
                                                            "ACPC_Alignment", "CBF.nii.gz") ):
                                #
                                # file - 1: gray matter registered T2
                                PVE = os.path.join(patient_dir, "PVE_Segmentation")
                                GM_T2 = ""
                                if os.path.exists( PVE ):
                                    for gm in os.listdir( PVE ):
                                        if gm.startswith("c1") and gm.endswith("T2.nii.gz"):
                                            GM_T2 = os.path.join(PVE, gm)
                                    #
                                    if os.path.exists( GM_T2 ):
                                        estimators[row[0]]["GM_T2"].append( GM_T2 ) 
                                    else:
                                        self.production_failed_.append( patient_dir )
                                        
                                #
                                # file - 2: CBF gray matter registered T2
                                CBF_GM_T2 = os.path.join(patient_dir, 
                                                         "ACPC_Alignment", "CBF_GM_T2.nii.gz")
                                if os.path.exists( CBF_GM_T2 ):
                                    estimators[row[0]]["CBF_GM_T2"].append( CBF_GM_T2 ) 
                                else:
                                    self.production_failed_.append( patient_dir )
                        
                                #
                                # file - 3: CBF registered T2
                                CBF_T2 = os.path.join(patient_dir, "ACPC_Alignment", "CBF_T2.nii.gz")
                                if os.path.exists( CBF_T2 ):
                                    estimators[row[0]]["CBF_T2"].append( CBF_T2 ) 
                                else:
                                    self.production_failed_.append( patient_dir )
                        
                                #
                                # file - 4: T1 registered T2
                                T1_T2 = ""
                                for f in os.listdir( PVE ):
                                    if f.startswith("m") and f.endswith("_T2.nii.gz"):
                                        T1_T2 = os.path.join( PVE, f )
                                #
                                if os.path.exists( T1_T2 ):
                                    estimators[row[0]]["T1_T2"].append( T1_T2 ) 
                                else:
                                    self.production_failed_.append( patient_dir )
                        
                                #
                                # file - 5: T1 brain map registered T2
                                T1_brain_map_T2 = os.path.join(PVE, "brain_map.nii.gz")
                                if os.path.exists( T1_brain_map_T2 ):
                                    estimators[row[0]]["T1_brain_map_T2"].append( T1_brain_map_T2 ) 
                                else:
                                    self.production_failed_.append( patient_dir )

                                #
                                # file - 6: T1 brain registered T2
                                T1_brain_T2 = os.path.join(PVE, "T1_brain.nii.gz")
                                #
                                if os.path.exists( T1_brain_T2 ):
                                    estimators[row[0]]["T1_brain_T2"].append( T1_brain_T2 ) 
                                else:
                                    self.production_failed_.append( patient_dir )
                           #
                            else:
                                self.production_failed_.append( patient_dir )

            #
            # Sort and unique the the gray matter list
            # Create the template based on th first time scan
            #

            #
            # Create destination directories 
            GM_dir           = os.path.join(self.ana_res_, "GM")
            CBF_GM_dir       = os.path.join(self.ana_res_, "CBF_GM")
            CBF_dir          = os.path.join(self.ana_res_, "CBF")
            T1_dir           = os.path.join(self.ana_res_, "T1")
            T1_brain_dir     = os.path.join(self.ana_res_, "T1_brain")
            T1_brain_map_dir = os.path.join(self.ana_res_, "T1_brain_map")
            #
            if not os.path.exists( GM_dir ):
                os.mkdir(GM_dir)
                os.mkdir(CBF_GM_dir)
                os.mkdir(CBF_dir)
                os.mkdir(T1_dir)
                os.mkdir(T1_brain_dir)
                os.mkdir(T1_brain_map_dir)
                #
                for PIDN in estimators:
                    # print PIDN
                    # check we have result
                    if len( estimators[PIDN]["CBF_GM_T2"] ) > 0:
                        #
                        # GM
                        # destination: GM_"PIDN"_"multiplicity"
                        dstname_GM = "GM_%s_%s.nii.gz"%(PIDN,"1")
                        shutil.copy( estimators[PIDN]["GM_T2"][0], 
                                     os.path.join(GM_dir, dstname_GM) )
                        #
                        self.GM_1_list_.append( dstname_GM )
                        #
                        # CBF GM
                        # destination: CBF_GM_"PIDN"_"multiplicity"
                        dstname_CBF_GM = "CBF_GM_%s_%s.nii.gz"%(PIDN,"1")
                        shutil.copy( estimators[PIDN]["CBF_GM_T2"][0], 
                                     os.path.join(CBF_GM_dir, dstname_CBF_GM) )
                        #
                        self.CBF_GM_1_list_.append( dstname_CBF_GM )
                        #
                        # CBF
                        # destination: CBF_"PIDN"_"multiplicity"
                        dstname_CBF = "CBF_%s_%s.nii.gz"%(PIDN,"1")
                        shutil.copy( estimators[PIDN]["CBF_T2"][0], 
                                     os.path.join(CBF_dir, dstname_CBF) )
                        #
                        self.CBF_1_list_.append( dstname_CBF )
                        #
                        # T1 registered T2
                        # destination: T1_"PIDN"_"multiplicity"
                        dstname_T1 = "T1_%s_%s.nii.gz"%(PIDN,"1")
                        shutil.copy( estimators[PIDN]["T1_T2"][0], 
                                     os.path.join(T1_dir, dstname_T1) )
                        #
                        self.T1_1_list_.append( dstname_T1 )
                        #
                        # T1 brain registered T2
                        # destination: T1_brain_"PIDN"_"multiplicity"
                        dstname_T1_brain = "T1_brain_%s_%s.nii.gz"%(PIDN,"1")
                        shutil.copy( estimators[PIDN]["T1_brain_T2"][0], 
                                     os.path.join(T1_brain_dir, dstname_T1_brain) )
                        #
                        self.T1_brain_1_list_.append( dstname_T1_brain )
                        #
                        # T1 brain map registered T2
                        # destination: T1_brain_map_"PIDN"_"multiplicity"
                        dstname_T1_brain_map = "T1_brain_map_%s_%s.nii.gz"%(PIDN,"1")
                        shutil.copy( estimators[PIDN]["T1_brain_map_T2"][0], 
                                     os.path.join(T1_brain_map_dir, dstname_T1_brain_map) )
                        #
                        self.T1_brain_map_1_list_.append( dstname_T1_brain_map )
            else:
                for PIDN in estimators:
                    # print PIDN
                    # check we have result
                    if len( estimators[PIDN]["CBF_GM_T2"] ) > 0:
                        # GM
                        # destination: GM_"PIDN"_"multiplicity"
                        self.GM_1_list_.append( "GM_%s_%s.nii.gz"%(PIDN,"1") )
                        # CBF GM
                        # destination: CBF_GM_"PIDN"_"multiplicity"
                        self.CBF_GM_1_list_.append( "CBF_GM_%s_%s.nii.gz"%(PIDN,"1") )
                        #
                        # CBF
                        # destination: CBF_"PIDN"_"multiplicity"
                        self.CBF_1_list_.append( "CBF_%s_%s.nii.gz"%(PIDN,"1") )
                        #
                        # T1 registered T2
                        # destination: T1_"PIDN"_"multiplicity"
                        self.T1_1_list_.append( "T1_%s_%s.nii.gz"%(PIDN,"1") )
                        #
                        # T1 brain registered T2
                        # destination: T1_brain_"PIDN"_"multiplicity"
                        self.T1_brain_1_list_.append( "T1_brain_%s_%s.nii.gz"%(PIDN,"1") )
                        #
                        # T1 brain map registered T2
                        # destination: T1_brain_map_"PIDN"_"multiplicity"
                        dstname_T1_brain_map = "T1_brain_map_%s_%s.nii.gz"%(PIDN,"1")
                        self.T1_brain_map_1_list_.append( "T1_brain_map_%s_%s.nii.gz"%(PIDN,"1") )
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
    def VBM_X_GM_( self ):
        """Voxel based morphometry for cross-sectional analysis."""
        try:
            # 
            # 
            template = Analysis_tools.Make_GM_template( "FSL", 
                                                        self.ana_res_, 
                                                        os.path.join( self.ana_res_, "GM" ), 
                                                        self.GM_1_list_,
                                                        self.procs_ )
            template.run()
            #
            # Warp the CBF maps
            template.warp_CBF_map( os.path.join( self.ana_res_, "CBF_GM"), 
                                   self.CBF_GM_1_list_ )
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
    def VBM_X_T1_( self ):
        """Voxel based morphometry for cross-sectional analysis."""
        try:

            # 
            # 
            template = Analysis_tools.Make_brain_template( "FSL", 
                                                           self.ana_res_, 
                                                           os.path.join(self.ana_res_, "T1_brain_dir"), 
                                                           self.T1_brain_1_list_,
                                                           os.path.join(self.ana_res_, "T1_dir"), 
                                                           self.T1_1_list_, 
                                                           self.procs_ )
            template.run()

            #
            # Warp the CBF maps and brain
            template.warp( os.path.join(self.ana_res_, "CBF_dir"), 
                           self.CBF_1_list_ )
            #
            template.modulation( os.path.join( self.ana_res_, "CBF_dir"), 
                                 self.CBF_1_list_ )
            # Warp the T1
            template.warp( os.path.join( self.ana_res_, "T1_brain_dir"), 
                           self.T1_brain_1_list_ )
            # Warp GM
            template.warp( os.path.join(self.ana_res_, "GM_dir"), 
                           self.GM_1_list_ )
            template.modulation( os.path.join(self.ana_res_, "GM_dir"), 
                                 self.GM_1_list_ )
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
