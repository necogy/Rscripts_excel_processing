import logging
import json
import os, sys
from functools import partial
import hashlib
import time


_log = logging.getLogger("__MAC_tools__")


##
#
# MAC utils. Functions used as stand alone.
#
##
class Utils( object ):
    """."""
    def __init__( self ):
        """."""
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
    def md5sum(self, File_name ):
        """Calculate the md5sum signature for a target file"""
        with open(File_name, mode='rb') as f:
            d = hashlib.md5()
            for buf in iter(partial(f.read, 128), b''):
                d.update(buf)
            return d.hexdigest()
##
#
# Scan directory
#
##
class Scan_directory( object ):
    """
    
    Attributes:
      sub_dir_to_protocols_:string     - directory of a new scan
      protocols_dir_:List              - list of protocol directories
      protocols_container_: dictionary - for each protocol: list of tuple {DICOM:MD5_signature}
    """
    def __init__( self, Scan ):
        """."""
        try:
            #
            #
            self.new_scan_ = Scan
            #
            self.sub_dir_to_protocols_ = Scan
            self.protocols_dir_        = []
            self.protocols_container_  = {}
            
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
    def load_directory( self ):
        """Check the protocol."""
        try:
            #
            # return containers
            sub_dir_to_protocols = ""
            protocols_dir        = []
            protocols_container  = {}

            #
            #
            for root, subdirs, files in os.walk( self.new_scan_ ):
                # take all the subdirectory to the protocols directory
                if len( files ) is 0 and len( subdirs ) is 1:
                    sub_dir_to_protocols = os.path.join( sub_dir_to_protocols, subdirs[0] )
                # in the protocols directory: record all protocols
                elif len( files ) is 0 and len( subdirs ) is not 1:
                    protocols_dir = subdirs
                # For each protocol record all the DICOMs
                else:
                    tuple_dicom_md = {}
                    for dicom in files:
                        tuple_dicom_md[ dicom ] = Utils().md5sum( os.path.join(root,dicom) )
                    #
                    protocols_container[os.path.join(os.sep, root)] = tuple_dicom_md
                        
            #
            #
            print self.new_scan_
            return ( sub_dir_to_protocols, protocols_dir, protocols_container )
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
            # Walk through the directory structure of a new scan
            ( sub_dir_to_protocols_1, protocols_dir_1, protocols_container_1 ) = self.load_directory()

            #
            # While the copy is not done: loop over the files
            copy_not_done = True
            #
            while copy_not_done:
                #
                # Wait a bit
#                time.sleep( 5*60 )
                time.sleep( 0 )
                # retrive all scan files information
                ( sub_dir_to_protocols_2, protocols_dir_2, protocols_container_2 ) = self.load_directory()
                
                #
                # Check if we have the same number of directories between the two checks
                if len( protocols_dir_2 ) != len( protocols_dir_1 ):
                    _log.debug( "Number of protocols in protocols_dir_{1,2} not yet the same." )
                    print "Number of protocols in protocols_dir_{1,2} not yet the same."
                    # copy is not done 
                    copy_not_done = True
                    # update the first containers
                    ( sub_dir_to_protocols_1, 
                      protocols_dir_1, 
                      protocols_container_1 ) = ( sub_dir_to_protocols_2, 
                                                  protocols_dir_2, 
                                                  protocols_container_2 )
                else:
                    #
                    # Two 'for' loop embeded: break_loops will stop the second loop
                    # Here we have the same number of directoies in protocols_dir_{1,2}
                    break_loops = False
                    for protocol in protocols_container_2:
                        if not break_loops:
                            for (scan, md5) in protocols_container_2[ protocol ].iteritems():
                                # Check if protocols_container_1 has the same number of DICOMs
                                if scan not in protocols_container_1[protocol].keys():
                                    _log.debug( "scan %s is not in contenairs"%(scan) )
                                    # scan does not exist in the first contenair
                                    # break all the loops
                                    break_loops = True
                                    #
                                    break
                                # Check if all the DICOMs have the same signature
                                elif md5 != protocols_container_1[protocol][scan]:
                                    _log.debug( "signature of %s changed"%(scan) )
                                    # File signature has changed
                                    # break all the loops
                                    break_loops = True
                                    #
                                    break
                                # everything seems going fine
                                else:
                                    # copy is done
                                    copy_not_done = False
                        else:
                            # copy is not done 
                            ( sub_dir_to_protocols_1, 
                              protocols_dir_1, 
                              protocols_container_1 ) = ( sub_dir_to_protocols_2, 
                                                          protocols_dir_2, 
                                                          protocols_container_2 )
                            #
                            copy_not_done = True
                            #
                            _log.warning( "Copy of %s is not yet achieved!"%(self.new_scan_) )
 
            #
            # We can attribute the containers in privat members
            ( self.sub_dir_to_protocols_, 
              self.protocols_dir_, 
              self.protocols_container_ ) = ( sub_dir_to_protocols_1, 
                                              protocols_dir_1, 
                                              protocols_container_1 )
            #
            #
            _log.info( "Copy of %s is done."%(self.new_scan_) )
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
       
