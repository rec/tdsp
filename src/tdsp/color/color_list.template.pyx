from numbers import Number

cdef class _ColorList:
    """A list of RGB floating point Colors, with many mutating functions.

       A ColorList looks quite like a Python list of Colors (which look like
       tuples) with the big interface difference that operations like + and *
       perform arithmetic and not list construction.

       Written in C++, this class should consume significantly fewer memory and
       CPU resources than a corresponding Python list, as well as providing a
       range of useful facilities.

       While ColorList provides a full set of functions and operations that
       create new ColorLists, in each case there is a corresponding mutating
       function or operation that works "in-place" with no heap allocations
       at all, for best performance.

       The base class ColorList is a list of Color, which are normalized to
       [0, 1]; the derived class ColorList256 is a list of Color256, which
       are normalized to [0, 255].
"""
    cdef ColorList colors

    def __cinit__(self, items=None):
        """Construct a ColorList with an iterator of items, each of which looks
           like a Color."""
        if items is not None:
            if isinstance(items, _ColorList):
                self.colors = (<_ColorList> items).colors
            else:
                # A list of tuples, Colors or strings.
                self.colors.resize(len(items))
                for i, item in enumerate(items):
                    self[i] = item

    def __setitem__(self, object key, object x):
        cdef size_t length, slice_length
        cdef int begin, end, step, index
        cdef float r, g, b
        cdef _ColorList cl
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            if sliceIntoVector(_toCL(x).colors, self.colors,
                               begin, end, step):
                return
            raise ValueError('attempt to assign sequence of one size '
                             'to extended slice of another size')
        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(index))
        if isinstance(x, str):
            x = _Color(x)
        r, g, b = x
        self.colors.setColor(index, r, g, b)

    def __getitem__(self, object key):
        cdef Color c
        cdef int index
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            cl = _ColorList()
            cl.colors = sliceVector(self.colors, begin, end, step)
            return cl

        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(key))

        c = self.colors[index]
        return _Color(c.at(0), c.at(1), c.at(2))

    # Unary operators and corresponding mutators.
    def abs(self):
        """Replace each color by its absolute value."""
        absColor(self.colors)

    def __abs__(self):
        cdef _ColorList cl;
        cl = self[:]
        cl.abs()
        return cl

    def ceil(self):
        """Replace each color by its absolute value."""
        ceilColor(self.colors)

    def __ceil__(self):
        cdef _ColorList cl;
        cl = self[:]
        cl.ceil()
        return cl

    def floor(self):
        """Replace each color by its floorolute value."""
        floorColor(self.colors)

    def __floor__(self):
        cdef _ColorList cl;
        cl = self[:]
        cl.floor()
        return cl

    def invert(self):
        """Invert each color to its complement."""
        invertColor(self.colors)

    def __invert__(self):
        cdef _ColorList cl;
        cl = self[:]
        cl.invert()
        return cl

    def neg(self):
        """Negate each color."""
        negateColor(self.colors)

    def __negative__(self):
        cdef _ColorList cl;
        cl = self[:]
        cl.negative()
        return cl

    def round(self):
        """Round each color value to the nearest integer."""
        roundColor(self.colors)

    def __round__(self):
        cdef _ColorList cl;
        cl = self[:]
        cl.round()
        return cl

    def trunc(self):
        """Truncate each value to an integer."""
        truncColor(self.colors)

    def __trunc__(self):
        cdef _ColorList cl;
        cl = self[:]
        cl.trunc()
        return cl

    # List-like operations.
    def append(self, object value):
        """Append to the list of colors."""
        cdef uint s
        s = self.colors.size()
        self.colors.resize(s + 1)
        try:
            self[s] = value
        except:
            self.colors.resize(s)
            raise

    def clear(self):
        """Set all colors to black."""
        self.colors.clear()

    def rotate(self, int pos):
        """Rotate the colors forward by `pos` positions."""
        rotate(self.colors, pos)

    def reverse(self):
        """Reverse the colors in place."""
        reverse(self.colors)

    def duplicate(self, uint count):
        """Return a new `ColorList` with `count` copies of this one."""
        cl = _ColorList()
        cl.colors = duplicate(self.colors, count)
        return cl

    def extend(self, object values):
        """Extend the colors from an iterator."""
        cdef size_t s
        s = self.colors.size()
        try:
            for v in values:
                self.append(v)
        except:
            self.colors.resize(s)
            raise

    def max(self, c):
        """Mutate each color by max-ing it with a number or a ColorList."""
        if isinstance(c, Number):
            maxInto(<float> c, self.colors)
        else:
            maxInto(_toCL(c).colors, self.colors)

    def min(self, c):
        """Mutate each color by min-ing it with a number or a ColorList."""
        if isinstance(c, Number):
            minInto(<float> c, self.colors)
        else:
            minInto(_toCL(c).colors, self.colors)

    def pow(self, float c):
        """Raise each color to the given power (gamma correction)."""
        if isinstance(c, Number):
            powInto(<float> c, self.colors)
        else:
            powInto(_toCL(c).colors, self.colors)

    def resize(self, size_t size):
        """Set the size of the ColorList, filling with black if needed."""
        self.colors.resize(size)

    def rpow(self, c):
        """Right-hand (reversed) reverse of pow()."""
        if isinstance(c, Number):
            rpowInto(<float> c, self.colors)
        else:
            rpowInto(_toCL(c).colors, self.colors)

    # Mutating operations.
    def __iadd__(self, c):
        if isinstance(c, Number):
            addInto(<float> c, self.colors)
        else:
            addInto(_toCL(c).colors, self.colors)
        return self

    def __imul__(self, c):
        if isinstance(c, Number):
            multiplyInto(<float> c, self.colors)
        else:
            multiplyInto(_toCL(c).colors, self.colors)

    def __ipow__(self, c):
        if isinstance(c, Number):
             powInto(<float> c, self.colors)
        else:
             powInto(_toCL(c).colors, self.colors)

    def __isub__(self, c):
        if isinstance(c, Number):
             subtractInto(<float> c, self.colors)
        else:
             subtractInto(_toCL(c).colors, self.colors)

    def __itruediv__(self, c):
        if isinstance(c, Number):
            divideInto(<float> c, self.colors)
        else:
            divideInto(_toCL(c).colors, self.colors)

    def __add__(self, c):
        cdef _ColorList cl
        cl = _ColorList()
        if isinstance(c, Number):
            addOver((<_ColorList> self).colors, <float> c, cl.colors)
        elif isinstance(self, _ColorList):
            addOver((<_ColorList> self).colors, _toCL(c).colors, cl.colors)
        elif isinstance(self, Number):
            addOver(<float> self, _toCL(c).colors, cl.colors)
        else:
            addOver(_ColorList(self).colors, (<_ColorList> c).colors, cl.colors)
        return cl

    def __mul__(self, c):
        cdef _ColorList cl
        cl = _ColorList()
        if isinstance(c, Number):
            mulOver((<_ColorList> self).colors, <float> c, cl.colors)
        elif isinstance(self, _ColorList):
            mulOver((<_ColorList> self).colors, _toCL(c).colors, cl.colors)
        elif isinstance(self, Number):
            mulOver(<float> self, _toCL(c).colors, cl.colors)
        else:
            mulOver(_ColorList(self).colors, (<_ColorList> c).colors, cl.colors)
        return cl

    def __pow__(self, c, mod):
        cdef _ColorList cl
        if mod:
            raise ValueError('Can\'t handle three operator pow')

        cl = _ColorList()
        if isinstance(c, Number):
            powOver((<_ColorList> self).colors, <float> c, cl.colors)
        elif isinstance(self, _ColorList):
            powOver((<_ColorList> self).colors, _toCL(c).colors, cl.colors)
        elif isinstance(self, Number):
            powOver(<float> self, _toCL(c).colors, cl.colors)
        else:
            powOver(_ColorList(self).colors, (<_ColorList> c).colors, cl.colors)
        return cl

    def __sub__(self, c):
        cdef _ColorList cl
        cl = _ColorList()
        if isinstance(c, Number):
            subOver((<_ColorList> self).colors, <float> c, cl.colors)
        elif isinstance(self, _ColorList):
            subOver((<_ColorList> self).colors, _toCL(c).colors, cl.colors)
        elif isinstance(self, Number):
            subOver(<float> self, _toCL(c).colors, cl.colors)
        else:
            subOver(_ColorList(self).colors, (<_ColorList> c).colors, cl.colors)
        return cl

    def __truediv__(self, c):
        cdef _ColorList cl
        cl = _ColorList()
        if isinstance(c, Number):
            divOver((<_ColorList> self).colors, <float> c, cl.colors)
        elif isinstance(self, _ColorList):
            divOver((<_ColorList> self).colors, _toCL(c).colors, cl.colors)
        elif isinstance(self, Number):
            divOver(<float> self, _toCL(c).colors, cl.colors)
        else:
            divOver(_ColorList(self).colors, (<_ColorList> c).colors, cl.colors)
        return cl

    def __len__(self):
        return self.colors.size()

    def __repr__(self):
        return '_ColorList(%s)' % str(self)

    def __richcmp__(_ColorList self, _ColorList other, int rcmp):
        return cmpToRichcmp(compareContainers(self.colors, other.colors), rcmp)

    def __sizeof__(self):
        return self.colors.getSizeOf()

    def __str__(self):
        return toString(self.colors).decode('ascii')


cdef _ColorList _toCL(object value):
    if isinstance(value, _ColorList):
        return <_ColorList> value
    else:
        return _ColorList(value)