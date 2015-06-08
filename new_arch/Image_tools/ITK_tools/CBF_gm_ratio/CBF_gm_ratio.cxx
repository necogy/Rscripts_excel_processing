#include <cstdlib>
#include <string>
#include <cstdlib>

#include <itkImage.h>
#include <itkImageFileReader.h>
#include <itkImageFileWriter.h>
#include <itkImageRegionIterator.h>
#include <itkNiftiImageIO.h>
#include <itkOrientImageFilter.h>
#include <itkSpatialOrientation.h>

itk::ImageIOBase::Pointer getImageIO(std::string input){
  itk::ImageIOBase::Pointer imageIO = itk::ImageIOFactory::CreateImageIO(input.c_str(), itk::ImageIOFactory::ReadMode);

  imageIO->SetFileName(input);
  imageIO->ReadImageInformation();

  return imageIO;
}

itk::ImageIOBase::IOComponentType component_type(itk::ImageIOBase::Pointer imageIO){
  return imageIO->GetComponentType();
}

itk::ImageIOBase::IOPixelType pixel_type(itk::ImageIOBase::Pointer imageIO){
  return imageIO->GetPixelType();
}

size_t num_dimensions(itk::ImageIOBase::Pointer imageIO){
  return imageIO->GetNumberOfDimensions();
}

float magnetization( const float Rho, 
		     const float T1, const float T2, 
		     const float TE, const float TR )
{
  return Rho * exp(- TE/T2) * ( 1 - exp(- TR/T1) );
}

int main(int argc, char const *argv[]){
  if( argc < 5 )
    {
      std::cerr << "gray_matter requires: <name> <rho_gm rho_wm rho_csf T1_gm T1_wm T1_csf T2_gm T2_wm T2_csf TE_gm TR_gm> c1 c2 c3 mask" << std::endl;
      return EXIT_FAILURE;
    }
//  char szOrbits[] = "365.24 29.53";
//  char* pEnd;
//  double d1, d2;
//  d1 = strtod (szOrbits, &pEnd);
//  d2 = strtod (pEnd, NULL);

  //
  // input float
  char* pEnd;
  float rho_gm  = strtof( argv[2], &pEnd );
  float rho_wm  = strtof( pEnd, &pEnd );
  float rho_csf = strtof( pEnd, &pEnd );
  //
  float T1_gm   = strtof( pEnd, &pEnd );
  float T1_wm   = strtof( pEnd, &pEnd );
  float T1_csf  = strtof( pEnd, &pEnd );
  //
  float T2_gm   = strtof( pEnd, &pEnd );
  float T2_wm   = strtof( pEnd, &pEnd );
  float T2_csf  = strtof( pEnd, &pEnd );
  //
  float TE      = strtof( pEnd, &pEnd );
  float TR      = strtof( pEnd, NULL );
  // input images                                          
  itk::ImageIOBase::Pointer GM_proba   = getImageIO( argv[3] );
  itk::ImageIOBase::Pointer WM_proba   = getImageIO( argv[4] );
  itk::ImageIOBase::Pointer CSF_proba  = getImageIO( argv[5] );
  itk::ImageIOBase::Pointer brain_mask = getImageIO( argv[6] );
  //
  // In order to read a image, we need its dimensionality and component type
  if ( false )
    {
      std::cout << "numDimensions: " << num_dimensions(GM_proba) << std::endl;
      std::cout << "component type: " 
		<< GM_proba->GetComponentTypeAsString(component_type(brain_mask)) << std::endl;
      // The pixel type is not necessary. This is just to let you know that it exists
      std::cout << "pixel type: " << GM_proba->GetPixelTypeAsString(pixel_type(GM_proba)) 
		<< std::endl;
      //
      std::cout << "rho_gm  :" << rho_gm  << std::endl;
      std::cout << "rho_wm  :" << rho_wm  << std::endl;
      std::cout << "rho_csf :" << rho_csf << std::endl;
      //	  
      std::cout << "T1_gm   :" << T1_gm   << std::endl;
      std::cout << "T1_wm   :" << T1_wm   << std::endl;
      std::cout << "T1_csf  :" << T1_csf  << std::endl;
      //	  
      std::cout << "T2_gm   :" << T2_gm   << std::endl;
      std::cout << "T2_wm   :" << T2_wm   << std::endl;
      std::cout << "T2_csf  :" << T2_csf  << std::endl;
      //	  
      std::cout << "TE      :" << TE      << std::endl;
      std::cout << "TR      :" << TR      << std::endl;

    }
  
  //
  //
  if ( num_dimensions(GM_proba) == 3 && component_type(GM_proba) == GM_proba->GetComponentTypeFromString("float") )
    {
      //
      // reader
      typedef itk::Image< float, 3 >         Proba;
      typedef itk::Image< unsigned char, 3 > Mask;
      //
      typedef itk::ImageFileReader< Proba > Reader;
      typedef itk::ImageFileReader< Mask >  Mask_reader;
      //
      // Mask
      Mask_reader::Pointer reader_mask = Mask_reader::New();
      reader_mask->SetFileName( brain_mask->GetFileName() );
      reader_mask->Update();
      //
      // Probabilities
      // GM
      Reader::Pointer reader_gm = Reader::New();
      reader_gm->SetFileName( GM_proba->GetFileName() );
      reader_gm->Update();
      // WM
      Reader::Pointer reader_wm = Reader::New();
      reader_wm->SetFileName( WM_proba->GetFileName() );
      reader_wm->Update();
      // CSF
      Reader::Pointer reader_csf = Reader::New();
      reader_csf->SetFileName( CSF_proba->GetFileName() );
      reader_csf->Update();
      // Output
      Reader::Pointer out = Reader::New();
      out->SetFileName( GM_proba->GetFileName() );
      out->Update();

      //
      // Create a new image
      Proba::RegionType region;
      //
      Proba::Pointer   image_gm = reader_gm->GetOutput();
      Proba::SizeType  img_size = image_gm->GetLargestPossibleRegion().GetSize();
      Proba::IndexType start    = {0, 0, 0};
      //
      region.SetSize( img_size );
      region.SetIndex( start );
      //
      // 
      // Proba::Pointer out = Proba::New();
      Proba::Pointer image_out = out->GetOutput();
      image_out->SetRegions( region );
      image_out->Allocate();
      //
      itk::ImageRegionIterator<Proba> imageIterator_gm( reader_gm->GetOutput(),  region );
      itk::ImageRegionIterator<Proba> imageIterator_wm( reader_wm->GetOutput(),  region );
      itk::ImageRegionIterator<Proba> imageIterator_csf( reader_csf->GetOutput(), region );
      //
      itk::ImageRegionIterator<Mask> imageIterator_mask( reader_mask->GetOutput(), region );
      //
      float Mgm  = magnetization( rho_gm,  T1_gm,  T2_gm,  TE, TR );
      float Mwm  = magnetization( rho_wm,  T1_wm,  T2_wm,  TE, TR );
      float Mcsf = magnetization( rho_csf, T1_csf, T2_csf, TE, TR );
      //
      while( !imageIterator_gm.IsAtEnd() )
	{
	  if( static_cast<int>( imageIterator_mask.Value() ) != 0 )
	    {
	      //
	      // Gray matter partiel volume
	      float PV_gm = imageIterator_gm.Value();
	      // denominator
	      float delta_m_factor = PV_gm + 0.4 * imageIterator_wm.Value();
	      //
	      float value = PV_gm;
	      value += imageIterator_wm.Value()  * Mwm / Mgm;
	      value += imageIterator_csf.Value() * Mcsf / Mgm;
	      // In the article GM is cut below 30% of ots value
	      image_out->SetPixel( imageIterator_gm.GetIndex(), 
				   (PV_gm > 0.2 ? value / delta_m_factor : 0.) );
	    }
	  else
	    image_out->SetPixel( imageIterator_gm.GetIndex(), 0. );
	  //
	  ++imageIterator_gm;
	  ++imageIterator_wm;
	  ++imageIterator_csf;
	  ++imageIterator_mask;
	}

      //
      // Writer
      itk::NiftiImageIO::Pointer nifti_io = itk::NiftiImageIO::New();
      nifti_io->SetPixelType( pixel_type(GM_proba) );
      //
      itk::ImageFileWriter<Proba>::Pointer writer = itk::ImageFileWriter<Proba>::New();
      writer->SetFileName( argv[1] );
      writer->SetInput( image_out/*orienter->GetOutput()*/ );
      writer->SetImageIO( nifti_io );
      writer->Update();
    }
  
  //
  //
  return EXIT_SUCCESS;
}

