#!/bin/bash
__heredoc__="""
# Ubuntu
sudo apt install liblz4-dev libhdf5-serial-dev

# MacOS with MacPorts
sudo port install ninja hdf5 lz4 hdf5-lz4-plugin
pip install -U scikit-build cmake lz4
"""

python setup.py build_ext --inplace
python setup.py develop
