import numpy
import Quality_control

class Signal_to_noise_ratio( Quality_control.Quality_control ):
    """Signal-to-noise ratio (SNR) calculation.
    
    Attributes:
    image_:Super:NiftiImage   - image data
    setup_:map                - mapping of the setup
    """
    def __init__( self, Image_name ):
        """Return a new Signal to noise ratio instance."""
        super( Signal_to_noise_ratio, self ).__init__( Image_name )

    def average_signal_( self ):
        average = 0
        count   = 0
        # for index = (i,j,k), value in numpy.ndenumerate( self.brain_.data ):
        for index, value in numpy.ndenumerate( self.brain_.data ):
            if self.brain_mask_.data[index] == 1:
                average += self.brain_.data[index]
                count   += 1
        #
        if count != 0:
            average /= count
            print average
        else:
            print "Problem with the count"

    def roi_selection_( self ):
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

        average = self.image_.data[ roi_selection[0][1], roi_selection[0][2], roi_selection[0][3]].mean()
        std =  self.image_.data[ roi_selection[0][1], roi_selection[0][2], roi_selection[0][3]].std()
        print average
        print std

