import logging
import sys, os, shutil
import csv
import inspect
import threading, Queue, time
singlelock = threading.Lock()
#
#
#
_log = logging.getLogger("__Analysis_tools__")
#
#
#
import Arterial_Spin_Labeling
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

    """
    def __init__( self, CSV_file, Procs = 8 ):
        """Return a new Protocol instance (constructor)."""
        try:
            #
            # public variables
            file_csv = open(CSV_file, 'rt')
            self.csv_reader_ = csv.reader( file_csv )
            #file_csv.close()
            #
            self.procs_           = Procs
            self.ignore_patterns_ = ()

            #
            # private variables
            self.dir_base_ = os.path.join(os.sep, 'mnt','macdata','projects','images')
            self.queue_    = Queue.Queue()

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
            pass
            if not os.path.exists( self.dir_base_ ):
                raise Exception( "User must mount R: drive, or directory %s not found." 
                                 %self.dir_base_ )
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
                        self.queue_.put( os.path.join(dir, patient) )
            # block until all tasks are done
            self.queue_.join()
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


################################################################################
## 
## Image treatment pipeline
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
        # public attribute
        #
        self.check_environment()
        #
        #self.asl_ = []
    #
    #
    #
    def run_( self ):
        """."""
        #        try:
        #
        # 
        # Loop on the tasks
        while True:
            #
            # Strategy pipeline
            singlelock.acquire()
            time.sleep(1) # give some time to start rhe program on the good count
            self.asl_.append( Arterial_Spin_Labeling.Protocol() )
            count = len( self.asl_ ) - 1
            self.asl_[count].patient_dir_ = self.queue_.get()
            
            #print "count in", count
            singlelock.release()
            #
            self.asl_[count].run()
            
            #
            # lock and add the file
#            singlelock.acquire()
#            print "pass 3"
#            _log.debug( "Item %s treated."%(item) )
#            singlelock.release()
            # job is done
            self.queue_.task_done()
#        #
#        #
#        except Exception as inst:
#            print inst
#            _log.error(inst)
#            #quit(-1)
#        except IOError as e:
#            print "I/O error({0}): {1}".format(e.errno, e.strerror)
#            #quit(-1)
#        except:
#            print "Unexpected error:", sys.exc_info()[0]
#            #quit(-1)


################################################################################
## 
## Specific Image treatment
## 
################################################################################
