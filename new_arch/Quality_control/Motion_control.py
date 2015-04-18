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
    def __init__( self, Image_name_4D ):
        """Return a new Motion control instance."""
        super( Motion_control, self ).__init__( Image_name )
    #
    #
    def MC_flirt( self, Output_file ):
        """Create motion correction file. All the images are aligned on the first frame. RMS and plots are saved for further analysise."""
        try:
            #
            # Run FSL McFlirt on 4D image
            mcflt = fsl.MCFLIRT()
            mcflt.inputs.in_file    = self.image_
            mcflt.inputs.ref_vol    = 0
            mcflt.inputs.out_file   = Output_file
            mcflt.inputs.save_rms   = True
            mcflt.inputs.save_plots = True
            mcflt.runt()
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
    def good_for_research( self ):
        """Analyse the results."""
        try:
            #
            # Load the absolut motion
            RMS_abs = numpy.loadtxt("tempo_mcf_abs.rms")
            #
            mean_abs = numpy.mean(RMS, axis=0)
            std_abs  = numpy.std(RMS, axis=0)
            #
            quartile_abs_0  = numpy.percentile(RMS_abs, 0, axis=0)
            quartile_abs_25 = numpy.percentile(RMS_abs, 25, axis=0)
            quartile_abs_50 = numpy.percentile(RMS_abs, 50, axis=0)
            quartile_abs_75 = numpy.percentile(RMS_abs, 75, axis=0)
            # assert values


            #
            # Load the relative motion
            RMS_rel = numpy.loadtxt("tempo_mcf_rel.rms")
            #
            mean_rel = numpy.mean(RMS, axis=0)
            std_rel  = numpy.std(RMS, axis=0)
            #
            quartile_rel_0  = numpy.percentile(RMS_rel, 0, axis=0)
            quartile_rel_25 = numpy.percentile(RMS_rel, 25, axis=0)
            quartile_rel_50 = numpy.percentile(RMS_rel, 50, axis=0)
            quartile_rel_75 = numpy.percentile(RMS_rel, 75, axis=0)
            # assert values
          
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
