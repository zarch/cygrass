# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 15:21:17 2013

@author: pietro
"""

cdef class ArrayWrapper:
    cdef void* data
    cdef int gtype
    cdef int size
    cdef void set_data(self, int, int, void*)
