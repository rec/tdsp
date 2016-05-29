# Automatically generated by {script} from {template_file}

from numbers import Number

cdef class ColorList{suffix}:
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

    def __cinit__(self, items=None):
        """Construct a ColorList with an iterator of items, each of which looks
           like a Color."""
        if items is not None:
            if isinstance(items, ColorList{suffix}):
                self.colors = (<ColorList{suffix}> items).colors
            else:
                # A list of tuples, Colors or strings.
                self.colors.resize(len(items))
                for i, item in enumerate(items):
                    self[i] = item

    def __setitem__(self, object key, object x):
        cdef size_t length, slice_length
        cdef int begin, end, step, index
        cdef float r, g, b
        cdef ColorList{suffix} cl
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            if sliceIntoVector(_toColorList{suffix}(x).colors, self.colors,
                               begin, end, step):
                return
            raise ValueError('attempt to assign sequence of one size '
                             'to extended slice of another size')
        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(index))
        try:
            if isinstance(x, str):
                x = Color{suffix}(x)
            r, g, b = x
            self.colors.setColor(index, r, g, b)
        except:
            raise ValueError('Can\'t convert ' + str(x) + ' to a color')

    def __getitem__(self, object key):
        cdef ColorS c
        cdef int index
        if isinstance(key, slice):
            begin, end, step = key.indices(self.colors.size())
            cl = ColorList{suffix}()
            cl.colors = sliceVector(self.colors, begin, end, step)
            return cl

        index = key
        if not self.colors.fixKey(index):
            raise IndexError('ColorList index out of range ' + str(key))

        c = self.colors[index]
        return Color{suffix}(c.red, c.green, c.blue)

    # Unary operators and corresponding mutators.
    cpdef abs(self):
        """Replace each color by its absolute value."""
        absInto(self.colors)
        return self

    def __abs__(self):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        cl.abs()
        return cl

    cpdef ceil(self):
        """Replace each color by its integer ceiling."""
        ceilInto(self.colors)
        return self

    def __ceil__(self):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        cl.ceil()
        return cl

    cpdef floor(self):
        """Replace each color by its integer floor."""
        floorInto(self.colors)
        return self

    def __floor__(self):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        cl.floor()
        return cl

    cpdef invert(self):
        """Replace each color by its complementary color."""
        invertColor(self.colors)
        return self

    def __invert__(self):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        cl.invert()
        return cl

    cpdef neg(self):
        """Negate each color in the list."""
        negateColor(self.colors)
        return self

    def __neg__(self):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        cl.negative()
        return cl

    cpdef round(self, uint digits=0):
        """Round each element in each color to the nearest integer."""
        roundColor(self.colors, digits)
        return self

    def __round__(self, uint digits=0):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        cl.round(digits)
        return cl

    cpdef trunc(self):
        """Truncate each value to an integer."""
        truncColor(self.colors)
        return self

    def __trunc__(self):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cl.colors = self.colors
        cl.trunc()
        return cl

    # List operations.
    cpdef append(self, object x):
        """Append to the list of colors."""
        cdef Color{suffix} c = _toColor{suffix}(x)
        self.colors.push_back(c.color)

    cpdef duplicate(self, uint count):
        """Return a new `ColorList` with `count` copies of this one."""
        duplicateInto(count, self.colors)
        return self

    cpdef extend(ColorList{suffix} self, object values):
        """Extend the colors from an iterator."""
        appendInto(ColorList{suffix}(values).colors, self.colors)
        return self

    cpdef resize(self, size_t size):
        """Set the size of the ColorList, filling with black if needed."""
        self.colors.resize(size)
        return self

    cpdef reverse(self):
        """Reverse the colors in place."""
        reverse(self.colors)
        return self

    cpdef rotate(self, int pos):
        """In-place rotation of the colors forward by `pos` positions."""
        rotate(self.colors, pos)
        return self

    # Arithemetic and color operations.
    cpdef clear(self):
        """Set all colors to black."""
        clearInto(self.colors)
        return self

    cpdef hsv_to_rgb(self):
        """Convert each color in the list from HSV to RBG."""
        hsvToRgbInto(self.colors, {base})
        return self

    cpdef max(self):
        """Return the maximum values for each component"""
        cdef ColorS c = maxColor(self.colors)
        return Color{suffix}(c.red, c.green, c.blue)

    cpdef min(self):
        """Return the minimum values of each component"""
        cdef ColorS c = minColor(self.colors)
        return Color{suffix}(c.red, c.green, c.blue)

    cpdef max_limit(self, float max):
        """Limit each color to be not greater than max."""
        if isinstance(max, Number):
            minInto(<float> max, self.colors)
        else:
            minInto(_toColorList{suffix}(max).colors, self.colors)
        return self

    cpdef min_limit(self, float min):
        """Limit each color to be not less than min."""
        if isinstance(min, Number):
            maxInto(<float> min, self.colors)
        else:
            maxInto(_toColorList{suffix}(min).colors, self.colors)
        return self

    cpdef pow(self, float c):
        """Raise each color to the given power (gamma correction)."""
        if isinstance(c, Number):
            powInto(<float> c, self.colors)
        else:
            powInto(_toColorList{suffix}(c).colors, self.colors)
        return self

    cpdef rgb_to_hsv(self):
        """Convert each color in the list from RBG to HSV."""
        rgbToHsvInto(self.colors, {base})
        return self

    cpdef rpow(self, c):
        """Right-hand (reversed) call of pow()."""
        if isinstance(c, Number):
            rpowInto(<float> c, self.colors)
        else:
            rpowInto(_toColorList{suffix}(c).colors, self.colors)
        return self

    # Mutating operations.
    def __iadd__(self, c):
        if isinstance(c, Number):
            addInto(<float> c, self.colors)
        else:
            addInto(_toColorList{suffix}(c).colors, self.colors)
        return self

    def __imul__(self, c):
        if isinstance(c, Number):
            multiplyInto(<float> c, self.colors)
        else:
            multiplyInto(_toColorList{suffix}(c).colors, self.colors)
        return self

    def __ipow__(self, c):
        if isinstance(c, Number):
             powInto(<float> c, self.colors)
        else:
             powInto(_toColorList{suffix}(c).colors, self.colors)
        return self

    def __isub__(self, c):
        if isinstance(c, Number):
             subtractInto(<float> c, self.colors)
        else:
             subtractInto(_toColorList{suffix}(c).colors, self.colors)
        return self

    def __itruediv__(self, c):
        if isinstance(c, Number):
            divideInto(<float> c, self.colors)
        else:
            divideInto(_toColorList{suffix}(c).colors, self.colors)
        return self

    # Magic methods that create new ColorLists.
    def __add__(self, c):
        cdef ColorList{suffix} cl = ColorList{suffix}()

        if isinstance(c, Number):
            addOver((<ColorList{suffix}> self).colors, <float> c, cl.colors)
        elif isinstance(self, ColorList{suffix}):
            addOver((<ColorList{suffix}> self).colors,
                    _toColorList{suffix}(c).colors, cl.colors)
        elif isinstance(self, Number):
            addOver(<float> self, _toColorList{suffix}(c).colors, cl.colors)
        else:
            addOver(ColorList{suffix}(self).colors,
                    (<ColorList{suffix}> c).colors, cl.colors)
        return cl

    def __mul__(self, c):
        cdef ColorList{suffix} cl = ColorList{suffix}()

        if isinstance(c, Number):
            mulOver((<ColorList{suffix}> self).colors, <float> c, cl.colors)
        elif isinstance(self, ColorList{suffix}):
            mulOver((<ColorList{suffix}> self).colors,
                    _toColorList{suffix}(c).colors, cl.colors)
        elif isinstance(self, Number):
            mulOver(<float> self, _toColorList{suffix}(c).colors, cl.colors)
        else:
            mulOver(ColorList{suffix}(self).colors,
                    (<ColorList{suffix}> c).colors, cl.colors)
        return cl

    def __pow__(self, c, mod):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        if mod:
            raise ValueError('Can\'t handle three operator pow')

        if isinstance(c, Number):
            powOver((<ColorList{suffix}> self).colors, <float> c, cl.colors)
        elif isinstance(self, ColorList{suffix}):
            powOver((<ColorList{suffix}> self).colors,
                    _toColorList{suffix}(c).colors, cl.colors)
        elif isinstance(self, Number):
            powOver(<float> self, _toColorList{suffix}(c).colors, cl.colors)
        else:
            powOver(ColorList{suffix}(self).colors,
                    (<ColorList{suffix}> c).colors, cl.colors)
        return cl

    def __sub__(self, c):
        cdef ColorList{suffix} cl = ColorList{suffix}()

        if isinstance(c, Number):
            subOver((<ColorList{suffix}> self).colors, <float> c, cl.colors)
        elif isinstance(self, ColorList{suffix}):
            subOver((<ColorList{suffix}> self).colors,
                    _toColorList{suffix}(c).colors, cl.colors)
        elif isinstance(self, Number):
            subOver(<float> self, _toColorList{suffix}(c).colors, cl.colors)
        else:
            subOver(ColorList{suffix}(self).colors,
                    (<ColorList{suffix}> c).colors, cl.colors)
        return cl

    def __truediv__(self, c):
        cdef ColorList{suffix} cl = ColorList{suffix}()
        if isinstance(c, Number):
            divOver((<ColorList{suffix}> self).colors, <float> c, cl.colors)
        elif isinstance(self, ColorList{suffix}):
            divOver((<ColorList{suffix}> self).colors,
                    _toColorList{suffix}(c).colors, cl.colors)
        elif isinstance(self, Number):
            divOver(<float> self, _toColorList{suffix}(c).colors, cl.colors)
        else:
            divOver(ColorList{suffix}(self).colors,
                    (<ColorList{suffix}> c).colors, cl.colors)
        return cl

    # Other key magic methods.
    def __len__(self):
        return self.colors.size()

    def __repr__(self):
        return 'ColorList{suffix}(%s)' % str(self)

    def __richcmp__(ColorList{suffix} self, ColorList{suffix} other, int rcmp):
        return cmpToRichcmp(compareContainers(self.colors, other.colors), rcmp)

    def __sizeof__(self):
        return self.colors.getSizeOf()

    def __str__(self):
        return toString(self.colors).decode('ascii')

    @staticmethod
    def spread(*args):
        """Spreads!"""
        cdef ColorList{suffix} cl = ColorList{suffix}()
        cdef Color{suffix} color
        cdef size_t last_number = 0

        def spread_append(item):
            nonlocal last_number
            if last_number:
                color = _toColor{suffix}(item)
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


cdef ColorList{suffix} _toColorList{suffix}(object value):
    if isinstance(value, ColorList{suffix}):
        return <ColorList{suffix}> value
    else:
        return ColorList{suffix}(value)
