# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 13:01:22 2013

@author: pietro
"""
cimport cgis

cdef class CRegion:
    cdef cgis.Cell_head c_region


