#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, print_function

try:
    from setuptools import setup
    from setuptools.command.develop import develop as _develop
except ImportError:
    print('setuptools is not installed. Falling back to distutils.core')
    from distutils.core import setup
# from distutils.command.install import install as _install
from os.path import exists, abspath, dirname, join
import sys

possible_libs = ['libflann.so', 'flann.dll', 'libflann.dll', 'libflann.dylib']


def find_path():
    lib_paths = [
        # abspath('@LIBRARY_OUTPUT_PATH@'),
        abspath('@LIBRARY_OUTPUT_DIRECTORY@'),
        # hacks for msvc
        abspath('@LIBRARY_OUTPUT_DIRECTORY@/Release'),
        abspath('@LIBRARY_OUTPUT_DIRECTORY@/MinSizeRel'),
        abspath('@LIBRARY_OUTPUT_DIRECTORY@/RelWithDebInfo'),
        abspath('@LIBRARY_OUTPUT_DIRECTORY@/Debug'),
        # abspath(join(dirname(dirname(sys.argv[0])), '../../../lib'))
    ]
    print('lib_paths = %r' % (lib_paths,))

    for path in lib_paths:
        for lib in possible_libs:
            if exists(join(path, lib)):
                return path


class develop(_develop):
    def run(self):
        # Ensure build is run before develop
        self.run_command("build")
        return _develop.run(self)


setup(name='flann',
      version='@FLANN_VERSION@',
      description='Fast Library for Approximate Nearest Neighbors',
      author='Marius Muja',
      author_email='mariusm@cs.ubc.ca',
      license='BSD',
      cmdclass={
          'develop': develop,
      },
      url='http://www.cs.ubc.ca/~mariusm/flann/',
      packages=['pyflann', 'pyflann.lib'],
      package_dir={'pyflann.lib': find_path() },
      package_data={'pyflann.lib': possible_libs}, 
)
