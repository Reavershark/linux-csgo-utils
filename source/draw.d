module draw;

import x11.X;
import x11.Xlib;
import x11.Xutil;
import cairo.cairo;
import cairo.c.cairo;
import cairo.c.xlib;

class Draw
{
    Display* display;
    Window root;
    int screen;
    int width;
    int height;

    XVisualInfo vinfo;
    Window overlay;

    cairo_surface_t* surf;
    cairo_t* cr;
    
    this()
    {
        openDisplay();
        createOverlay();

        surf = cairo_xlib_surface_create(display, overlay, vinfo.visual, 200, 200);
        cr = cairo_create(surf);
        drawRectangle(cr);

        XFlush(display);
    }

    void openDisplay()
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
    }

    void createOverlay()
    {
        XSetWindowAttributes attrs;
        attrs.override_redirect = true;
        //overlay = XCreateWindow(
        //    display, root,
        //    0, 0, 200, 200, 0,
        //    vinfo.depth, InputOutput,
        //    vinfo.visual,
        //    CWOverrideRedirect | CWColormap | CWBackPixel | CWBorderPixel, &attrs
        //);

        overlay = XCreateWindow(
            display, root,
            0, 0, 200, 200, 0,
            vinfo.depth, InputOutput,
            vinfo.visual,
            CWOverrideRedirect | CWColormap | CWBackPixel | CWBorderPixel, &attrs
        );
        XMapWindow(display, overlay);
    }

    void drawRectangle(cairo_t *cr)
    {
        cairo_set_source_rgba(cr, 1.0, 0.0, 0.0, 0.5);
        cairo_rectangle(cr, 0, 0, 200, 200);
        cairo_fill(cr);
    }

    void close()
    {
        cairo_destroy(cr);
        cairo_surface_destroy(surf);

        XUnmapWindow(display, overlay);
        XCloseDisplay(display);
    }
}
