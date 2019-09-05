module draw;

import x11.X;
import x11.Xlib;
import x11.Xutil;
import cairo.cairo;
import cairo.c.cairo;
import cairo.c.xlib;

import core.thread;

class Draw
{
    private Display* display;
    private Window overlay;
    private int screen;
    private int width;
    private int height;
    private int scale;

    private cairo_surface_t* surf;
    private cairo_t* cr;

    this()
    {
        display = XOpenDisplay(null);
        if (!display)
            throw new Exception("Cannot open display");
        scope (exit)
            XCloseDisplay(display);
    
        screen = DefaultScreen(display);
        width = DisplayWidth(display, screen);
        height = DisplayHeight(display, screen);

        XVisualInfo vinfo;
        Window root = DefaultRootWindow(display);

        XSetWindowAttributes attrs;
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
        XMapWindow(display, overlay);

        surf = cairo_xlib_surface_create(display, overlay, vinfo.visual, width, height);
        cr = cairo_create(surf);
        cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 0.0);
        cairo_rectangle(cr, 0, 0, width, height);
        cairo_fill(cr);

        XFlush(display);

        Thread.sleep(dur!("seconds")(1));

        cairo_destroy(cr);
        cairo_surface_destroy(surf);
    }

    void startDraw()
    {
    
    }

    void drawCrossHair()
    {

    }

    void endDraw()
    {
    
    }

    void close()
    {
        XUnmapWindow(display, overlay);
        XCloseDisplay(display);
    }
}
