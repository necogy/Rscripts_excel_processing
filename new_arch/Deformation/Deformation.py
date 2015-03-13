import logging

_log = logging.getLogger("__Deformation__")

class Deformation( object ):
    """A deformation mother class. This class is a super class for registration and distortion correction.
    
    Attributes:
    setup_:map            - mapping of the setup
    """
    def __init__( self ):
        """Return a new Protocol instance."""
        self.setup_ = {'gallahad': 'the pure', 'robin': 'the brave'}
