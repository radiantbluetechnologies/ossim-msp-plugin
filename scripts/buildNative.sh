#!/bin/bash
#################################################################
#
# Script to build the ossim-msp-plugin library and dedicated 
# native application.
#
# The build environment must have the following variables defined 
# (in addition to other OSSIM requirements):
#
#     OSSIM_INSTALL_PREFIX or OSSIM_DEV_HOME
#     MSP_HOME or CSM_HOME
#     OPENCV_HOME
#
# OSSIM_DEV_HOME is used for cases where the build is being 
# done in a development environment.

#################################################################

# Uncomment following line to debug script line by line:
#set -x; trap read debug

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
pushd $SCRIPT_DIR/.. >/dev/null
export CMAKE_DIR=$PWD
popd >/dev/null

mkdir -p $CMAKE_DIR/build
pushd $CMAKE_DIR/build

if [ -n "$OSSIM_INSTALL_PREFIX" ]; then
   echo "27"
   CMAKE_MODULE_PATH=$OSSIM_INSTALL_PREFIX/share/ossim/CMakeModules
elif [ -n "$OSSIM_DEV_HOME" ]; then
   echo "30"
   CMAKE_MODULE_PATH=$OSSIM_DEV_HOME/ossim/cmake/CMakeModules
else
  echo "ERROR: Must have either OSSIM_INSTALL_PREFIX or OSSIM_DEV_HOME defined. Cannot continue."
  popd; exit 1
fi

echo "buildNative.sh: "
echo "  OSSIM_DEV_HOME       = $OSSIM_DEV_HOME"
echo "  OSSIM_INSTALL_PREFIX = $OSSIM_INSTALL_PREFIX"
echo "  MSP_HOME             = $MSP_HOME"
echo "  CMAKE_DIR            = $CMAKE_DIR"
echo "  CMAKE_MODULE_PATH    = $CMAKE_MODULE_PATH"

echo; echo "Generate makefiles."
cmake \
-DCMAKE_BUILD_TYPE="RelWithDebug" \
-DOSSIM_INSTALL_PREFIX=$OSSIM_INSTALL_PREFIX \
-DOSSIM_DEV_HOME=$OSSIM_DEV_HOME \
-DMSP_HOME=$MSP_HOME \
-DOPENCV_HOME=$OPENCV_HOME \
-DCMAKE_INSTALL_PREFIX=$CMAKE_DIR/install \
-DCMAKE_MODULE_PATH=$CMAKE_MODULE_PATH \
$CMAKE_DIR

if [ $? != 0 ]; then
  echo "Error encountered in cmake command."
  popd; exit 1
fi
  
echo; echo "Build/install native service locally."
make -j 8 install
if [ $? != 0 ]; then
  echo "Error encountered in build."
  popd; exit 1
fi
echo "Build successful!"; 
popd

echo

