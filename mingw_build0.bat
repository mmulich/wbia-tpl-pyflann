SET ORIGINAL=%CD%

call :build_flann
goto :exit

:build_flann
:: helper variables
set INSTALL32=C:\Program Files (x86)
set INSTALL64=C:\Program Files
set FLANN_INSTALL="%INSTALL32%\Flann"
::set CMAKE_EXE="%INSTALL32%\CMake 2.8\bin\cmake.exe"
::set CMAKE_GUI_EXE="%INSTALL32%\CMake 2.8\bin\cmake-gui.exe"
set CMAKE_EXE="%INSTALL64%\CMake\bin\cmake.exe"
set CMAKE_GUI_EXE="%INSTALL64%\CMake\bin\cmake-gui.exe"
set FLANN_DIR=%USERPROFILE%\code\flann

cd %FLANN_DIR%
:: rm -rf build
mkdir cmake_builds
cd cmake_builds
mkdir build.win32-cpython27
cd build.win32-cpython27

:: set CMAKE_GENERATOR="MSYS Makefiles"
set CMAKE_GENERATOR="MinGW Makefiles"

:: OpenCV settings on windows
%CMAKE_EXE% -G %CMAKE_GENERATOR% ^
-DCMAKE_INSTALL_PREFIX=%FLANN_INSTALL% ^
-DBUILD_MATLAB_BINDINGS=Off ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_C_FLAGS=-m32 ^
-DCMAKE_CXX_FLAGS=-m32 ^
-DUSE_OPENMP=On ^
-DUSE_MPI=Off ^
-DHDF5_INCLUDE_DIRS="" ^
-DHDF5_ROOT_DIR="" ^
%FLANN_DIR%

:: make command that doesn't freeze on mingw
echo "BUILDING FLANN TAKES AWHILE. BE PATIENT."
:: mingw32-make -j7 "MAKE=mingw32-make -j3" -f CMakeFiles\Makefile2 all
::

IF "%CMAKE_GENERATOR%"=="MinGW Makefiles" (
    mingw32-make
) ELSE
(
    make
)

cd %FLANN_DIR%/src/python
:: need to build first to move in libs
python setup.py build
:: install FLANN in editable mode
pip install -e %FLANN_DIR%/src/python

exit /b

:exit
cd %ORIGINAL%
exit /b


:: cd
:: python ../../build/src/python/setup.py develop
