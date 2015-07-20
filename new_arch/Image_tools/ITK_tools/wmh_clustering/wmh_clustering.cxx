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
#include <itkMetaDataObject.h>
#include <itkMetaDataDictionary.h>

#include "itkImageRegionIteratorWithIndex.h"

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
      Mask::Pointer image_mask = reader_mask->GetOutput();
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
      // Dictionary
      typedef itk::MetaDataDictionary DictionaryType;
      typedef itk::MetaDataObject< std::string > MetaDataStringType;
      //
      DictionaryType& dictionary = image_tissue->GetMetaDataDictionary();
      // Print image header
      if ( true )
	{
	  DictionaryType::ConstIterator itr = dictionary.Begin();
	  while ( itr != dictionary.End() )
	    {
	      itk::MetaDataObjectBase::Pointer entry = itr->second;
	      MetaDataStringType::Pointer entryvalue = 
		dynamic_cast< MetaDataStringType *>( entry.GetPointer() );
	      std::string tagvalue = entryvalue->GetMetaDataObjectValue();
	      std::cout << "key=" << itr->first << " value=" << tagvalue << std::endl;
	      ++itr;
	    }
	}
      // dimension
      std::string s_dim_1 = (dynamic_cast< MetaDataStringType *>( dictionary["dim[1]"].GetPointer() ))->GetMetaDataObjectValue();
      std::string s_dim_2 = (dynamic_cast< MetaDataStringType *>( dictionary["dim[2]"].GetPointer() ))->GetMetaDataObjectValue();
      std::string s_dim_3 = (dynamic_cast< MetaDataStringType *>( dictionary["dim[3]"].GetPointer() ))->GetMetaDataObjectValue();
      // convert into integer
     int dim_1 = std::stoi( s_dim_1 );
     int dim_2 = std::stoi( s_dim_2 );
     int dim_3 = std::stoi( s_dim_3 );
      
      std::cout << dim_1 << std::endl;
      std::cout << dim_2 << std::endl;
      std::cout << dim_3 << std::endl;
      // srow
      std::string s_srow_x = (dynamic_cast< MetaDataStringType *>( dictionary["srow_x"].GetPointer() ))->GetMetaDataObjectValue();
      std::string s_srow_y = (dynamic_cast< MetaDataStringType *>( dictionary["srow_y"].GetPointer() ))->GetMetaDataObjectValue();
      std::string s_srow_z = (dynamic_cast< MetaDataStringType *>( dictionary["srow_z"].GetPointer() ))->GetMetaDataObjectValue();
      std::cout << s_srow_x << std::endl;
      std::cout << s_srow_y << std::endl;
      std::cout << s_srow_z << std::endl;

      // x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
      // y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
      // z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
      // 
      // -1 -0 0 78
      // -0 1 -0 -132
      // 0 0 1 -145


      //
      //
      //
      Proba::Pointer outputImage = Proba::New();
      outputImage->SetRegions( image_tissue->GetRequestedRegion() );
      outputImage->CopyInformation( image_tissue );
      outputImage->Allocate();

      itk::ImageRegionIteratorWithIndex< Proba > outputIt( outputImage, outputImage->GetRequestedRegion() );

      Proba::IndexType requestedIndex =
	outputImage->GetRequestedRegion().GetIndex();
      Proba::SizeType requestedSize =
	outputImage->GetRequestedRegion().GetSize();

      for ( outputIt.GoToBegin(); !outputIt.IsAtEnd(); ++outputIt )
	{
	  Proba::IndexType idx = outputIt.GetIndex();
	  if ( image_mask->GetPixel(idx)  == ROI || ROI == 0 )
	    {
	      double  x = -1 * idx[0] + 78.;
	      double  y = idx[1] - 132.;
	      double  z = idx[2] - 145;
	      std::cout << "[" << x << ", " << y << ", " << z << "] = " << image_tissue->GetPixel(idx)
			<< std::endl;
	      //std::cout << "Index: " << idx << std::endl;
	      //std::cout << "val at index: " << image_tissue->GetPixel(idx) << std::endl;
	    }
	  //idx[0] =  requestedIndex[0] + requestedSize[0] - 1 - idx[0];
	  //outputIt.Set( inputImage->GetPixel(idx) );
	}
      // Software Guide : EndCodeSnippet
      
//      WriterType::Pointer writer = WriterType::New();
//      writer->SetFileName( argv[2] );
//      writer->SetInput(outputImage);
//      try
//	{
//	  writer->Update();
//	}
//      catch ( itk::ExceptionObject &err)
//	{
//	  std::cout << "ExceptionObject caught !" << std::endl;
//	  std::cout << err << std::endl;
//	  return -1;


      //
      //
      //


      //
      itk::ImageRegionIterator<Proba> imageIterator_tissue( reader_tissue->GetOutput(),  region );
      itk::ImageRegionIterator<Mask>  imageIterator_mask( reader_mask->GetOutput(), region );
      //
      double tissue_volume = 0.;
//      while( !imageIterator_tissue.IsAtEnd() )
//	{
//	  if( static_cast<int>( imageIterator_mask.Value() ) == ROI || ROI == 0 )
//	    tissue_volume += imageIterator_tissue.Value();
//	  //
//	  ++imageIterator_tissue;
//	  ++imageIterator_mask;
//	}
      
      //
      //
      std::cout.precision(15);
      std::cout << 
	tissue_volume * tissue_proba->GetSpacing(0) * tissue_proba->GetSpacing(1) * tissue_proba->GetSpacing(2)
		<< std::endl;
    }
  
  //
  //
  return EXIT_SUCCESS;
}

