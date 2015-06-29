cmake_minimum_required(VERSION 2.8)
 
project(CBF_gm_ratio)
 
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

add_executable(CBF_gm_ratio MACOSX_BUNDLE CBF_gm_ratio.cxx)
target_link_libraries(CBF_gm_ratio 
  ${Glue}  ${VTK_LIBRARIES} ${ITK_LIBRARIES})
