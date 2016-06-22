from numbers import Number

cdef class ColorList:
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
    cdef ColorVector colors

    # Magic methods.
    def __cinit__(self, items=None):
        """Construct a ColorList with an iterator of items, each of which looks
           like a Color."""
        if items is not None:
            if isinstance(items, ColorList):
                self.colors = (<ColorList> items).colors
            else:
                # A list of tuples, Colors or strings.
                self.colors.resize(len(items))
                for i, item in enumerate(items):
                    self[i] = item

    def __setitem__(self, object key, object x):
        cdef size_t length, slice_length
        cdef int begin, end, step, index
        cdef float r, g, b
        cdef ColorList cl
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            if isinstance(x, ColorList):
                cl = <ColorList> x
            else:
                cl = ColorList(x)
            if sliceIntoVector(cl.colors, self.colors, begin, end, step):
                return
            raise ValueError('attempt to assign sequence of one size '
                             'to extended slice of another size')
        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(index))
        try:
            if isinstance(x, str):
                x = Color(x)
            r, g, b = x
            self.colors.setColor(index, r, g, b)
        except:
            raise ValueError('Can\'t convert ' + str(x) + ' to a color')

    def __getitem__(self, object key):
        cdef ColorS c
        cdef int index
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            cl = ColorList()
            cl.colors = sliceVector(self.colors, begin, end, step)
            return cl

        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(key))

        c = self.colors[index]
        return Color(c.red, c.green, c.blue)

    def __add__(ColorList self, ColorList cl):
        cdef ColorList result = ColorList()
        result.colors = self.colors
        appendInto(cl.colors, result.colors)
        return result

    def __iadd__(ColorList self, ColorList cl):
        appendInto(cl.colors, self.colors)
        return self

    def __mul__(object self, object other):
        # A little tricky because ColorList can appear on the left or the
        # right side of the argument.
        cdef size_t mult
        cdef ColorList cl = ColorList()
        if isinstance(self, ColorList):
            cl.colors = (<ColorList> self).colors
            mult = <size_t> other
        else:
            cl.colors = (<ColorList> other).colors
            mult = <size_t> self
        duplicateInto(mult, cl.colors)
        return cl

    def __imul__(ColorList self, size_t mult):
        duplicateInto(mult, self.colors)
        return self

    def __len__(self):
        return self.colors.size()

    def __repr__(self):
        return 'ColorList(%s)' % str(self)

    def __richcmp__(ColorList self, ColorList other, int rcmp):
        return cmpToRichcmp(compareContainers(self.colors, other.colors), rcmp)

    def __sizeof__(ColorList self):
        return self.colors.getSizeOf()

    def __str__(ColorList self):
        return toString(self.colors).decode('ascii')

    # List operations.
    cpdef ColorList append(ColorList self, Color c):
        """Append to the list of colors."""
        self.colors.push_back(c.color)
        return self

    cpdef ColorList clear(self):
        """Resize the list of colors to 0."""
        self.colors.clear()
        return self

    cpdef ColorList copy(self):
        """Resize a copy of this list."""
        cdef ColorList cl = ColorList()
        cl.colors = self.colors
        return cl

    cpdef size_t count(self, Color color):
        """Return the number of times a color appears in this list."""
        return count(self.colors, color.color)

    cpdef ColorList extend(ColorList self, object values):
        """Extend the colors from an iterator."""
        appendInto(ColorList(values).colors, self.colors)
        return self

    cpdef index(ColorList self, Color color):
        """Returns an index to the first occurance of that Color, or
           raises a ValueError if that Color isn't there."""
        cdef int id = indexOf(self.colors, color.color)
        if id >= 0:
            return id
        raise ValueError('Can\'t find color %s' % color)

    cpdef ColorList insert(ColorList self, int key,
                                   Color color):
        """Insert a color before key."""
        insertBefore(self.colors, key, color.color)
        return self

    cpdef Color pop(ColorList self, int key = -1):
        """Pop the color at key."""
        cdef Color result = Color()
        if popAt(self.colors, key, result.color):
            return result
        raise IndexError('pop index out of range')

    cpdef ColorList remove(self, Color color):
        """Find and remove a specific color."""
        self.pop(self.index(color))
        return self

    cpdef ColorList resize(ColorList self, size_t size):
        """Set the size of the ColorList, filling with black if needed."""
        self.colors.resize(size)
        return self

    cpdef ColorList reverse(self):
        """Reverse the colors in place."""
        reverse(self.colors)
        return self

    cpdef ColorList rotate(self, int pos):
        """In-place rotation of the colors forward by `pos` positions."""
        rotate(self.colors, pos)
        return self

    cpdef ColorList sort(self, object key=None, bool reverse=False):
        """Sort items."""
        if key is None:
            sortColors(self.colors)
            if reverse:
                self.reverse()
        else:
            self[:] = sorted(self, key=key, reverse=reverse)
        return self

    # Basic arithmetic operations.
    cpdef ColorList add(ColorList self, c):
        """Add into colors from either a number or a ColorList."""
        if isinstance(c, Number):
            addInto(<float> c, self.colors)
        else:
            addInto((<ColorList> c).colors, self.colors)
        return self

    cpdef ColorList div(ColorList self, c):
        """Divide colors by either a number or a ColorList."""
        if isinstance(c, Number):
            divideInto(<float> c, self.colors)
        else:
            divideInto((<ColorList> c).colors, self.colors)
        return self

    cpdef ColorList mul(ColorList self, c):
        """Multiply colors by either a number or a ColorList."""
        if isinstance(c, Number):
            multiplyInto(<float> c, self.colors)
        else:
            multiplyInto((<ColorList> c).colors, self.colors)
        return self

    cpdef ColorList pow(ColorList self, float c):
        """Raise each color to the given power (gamma correction)."""
        if isinstance(c, Number):
            powInto(<float> c, self.colors)
        else:
            powInto((<ColorList> c).colors, self.colors)
        return self

    cpdef ColorList sub(ColorList self, c):
        """Subtract either a number or a ColorList from the colors."""
        if isinstance(c, Number):
             subtractInto(<float> c, self.colors)
        else:
             subtractInto((<ColorList> c).colors, self.colors)
        return self

    # Arithmetic where "self" is on the right side.
    cpdef ColorList rdiv(ColorList self, c):
        """Right-side divide colors by either a number or a ColorList."""
        if isinstance(c, Number):
            rdivideInto(<float> c, self.colors)
        else:
            rdivideInto((<ColorList> c).colors, self.colors)
        return self

    cpdef ColorList rpow(ColorList self, c):
        """Right-hand (reversed) call of pow()."""
        if isinstance(c, Number):
            rpowInto(<float> c, self.colors)
        else:
            rpowInto((<ColorList> c).colors, self.colors)
        return self

    cpdef ColorList rsub(ColorList self, c):
        """Right-side subtract either a number or a ColorList."""
        if isinstance(c, Number):
             rsubtractInto(<float> c, self.colors)
        else:
             rsubtractInto((<ColorList> c).colors, self.colors)
        return self

    # Mutators corresponding to built-in operations.
    cpdef ColorList abs(self):
        """Replace each color by its absolute value."""
        absInto(self.colors)
        return self

    cpdef ColorList ceil(self):
        """Replace each color by its integer ceiling."""
        ceilInto(self.colors)
        return self

    cpdef ColorList floor(self):
        """Replace each color by its integer floor."""
        floorInto(self.colors)
        return self

    cpdef ColorList invert(self):
        """Replace each color by its complementary color."""
        invertColor(self.colors)
        return self

    cpdef ColorList neg(self):
        """Negate each color in the list."""
        negateColor(self.colors)
        return self

    cpdef ColorList round(self, uint digits=0):
        """Round each element in each color to the nearest integer."""
        roundColor(self.colors, digits)
        return self

    # Other mutators.
    cpdef ColorList trunc(self):
        """Truncate each value to an integer."""
        truncColor(self.colors)
        return self

    cpdef ColorList hsv_to_rgb(self):
        """Convert each color in the list from HSV to RBG."""
        hsvToRgbInto(self.colors, normal)
        return self

    cpdef ColorList max_limit(self, float max):
        """Limit each color to be not greater than max."""
        if isinstance(max, Number):
            minInto(<float> max, self.colors)
        else:
            minInto((<ColorList> max).colors, self.colors)
        return self

    cpdef ColorList min_limit(self, float min):
        """Limit each color to be not less than min."""
        if isinstance(min, Number):
            maxInto(<float> min, self.colors)
        else:
            maxInto((<ColorList> min).colors, self.colors)
        return self

    cpdef ColorList rgb_to_hsv(self):
        """Convert each color in the list from RBG to HSV."""
        rgbToHsvInto(self.colors, normal)
        return self

    cpdef ColorList zero(self):
        """Set all colors to black."""
        clearInto(self.colors)
        return self

    # Methods that do not change this ColorList.
    cpdef float distance2(ColorList self, ColorList x):
        """Return the square of the cartestian distance to another ColorList."""
        return distance2(self.colors, x.colors)

    cpdef float distance(ColorList self, ColorList x):
        """Return the cartestian distance to another ColorList."""
        return distance(self.colors, x.colors)

    cpdef Color max(self):
        """Return the maximum values of each component."""
        cdef ColorS c = maxColor(self.colors)
        return Color(c.red, c.green, c.blue)

    cpdef Color min(self):
        """Return the minimum values of each component/"""
        cdef ColorS c = minColor(self.colors)
        return Color(c.red, c.green, c.blue)

    @staticmethod
    def spread(*args):
        """Spreads!"""
        cdef ColorList cl = ColorList()
        cdef Color color
        cdef size_t last_number = 0

        def spread_append(item):
            nonlocal last_number
            if last_number:
                color = _toColor(item)
                spreadAppend(cl.colors, last_number - 1, color.color)
                last_number = 0

        for a in args:
            if isinstance(a, Number):
                last_number += a
            else:
                last_number += 1
                spread_append(a)

        spread_append(None)
        return cl