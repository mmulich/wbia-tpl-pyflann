#!/bin/bash

REPODIR=$(cd $(dirname $0) ; pwd)
cd $REPODIR/flann
mkdir build
cd build

#sudo apt-get install libcr-dev mpich2 mpich2-doc

# Grab correct python executable
export PYTHON_EXECUTABLE=$(which python)

# Configure make build install
cmake -G "Unix Makefiles" \
    -DBUILD_MATLAB_BINDINGS=Off \
    -DCMAKE_BUILD_TYPE=Release \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    .. && make && sudo make install
