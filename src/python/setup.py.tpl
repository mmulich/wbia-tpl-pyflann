#!/usr/bin/env python2

try:
    from setuptools import setup
except ImportError:
    print('setuptools is not installed. Falling back to distutils.core')
    from distutils.core import setup
from os.path import exists, abspath, dirname, join
import os
import sys

POSSIBLE_LIBS = ['libflann.so', 'flann.dll', 'libflann.dll', 'libflann.dylib']


def find_path():
    lib_paths = [
        # os.path.abspath('@LIBRARY_OUTPUT_PATH@'),
        os.path.abspath('@LIBRARY_OUTPUT_DIRECTORY@'),
        abspath(join(dirname(dirname(sys.argv[0])), '../../../lib'))
    ]

    for path in lib_paths:
        for lib in POSSIBLE_LIBS:
            if exists(join(path,lib)):
                return path

setup(name='flann',
      # version='@FLANN_VERSION@',
      version='1.8.4',
      description='Fast Library for Approximate Nearest Neighbors',
      author='Marius Muja',
      author_email='mariusm@cs.ubc.ca',
      license='BSD',
      url='http://www.cs.ubc.ca/~mariusm/flann/',
      packages=['pyflann', 'pyflann.lib'],
      package_dir={'pyflann.lib': find_path() },
      package_data={'pyflann.lib': POSSIBLE_LIBS}, 
)
