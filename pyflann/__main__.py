

def main():  # nocover
    import pyflann
    print('Looks like the imports worked')
    print('pyflann = {!r}'.format(pyflann))
    print('pyflann.__file__ = {!r}'.format(pyflann.__file__))
    print('pyflann.__version__ = {!r}'.format(pyflann.__version__))
    print('pyflann.flann_ctypes.flannlib = {!r}'.format(pyflann.flann_ctypes.flannlib))
    print('pyflann.flann_ctypes.libpath = {!r}'.format(pyflann.flann_ctypes.libpath))


if __name__ == '__main__':
    """
    CommandLine:
       python -m pyflann
    """
    main()
