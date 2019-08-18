#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, print_function

try:
    from setuptools import setup
    from setuptools.command.develop import develop as _develop
except ImportError:
    print('setuptools is not installed. Falling back to distutils.core')
    from distutils.core import setup
from os.path import exists, abspath, dirname, join
import skbuild

possible_libs = ['libflann.so', 'flann.dll', 'libflann.dll', 'libflann.dylib']


def find_path():
    lib_paths = [
        # abspath('/home/joncrall/code/flann/cmake-builds/build3.7/lib'),
        # abspath(''),
        abspath('/home/joncrall/code/flann/cmake-builds/build3.7/lib'),
        # hacks for msvc
        abspath('/home/joncrall/code/flann/cmake-builds/build3.7/lib/Release'),
        abspath('/home/joncrall/code/flann/cmake-builds/build3.7/lib/MinSizeRel'),
        abspath('/home/joncrall/code/flann/cmake-builds/build3.7/lib/RelWithDebInfo'),
        abspath('/home/joncrall/code/flann/cmake-builds/build3.7/lib/Debug'),
        # abspath(join(dirname(dirname(sys.argv[0])), '../../../lib'))
    ]
    print('lib_paths = %r' % (lib_paths,))

    for path in lib_paths:
        for lib in possible_libs:
            if exists(join(path, lib)):
                print('path = %r' % path)
                return path


class develop(_develop):
    def run(self):
        # Ensure build is run before develop
        self.run_command("build")
        return _develop.run(self)


setup(name='ibeis_pyflann',
      version='2.0.0',
      description='Fast Library for Approximate Nearest Neighbors',
      author='Marius Muja',
      author_email='mariusm@cs.ubc.ca',
      license='BSD',
      cmdclass={
          'develop': develop,
      },
      url='http://www.cs.ubc.ca/~mariusm/flann/',
      packages=['ibeis_pyflann'],
      package_dir={'pyflann.lib': find_path() },
      package_data={'pyflann.lib': possible_libs},
)
