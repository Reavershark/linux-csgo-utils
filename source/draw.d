module draw;

import x11.X;
import x11.Xlib;
import x11.Xutil;
import cairo.cairo;
import cairo.c.cairo;
import cairo.c.xlib;

import core.thread;

extern(C)
{
    alias XserverRegion = XID;
    XserverRegion XFixesCreateRegion(Display *dpy, XRectangle *rectangles, int nrectangles);
    void XFixesSetWindowShapeRegion (Display *dpy, Window win, int shape_kind, int x_off, int y_off, XserverRegion region);
    enum ShapeInput = 2;
    void XFixesDestroyRegion(Display *dpy, XserverRegion region);
}

class Draw
{
    private Display* display;
    private Window overlay;
    private int screen;
    private XVisualInfo vinfo;
    private Window root;
    private XSetWindowAttributes attrs;
    private XserverRegion region;

    private int width;
    private int height;
    private int scale = 2;

    private cairo_surface_t* surf;
    private cairo_t* cr;

    bool initialized = false;

    void init()
    {
        display = XOpenDisplay(null);
        if (!display)
            throw new Exception("Cannot open display");
        scope (exit)
            XCloseDisplay(display);
    
        screen = DefaultScreen(display);
        width = DisplayWidth(display, screen);
        height = DisplayHeight(display, screen);

        root = DefaultRootWindow(display);
        attrs.override_redirect = true;
        if (!XMatchVisualInfo(display, DefaultScreen(display), 32, TrueColor, &vinfo)) {
            throw new Exception("No 32-bit depth / TrueColor support");
        }
        attrs.colormap = XCreateColormap(display, root, vinfo.visual, AllocNone);
        attrs.background_pixel = 0;
        attrs.border_pixel = 0;
        overlay = XCreateWindow(
            display, root,
            0, 0, width, height, 0,
            vinfo.depth, InputOutput,
            vinfo.visual,
            CWOverrideRedirect | CWColormap | CWBackPixel | CWBorderPixel, &attrs
        );
        // Allow input passtrough
        region = XFixesCreateRegion(display, null, 0);
        XFixesSetWindowShapeRegion (display, overlay, ShapeInput, 0, 0, region);
        XFixesDestroyRegion (display, region);
        XMapWindow(display, overlay);

        surf = cairo_xlib_surface_create(display, overlay, vinfo.visual, width, height);
        cr = cairo_create(surf);

        initialized = true;
        while (true) {}
    }

    void start()
    {
        XClearWindow(display, overlay);
    }

    void drawCrossHair(int xOffset, int yOffset)
    {
        // Color
        cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
        // Line shape
        int w = 1;
        int l = 5 * scale;
        // Center
        int x = width/2 - xOffset;
        int y = height/2 - yOffset;
        cairo_rectangle(cr, x-l, y-w, l*2, w*2); // Horizontal
        cairo_rectangle(cr, x-w, y-l, w*2, l*2); // Vertical
        cairo_fill(cr);
    }

    void end()
    {
        XFlush(display);
    }

    void close()
    {
        cairo_destroy(cr);
        cairo_surface_destroy(surf);
        XUnmapWindow(display, overlay);
        XCloseDisplay(display);
    }
}
