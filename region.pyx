"""
python setup.py build_ext --inplace --force
"""
#from libc.stdlib cimport free

cimport cgis


_REGION_ATTRS = ("format", "compressed", "rows", "rows3", "cols", "cols3",
                 "depths", "proj", "zone",
                 "ew_res", "ew_res3", "ns_res", "ns_res3", "tb_res",
                 "north", "south", "east", "west", "top", "bottom")


cdef class CRegion:

    #----------PROPERTIES----------

    property format:

        def __get__(self):
            return self.c_region.format

        def __set__(self, value):
            self.c_region.format = value

        def __del__(self):
            self.c_region.format = 0


    property compressed:

        def __get__(self):
            return self.c_region.compressed

        def __set__(self, value):
            self.c_region.compressed = value

        def __del__(self):
            self.c_region.compressed = 0


    property rows:

        def __get__(self):
            return self.c_region.rows

        def __set__(self, value):
            self.c_region.rows = value

        def __del__(self):
            self.c_region.rows = 0


    property rows3:

        def __get__(self):
            return self.c_region.rows3

        def __set__(self, value):
            self.c_region.rows3 = value

        def __del__(self):
            self.c_region.rows3 = 0


    property cols:

        def __get__(self):
            return self.c_region.cols

        def __set__(self, value):
            self.c_region.cols = value

        def __del__(self):
            self.c_region.cols = 0


    property cols3:

        def __get__(self):
            return self.c_region.cols3

        def __set__(self, value):
            self.c_region.cols3 = value

        def __del__(self):
            self.c_region.cols3 = 0


    property depths:

        def __get__(self):
            return self.c_region.depths

        def __set__(self, value):
            self.c_region.depths = value

        def __del__(self):
            self.c_region.depths = 0


    property proj:

        def __get__(self):
            return self.c_region.proj

        def __set__(self, value):
            self.c_region.proj = value

        def __del__(self):
            self.c_region.proj = 0


    property zone:

        def __get__(self):
            return self.c_region.zone

        def __set__(self, value):
            self.c_region.zone = value

        def __del__(self):
            self.c_region.zone = 0


    property ew_res:

        def __get__(self):
            return self.c_region.ew_res

        def __set__(self, value):
            self.c_region.ew_res = value

        def __del__(self):
            self.c_region.ew_res = 0


    property ew_res3:

        def __get__(self):
            return self.c_region.ew_res3

        def __set__(self, value):
            self.c_region.ew_res3 = value

        def __del__(self):
            self.c_region.ew_res3 = 0


    property ns_res:

        def __get__(self):
            return self.c_region.ns_res

        def __set__(self, value):
            self.c_region.ns_res = value

        def __del__(self):
            self.c_region.ns_res = 0


    property ns_res3:

        def __get__(self):
            return self.c_region.ns_res3

        def __set__(self, value):
            self.c_region.ns_res3 = value

        def __del__(self):
            self.c_region.ns_res3 = 0


    property tb_res:

        def __get__(self):
            return self.c_region.tb_res

        def __set__(self, value):
            self.c_region.tb_res = value

        def __del__(self):
            self.c_region.tb_res = 0


    property north:

        def __get__(self):
            return self.c_region.north

        def __set__(self, value):
            self.c_region.north = value

        def __del__(self):
            self.c_region.north = 0

    property south:

        def __get__(self):
            return self.c_region.south

        def __set__(self, value):
            self.c_region.south = value

        def __del__(self):
            self.c_region.south = 0


    property east:

        def __get__(self):
            return self.c_region.east

        def __set__(self, value):
            self.c_region.east = value

        def __del__(self):
            self.c_region.east = 0


    property west:

        def __get__(self):
            return self.c_region.west

        def __set__(self, value):
            self.c_region.west = value

        def __del__(self):
            self.c_region.west = 0


    property top:

        def __get__(self):
            return self.c_region.top

        def __set__(self, value):
            self.c_region.top = value

        def __del__(self):
            self.c_region.top = 0


    property bottom:

        def __get__(self):
            return self.c_region.bottom

        def __set__(self, value):
            self.c_region.bottom = value

        def __del__(self):
            self.c_region.bottom = 0



cdef class Region(CRegion):

    def __cinit__(self, n=None, s=None, e=None, w=None, t=None, b=None,
                  nsres=None, ewres=None, tbres=None,
                  default=False):
        if n is s is e is w is t is b is nsres is ewres is tbres is None:
            if default:
                self.get_default()
            else:
                self.get_current()
        else:
            self.north = n if n else 0
            self.south = s if s else 0
            self.east = e if e else 0
            self.west = w if w else 0
            self.top = t if t else 0
            self.bottom = b if b else 0
            self.nsres = nsres if nsres else 0
            self.ewres = ewres if ewres else 0
            self.tbres = tbres if tbres else 0

    #----------MAGIC METHODS----------
    def __cmp__(self, reg):
        for attr in _REGION_ATTRS:
            print attr
            if getattr(self, attr) != getattr(reg, attr):
                return False
        print "FATTO"
        return True

#    def __dealloc__(self):
#        free(<void *>&self.c_region)


    def __repr__(self):
        return 'Region(n=%g, s=%g, e=%g, w=%g, ns_res=%g, ew_res=%g)' % (
               self.north, self.south, self.east, self.west,
               self.ns_res, self.ew_res)

    #----------CP-METHODS----------

    cpdef adjust(self, int rows=0, int cols=0, int depth=0):
        """Adjust rows and cols number according with the nsres and ewres
        resolutions. If rows or cols parameters are True, the adjust method
        update nsres and ewres according with the rows and cols numbers.
        """
        if depth:
            cgis.G_adjust_Cell_head3(&self.c_region, rows, cols, depth)
        else:
            cgis.G_adjust_Cell_head(&self.c_region, rows, cols)

    def align(self, rast_name, mapset_name=''):
        """Adjust region cells to cleanly align with this raster map"""
        #Rast_get_cellhd(name, mapset, &temp_window);
	  #Rast_align_window(&window, &temp_window);
        pass

    cpdef get_bbox(self):
        pass

    cpdef get_current(self):
        cgis.G_get_set_window(&self.c_region)

    cpdef get_default(self):
        cgis.G_get_window(&self.c_region)

    cpdef set_bbox(self, int bbox):
        pass

    cpdef set_current(self):
        cgis.G_set_window(&self.c_region)

    cpdef set_default(self):
        pass

    cpdef rast(self, rast_name, mapset_name=''):
        pass

    cpdef rast3d(self, rast3d_name, mapset_name=''):
        pass

    cpdef vect(self, vect_name, mapset_name=''):
        pass

    cpdef zoom(self, raster_name):
        """Shrink region until it meets non-NULL data from this raster map:"""
        pass

    #----------P-METHODS----------
    def items(self):
        return [(k, self.__getattribute__(k)) for k in self.keys()]

    def keys(self):
        return _REGION_ATTRS





