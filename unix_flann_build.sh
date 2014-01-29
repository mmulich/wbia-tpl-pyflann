cd ~/code/flann
mkdir build
cd build

#sudo apt-get install libcr-dev mpich2 mpich2-doc

cmake -G "Unix Makefiles" -DBUILD_MATLAB_BINDINGS=Off -DCMAKE_BUILD_TYPE=Release
..

make
sudo make install
