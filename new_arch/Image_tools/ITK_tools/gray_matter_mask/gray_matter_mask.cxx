//#include "QuickView.h"

#include <cstdlib>
#include <string>

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

int main(int argc, char const *argv[]){
  if( argc < 5 )
    {
      std::cerr << "gray_matter requires: <name> c1 c2 c3 mask" << std::endl;
      return EXIT_FAILURE;
    }

  //
  // input images                                         
  itk::ImageIOBase::Pointer GM_proba   = getImageIO( argv[2] );
  itk::ImageIOBase::Pointer WM_proba   = getImageIO( argv[3] );
  itk::ImageIOBase::Pointer CSF_proba  = getImageIO( argv[4] );
  itk::ImageIOBase::Pointer brain_mask = getImageIO( argv[5] );
  //
  // In order to read a image, we need its dimensionality and component type
  std::cout << "numDimensions: " << num_dimensions(GM_proba) << std::endl;
  std::cout << "component type: " << GM_proba->GetComponentTypeAsString(component_type(brain_mask)) << std::endl;
  // The pixel type is not necessary. This is just to let you know that it exists
  std::cout << "pixel type: " << GM_proba->GetPixelTypeAsString(pixel_type(GM_proba)) << std::endl;
  
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
      while( !imageIterator_gm.IsAtEnd() )
	{
	  if( static_cast<int>( imageIterator_mask.Value() ) != 0 )
	    if( imageIterator_gm.Value() > imageIterator_wm.Value() && 
		imageIterator_gm.Value() > imageIterator_csf.Value() )
	      image_out->SetPixel( imageIterator_gm.GetIndex(), 1. );
	    else
	      image_out->SetPixel( imageIterator_gm.GetIndex(), 0. );
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

