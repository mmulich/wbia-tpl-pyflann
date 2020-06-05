#!/usr/bin/env python2
# -*- coding: utf-8 -*-


import sys

# import unittest

if __name__ == '__main__':
    if len(sys.argv) == 1:
        print('Usage: %s file' % sys.argv[0])
        sys.exit(1)

    test_file = sys.argv[1]
    sys.argv = sys.argv[1:]
    exec(open(test_file).read())
