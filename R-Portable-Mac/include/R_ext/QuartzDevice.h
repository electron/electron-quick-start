/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2007-2016  The R Core Team
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 *
 *---------------------------------------------------------------------
 *  This header file constitutes the (unofficial) API to the Quartz
 *  device. Being unofficial, the API may change at any point without
 *  warning.
 *
 *  Quartz is a general device-independent way of drawing in macOS,
 *  therefore the Quartz device modularizes the actual drawing target
 *  implementation into separate modules (e.g. Carbon and Cocoa for
 *  on-screen display and PDF, Bitmap for off-screen drawing). The API
 *  below is used by the modules to talk to the Quartz device without
 *  having to know anything about R graphics device API.
 *
 *  Key functions are listed here:
 *  QuartzDevice_Create - creates a Quartz device
 *  QuartzDevice_ResetContext - should be called after the target
 *    context has been created to initialize it.
 *  QuartzDevice_Kill - closes the Quartz device (e.g. on window close)
 *  QuartzDevice_SetScaledSize - resize device (does not include
 *    re-painting, it should be followed by a call to
 *    QuartzDevice_ReplayDisplayList)
 *  QuartzDevice_ReplayDisplayList - replays all plot commands
 *
 *  Key concepts
 *  - all Quartz modules are expected to provide a device context
 *    (CGContextRef) for drawing. A device can temporarily return NULL
 *    (e.g. if the context is not available immediately) and replay
 *    the display list later to catch up.
 *
 *  - interactive devices can use QuartzDevice_SetScaledSize to resize
 *    the device (no context is necessary), then prepare the context
 *    (call QuartzDevice_ResetContext if a new context was created)
 *    and finally re-draw using QuartzDevice_ReplayDisplayList.
 *
 *  - snapshots can be created either off the current display list
 *    (last=0) or off the last known one (last=1). NewPage callback
 *    can only use last=1 as there is no display list during that
 *    call. Restored snapshots become the current display list and
 *    thus can be extended by further painting (yet the original saved
 *    copy is not influenced). Also note that all snapshots are SEXPs
 *    (the declaration doesn't use SEXP as to not depend on
 *    Rinternals.h) therefore must be protected or preserved immediately
 *    (i.e. the Quartz device does NOT protect them - except in the
 *    call to RestoreSnapshot).
 *
 *  - dirty flag: the dirty flag is not used internally by the Quartz
 *    device, but can be useful for the modules to determine whether
 *    the current graphics is a restored copy or in-progress
 *    drawing. The Quartz device manages the flag as follows: a)
 *    display list replay does NOT change the flag, b) snapshot
 *    restoration resets the flag, c) all other paint operations
 *    (i.e. outside of restore/replay) set the flag. Most common use
 *    is to determine whether restored snapshots have been
 *    subsequently modified.
 *
 *  - history: currently the history management is not used by any
 *    modules and as such is untested and strictly experimental. It
 *    may be removed in the future as it is not clear whether it makes
 *    sense to be part of the device. See Cocoa module for a
 *    module-internal implementation of the display history.
 *
 *  Quartz device creation path:
 *    quartz() function -> SEXP Quartz(args) ->
 *    setup QuartzParameters_t, call backend constructor
 *    [e.g. QuartzCocoa_DeviceCreate(dd, fn, QuartzParameters_t *pars)] ->
 *    create backend definition (QuartzBackend_t backend) -> 
 *    fn->Create(dd, &backend), return the result
 */

/* Unix-only header */

#ifndef R_EXT_QUARTZDEVICE_H_
#define R_EXT_QUARTZDEVICE_H_

/* FIXME: this is installed, but can it really work without config.h? */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif   
 
#if HAVE_AQUA
#include <ApplicationServices/ApplicationServices.h>
#else
    typedef void* CGContextRef;
#endif

/* flags passed to the newPage callback */
#define QNPF_REDRAW 0x0001 /* is set when NewPage really means re-draw of an existing page */

/* flags passed to QuartzDevice_Create (as fs parameter) */
#define QDFLAG_DISPLAY_LIST 0x0001
#define QDFLAG_INTERACTIVE  0x0002 
#define QDFLAG_RASTERIZED   0x0004 /* rasterized media - may imply disabling AA paritally for rects etc. */

/* parameter flags (they should not conflict with QDFLAGS to allow chaining) */
#define QPFLAG_ANTIALIAS 0x0100

typedef void* QuartzDesc_t;

typedef struct QuartzBackend_s {
    int    size;                          /* structure size */
    double width, height;
    double scalex, scaley, pointsize;
    int    bg, canvas;
    int    flags;
    void*  userInfo;
    CGContextRef (*getCGContext)(QuartzDesc_t dev, void*userInfo); /* Get the context for this device */
    int          (*locatePoint)(QuartzDesc_t dev, void*userInfo, double*x, double*y);
    void         (*close)(QuartzDesc_t dev, void*userInfo);
    void         (*newPage)(QuartzDesc_t dev, void*userInfo, int flags);
    void         (*state)(QuartzDesc_t dev, void*userInfo, int state);
    void*        (*par)(QuartzDesc_t dev, void*userInfo, int set, const char *key, void *value);
    void         (*sync)(QuartzDesc_t dev, void*userInfo);
    void*        (*cap)(QuartzDesc_t dev, void*userInfo);
} QuartzBackend_t;

/* parameters that are passed to functions that create backends */
typedef struct QuartzParameters_s {
    int        size;                   /* structure size */
    const char *type, *file, *title;
    double     x, y, width, height, pointsize;
    const char *family;
    int        flags;
    int        connection;
    int        bg, canvas;
    double     *dpi;
    /* the following parameters can be used to pass custom parameters when desired */
    double     pard1, pard2;
    int        pari1, pari2;
    const char *pars1, *pars2;
    void       *parv;
} QuartzParameters_t;
    
/* all device implementations have to call this general Quartz device constructor at some point */
QuartzDesc_t QuartzDevice_Create(void *dd, QuartzBackend_t* def);
    
typedef struct QuartzFunctons_s {
    void*  (*Create)(void *, QuartzBackend_t *);  /* create a new device */
    int    (*DevNumber)(QuartzDesc_t desc);       /* returns device number */
    void   (*Kill)(QuartzDesc_t desc);            /* call to close the device */
    void   (*ResetContext)(QuartzDesc_t desc);    /* notifies Q back-end that the implementation has created a new context */
    double (*GetWidth)(QuartzDesc_t desc);        /* get device width (in inches) */
    double (*GetHeight)(QuartzDesc_t desc);       /* get device height (in inches) */
    void   (*SetSize)(QuartzDesc_t desc, double width, double height); /* set device size (in inches) */
    
    double (*GetScaledWidth)(QuartzDesc_t desc);  /* get device width (in pixels) */
    double (*GetScaledHeight)(QuartzDesc_t desc); /* get device height (in pixels) */
    void   (*SetScaledSize)(QuartzDesc_t desc, double width, double height); /* set device size (in pixels) */

    double (*GetXScale)(QuartzDesc_t desc);     /* get x scale factor (px/pt ratio) */
    double (*GetYScale)(QuartzDesc_t desc);     /* get y scale factor (px/pt ratio) */
    void   (*SetScale)(QuartzDesc_t desc,double scalex, double scaley); /* sets both scale factors (px/pt ratio) */

    void   (*SetTextScale)(QuartzDesc_t desc,double scale); /* sets text scale factor */
    double (*GetTextScale)(QuartzDesc_t desc);  /* sets text scale factor */

    void   (*SetPointSize)(QuartzDesc_t desc,double ps); /* sets point size */
    double (*GetPointSize)(QuartzDesc_t desc);  /* gets point size */

    int    (*GetDirty)(QuartzDesc_t desc);        /* sets dirty flag */
    void   (*SetDirty)(QuartzDesc_t desc,int dirty); /* gets dirty flag */

    void   (*ReplayDisplayList)(QuartzDesc_t desc); /* replay display list
     Note: it inhibits sync calls during repaint,
     the caller is responsible for calling sync if needed.
     Dirty flag is kept unmodified */
    void*  (*GetSnapshot)(QuartzDesc_t desc, int last);    
    /* create a (replayable) snapshot of the device contents. 
       when 'last' is set then the last stored display list is used, 
       otherwise a new snapshot is created */
    void   (*RestoreSnapshot)(QuartzDesc_t desc,void* snapshot);
    /* restore a snapshot. also clears the dirty flag */

    int    (*GetAntialias)(QuartzDesc_t desc);    /* get anti-alias flag */
    void   (*SetAntialias)(QuartzDesc_t desc, int aa); /* set anti-alias flag */

    int    (*GetBackground)(QuartzDesc_t desc);   /* get background color */
    void   (*Activate)(QuartzDesc_t desc);        /* activate/select the device */
    /* get/set Quartz-specific parameters. desc can be NULL for global parameters */
    void*  (*SetParameter)(QuartzDesc_t desc, const char *key, void *value);
    void*  (*GetParameter)(QuartzDesc_t desc, const char *key);
} QuartzFunctions_t;

#define QuartzParam_EmbeddingFlags "embeddeding flags" /* value: int[1] */
#define QP_Flags_CFLoop 0x0001  /* drives application event loop */
#define QP_Flags_Cocoa  0x0002  /* Cocoa is fully initialized */
#define QP_Flags_Front  0x0004  /* is front application */

/* FIXME: no longer used, remove in due course */
/* from unix/aqua.c - loads grDevices if necessary and returns NULL on failure */
QuartzFunctions_t *getQuartzFunctions();

/* type of a Quartz contructor */
typedef QuartzDesc_t (*quartz_create_fn_t)(void *dd, QuartzFunctions_t *fn, QuartzParameters_t *par);

/* grDevices currently supply following constructors:
   QuartzCocoa_DeviceCreate, QuartzCarbon_DeviceCreate,
   QuartzBitmap_DeviceCreate, QuartzPDF_DeviceCreate */

/* embedded Quartz support hook (defined in unix/aqua.c):
     dd = should be passed-through to QuartzDevice_Create
     fn = Quartz API functions
     par = parameters (see above) */
#ifndef IN_AQUA_C
    extern
#endif
    QuartzDesc_t (*ptr_QuartzBackend)(void *dd, QuartzFunctions_t *fn, QuartzParameters_t *par);

/* C version of the Quartz call (experimental)
   returns 0 on success, error code on failure */
QuartzDesc_t Quartz_C(QuartzParameters_t *par, quartz_create_fn_t q_create, int *errorCode);

#ifdef __cplusplus
}
#endif   

#endif
