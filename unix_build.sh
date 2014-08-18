#!/bin/bash
#REPODIR=$(cd $(dirname $0) ; pwd)
#cd $REPODIR/flann

rm -rf build
mkdir build

#sudo apt-get install libhdf5-serial-1.8.4
#libhdf5-openmpi-dev

cd build

#sudo apt-get install libcr-dev mpich2 mpich2-doc

# Grab correct python executable
export PYEXE=$(which python2.7)
export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
# This gives /usr for python2.7, should give /usr/local?
#export CMAKE_INSTALL_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")
#export CMAKE_INSTALL_PREFIX=/usr/local
echo "CMAKE_INSTALL_PREFIX     = $CMAKE_INSTALL_PREFIX"
echo "PYTHON_EXECUTABLE        = $PYTHON_EXECUTABLE"
echo "PYEXE        = $PYEXE"

## Configure make build install
#cmake -G "Unix Makefiles" \
#    -DBUILD_MATLAB_BINDINGS=Off \
#    -DCMAKE_BUILD_TYPE=Release \
#    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
#    ..

    #-DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX \


# Configure make build install
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -DBUILD_PYTHON_BINDINGS=On \
    -DBUILD_MATLAB_BINDINGS=Off \
    -DLATEX_OUTPUT_PATH=. \
    ..

    #-DNVCC_COMPILER_BINDIR=/usr/bin/gcc \
    #-DCUDA_BUILD_CUBIN=On \
    #-DCUDA_npp_LIBRARY=/usr/local/cuda-6.0/lib64/libnppc.so \
    #-DHDF5_DIR=/home/joncrall/usr \
    #-DHDF5_C_INCLUDE_DIR=/home/joncrall/usr/include \

    #-DCMAKE_VERBOSE_MAKEFILE=On\
    #-DCUDA_VERBOSE_BUILD=On\
    #-DBUILD_CUDA_LIB=On\
    #-DCUDA_NVCC_FLAGS=-gencode;arch=compute_20,code=sm_20;-gencode;arch=compute_20,code=sm_21 

make -j$NCPUS 
make -j$NCPUS || { echo "FAILED MAKE" ; exit 1; }

sudo make install || { echo "FAILED MAKE INSTALL" ; exit 1; }

python -c "import pyflann; print(pyflann)"
