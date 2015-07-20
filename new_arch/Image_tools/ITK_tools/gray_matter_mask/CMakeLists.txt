cmake_minimum_required(VERSION 2.8)
 
project(gray_matter_mask)
 
if(CMAKE_COMPILER_IS_GNUCXX)
  add_definitions(-std=c++11)
endif()

find_package(ITK REQUIRED)
include(${ITK_USE_FILE})
if (ITKVtkGlue_LOADED)
  find_package(VTK REQUIRED)
  include(${VTK_USE_FILE})
else()
  find_package(ItkVtkGlue REQUIRED)
  include(${ItkVtkGlue_USE_FILE})
  set(Glue ItkVtkGlue)
endif()

add_executable(gray_matter_mask MACOSX_BUNDLE gray_matter_mask.cxx)
target_link_libraries(gray_matter_mask 
  ${Glue}  ${VTK_LIBRARIES} ${ITK_LIBRARIES})
