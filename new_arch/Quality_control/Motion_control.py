import logging
import numpy
import Quality_control
import nipype
import nipype.interfaces.fsl as fsl


_log = logging.getLogger("__Motion_control__")

class Motion_control( Quality_control.Quality_control ):
    """Motion control estimation.
    
    Attributes:
    

    """
    #
    #
    def __init__( self, Image_name ):
        """Return a new Motion control instance."""
        super( Motion_control, self ).__init__( Image_name )
    #
    #
    def MC_flirt( self, Output_file, Threshold_rel = 0.2 ):
        """Create motion correction file. All the images are aligned on the first frame. RMS and plots are saved for further analysise."""
        try:
            #
            # Run FSL McFlirt on 4D image
            mcflt = fsl.MCFLIRT()
            mcflt.inputs.in_file    = self.image_.filename
            mcflt.inputs.ref_vol    = 0
            mcflt.inputs.out_file   = Output_file
            mcflt.inputs.save_rms   = True
            mcflt.inputs.save_plots = True
            mcflt.run()

            #
            # Load the absolut motion
            RMS_abs      = numpy.loadtxt("%s_abs.rms"%(Output_file))
            #
            # maximum drift from 
            max_abs  = numpy.max(RMS_abs, axis=0)
            mean_abs = numpy.mean(RMS_abs, axis=0)
            std_abs  = numpy.std(RMS_abs, axis=0)
            #
            quartile_abs_0  = numpy.percentile(RMS_abs, 0, axis=0)
            quartile_abs_25 = numpy.percentile(RMS_abs, 25, axis=0)
            quartile_abs_50 = numpy.percentile(RMS_abs, 50, axis=0)
            quartile_abs_75 = numpy.percentile(RMS_abs, 75, axis=0)

            #
            # assert values:
            # Max drifting value
            if max_abs > 1: #mm
                message = "Maximum motion from the reference image has been reached at least by one frame of \n %s"% self.image_.filename
                _log.warning(message)
            # If absolut motion  sup than 1mm -> Warning
            # If absolut average sup than 1mm -> Warning
            
            #
            # Load the relative motion
            RMS_rel = numpy.loadtxt("%s_rel.rms"%(Output_file))
            #
            mean_rel = numpy.mean(RMS_rel, axis=0)
            std_rel  = numpy.std(RMS_rel, axis=0)
            #
            quartile_rel_0  = numpy.percentile(RMS_rel, 0, axis=0)
            quartile_rel_25 = numpy.percentile(RMS_rel, 25, axis=0)
            quartile_rel_50 = numpy.percentile(RMS_rel, 50, axis=0)
            quartile_rel_75 = numpy.percentile(RMS_rel, 75, axis=0)
            
            #
            # assert values
            # If relative motion third quantile sup than 0.5mm -> Error
            if quartile_rel_75 > 0.5:
                raise Exception("Relative motion is too high (> 0.5mm) in file: \n %s"%self.image_.filename)            
            # If relative motion third quantile sup than 0.15mm -> Warning
            elif quartile_rel_75 > 0.15:
                message = "Check the relative motion in \n %s"% self.image_.filename
                _log.warning(message)

            # If relative motion third quantile sup than 0.15mm -> Warning
            # Check how many outliers
         
            #
            #
            return True
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
