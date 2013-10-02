# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 13:12:51 2013

@author: pietro
"""
# Import the C-level symbols of numpy
cimport numpy as np

cimport crast
cimport buffer as bf

#ctypedef np.int_t DTYPE_CELL
#ctypedef np.float32_t DTYPE_FCELL
#ctypedef np.float64_t DTYPE_DCELL

cdef char *GTYPE2MTYPE = ('CELL', 'FCELL', 'DCELL')
cdef char *GTYPE2NUMSTR = ('i', 'f', 'd')
#cdef int  *GTYPE2DTYPE = (DTYPE_CELL, DTYPE_FCELL, DTYPE_DCELL)
cdef unsigned long *GTYPE2SIZE = [4, 4, 8]

cdef class Range:
    # C only attributes
    cdef crast.Range c_range
    # CP-Methods
    cpdef public read_range(self, char*, char*)


cdef class RasterAbstract:
    # public attributes
    cdef public char* name
    cdef public char* mapset
    cdef public char* mode
    cdef public int   gtype
    cdef public bint  overwrite
    cdef public bint  copy
    # readonly attributes
    cdef readonly int fd
    cdef readonly int rows
    cdef readonly int cols
    # C only attributes
    cdef void* buf
    cdef bf.ArrayWrapper aw

    # CP-Methods
    cpdef public       close(self)
    cpdef public bint  exist(self)
#    cpdef public char* fullname(self)
    cpdef public bint  is_open(self)
