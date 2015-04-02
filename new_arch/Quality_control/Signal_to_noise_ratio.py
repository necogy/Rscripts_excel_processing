import logging
import numpy
import Quality_control

_log = logging.getLogger("__Signal_to_noise_ratio__")

class Signal_to_noise_ratio( Quality_control.Quality_control ):
    """Signal-to-noise ratio (SNR) calculation.
    
    Attributes:
    Rayleigh_:double   - Rayleigh threashold. If the ration of (Mean/Sd)_{background} > Rayleigh_, the background does not follow a Rayleigh distribution and we can't use:

    SNR_{sd} = \fract{\mu_{signal}}{1.52 * \sigma_{background}}

    """
    #
    #
    def __init__( self, Image_name ):
        """Return a new Signal to noise ratio instance."""
        super( Signal_to_noise_ratio, self ).__init__( Image_name )
        
        self.Rayleigh_         = 1.91
        self.mean_signal_      = 0.
        self.mean_background_  = 0.
        self.sigma_background_ = 0.


    #
    #
    def average_signal_( self ):
        """Average signal caculates the mean signal over the brain area."""
        try:
            count   = 0
            # for index = (i,j,k), value in numpy.ndenumerate( self.brain_.data ):
            for index, value in numpy.ndenumerate( self.brain_.data ):
                if self.brain_mask_.data[index] == 1:
                    self.mean_signal_ += self.brain_.data[index]
                    count   += 1
            #
            if count != 0:
                self.mean_signal_ /= count
            else:
                raise Exception( "Problem with the count of voxels.")

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
    def roi_selection_( self ):
        """Region of interest function calculates the background signal within four regions and estimates the standard deviation of the signal in those region."""
        try:
            # sform
            #     [ 0.,  0.,  1.]
            # R = [ 1.,  0.,  0.]
            #     [ 0.,  1.,  0.]
            #
            # Please notice the order in which the dimensions are specified: (t, z, y, x).
            # (i,j,k) = (1,2,3) => R(i,j,k) = (k,i,j) = (3,1,2)
            (X, Y, Z)                = abs(self.image_.header['sform'][0:3,0:3]).round().dot((1,2,3))
            (X_data, Y_data, Z_data) = abs(self.image_.header['sform'][0:3,0:3]).round().dot((3,2,1))
        
            #
            # Regions of interest
            #
            box_size = 10
            # ROI selection
            roi_selection = [
                {
                    X_data: slice( 0, box_size ),
                    Y_data: slice( 0, box_size ),
                    Z_data: slice( self.image_.header['dim'][int(Z)] - 20, self.image_.header['dim'][int(Z)] )
                },
                #
                {
                    X_data: slice( self.image_.header['dim'][int(X)] - box_size, self.image_.header['dim'][int(X)] ),
                    Y_data: slice( 0, box_size ),
                    Z_data: slice( self.image_.header['dim'][int(Z)] - 20, self.image_.header['dim'][int(Z)] )
                },
                #
                {
                    X_data: slice( 0, box_size ),
                    Y_data: slice( self.image_.header['dim'][int(Y)] - box_size, self.image_.header['dim'][int(Y)] ),
                    Z_data: slice( self.image_.header['dim'][int(Z)] - 20, self.image_.header['dim'][int(Z)] )
                },
                #
                {
                    X_data: slice( self.image_.header['dim'][int(X)] - box_size, self.image_.header['dim'][int(X)] ),
                    Y_data: slice( self.image_.header['dim'][int(Y)] - box_size, self.image_.header['dim'][int(Y)] ),
                    Z_data: slice( self.image_.header['dim'][int(Z)] - 20, self.image_.header['dim'][int(Z)] )
                } ]
            #
            # ROI
            #self.image_.data[ roi_selection[0][1], roi_selection[0][2], roi_selection[0][3]] = 1000
            #self.image_.data[ roi_selection[1][1], roi_selection[1][2], roi_selection[1][3]] = 1000
            #self.image_.data[ roi_selection[2][1], roi_selection[2][2], roi_selection[2][3]] = 1000
            #self.image_.data[ roi_selection[3][1], roi_selection[3][2], roi_selection[3][3]] = 1000

            self.mean_background_ = self.image_.data[ roi_selection[0][1], roi_selection[0][2], roi_selection[0][3]].mean()
            self.sigma_background_ =  self.image_.data[ roi_selection[0][1], roi_selection[0][2], roi_selection[0][3]].std()

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
    def process( self ):
        """Process fuction calculates the signal-to-noise ratio."""
        try:
            if self.mean_background_ / self.sigma_background_ < self.Rayleigh_:
                return self.mean_signal_  / (1.52 * self.sigma_background_ )
            else:
                 _log.warning("The background should not be calculated following Rayleigh's law.")
                 return -1
            
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
