# https://github.com/sagemath/sage/blob/master/src/sage/plot/polygon.py 
from sage.plot.primitive import GraphicPrimitive_xydata
from sage.misc.decorators import options, rename_keyword
from sage.plot.colors import to_mpl_color

class Polygon(GraphicPrimitive_xydata):
    """
    Primitive class for the Polygon graphics type.  For information
    on actual plotting, please see :func:`polygon`, :func:`polygon2d`,
    or :func:`~sage.plot.plot3d.shapes2.polygon3d`.

    INPUT:

    - xdata - list of `x`-coordinates of points defining Polygon

    - ydata - list of `y`-coordinates of points defining Polygon

    - options - dict of valid plot options to pass to constructor

    EXAMPLES:

    Note this should normally be used indirectly via :func:`polygon`::

        sage: from sage.plot.polygon import Polygon
        sage: P = Polygon([1,2,3],[2,3,2],{'alpha':.5})
        sage: P
        Polygon defined by 3 points
        sage: P.options()['alpha']
        0.500000000000000
        sage: P.ydata
        [2, 3, 2]

    TESTS:

    We test creating polygons::

        sage: polygon([(0,0), (1,1), (0,1)])

    ::

        sage: polygon([(0,0,1), (1,1,1), (2,0,1)])
    """
    def __init__(self, xdata, ydata, options):
        """
        Initializes base class Polygon.

        EXAMPLES::

            sage: P = polygon([(0,0), (1,1), (-1,3)], thickness=2)
            sage: P[0].xdata
            [0.0, 1.0, -1.0]
            sage: P[0].options()['thickness']
            2
        """
        self.xdata = xdata
        self.ydata = ydata
        GraphicPrimitive_xydata.__init__(self, options)

    def _repr_(self):
        """
        String representation of Polygon primitive.

        EXAMPLES::

            sage: P = polygon([(0,0), (1,1), (-1,3)])
            sage: p=P[0]; p
            Polygon defined by 3 points
        """
        return "Polygon defined by %s points"%len(self)

    def __getitem__(self, i):
        """
        Returns `i`th vertex of Polygon primitive, starting count
        from 0th vertex.

        EXAMPLES::

            sage: P = polygon([(0,0), (1,1), (-1,3)])
            sage: p=P[0]
            sage: p[0]
            (0.0, 0.0)
        """
        return self.xdata[i], self.ydata[i]

    def __setitem__(self, i, point):
        """
        Changes `i`th vertex of Polygon primitive, starting count
        from 0th vertex.  Note that this only changes a vertex,
        but does not create new vertices.

        EXAMPLES::

            sage: P = polygon([(0,0), (1,2), (0,1), (-1,2)])
            sage: p=P[0]
            sage: [p[i] for i in range(4)]
            [(0.0, 0.0), (1.0, 2.0), (0.0, 1.0), (-1.0, 2.0)]
            sage: p[2]=(0,.5)
            sage: p[2]
            (0.0, 0.5)
        """
        i = int(i)
        self.xdata[i] = float(point[0])
        self.ydata[i] = float(point[1])

    def __len__(self):
        """
        Returns number of vertices of Polygon primitive.

        EXAMPLES::

            sage: P = polygon([(0,0), (1,2), (0,1), (-1,2)])
            sage: p=P[0]
            sage: len(p)
            4
        """
        return len(self.xdata)

    def _allowed_options(self):
        """
        Return the allowed options for the Polygon class.

        EXAMPLES::

            sage: P = polygon([(1,1), (1,2), (2,2), (2,1)], alpha=.5)
            sage: P[0]._allowed_options()['alpha']
            'How transparent the figure is.'
        """
        return {'alpha':'How transparent the figure is.',
                'thickness': 'How thick the border line is.',
                'fill':'Whether or not to fill the polygon.',
                'legend_label':'The label for this item in the legend.',
                'legend_color':'The color of the legend text.',
                'rgbcolor':'The color as an RGB tuple.',
                'hue':'The color given as a hue.',
                'zorder':'The layer level in which to draw'}

    def _plot3d_options(self, options=None):
        """
        Translate 2d plot options into 3d plot options.

        EXAMPLES::

            sage: P = polygon([(1,1), (1,2), (2,2), (2,1)], alpha=.5)
            sage: p=P[0]; p
            Polygon defined by 4 points
            sage: q=p.plot3d()
            sage: q.texture.opacity
            0.500000000000000
        """
        if options is None:
            options = dict(self.options())
        for o in ['thickness', 'zorder', 'legend_label', 'fill']:
            options.pop(o, None)
        return GraphicPrimitive_xydata._plot3d_options(self, options)

    def plot3d(self, z=0, **kwds):
        """
        Plots a 2D polygon in 3D, with default height zero.

        INPUT:


        -  ``z`` - optional 3D height above `xy`-plane, or a list of
           heights corresponding to the list of 2D polygon points.

        EXAMPLES:

        A pentagon::

            sage: polygon([(cos(t), sin(t)) for t in srange(0, 2*pi, 2*pi/5)]).plot3d()

        Showing behavior of the optional parameter z::

            sage: P = polygon([(0,0), (1,2), (0,1), (-1,2)])
            sage: p = P[0]; p
            Polygon defined by 4 points
            sage: q = p.plot3d()
            sage: q.obj_repr(q.testing_render_params())[2]
            ['v 0 0 0', 'v 1 2 0', 'v 0 1 0', 'v -1 2 0']
            sage: r = p.plot3d(z=3)
            sage: r.obj_repr(r.testing_render_params())[2]
            ['v 0 0 3', 'v 1 2 3', 'v 0 1 3', 'v -1 2 3']
            sage: s = p.plot3d(z=[0,1,2,3])
            sage: s.obj_repr(s.testing_render_params())[2]
            ['v 0 0 0', 'v 1 2 1', 'v 0 1 2', 'v -1 2 3']

        TESTS:

        Heights passed as a list should have same length as
        number of points::

            sage: P = polygon([(0,0), (1,2), (0,1), (-1,2)])
            sage: p = P[0]
            sage: q = p.plot3d(z=[2,-2])
            Traceback (most recent call last):
            ...
            ValueError: Incorrect number of heights given
        """
        from sage.plot.plot3d.index_face_set import IndexFaceSet
        options = self._plot3d_options()
        options.update(kwds)
        zdata=[]
        if type(z) is list:
            zdata=z
        else:
            zdata=[z]*len(self.xdata)
        if len(zdata)==len(self.xdata):
            return IndexFaceSet([[(x, y, z) for x, y, z in zip(self.xdata, self.ydata, zdata)]], **options)
        else:
            raise ValueError, 'Incorrect number of heights given'

    def _render_on_subplot(self, subplot):
        """
        TESTS::

            sage: P = polygon([(0,0), (1,2), (0,1), (-1,2)])
        """
        import matplotlib.patches as patches
        options = self.options()
        p = patches.Polygon([(self.xdata[i],self.ydata[i]) for i in xrange(len(self.xdata))])
        p.set_linewidth(float(options['thickness']))
        a = float(options['alpha'])
        z = int(options.pop('zorder', 1))
        p.set_alpha(a)
        f = options.pop('fill')
        p.set_fill(f)
        c = to_mpl_color(options['rgbcolor'])
        p.set_edgecolor(c)
        p.set_facecolor(c)
        p.set_label(options['legend_label'])
        p.set_zorder(z)
        subplot.add_patch(p)

    def rotate(self, theta)

        for i in range(len(self.xdata[i])):
            self.xdata[i] = self.xdata[i]*costheta + self.ydata[i]*sintheta
            self.ydata[i] = self.ydata[i]*costheta - self.xdata[i]*sintheta
            print '(%s, %s)'%(self.xdata[i], self.ydata[i])
            return plot2d(self.xdata[i], self.ydata[i])

def polygon(points, **options):
    """
    Returns either a 2-dimensional or 3-dimensional polygon depending
    on value of points.

    For information regarding additional arguments, see either
    :func:`polygon2d` or :func:`~sage.plot.plot3d.shapes2.polygon3d`.
    Options may be found and set using the dictionaries ``polygon2d.options``
    and ``polygon3d.options``.

    EXAMPLES::

        sage: polygon([(0,0), (1,1), (0,1)])
        sage: polygon([(0,0,1), (1,1,1), (2,0,1)])

    Extra options will get passed on to show(), as long as they are valid::

        sage: polygon([(0,0), (1,1), (0,1)], axes=False)
        sage: polygon([(0,0), (1,1), (0,1)]).show(axes=False) # These are equivalent
    """
    try:
        return polygon2d(points, **options)
    except ValueError:
        from sage.plot.plot3d.shapes2 import polygon3d
        return polygon3d(points, **options)

@rename_keyword(color='rgbcolor')
@options(alpha=1, rgbcolor=(0,0,1), thickness=None, legend_label=None, legend_color=None,
         aspect_ratio=1.0, fill=True)
def polygon2d(points, **options):
    r"""
    Returns a 2-dimensional polygon defined by ``points``.

    Type ``polygon2d.options`` for a dictionary of the default
    options for polygons.  You can change this to change the
    defaults for all future polygons.  Use ``polygon2d.reset()``
    to reset to the default options.

    EXAMPLES:

    We create a purple-ish polygon::

        sage: polygon2d([[1,2], [5,6], [5,0]], rgbcolor=(1,0,1))

    By default, polygons are filled in, but we can make them
    without a fill as well::

        sage: polygon2d([[1,2], [5,6], [5,0]], fill=False)

    In either case, the thickness of the border can be controlled::

        sage: polygon2d([[1,2], [5,6], [5,0]], fill=False, thickness=4, color='orange')

    Some modern art -- a random polygon, with legend::

        sage: v = [(randrange(-5,5), randrange(-5,5)) for _ in range(10)]
        sage: polygon2d(v, legend_label='some form')

    A purple hexagon::

        sage: L = [[cos(pi*i/3),sin(pi*i/3)] for i in range(6)]
        sage: polygon2d(L, rgbcolor=(1,0,1))

    A green deltoid::

        sage: L = [[-1+cos(pi*i/100)*(1+cos(pi*i/100)),2*sin(pi*i/100)*(1-cos(pi*i/100))] for i in range(200)]
        sage: polygon2d(L, rgbcolor=(1/8,3/4,1/2))

    A blue hypotrochoid::

        sage: L = [[6*cos(pi*i/100)+5*cos((6/2)*pi*i/100),6*sin(pi*i/100)-5*sin((6/2)*pi*i/100)] for i in range(200)]
        sage: polygon2d(L, rgbcolor=(1/8,1/4,1/2))

    Another one::

        sage: n = 4; h = 5; b = 2
        sage: L = [[n*cos(pi*i/100)+h*cos((n/b)*pi*i/100),n*sin(pi*i/100)-h*sin((n/b)*pi*i/100)] for i in range(200)]
        sage: polygon2d(L, rgbcolor=(1/8,1/4,3/4))

    A purple epicycloid::

        sage: m = 9; b = 1
        sage: L = [[m*cos(pi*i/100)+b*cos((m/b)*pi*i/100),m*sin(pi*i/100)-b*sin((m/b)*pi*i/100)] for i in range(200)]
        sage: polygon2d(L, rgbcolor=(7/8,1/4,3/4))

    A brown astroid::

        sage: L = [[cos(pi*i/100)^3,sin(pi*i/100)^3] for i in range(200)]
        sage: polygon2d(L, rgbcolor=(3/4,1/4,1/4))

    And, my favorite, a greenish blob::

        sage: L = [[cos(pi*i/100)*(1+cos(pi*i/50)), sin(pi*i/100)*(1+sin(pi*i/50))] for i in range(200)]
        sage: polygon2d(L, rgbcolor=(1/8, 3/4, 1/2))

    This one is for my wife::

        sage: L = [[sin(pi*i/100)+sin(pi*i/50),-(1+cos(pi*i/100)+cos(pi*i/50))] for i in range(-100,100)]
        sage: polygon2d(L, rgbcolor=(1,1/4,1/2))

    One can do the same one with a colored legend label::

        sage: polygon2d(L, color='red', legend_label='For you!', legend_color='red')

    Polygons have a default aspect ratio of 1.0::

        sage: polygon2d([[1,2], [5,6], [5,0]]).aspect_ratio()
        1.0

    AUTHORS:

    - David Joyner (2006-04-14): the long list of examples above.

    """
    from sage.plot.plot import xydata_from_point_list
    from sage.plot.all import Graphics
    if options["thickness"] is None:    # If the user did not specify thickness
        if options["fill"]:                 # If the user chose fill
            options["thickness"] = 0
        else:
            options["thickness"] = 1
    xdata, ydata = xydata_from_point_list(points)
    g = Graphics()

    # Reset aspect_ratio to 'automatic' in case scale is 'semilog[xy]'.
    # Otherwise matplotlib complains.
    scale = options.get('scale', None)
    if isinstance(scale, (list, tuple)):
        scale = scale[0]
    if scale == 'semilogy' or scale == 'semilogx':
        options['aspect_ratio'] = 'automatic'

    g._set_extra_kwds(Graphics._extract_kwds_for_show(options))
    g.add_primitive(Polygon(xdata, ydata, options))
    if options['legend_label']:
        g.legend(True)
        g._legend_colors = [options['legend_color']]
    return g









