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
            #
            pass
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
            for scan in os.listdir( self.scans_dir_ ):
                new_scan = MAC.Scan_directory( os.path.join(self.scans_dir_, scan) )
                new_scan.run()
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
       
