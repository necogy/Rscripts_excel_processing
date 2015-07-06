import logging
import json
import os, sys
#
import MAC_tools as MAC

_log = logging.getLogger("__Probe_new_scan__")

class Probe_new_scan( object ):
    """Setting for new scans check
    
    Attributes:
    """
    def __init__( self, Scans_dir ):
        """Return a new Probe_new_scan instance."""
        try:
            #
            #
            self.scans_dir_ = Scans_dir

            #
            # Scan status: Done, Running, Failed
            self.json_scan_status_ = "/home/quality/QC/scan_status.json"
            json_scan_status_file  = open( self.json_scan_status_ , 'r' )
            self.scan_status_      = json.load( json_scan_status_file )
            json_scan_status_file.close()

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
    def load_previous_scan_information_( self ):
        """Load JSON history of scan. The function load under a name directory items (key), the number of scans per protocol. This function let us know if a scan was already treated."""
        try:
            #
            # Load all experiments with PIDN and the scan dates in those folders
            list_exp = []
            #
            for experiment_PIDN in os.listdir( self.scans_dir_ ):
                if os.path.isdir( os.path.join(self.scans_dir_, experiment_PIDN) ):
                    for date in os.listdir( os.path.join(self.scans_dir_, experiment_PIDN) ):
                        list_exp.append( "%s/%s"%(experiment_PIDN, date) )

            #
            # For new scans set 'Copy_check' status to the scan
            for scan in list_exp:
                if scan not in self.scan_status_.keys():
                    self.scan_status_[scan] = "Copy_check"
            # Update the status of scans
            with open( self.json_scan_status_, 'w') as outfile:
                json.dump( self.scan_status_, outfile,
                           indent = 2, separators = (',',': '), sort_keys = True )
            outfile.close()
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
    def check_scans_directory_( self ):
        """Check the protocol."""
        try:
            #
            #
            for scan, status in self.scan_status_.iteritems():
                if status == "Copy_check":
                    new_scan = MAC.Scan_directory( os.path.join(self.scans_dir_, scan) )
                    new_scan.run()
                    # Update scan status
                    self.scan_status_[scan] = "New"
                    #
                    with open( self.json_scan_status_, 'w') as outfile:
                        json.dump( self.scan_status_, outfile,
                                   indent = 2, separators = (',',': '), sort_keys = True )
                    outfile.close()
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
    def run( self ):
        """Check the protocol."""
        try:
            #
            # Load new scans
            self.load_previous_scan_information_()

            #
            # Check for new scans
            self.check_scans_directory_()
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
       
