#!/bin/bash
#REPODIR=$(cd $(dirname $0) ; pwd)
#cd $REPODIR/flann
#sudo apt-get install libhdf5-serial-1.8.4
#libhdf5-openmpi-dev

export FAILCMD='{ echo "FAILED FLANN BUILD" ; exit 1; }'

#rm -rf build
python2.7 -c "import utool as ut; print('keeping build dir' if not ut.get_argflag('--rmbuild') else ut.delete('build'))" $@
mkdir build

cd build

#sudo apt-get install libcr-dev mpich2 mpich2-doc

# Grab correct python executable
export PYEXE=$(which python2.7)
export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
if [[ "$VIRTUAL_ENV" == ""  ]]; then
    export LOCAL_PREFIX=/usr/local
    export _SUDO="sudo"
else
    export LOCAL_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")/local
    export _SUDO=""
fi

echo "PYEXE              = $PYEXE"
echo "PYTHON_EXECUTABLE  = $PYTHON_EXECUTABLE"
echo "LOCAL_PREFIX       = $LOCAL_PREFIX"
echo "_SUDO              = $_SUDO"

# Configure make build install
#-DCMAKE_BUILD_TYPE="Release" \
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE="Debug" \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -DBUILD_PYTHON_BINDINGS=On \
    -DBUILD_MATLAB_BINDINGS=Off \
    -DCMAKE_INSTALL_PREFIX=$LOCAL_PREFIX \
    -DLATEX_OUTPUT_PATH=. \
    -DBUILD_CUDA_LIB=Off\
    -CPACK_SOURCE_TGZ=Off
    -CPACK_SOURCE_TBZ2=Off
    -CPACK_SOURCE_TZ=Off
    ..

    # Show expanded templates
    #-DCMAKE_C_FLAGS="-E" \  

    #-DBUILD_EXAMPLES=Off \
    #-DBUILD_DOC=Off \
    #-DBUILD_TESTS=Off \

    #-DNVCC_COMPILER_BINDIR=/usr/bin/gcc \
    #-DCUDA_BUILD_CUBIN=On \
    #-DCUDA_npp_LIBRARY=/usr/local/cuda-6.0/lib64/libnppc.so \
    #-DHDF5_DIR=/home/joncrall/usr \
    #-DHDF5_C_INCLUDE_DIR=/home/joncrall/usr/include \

    #-DCMAKE_VERBOSE_MAKEFILE=On\
    #-DCUDA_VERBOSE_BUILD=On\
    #-DCUDA_NVCC_FLAGS=-gencode;arch=compute_20,code=sm_20;-gencode;arch=compute_20,code=sm_21 

make -j$NCPUS || $FAILCMD
$_SUDO make install || $FAILCMD

# setup to develop
cd ../src/python
$_SUDO python ../../build/src/python/setup.py develop

python -c "import pyflann; print(pyflann.__file__)"
python -c "import pyflann; print(pyflann)"

#copying pyflann/__init__.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/flann_ctypes.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/index.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/exceptions.py -> build/lib.linux-x86_64-2.7/pyflann
#creating build/lib.linux-x86_64-2.7/pyflann/lib
#copying /home/joncrall/tmp/flann/build/lib/libflann.so -> build/lib.linux-x86_64-2.7/pyflann/lib
#package init file '/home/joncrall/tmp/flann/build/lib/__init__.py' not found (or not a regular file)
#running install_lib
#creating /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/__init__.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/flann_ctypes.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/index.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#creating /home/joncrall/venv/lib/python2.7/site-packages/pyflann/lib
#copying build/lib.linux-x86_64-2.7/pyflann/lib/libflann.so -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann/lib
#copying build/lib.linux-x86_64-2.7/pyflann/exceptions.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/__init__.py to __init__.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/flann_ctypes.py to flann_ctypes.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/index.py to index.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/exceptions.py to exceptions.pyc

flann_setuptools_install()
{
    cd $CODE_DIR/flann/src/python
    #../../build/src/python/setup.py
    python ../../build/src/python/setup.py develop
    sudo python ../../build/src/python/setup.py develop
}
#setupinstall_flann()
#{
#    code 
#    cd flann
#    cd src/python
#    python ../../build/src/python/setup.py install
#}


uninstall_flann()
{
    cd $CODE_DIR/flann/src/python
    sudo python ../../build/src/python/setup.py develop --uninstall

    pip list | grep flann
    python -c "import pyflann; print(pyflann.__file__)"
    python -c "import pyflann, os.path; print(os.path.dirname(pyflann.__file__))"
    sudo rm -rf /home/joncrall/venv/local/lib/python2.7/site-packages/pyflann
    python -c "import pyflann; print(pyflann.FLANN.add_points)"
    python -c "import pyflann; print(pyflann.__tmp_version__)"
    ls -al /home/joncrall/venv/local/lib/python2.7/site-packages/pyflann/lib

    # The add remove/error branch info 
    # Seems to work here: 880433b352d190fcbef78ea95d94ec8324059424
    # Seems to fail here: e5b9cbeabc9f790e231fbb91376a6842207565ba
}


debug_flann()
{
    wget http://svn.python.org/projects/python/trunk/Misc/valgrind-python.supp

    sh -c 'cat >> valgrind-python.supp << EOL
{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Addr4
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Value4
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Conditional jump or move depends on uninitialised value
   Memcheck:Cond
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Addr4
   fun:PyObject_Realloc
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Value4
   fun:PyObject_Realloc
}

{
   ADDRESS_IN_RANGE/Conditional jump or move depends on uninitialised value
   Memcheck:Cond
   fun:PyObject_Realloc
}
EOL' 
    valgrind --tool=memcheck --suppressions=valgrind-python.supp python -E -tt ./examples/example.py

    valgrind --tool=memcheck --suppressions=valgrind-python.supp python  ./examples/example.py
    
}
