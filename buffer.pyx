# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 12:02:21 2013

@author: pietro
"""

from libc.stdlib cimport free
from cpython cimport PyObject, Py_INCREF

# Import the Python-level symbols of numpy
import numpy as np

# Import the C-level symbols of numpy
cimport numpy as np

# Numpy must be initialized. When using numpy from C or Cython you must
# _always_ do that, or you will have segfaults
np.import_array()

# We need to build an array-wrapper class to deallocate our array when
# the Python object is deleted.

GTYPE2NP = (np.NP_INT,
            np.NP_FLOAT,
            np.NP_DOUBLE)

cdef class ArrayWrapper:

    cdef void set_data(self, int size, int gtype, void* data):
        self.data = data
        self.gtype = gtype
        self.size = size

    def __array__(self):
        """Define the __array__ method, that is called when numpy
        tries to get an array from the object."""
        cdef np.npy_intp shape[1]
        shape[0] = <np.npy_intp> self.size
        # Create a 1D array, of length 'size'
        ndarray = np.PyArray_SimpleNewFromData(1, shape,
                                               GTYPE2NP[self.gtype], self.data)
        return ndarray

    def __dealloc__(self):
        free(<void*>self.data)


#def py_compute(int size):
#    """ Python binding of the 'compute' function in 'c_code.c' that does
#        not copy the data allocated in C.
#    """
#    cdef float *array
#    cdef np.ndarray ndarray
#    # Call the C function
#    array = compute(size)
#
#    array_wrapper = ArrayWrapper()
#    array_wrapper.set_data(size, <void*> array)
#    ndarray = np.array(array_wrapper, copy=False)
#    # Assign our object to the 'base' of the ndarray object
#    ndarray.base = <PyObject*> array_wrapper
#    # Increment the reference count, as the above assignement was done in
#    # C, and Python does not know that there is this additional reference
#    Py_INCREF(array_wrapper)
#
#    return ndarray
