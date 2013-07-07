#git clone https://github.com/abramhindle/flann.git


echo 'Entering abrahamhindle_flann...'
cd ~/code/abrahamhindle_flann
echo 'Executing small python script...'
python -c '
import os;
print("checking if build exists")
if (not os.path.exists("build")):
    print("making directory build")
    os.mkdir("build")
else:
    print("...yes")'

echo 'Entering abrahamhindle_flann/build...'
cd build
echo 'Running CMake...'

#cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32 -DCMAKE_BUILD_TYPE=Release -DBUILD_MATLAB_BINDINGS=OFF -DUSE_OPENMP=OFF ..
cmake -G "MinGW Makefiles" -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32 -DCMAKE_BUILD_TYPE=Release -DBUILD_MATLAB_BINDINGS=OFF -DUSE_OPENMP=OFF ..

cd ~/code/abrahamhindle_flann


