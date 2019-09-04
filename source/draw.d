module draw;

import x11.X;
import x11.Xlib;
import x11.Xutil;

/*
Display* display;
Window win;
int screen;
int width;
int height;

Colormap colormap;
GC gc;

extern(C)
{
    alias XserverRegion = XID;
    enum ShapeInput = 2;

    XserverRegion XFixesCreateRegion (Display *dpy, XRectangle *rectangles, int nrectangles);

    void XFixesSetWindowShapeRegion (Display *dpy, Window win, int shape_kind,
        int x_off, int y_off, XserverRegion region);

    void XFixesDestroyRegion (Display* dpy, XserverRegion region);

    bool XShapeQueryExtension (Display* display, int* shape_event_base, int* shape_error_base);
}

void drawWindow()
{
    openDisplay();
    createShapedWindow();

    //gc = XCreateGC(display, win, cast(ulong) 0, cast(XGCValues*) 0);
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

    int shape_event_base;
    int shape_error_base;

    if (!XShapeQueryExtension (display, &shape_event_base, &shape_error_base)) {
       import std.stdio;
       writeln("e");
       return;
    }
}

void createShapedWindow() {
    XSetWindowAttributes wattr;
    XColor bgcolor = createXColorFromRGBA(0, 0, 0, 0);

    Window root = DefaultRootWindow(display);

    XVisualInfo vinfo;
    //XMatchVisualInfo(display, screen, 32, TrueColor, &vinfo);
    //colormap = XCreateColormap(display, DefaultRootWindow(display), vinfo.visual, AllocNone);

    XSetWindowAttributes attr;
    attr.background_pixmap = None;
    attr.background_pixel = bgcolor.pixel;
    attr.border_pixel=0;
    attr.win_gravity=NorthWestGravity;
    attr.bit_gravity=ForgetGravity;
    attr.save_under=1;
    attr.event_mask=(StructureNotifyMask|ExposureMask|PropertyChangeMask|EnterWindowMask|LeaveWindowMask|KeyPressMask|KeyReleaseMask|KeymapStateMask);
    attr.do_not_propagate_mask=(KeyPressMask|KeyReleaseMask|ButtonPressMask|ButtonReleaseMask|PointerMotionMask|ButtonMotionMask);
    attr.override_redirect=1; // OpenGL > 0
    //attr.colormap = colormap;

    //unsigned long mask = CWBackPixel|CWBorderPixel|CWWinGravity|CWBitGravity|CWSaveUnder|CWEventMask|CWDontPropagate|CWOverrideRedirect;
    ulong mask = CWColormap | CWBorderPixel | CWBackPixel | CWEventMask | CWWinGravity|CWBitGravity | CWSaveUnder | CWDontPropagate | CWOverrideRedirect;

    win = XCreateWindow(display, root, 0, 0, 3840, 2160, 0, vinfo.depth, InputOutput, vinfo.visual, mask, &attr);

    //XShapeCombineMask(g_display, g_win, ShapeBounding, 900, 500, g_bitmap, ShapeSet);
    //XShapeCombineMask(display, win, ShapeInput, 0, 0, None, ShapeSet);

    // We want shape-changed event too
    //XShapeSelectInput (display, win, SHAPE_MASK);

    // Tell the Window Manager not to draw window borders (frame) or title.
    wattr.override_redirect = 1;
    XChangeWindowAttributes(display, win, CWOverrideRedirect, &wattr);

    // Allow input passthrough
    XserverRegion region = XFixesCreateRegion(display, null, 0);
    //XFixesSetWindowShapeRegion (display, win, ShapeBounding, 0, 0, 0);
    XFixesSetWindowShapeRegion(display, win, ShapeInput, 0, 0, region);
    XFixesDestroyRegion(display, region);

    // Show the window
    XMapWindow(display, win);
}

XColor createXColorFromRGBA(short red, short green, short blue, short alpha) {
    XColor color;

    // m_color.red = red * 65535 / 255;
    color.red = cast(short) ((red * 0xFFFF) / 0xFF);
    color.green = cast(short) ((green * 0xFFFF) / 0xFF);
    color.blue = cast(short) ((blue * 0xFFFF) / 0xFF);
    color.flags = DoRed | DoGreen | DoBlue;

    //XAllocColor(display, DefaultColormap(display, screen), &color);

    *(&color.pixel) = ((*(&color.pixel)) & 0x00ffffff) | (alpha << 24);
    return color;
}
*/

extern(C++)
{
    class Draw {
        public:
        this();
        //void drawString(const char* text, int x, int y, XColor fgcolor, XColor bgcolor, int align);
        void clearArea(int x, int y, int width, int height);
        void fillRectangle(int x, int y, int width, int height, XColor color);
        void drawLine(int x1, int y1, int x2, int y2, XColor color);
        XColor createXColorFromRGBA(short red, short green, short blue, short alpha);
        XColor createXColorFromRGB(short red, short green, short blue);
        void addCaptureArea(XRectangle rect);
        void clearCaptureAreas();
        void createShapedWindow();
        void openDisplay();
        void allow_input_passthrough (Window w);
        void list_fonts();
        void init();
        void halt();
        void toggleoverlay(bool state);
        void toggleoverlay();
        void startCaptureInput();
        void stopCaptureInput();
        void setCaptureInput(bool state);
        void clearscreen();
        void startdraw();
        void enddraw();
        Display *g_display;
        int      g_screen;
        Window   g_win;
        int      g_disp_width;
        int      g_disp_height;
        Colormap g_colormap;
        bool overlayenabled = true;
        bool overlayavailable = false;
        bool doesCaptureInput = false;
        void* captureAreas;
        GC       gc;
        XGCValues   gcv;
        XFontStruct * font;
        XColor red, black, blacka, blackla, white, transparent, ltblue, blue, yellow, grey, ltgrey, ltred, ltyellow, green, blackma;
    
        const char* font_name = "-misc-dejavu sans mono-medium-o-normal--0-0-0-0-m-0-ascii-0";
        const int font_width = 9;
        const int font_height = 15;
    
        // The window size
        int WIDTH  = 3840;
        int HEIGHT = 2160;
    
        int posx = 0;
        int posy = 0;
    
    
        private:
        long event_mask = (StructureNotifyMask|ExposureMask|PropertyChangeMask|EnterWindowMask|LeaveWindowMask|KeyRelease|ButtonPress|ButtonRelease|KeymapStateMask);
        int shape_event_base;
        int shape_error_base;
        int renderi = 0;
    }
}
