# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 13:12:51 2013

@author: pietro
"""
from cpython cimport bool

cimport crast


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
    # readonly attributes
    cdef readonly int fd
    cdef readonly int rows
    cdef readonly int cols
    # C only attributes
    cdef void* buf

    # CP-Methods
    cpdef public       close(self)
    cpdef public bint  exist(self)
#    cpdef public char* fullname(self)
    cpdef public bint  is_open(self)
