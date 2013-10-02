# -*- coding: utf-8 -*-
# python2 setup.py build_ext --inplace --force
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import os
import numpy as np

GISBASE = os.getenv('GISBASE')
INCLUDE_DIR = os.path.join(GISBASE, 'include')  # include
LIB_DIR = os.path.join(GISBASE, 'lib')          # lib

setup(
    cmdclass={'build_ext': build_ext},
    ext_modules=[Extension("region", ["region.pyx"],
                           include_dirs=[INCLUDE_DIR, ],
                           libraries=['grass_gis'],
                           library_dirs=[LIB_DIR, ],
                           ),
                 Extension("buffer", ["buffer.pyx"],
                           include_dirs=[INCLUDE_DIR, np.get_include()],
                           libraries=['grass_gis', 'grass_raster'],
                           library_dirs=[LIB_DIR, ],
                           ),
                 Extension("raster", ["raster.pyx"],
                           include_dirs=[INCLUDE_DIR, np.get_include()],
                           libraries=['grass_gis', 'grass_raster'],
                           library_dirs=[LIB_DIR, ],
                           )
                 ]
)
