import dicom
import logging
import json
import os
from pprint import pprint

_log = logging.getLogger("__Probe_DICOM__")

class Probe_DICOM( object ):
    """A Protocol setting
    
    Attributes:
    protocol_name_:string - name of the protocol
    dicom_:dicom          - dicom file to check against the protocol
    json_data_:json       - protocol as json file
    """
    def __init__( self, Protocol_name, Acuisition, Dicom ):
        """Return a new Probe_DICOM instance."""
        try:
            self.protocol_name_ = Protocol_name
            self.dicom_         = ""
            self.json_data_     = ""

            #
            # Check if the protocol exists as a JSON file
            protocol         = "%s.json"%(self.protocol_name_)
            protocol_present = False
            for json_file in os.listdir( os.path.join(os.getcwd(), "Quality_control", "JSON") ):
                if json_file in protocol:
                    protocol_present = True
            #
            if protocol_present:
                json_file = open( os.path.join(os.getcwd(), "Quality_control", "JSON", protocol), "r" )
                self.json_data_ = json.load(json_file)
                json_file.close()

            #
            # Load the DICOM
            self.dicom_ = dicom.read_file( Dicom )

        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)


    def check_protocol( self ):
        """Check the protocol."""
        try:
            #
            #
            #print "NumberOfSlices %s"%(self.dicom_.NumberOfSlices)
            print "SliceThickness %s"%(self.dicom_.SliceThickness)
            print "RepetitionTime %s"%(self.dicom_.RepetitionTime)
            print "EchoTime %s"%(self.dicom_.EchoTime)
            print "FlipAngle %s"%(self.dicom_.FlipAngle)
            print "StudyDate %s"%(self.dicom_.StudyDate)
            print "SeriesNo %s"%(self.dicom_.SeriesNumber)
            print "ProtocolName %s"%(self.dicom_.ProtocolName)
            print "ScannerModel %s"%(self.dicom_.ManufacturersModelName)
            #print "InversionTime %s"%(self.dicom_.InversionTime)
            #print "InversionTimes %s"%(self.dicom_.InversionTimes)

        except Exception as inst:
            _log.error(inst)
            quit(-1)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            quit(-1)
        except:
            print "Unexpected error:", sys.exc_info()[0]
            quit(-1)
       
