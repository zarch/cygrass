# -*- coding: utf-8 -*-
"""
Created on Fri Sep 27 11:18:06 2013

@author: pietro
"""
# Import the Python-level symbols of numpy
import numpy as np

# Import the C-level symbols of numpy
cimport numpy as np

cimport crast
cimport cgis

from region cimport CRegion
from buffer cimport ArrayWrapper


INFO = """{name}@{mapset}
rows: {rows}
cols: {cols}
north: {north} south: {south} nsres:{nsres}
east:  {east} west: {west} ewres:{ewres}
range: {min}, {max}
proj: {proj}
"""


from libc.stdlib cimport malloc, free


MTYPE2GTYPE = {'CELL': 0, 'FCELL': 1, 'DCELL': 2}


#cpdef int_row_add_x(int[:] row, x, int[:] res) nogil:
#    for i in range(row.shape[0]):
#        res[i] = row[i] + x
#    return res
#
#cpdef int_rowA_add_roxB(int[:] rowA, int[:] rowB, int[:] res) nogil:
#    for i in range(rowA.shape[0]):
#        res[i] = rowA[i] + rowB[i]
#    return res
#
#cpdef int_row_iadd_x(int[:] row, x) nogil:
#    for i in range(row.shape[0]):
#        row[i] += x
#    return row


cdef class Range:

    #----------PROPERTIES----------

    property first_time:

        def __get__(self):
            return self.c_range.first_time

        def __set__(self, value):
            self.c_range.first_time = value

        def __del__(self):
            self.c_range.first_time = 0

    property max:

        def __get__(self):
            return self.c_range.max

        def __set__(self, value):
            self.c_range.max = value

        def __del__(self):
            self.c_range.max = 0

    property min:

        def __get__(self):
            return self.c_range.min

        def __set__(self, value):
            self.c_range.min = value

        def __del__(self):
            self.c_range.min = 0

    #----------CP-METHODS----------

    cpdef read_range(self, char* name, char* mapset):
        crast.Rast_read_range(name, mapset, &self.c_range)

    #----------P-METHODS----------

    def __iter__(self):
        return (self.min, self.max)

    def __repr__(self):
        return "(%f, %f)" % (self.min, self.max)



cdef class RastInfo(CRegion):

    def __cinit__(self, name, mapset=''):
        self.name = name
        self.mapset = mapset
        self.range = Range()
        self.range.read_range(self.name, self.mapset)
        crast.Rast_get_cellhd(name, mapset, &self.c_region)

    #----------PROPERTIES----------

    property max:

        def __get__(self):
            return self.range.c_range.max


    property min:

        def __get__(self):
            return self.range.c_range.min

    #----------MAGIC-METHODS----------

    def __repr__(self):
        return INFO.format(name=self.name, mapset=self.mapset,
                           rows=self.rows, cols=self.cols,
                           north=self.north, south=self.south,
                           east=self.east, west=self.west,
                           top=self.top, bottom=self.bottom,
                           nsres=self.nsres, ewres=self.ewres,
                           tbres=self.tbres, zone=self.zone,
                           proj=self.proj, min=self.min, max=self.max)

    #----------CP-METHODS----------



    #----------P-METHODS----------

    def items(self):
        return [(k, self.__getattribute__(k)) for k in self.keys()]

    def keys(self):
        return ['name', 'mapset', 'rows', 'cols', 'north', 'south',
                'east', 'west', 'top', 'bottom', 'nsres', 'ewres', 'tbres',
                'zone', 'proj', 'min', 'max']



cdef class RasterAbstract:

    def __cinit__(self, name, mapset='',
                  mode='r', mtype='CELL', overwrite=False, copy=True):
        self.name = name
        self.mapset = mapset
        self.mode = mode
        self.mtype = mtype
        self.overwrite = overwrite
        self.copy = copy
        # init attributes
        self.fd = -1
        self.rows = 0
        self.cols = 0

    #----------PROPERTIES----------

    property mtype:

        def __get__(self):
            return GTYPE2MTYPE[self.gtype]

        def __set__(self, value):
            if value.upper() in GTYPE2MTYPE:
                self.gtype = MTYPE2GTYPE[value]
            else:
                msg = "Value <%s> not in the supported values %r"
                raise TypeError(msg % (value, GTYPE2MTYPE))

        def __del__(self):
            self.gtype = 0

    #----------MAGIC-METHODS----------

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()

    def __getitem__(self, key):
        pass

    def __iter__(self):
        pass

    def __len__(self):
        return self._rows

    def __str__(self):
        pass

    def __unicode__(self):
        pass

    #----------CP-METHODS----------
    cpdef close(self):
        if self.is_open():
            crast.Rast_close(self.fd)
            self.fd = -1
            self.rows = 0
            self.clos = 0


    cpdef bint exist(self):
        if self.name:
            if not self.mapset:
                self.mapset = cgis.G_find_raster(self.name, self.mapset)
                return True if self.mapset else False
            return True if cgis.G_find_raster(self.name, self.mapset) else False
        else:
            raise TypeError("Raster map has no name.")


#    cpdef char* fullname(self):
#        if self.exist:
#            return "%s@%s" % (self.name, self.mapset)
#        else:
#            return self.name


    cpdef bint is_open(self):
        return True if self.fd >= 0 else False


    #----------P-METHODS----------

    def remove(self):
        pass

    def rename(self):
        pass


cdef class RasterRow(RasterAbstract):

    cdef void cget_row(self, int row, void* buf):
        crast.Rast_get_row(self.fd, buf, row, self.gtype)

    cdef void cput_row(self, void* buf):
        crast.Rast_put_row(self.fd, buf, self.gtype)

    def get_row(self, int row, np.ndarray buf=None):
        cdef np.ndarray ndarray
        if buf is not None:
            self.buf = <void*> buf
        self.cget_row(row, self.buf)
        ndarray = np.array(self.aw, copy=self.copy)
        return ndarray

    def put_row(self, buf):
        self.cput_row(<void*>buf)

    cpdef open(self, char* mode='', char* mtype='', bint overwrite=None,
               bint copy=None):
        cdef char *msg
        cdef void *buf
        if mode:
            self.mode = mode
        if mtype:
            self.mtype = mtype
        if overwrite is not None:
            self.overwrite = overwrite
        if copy is not None:
            self.copy = copy

        if self.exist():
            if self.mode[0] == 'r':
                self.fd = crast.Rast_open_old(self.name, self.mapset)
                self.gtype = crast.Rast_get_map_type(self.fd)
            elif self.overwrite:
                self.fd = crast.Rast_open_new(self.name, self.gtype)
            else:
                msg = "Raster map <%s> already exists"
                raise RuntimeError(msg % self.name)
        else:
            if self.mode[0] == 'r':
                msg = "The map <%s> does not exist, I can't open in 'r' mode"
                raise RuntimeError(msg % self.name)
            self.fd = crast.Rast_open_new(self.name, self.gtype)

        # read rows and cols from the active region
        self.rows = crast.Rast_window_rows()
        self.cols = crast.Rast_window_cols()
        self.buf = crast.Rast_allocate_buf(self.gtype)
        self.aw = ArrayWrapper()
        self.aw.set_data(self.cols + 1, self.gtype, self.buf)


