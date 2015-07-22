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

int main(int argc, char const *argv[]){
  //
  // 
  itk::ImageIOBase::Pointer tissue_proba = NULL;
  itk::ImageIOBase::Pointer mask         = NULL;
  // Region of interest
  int ROI = 0;

  //
  //
  if( argc == 2 )
    {
      tissue_proba = getImageIO( argv[1] );
    }
  else if( argc == 3 )
    {
      tissue_proba = getImageIO( argv[1] );
      mask         = getImageIO( argv[2] );
    }
  else if( argc == 4 )
    {
      tissue_proba = getImageIO( argv[1] );
      mask         = getImageIO( argv[2] );
      ROI = std::stoi( argv[3] );
    }
  else
    {
      std::cerr << "tissue_volume requires: c1 <mask> <ROI>" << std::endl;
      return EXIT_FAILURE;
    }
  
  //
  // In order to read a image, we need its dimensionality and component type
  if ( false )
    {

      std::cout << "numDimensions: " << num_dimensions( tissue_proba ) << std::endl;
      std::cout << "component type: " 
		<< tissue_proba->GetComponentTypeAsString( component_type(tissue_proba) ) << std::endl;
      // The pixel type is not necessary. This is just to let you know that it exists
      std::cout << "pixel type: " << tissue_proba->GetPixelTypeAsString( pixel_type(tissue_proba) ) 
		<< std::endl;
      //
      std::cout << "pixel size 0: " << tissue_proba->GetSpacing(0) << std::endl;
      std::cout << "pixel size 1: " << tissue_proba->GetSpacing(1) << std::endl;
      std::cout << "pixel size 2: " << tissue_proba->GetSpacing(2) << std::endl;
      std::cout << tissue_proba << std::endl;
      //
      std::cout << "arg 1: " << argv[1] << std::endl;
      std::cout << "arg 2: " << argv[2] << std::endl;
      std::cout << "arg 3: " << ROI << std::endl;
    }
  
  //
  //
  if ( num_dimensions(tissue_proba) == 3 && component_type(tissue_proba) == tissue_proba->GetComponentTypeFromString("float") )
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
      reader_mask->SetFileName( mask->GetFileName() );
      reader_mask->Update();
      //
      // Tissue probability
      Reader::Pointer reader_tissue = Reader::New();
      reader_tissue->SetFileName( tissue_proba->GetFileName() );
      reader_tissue->Update();

      //
      // Region to explore
      Proba::RegionType region;
      //
      Proba::Pointer   image_tissue = reader_tissue->GetOutput();
      Proba::SizeType  img_size = image_tissue->GetLargestPossibleRegion().GetSize();
      Proba::IndexType start    = {0, 0, 0};
      //
      region.SetSize( img_size );
      region.SetIndex( start );
      //
      itk::ImageRegionIterator<Proba> imageIterator_tissue( reader_tissue->GetOutput(),  region );
      itk::ImageRegionIterator<Mask>  imageIterator_mask( reader_mask->GetOutput(), region );
      //
      double tissue_volume  = 0.;
      int    num_voxels_ROI = 0;
      while( !imageIterator_tissue.IsAtEnd() )
	{
	  if( static_cast<int>( imageIterator_mask.Value() ) == ROI || ROI == 0 )
	    if ( imageIterator_tissue.Value() > 0. )
	      {
		//std::cout << imageIterator_tissue.Value() << std::endl;
		tissue_volume += imageIterator_tissue.Value();
		num_voxels_ROI++;
	      }
	  //
	  ++imageIterator_tissue;
	  ++imageIterator_mask;
	}
      
      //
      //
      std::cout.precision(15);
      std::cout << tissue_volume 
		<< " " 
		<< tissue_proba->GetSpacing(0) * tissue_proba->GetSpacing(1) * tissue_proba->GetSpacing(2)
		<< " " 
		<< num_voxels_ROI
		<< std::endl;
    }
  
  //
  //
  return EXIT_SUCCESS;
}

