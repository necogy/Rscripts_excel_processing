cmake_minimum_required(VERSION 2.8)

project(tissue_volume)
 
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

add_executable(tissue_volume MACOSX_BUNDLE tissue_volume.cxx)
# cmake 3.1 target_compile_features(tissue_volume PRIVATE cxx_range_for)
target_link_libraries(tissue_volume 
  ${Glue}  ${VTK_LIBRARIES} ${ITK_LIBRARIES})
