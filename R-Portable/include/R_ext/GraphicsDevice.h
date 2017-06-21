/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2001-11 The R Core Team.
 *
 *  This header file is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2.1 of the License, or
 *  (at your option) any later version.
 *
 *  This file is part of R. R is distributed under the terms of the
 *  GNU General Public License, either Version 2, June 1991 or Version 3,
 *  June 2007. See doc/COPYRIGHTS for details of the copyright status of R.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 */

/* Used by third-party graphics devices.
 *
 * This defines DevDesc, whereas GraphicsEngine.h defines GEDevDesc.
 * Also contains entry points from gevents.c
 */

#ifndef R_GRAPHICSDEVICE_H_
#define R_GRAPHICSDEVICE_H_


/* ideally we would use prototypes in DevDesc.  
   Some devices have taken to passing pointers to their own structure
   instead of DevDesc* , defining R_USE_PROTOTYPES 0 allows them to
   opt out.
*/

#ifndef  R_USE_PROTOTYPES
# define R_USE_PROTOTYPES 1
# ifndef R_GRAPHICSENGINE_H_
#  error R_ext/GraphicsEngine.h must be included first, and includes this header
# endif
#endif

#include <R_ext/Boolean.h>

#ifdef __cplusplus
extern "C" {
#endif

/* --------- New (in 1.4.0) device driver structure ---------
 * NOTES:
 * 1. All locations and dimensions are in device coordinates.
 * 2. I found this comment in the doc for dev_Open -- looks nasty
 *    Any known instances of such a thing happening?  Should be
 *    replaced by a function to query the device for preferred gpars
 *    settings? (to be called when the device is initialised)
         *
         * NOTE that it is perfectly acceptable for this
         * function to set generic graphics parameters too
         * (i.e., override the generic parameter settings
         * which GInit sets up) all at the author's own risk
         * of course :)
	 *
 * 3. Do we really need dev_StrWidth as well as dev_MetricInfo?
 *    I can see the difference between the two -- its just a
 *    question of whether dev_MetricInfo should just return
 *    what dev_StrWidth would give if font metric information is
 *    not available.  I guess having both allows the developer
 *    to decide when to ask for which sort of value, and to decide
 *    what to do when font metric information is not available.
 *    And why not a dev_StrHeight?
 * 4. Should "ipr", "asp", and "cra" be in the device description?
 *    If not, then where?
 *    I guess they don't need to be if no device makes use of them.
 *    On the other hand, they would need to be replaced by a device
 *    call that R base graphics could use to get enough information
 *    to figure them out.  (e.g., some sort of dpi() function to
 *    complement the size() function.)
 */

typedef struct _DevDesc DevDesc;
typedef DevDesc* pDevDesc;

struct _DevDesc {
    /********************************************************
     * Device physical characteristics
     ********************************************************/
    double left;	        /* left raster coordinate */
    double right;	        /* right raster coordinate */
    double bottom;	        /* bottom raster coordinate */
    double top;		        /* top raster coordinate */
    /* R only has the notion of a rectangular clipping region
     */
    double clipLeft;
    double clipRight;
    double clipBottom;
    double clipTop;
    /* I hate these next three -- they seem like a real fudge
     * BUT I'm not sure what to replace them with so they stay for now.
     */
    double xCharOffset;	        /* x character addressing offset - unused */
    double yCharOffset;	        /* y character addressing offset */
    double yLineBias;	        /* 1/2 interline space as frac of line height */
    double ipr[2];	        /* Inches per raster; [0]=x, [1]=y */
    /* I hate this guy too -- seems to assume that a device can only
     * have one font size during its lifetime
     * BUT removing/replacing it would take quite a lot of work
     * to design and insert a good replacement so it stays for now.
     */
    double cra[2];	        /* Character size in rasters; [0]=x, [1]=y */
    double gamma;	        /* (initial) Device Gamma Correction */
    /********************************************************
     * Device capabilities
     ********************************************************/
    Rboolean canClip;		/* Device-level clipping */
    Rboolean canChangeGamma;    /* can the gamma factor be modified? */
    int canHAdj;	        /* Can do at least some horiz adjust of text
			           0 = none, 1 = {0,0.5,1}, 2 = [0,1] */
    /********************************************************
     * Device initial settings
     ********************************************************/
    /* These are things that the device must set up when it is created.
     * The graphics system can modify them and track current values,
     */
    double startps;
    int startcol;  /* sets par("fg"), par("col") and gpar("col") */
    int startfill; /* sets par("bg") and gpar("fill") */
    int startlty;
    int startfont;
    double startgamma;
    /********************************************************
     * Device specific information
     ********************************************************/
    void *deviceSpecific;	/* pointer to device specific parameters */
    /********************************************************
     * Device display list
     ********************************************************/
    Rboolean displayListOn;     /* toggle for initial display list status */


    /********************************************************
     * Event handling entries
     ********************************************************/

    /* Used in do_setGraphicsEventEnv */

    Rboolean canGenMouseDown; /* can the device generate mousedown events */
    Rboolean canGenMouseMove; /* can the device generate mousemove events */
    Rboolean canGenMouseUp;   /* can the device generate mouseup events */
    Rboolean canGenKeybd;     /* can the device generate keyboard events */
    Rboolean canGenIdle;      /* can the device generate idle events */
 
    Rboolean gettingEvent;    /* This is set while getGraphicsEvent
				 is actively looking for events */
    
    /********************************************************
     * Device procedures.
     ********************************************************/

    /*
     * ---------------------------------------
     * GENERAL COMMENT ON GRAPHICS PARAMETERS:
     * ---------------------------------------
     * Graphical parameters are now passed in a pointer to a 
     * graphics context structure (pGEcontext) rather than individually.
     * Each device action should extract the parameters it needs
     * and ignore the others.  Thought should be given to which
     * parameters are relevant in each case -- the graphics engine
     * does not REQUIRE that each parameter is honoured, but if
     * a parameter is NOT honoured, it might be a good idea to
     * issue a warning when a parameter is not honoured (or at
     * the very least document which parameters are not honoured
     * in the user-level documentation for the device).  [An example
     * of a parameter that may not be honoured by many devices is
     * transparency.]
     */

    /*
     * device_Activate is called when a device becomes the
     * active device.  For example, it can be used to change the
     * title of a window to indicate the active status of
     * the device to the user.  Not all device types will
     * do anything.
     * The only parameter is a device driver structure.
     * An example is ...
     *
     * static void   X11_Activate(pDevDesc dd);
     *
     * As from R 2.14.0 this can be omitted or set to NULL.
     */
#if R_USE_PROTOTYPES
    void (*activate)(const pDevDesc );
#else
    void (*activate)();
#endif
    /*
     * device_Circle should have the side-effect that a
     * circle is drawn, centred at the given location, with
     * the given radius.
     * (If the device has non-square pixels, 'radius' should
     * be interpreted in the units of the x direction.)
     * The border of the circle should be
     * drawn in the given "col", and the circle should be
     * filled with the given "fill" colour.
     * If "col" is NA_INTEGER then no border should be drawn
     * If "fill" is NA_INTEGER then the circle should not
     * be filled.
     * An example is ...
     *
     * static void X11_Circle(double x, double y, double r,
     *                        pGEcontext gc,
     *                        pDevDesc dd);
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   col, fill, gamma, lty, lwd
     */
#if R_USE_PROTOTYPES
    void (*circle)(double x, double y, double r, const pGEcontext gc, pDevDesc dd);
#else
    void (*circle)();
#endif
    /*
     * device_Clip is given the left, right, bottom, and
     * top of a rectangle (in DEVICE coordinates).
     * It should have the side-effect that subsequent output
     * is clipped to the given rectangle.
     * NOTE that R's graphics engine already clips to the
     * extent of the device.
     * NOTE also that this will probably only be called if
     * the flag canClip is true.
     * An example is ...
     *
     * static void X11_Clip(double x0, double x1, double y0, double y1,
     *                      pDevDesc dd)
     */
#if R_USE_PROTOTYPES
    void (*clip)(double x0, double x1, double y0, double y1, pDevDesc dd);
#else
    void (*clip)();
#endif
    /*
     * device_Close is called when the device is killed.
     * This function is responsible for destroying any
     * device-specific resources that were created in
     * device_Open and for FREEing the device-specific
     * parameters structure.
     * An example is ...
     *
     * static void X11_Close(pDevDesc dd)
     *
     */
#if R_USE_PROTOTYPES
    void (*close)(pDevDesc dd);
#else
    void (*close)();
#endif
    /*
     * device_Deactivate is called when a device becomes
     * inactive.
     * This allows the device to undo anything it did in
     * dev_Activate.
     * Not all device types will do anything.
     * An example is ...
     *
     * static void X11_Deactivate(pDevDesc dd)
     *
     * As from R 2.14.0 this can be omitted or set to NULL.
     */
#if R_USE_PROTOTYPES
    void (*deactivate)(pDevDesc );
#else
    void (*deactivate)();
#endif


    /*
     * device_Locator should return the location of the next
     * mouse click (in DEVICE coordinates)
     * Not all devices will do anything (e.g., postscript)
     * An example is ...
     *
     * static Rboolean X11_Locator(double *x, double *y, pDevDesc dd)
     *
     * As from R 2.14.0 this can be omitted or set to NULL.
     */
#if R_USE_PROTOTYPES
    Rboolean (*locator)(double *x, double *y, pDevDesc dd);
#else
    Rboolean (*locator)();
#endif
    /*
     * device_Line should have the side-effect that a single
     * line is drawn (from x1,y1 to x2,y2)
     * An example is ...
     *
     * static void X11_Line(double x1, double y1, double x2, double y2,
     *                      const pGEcontext gc,
     *                      pDevDesc dd);
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   col, gamma, lty, lwd
     */
#if R_USE_PROTOTYPES
    void (*line)(double x1, double y1, double x2, double y2,
		 const pGEcontext gc, pDevDesc dd);
#else
    void (*line)();
#endif
    /*
     * device_MetricInfo should return height, depth, and
     * width information for the given character in DEVICE
     * units.
     * Note: in an 8-bit locale, c is 'char'.
     * In an mbcslocale, it is wchar_t, and at least some
     * of code assumes that is UCS-2 (Windows, true) or UCS-4.
     * This is used for formatting mathematical expressions
     * and for exact centering of text (see GText)
     * If the device cannot provide metric information then
     * it MUST return 0.0 for ascent, descent, and width.
     * An example is ...
     *
     * static void X11_MetricInfo(int c,
     *                            const pGEcontext gc,
     *                            double* ascent, double* descent,
     *                            double* width, pDevDesc dd);
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   font, cex, ps
     */
#if R_USE_PROTOTYPES
    void (*metricInfo)(int c, const pGEcontext gc,
		       double* ascent, double* descent, double* width,
		       pDevDesc dd);
#else
    void (*metricInfo)();
#endif
    /*
     * device_Mode is called whenever the graphics engine
     * starts drawing (mode=1) or stops drawing (mode=0)
     * GMode (in graphics.c) also says that 
     * mode = 2 (graphical input on) exists.
     * The device is not required to do anything
     * An example is ...
     *
     * static void X11_Mode(int mode, pDevDesc dd);
     *
     * As from R 2.14.0 this can be omitted or set to NULL.
     */
#if R_USE_PROTOTYPES
    void (*mode)(int mode, pDevDesc dd);
#else
    void (*mode)();
#endif
    /*
     * device_NewPage is called whenever a new plot requires
     * a new page.
     * A new page might mean just clearing the
     * device (e.g., X11) or moving to a new page
     * (e.g., postscript)
     * An example is ...
     *
     *
     * static void X11_NewPage(const pGEcontext gc,
     *                         pDevDesc dd);
     *
     */
#if R_USE_PROTOTYPES
    void (*newPage)(const pGEcontext gc, pDevDesc dd);
#else
    void (*newPage)();
#endif
    /*
     * device_Polygon should have the side-effect that a
     * polygon is drawn using the given x and y values
     * the polygon border should be drawn in the "col"
     * colour and filled with the "fill" colour.
     * If "col" is NA_INTEGER don't draw the border
     * If "fill" is NA_INTEGER don't fill the polygon
     * An example is ...
     *
     * static void X11_Polygon(int n, double *x, double *y,
     *                         const pGEcontext gc,
     *                         pDevDesc dd);
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   col, fill, gamma, lty, lwd
     */
#if R_USE_PROTOTYPES
    void (*polygon)(int n, double *x, double *y, const pGEcontext gc, pDevDesc dd);
#else
    void (*polygon)();
#endif
    /*
     * device_Polyline should have the side-effect that a
     * series of line segments are drawn using the given x
     * and y values.
     * An example is ...
     *
     * static void X11_Polyline(int n, double *x, double *y,
     *                          const pGEcontext gc,
     *                          pDevDesc dd);
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   col, gamma, lty, lwd
     */
#if R_USE_PROTOTYPES
    void (*polyline)(int n, double *x, double *y, const pGEcontext gc, pDevDesc dd);
#else
    void (*polyline)();
#endif
    /*
     * device_Rect should have the side-effect that a
     * rectangle is drawn with the given locations for its
     * opposite corners.  The border of the rectangle
     * should be in the given "col" colour and the rectangle
     * should be filled with the given "fill" colour.
     * If "col" is NA_INTEGER then no border should be drawn
     * If "fill" is NA_INTEGER then the rectangle should not
     * be filled.
     * An example is ...
     *
     * static void X11_Rect(double x0, double y0, double x1, double y1,
     *                      const pGEcontext gc,
     *                      pDevDesc dd);
     *
     */
#if R_USE_PROTOTYPES
    void (*rect)(double x0, double y0, double x1, double y1,
		 const pGEcontext gc, pDevDesc dd);
#else
    void (*rect)();
#endif
    /* 
     * device_Path should draw one or more sets of points 
     * as a single path
     * 
     * 'x' and 'y' give the points
     *
     * 'npoly' gives the number of polygons in the path
     * MUST be at least 1
     *
     * 'nper' gives the number of points in each polygon
     * each value MUST be at least 2
     *
     * 'winding' says whether to fill using the nonzero 
     * winding rule or the even-odd rule
     *
     * Added 2010-06-27
     *
     * As from R 2.13.2 this can be left unimplemented as NULL.
     */
#if R_USE_PROTOTYPES
    void (*path)(double *x, double *y, 
                 int npoly, int *nper,
                 Rboolean winding,
                 const pGEcontext gc, pDevDesc dd);
#else
    void (*path)();
#endif
    /* 
     * device_Raster should draw a raster image justified 
     * at the given location,
     * size, and rotation (not all devices may be able to rotate?)
     * 
     * 'raster' gives the image data BY ROW, with every four bytes
     * giving one R colour (ABGR).
     *
     * 'x and 'y' give the bottom-left corner.
     *
     * 'rot' is in degrees (as per device_Text), with positive
     * rotation anticlockwise from the positive x-axis.
     *
     * As from R 2.13.2 this can be left unimplemented as NULL.
     */
#if R_USE_PROTOTYPES
    void (*raster)(unsigned int *raster, int w, int h,
                   double x, double y, 
                   double width, double height,
                   double rot, 
                   Rboolean interpolate,
                   const pGEcontext gc, pDevDesc dd);
#else
    void (*raster)();
#endif
    /* 
     * device_Cap should return an integer matrix (R colors)
     * representing the current contents of the device display.
     * 
     * The result is expected to be ROW FIRST.
     *
     * This will only make sense for raster devices and can 
     * probably only be implemented for screen devices.
     *
     * added 2010-06-27
     *
     * As from R 2.13.2 this can be left unimplemented as NULL.
     * For earlier versions of R it should return R_NilValue.
     */
#if R_USE_PROTOTYPES
    SEXP (*cap)(pDevDesc dd);
#else
    SEXP (*cap)();
#endif
    /*
     * device_Size is called whenever the device is
     * resized.
     * The function returns (left, right, bottom, and top) for the
     * new device size.
     * This is not usually called directly by the graphics
     * engine because the detection of device resizes
     * (e.g., a window resize) are usually detected by
     * device-specific code.
     * An example is ...
     *
     * static void X11_Size(double *left, double *right,
     *                      double *bottom, double *top,
     *                      pDevDesc dd);
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   col, fill, gamma, lty, lwd
     *
     * As from R 2.13.2 this can be left unimplemented as NULL.
     */
#if R_USE_PROTOTYPES
    void (*size)(double *left, double *right, double *bottom, double *top,
		 pDevDesc dd);
#else
    void (*size)();
#endif
    /*
     * device_StrWidth should return the width of the given
     * string in DEVICE units.
     * An example is ...
     *
     * static double X11_StrWidth(const char *str,
     *                            const pGEcontext gc,
     *                            pDevDesc dd)
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   font, cex, ps
     */
#if R_USE_PROTOTYPES
    double (*strWidth)(const char *str, const pGEcontext gc, pDevDesc dd);
#else
    double (*strWidth)();
#endif
    /*
     * device_Text should have the side-effect that the
     * given text is drawn at the given location.
     * The text should be rotated according to rot (degrees)
     * An example is ...
     *
     * static void X11_Text(double x, double y, const char *str,
     *                      double rot, double hadj,
     *                      const pGEcontext gc,
     * 	                    pDevDesc dd);
     *
     * R_GE_gcontext parameters that should be honoured (if possible):
     *   font, cex, ps, col, gamma
     */
#if R_USE_PROTOTYPES
    void (*text)(double x, double y, const char *str, double rot,
		 double hadj, const pGEcontext gc, pDevDesc dd);
#else
    void (*text)();
#endif
    /*
     * device_onExit is called by GEonExit when the user has aborted
     * some operation, and so an R_ProcessEvents call may not return normally.
     * It need not be set to any value; if null, it will not be called.
     *
     * An example is ...
     *
     * static void GA_onExit(pDevDesc dd);
    */
#if R_USE_PROTOTYPES
    void (*onExit)(pDevDesc dd);
#else
    void (*onExit)();
#endif
    /*
     * device_getEvent is no longer used, but the slot is kept for back
     * compatibility of the structure.
     */
    SEXP (*getEvent)(SEXP, const char *);

    /* --------- Optional features introduced in 2.7.0 --------- */

    /* Does the device have a device-specific way to confirm a 
       new frame (for e.g. par(ask=TRUE))?
       This should be NULL if it does not.
       If it does, it returns TRUE if the device handled this, and
       FALSE if it wants the engine to do so. 

       There is an example in the windows() device.

       Can be left unimplemented as NULL.
    */
#if R_USE_PROTOTYPES
    Rboolean (*newFrameConfirm)(pDevDesc dd);
#else
    Rboolean (*newFrameConfirm)();
#endif

    /* Some devices can plot UTF-8 text directly without converting
       to the native encoding, e.g. windows(), quartz() ....

       If this flag is true, all text *not in the symbol font* is sent
       in UTF8 to the textUTF8/strWidthUTF8 entry points.

       If the flag is TRUE, the metricInfo entry point should
       accept negative values for 'c' and treat them as indicating
       Unicode points (as well as positive values in a MBCS locale).
    */
    Rboolean hasTextUTF8; /* and strWidthUTF8 */
#if R_USE_PROTOTYPES
    void (*textUTF8)(double x, double y, const char *str, double rot,
		     double hadj, const pGEcontext gc, pDevDesc dd);
    double (*strWidthUTF8)(const char *str, const pGEcontext gc, pDevDesc dd);
#else
    void (*textUTF8)();
    double (*strWidthUTF8)();
#endif
    Rboolean wantSymbolUTF8;

    /* Is rotated text good enough to be preferable to Hershey in
       contour labels?  Old default was FALSE.
    */
    Rboolean useRotatedTextInContour;

    /* --------- Post-2.7.0 features --------- */

    /* Added in 2.12.0:  Changed graphics event handling. */
    
    SEXP eventEnv;   /* This is an environment holding event handlers. */
    /*
     * eventHelper(dd, 1) is called by do_getGraphicsEvent before looking for a 
     * graphics event.  It will then call R_ProcessEvents() and eventHelper(dd, 2)
     * until this or another device returns sets a non-null result value in eventEnv,
     * at which time eventHelper(dd, 0) will be called.
     * 
     * An example is ...
     *
     * static SEXP GA_eventHelper(pDevDesc dd, int code);

     * Can be left unimplemented as NULL
     */
#if R_USE_PROTOTYPES
    void (*eventHelper)(pDevDesc dd, int code);
#else
    void (*eventHelper)();
#endif

    /* added in 2.14.0, only used by screen devices.

       Allows graphics devices to have multiple levels of suspension: 
       when this reaches zero output is flushed.

       Can be left unimplemented as NULL.
     */
#if R_USE_PROTOTYPES
    int (*holdflush)(pDevDesc dd, int level);
#else
    int (*holdflush)();
#endif

    /* added in 2.14.0, for dev.capabilities.
       In all cases 0 means NA (unset).
    */
    int haveTransparency; /* 1 = no, 2 = yes */
    int haveTransparentBg; /* 1 = no, 2 = fully, 3 = semi */
    int haveRaster; /* 1 = no, 2 = yes, 3 = except for missing values */
    int haveCapture, haveLocator;  /* 1 = no, 2 = yes */


    /* Area for future expansion.
       By zeroing this, devices are more likely to work if loaded
       into a later version of R than that they were compiled under.
    */
    char reserved[64];
};


	/********************************************************/
	/* the device-driver entry point is given a device	*/
	/* description structure that it must set up.  this	*/
	/* involves several important jobs ...			*/
	/* (1) it must ALLOCATE a new device-specific parameters*/
	/* structure and FREE that structure if anything goes	*/
	/* wrong (i.e., it won't report a successful setup to	*/
	/* the graphics engine (the graphics engine is NOT	*/
	/* responsible for allocating or freeing device-specific*/
	/* resources or parameters)				*/
	/* (2) it must initialise the device-specific resources */
	/* and parameters (mostly done by calling device_Open)	*/
	/* (3) it must initialise the generic graphical		*/
	/* parameters that are not initialised by GInit (because*/
	/* only the device knows what values they should have)	*/
	/* see Graphics.h for the official list of these	*/
	/* (4) it may reset generic graphics parameters that	*/
	/* have already been initialised by GInit (although you	*/
	/* should know what you are doing if you do this)	*/
	/* (5) it must attach the device-specific parameters	*/
	/* structure to the device description structure	*/
	/* e.g., dd->deviceSpecfic = (void *) xd;		*/
	/* (6) it must FREE the overall device description if	*/
	/* it wants to bail out to the top-level		*/
	/* the graphics engine is responsible for allocating	*/
	/* the device description and freeing it in most cases	*/
	/* but if the device driver freaks out it needs to do	*/
	/* the clean-up itself					*/
	/********************************************************/

/* moved from Rgraphics.h */

/*
 *	Some Notes on Color
 *
 *	R uses a 24-bit color model.  Colors are specified in 32-bit
 *	integers which are partitioned into 4 bytes as follows.
 *
 *		<-- most sig	    least sig -->
 *		+-------------------------------+
 *		|   0	| blue	| green |  red	|
 *		+-------------------------------+
 *
 *	The red, green and blue bytes can be extracted as follows.
 *
 *		red   = ((color	     ) & 255)
 *		green = ((color >>  8) & 255)
 *		blue  = ((color >> 16) & 255)
 */
/*
 *	Changes as from 1.4.0: use top 8 bits as an alpha channel.
 * 	0 = opaque, 255 = transparent.
 */
/*
 * Changes as from 2.0.0:  use top 8 bits as full alpha channel
 *      255 = opaque, 0 = transparent
 *      [to conform with SVG, PDF and others]
 *      and everything in between is used
 *      [which means that NA is not stored as an internal colour;
 *       it is converted to R_RGBA(255, 255, 255, 0)]
 */

#define R_RGB(r,g,b)	((r)|((g)<<8)|((b)<<16)|0xFF000000)
#define R_RGBA(r,g,b,a)	((r)|((g)<<8)|((b)<<16)|((a)<<24))
#define R_RED(col)	(((col)	   )&255)
#define R_GREEN(col)	(((col)>> 8)&255)
#define R_BLUE(col)	(((col)>>16)&255)
#define R_ALPHA(col)	(((col)>>24)&255)
#define R_OPAQUE(col)	(R_ALPHA(col) == 255)
#define R_TRANSPARENT(col) (R_ALPHA(col) == 0)
    /*
     * A transparent white
     */
#define R_TRANWHITE     (R_RGBA(255, 255, 255, 0))


/* used in various devices */

#define curDevice		Rf_curDevice
#define killDevice		Rf_killDevice
#define ndevNumber		Rf_ndevNumber
#define NewFrameConfirm		Rf_NewFrameConfirm
#define nextDevice		Rf_nextDevice
#define NoDevices		Rf_NoDevices
#define NumDevices		Rf_NumDevices
#define prevDevice		Rf_prevDevice
#define selectDevice		Rf_selectDevice
#define AdobeSymbol2utf8	Rf_AdobeSymbol2utf8

/* Properly declared version of devNumber */
int ndevNumber(pDevDesc );

/* How many devices exist ? (>= 1) */
int NumDevices(void);

/* Check for an available device slot */
void R_CheckDeviceAvailable(void);
Rboolean R_CheckDeviceAvailableBool(void);

/* Return the number of the current device. */
int curDevice(void);

/* Return the number of the next device. */
int nextDevice(int);

/* Return the number of the previous device. */
int prevDevice(int);

/* Make the specified device (specified by number) the current device */
int selectDevice(int);

/* Kill device which is identified by number. */
void killDevice(int);

int NoDevices(void); /* used in engine, graphics, plot, grid */

void NewFrameConfirm(pDevDesc); /* used in graphics.c, grid */


/* Graphics events: defined in gevents.c */

/* These give the indices of some known keys */

typedef enum {knUNKNOWN = -1,
              knLEFT = 0, knUP, knRIGHT, knDOWN,
              knF1, knF2, knF3, knF4, knF5, knF6, knF7, knF8, knF9, knF10,
              knF11, knF12,
              knPGUP, knPGDN, knEND, knHOME, knINS, knDEL} R_KeyName;

/* These are the three possible mouse events */

typedef enum {meMouseDown = 0,
	      meMouseUp,
	      meMouseMove} R_MouseEvent;

#define leftButton   1
#define middleButton 2
#define rightButton  4

#define doKeybd			Rf_doKeybd
#define doMouseEvent		Rf_doMouseEvent
#define doIdle			Rf_doIdle
#define doesIdle		Rf_doesIdle

void doMouseEvent(pDevDesc dd, R_MouseEvent event,
                  int buttons, double x, double y);
void doKeybd(pDevDesc dd, R_KeyName rkey,
	     const char *keyname);
void doIdle(pDevDesc dd);
Rboolean doesIdle(pDevDesc dd);

/* For use in third-party devices when setting up a device:
 * duplicates Defn.h which is used internally.
 * (Tested in devNull.c)
 */

#ifndef BEGIN_SUSPEND_INTERRUPTS
/* Macros for suspending interrupts */
#define BEGIN_SUSPEND_INTERRUPTS do { \
    Rboolean __oldsusp__ = R_interrupts_suspended; \
    R_interrupts_suspended = TRUE;
#define END_SUSPEND_INTERRUPTS R_interrupts_suspended = __oldsusp__; \
    if (R_interrupts_pending && ! R_interrupts_suspended) \
        Rf_onintr(); \
} while(0)
    
#include <R_ext/libextern.h>
LibExtern Rboolean R_interrupts_suspended;    
LibExtern int R_interrupts_pending;
extern void Rf_onintr(void);
LibExtern Rboolean mbcslocale;
#endif

/* Useful for devices: translates Adobe symbol encoding to UTF-8 */
extern void *AdobeSymbol2utf8(char*out, const char *in, size_t nwork);
/* Translates Unicode point to UTF-8 */
extern size_t Rf_ucstoutf8(char *s, const unsigned int c);

#ifdef __cplusplus
}
#endif

#endif /* R_GRAPHICSDEVICE_ */
