/******************************************************************************
 * $Id: projects.h 2121 2011-11-22 22:51:47Z warmerdam $
 *
 * Project:  PROJ.4
 * Purpose:  Primary (private) include file for PROJ.4 library.
 * Author:   Gerald Evenden
 *
 ******************************************************************************
 * Copyright (c) 2000, Frank Warmerdam
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

/* General projections header file */
#ifndef PROJECTS_H
#define PROJECTS_H

#ifdef _MSC_VER
#  ifndef _CRT_SECURE_NO_DEPRECATE
#    define _CRT_SECURE_NO_DEPRECATE
#  endif
#  ifndef _CRT_NONSTDC_NO_DEPRECATE
#    define _CRT_NONSTDC_NO_DEPRECATE
#  endif
#endif

/* standard inclusions */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __cplusplus
#define C_NAMESPACE extern "C"
#define C_NAMESPACE_VAR extern "C"
extern "C" {
#else    
#define C_NAMESPACE extern
#define C_NAMESPACE_VAR
#endif

#ifndef NULL
#  define NULL	0
#endif

#ifndef FALSE
#  define FALSE	0
#endif

#ifndef TRUE
#  define TRUE	1
#endif

#ifndef MAX
#  define MIN(a,b)      ((a<b) ? a : b)
#  define MAX(a,b)      ((a>b) ? a : b)
#endif

#ifndef ABS
#  define ABS(x)        ((x<0) ? (-1*(x)) : x)
#endif

    /* maximum path/filename */
#ifndef MAX_PATH_FILENAME
#define MAX_PATH_FILENAME 1024
#endif
	/* prototype hypot for systems where absent */
#ifndef _WIN32
extern double hypot(double, double);
#endif

#ifdef _WIN32_WCE
#  include <wce_stdlib.h>
#  include <wce_stdio.h>
#  define rewind wceex_rewind
#  define getenv wceex_getenv
#  define strdup _strdup
#  define hypot _hypot
#endif

	/* some useful constants */
#define HALFPI		1.5707963267948966
#define FORTPI		0.78539816339744833
#define PI		3.14159265358979323846
#define TWOPI		6.2831853071795864769

/* environment parameter name */
#ifndef PROJ_LIB
#define PROJ_LIB "PROJ_LIB"
#endif
/* maximum tag id length for +init and default files */
#ifndef ID_TAG_MAX
#define ID_TAG_MAX 50
#endif

/* Use WIN32 as a standard windows 32 bit declaration */
#if defined(_WIN32) && !defined(WIN32) && !defined(_WIN32_WCE)
#  define WIN32
#endif

#if defined(_WINDOWS) && !defined(WIN32) && !defined(_WIN32_WCE)
#  define WIN32
#endif

/* directory delimiter for DOS support */
#ifdef WIN32
#define DIR_CHAR '\\'
#else
#define DIR_CHAR '/'
#endif

/* proj thread context */
typedef struct {
    int	    last_errno;
    int     debug_level;
    void    (*logger)(void *, int, const char *);
    void    *app_data;
} projCtx_t;

/* datum_type values */
#define PJD_UNKNOWN   0
#define PJD_3PARAM    1   
#define PJD_7PARAM    2   
#define PJD_GRIDSHIFT 3
#define PJD_WGS84     4   /* WGS84 (or anything considered equivelent) */

/* library errors */
#define PJD_ERR_GEOCENTRIC          -45
#define PJD_ERR_AXIS                -47
#define PJD_ERR_GRID_AREA           -48

#define USE_PROJUV 

typedef struct { double u, v; } projUV;
typedef struct { double r, i; }	COMPLEX;

#ifndef PJ_LIB__
#define XY projUV
#define LP projUV
#else
typedef struct { double x, y; }     XY;
typedef struct { double lam, phi; } LP;
#endif

typedef union { double  f; int  i; char *s; } PVALUE;
struct PJconsts;
    
struct PJ_LIST {
	char	*id;		/* projection keyword */
	struct PJconsts	*(*proj)(struct PJconsts*);/* projection entry point */
	char 	* const *descr;	/* description text */
};
struct PJ_ELLPS {
	char	*id;	/* ellipse keyword name */
	char	*major;	/* a= value */
	char	*ell;	/* elliptical parameter */
	char	*name;	/* comments */
};
struct PJ_UNITS {
	char	*id;	/* units keyword */
	char	*to_meter;	/* multiply by value to get meters */
	char	*name;	/* comments */
};

struct PJ_DATUMS {
    char    *id;     /* datum keyword */
    char    *defn;   /* ie. "to_wgs84=..." */
    char    *ellipse_id; /* ie from ellipse table */
    char    *comments; /* EPSG code, etc */
};

struct PJ_PRIME_MERIDIANS {
    char    *id;     /* prime meridian keyword */
    char    *defn;   /* offset from greenwich in DMS format. */
};

struct DERIVS {
    double x_l, x_p; /* derivatives of x for lambda-phi */
    double y_l, y_p; /* derivatives of y for lambda-phi */
};
    
struct FACTORS {
	struct DERIVS der;
	double h, k;	/* meridinal, parallel scales */
	double omega, thetap;	/* angular distortion, theta prime */
	double conv;	/* convergence */
	double s;		/* areal scale factor */
	double a, b;	/* max-min scale error */
	int code;		/* info as to analytics, see following */
};
#define IS_ANAL_XL_YL 01	/* derivatives of lon analytic */
#define IS_ANAL_XP_YP 02	/* derivatives of lat analytic */
#define IS_ANAL_HK	04		/* h and k analytic */
#define IS_ANAL_CONV 010	/* convergence analytic */
    /* parameter list struct */
typedef struct ARG_list {
	struct ARG_list *next;
	char used;
	char param[1]; } paralist;
	/* base projection data structure */


typedef struct PJconsts {
    projCtx_t *ctx;
	XY  (*fwd)(LP, struct PJconsts *);
	LP  (*inv)(XY, struct PJconsts *);
	void (*spc)(LP, struct PJconsts *, struct FACTORS *);
	void (*pfree)(struct PJconsts *);
	const char *descr;
	paralist *params;   /* parameter list */
	int over;   /* over-range flag */
	int geoc;   /* geocentric latitude flag */
        int is_latlong; /* proj=latlong ... not really a projection at all */
        int is_geocent; /* proj=geocent ... not really a projection at all */
	double
		a,  /* major axis or radius if es==0 */
                a_orig, /* major axis before any +proj related adjustment */
		es, /* e ^ 2 */
                es_orig, /* es before any +proj related adjustment */
		e,  /* eccentricity */
		ra, /* 1/A */
		one_es, /* 1 - e^2 */
		rone_es, /* 1/one_es */
		lam0, phi0, /* central longitude, latitude */
		x0, y0, /* easting and northing */
		k0,	/* general scaling factor */
		to_meter, fr_meter; /* cartesian scaling */
    
        int     datum_type; /* PJD_UNKNOWN/3PARAM/7PARAM/GRIDSHIFT/WGS84 */
        double  datum_params[7];
        struct _pj_gi **gridlist;
        int     gridlist_count;

        int     has_geoid_vgrids;
        struct _pj_gi **vgridlist_geoid;
        int     vgridlist_geoid_count;
        double  vto_meter, vfr_meter;

        double  from_greenwich; /* prime meridian offset (in radians) */
        double  long_wrap_center; /* 0.0 for -180 to 180, actually in radians*/
        int     is_long_wrap_set;
        char    axis[4];
        
#ifdef PROJ_PARMS__
PROJ_PARMS__
#endif /* end of optional extensions */
} PJ;

/* public API */
#include "proj_api.h"

/* Generate pj_list external or make list from include file */
#ifndef PJ_LIST_H
extern struct PJ_LIST pj_list[];
#else
#define PROJ_HEAD(id, name) \
    struct PJconsts *pj_##id(struct PJconsts*); extern char * const pj_s_##id;
    
#ifndef lint
#define DO_PJ_LIST_ID
#endif
#include PJ_LIST_H
#ifndef lint
#undef DO_PJ_LIST_ID
#endif
#undef PROJ_HEAD
#define PROJ_HEAD(id, name) {#id, pj_##id, &pj_s_##id},
	struct PJ_LIST
pj_list[] = {
#include PJ_LIST_H
		{0,     0,  0},
	};
#undef PROJ_HEAD
#endif

#ifndef PJ_ELLPS__
extern struct PJ_ELLPS pj_ellps[];
#endif

#ifndef PJ_UNITS__
extern struct PJ_UNITS pj_units[];
#endif

#ifndef PJ_DATUMS__
extern struct PJ_DATUMS pj_datums[];
extern struct PJ_PRIME_MERIDIANS pj_prime_meridians[];
#endif

#ifdef PJ_LIB__
    /* repeatative projection code */
#define PROJ_HEAD(id, name) static const char des_##id [] = name
#define ENTRYA(name) \
        C_NAMESPACE_VAR const char * const pj_s_##name = des_##name; \
	C_NAMESPACE PJ *pj_##name(PJ *P) { if (!P) { \
	if( (P = (PJ*) pj_malloc(sizeof(PJ))) != NULL) { \
        memset( P, 0, sizeof(PJ) ); \
	P->pfree = freeup; P->fwd = 0; P->inv = 0; \
	P->spc = 0; P->descr = des_##name;
#define ENTRYX } return P; } else {
#define ENTRY0(name) ENTRYA(name) ENTRYX
#define ENTRY1(name, a) ENTRYA(name) P->a = 0; ENTRYX
#define ENTRY2(name, a, b) ENTRYA(name) P->a = 0; P->b = 0; ENTRYX
#define ENDENTRY(p) } return (p); }
#define E_ERROR(err) { pj_ctx_set_errno( P->ctx, err); freeup(P); return(0); }
#define E_ERROR_0 { freeup(P); return(0); }
#define F_ERROR { pj_ctx_set_errno( P->ctx, -20); return(xy); }
#define I_ERROR { pj_ctx_set_errno( P->ctx, -20); return(lp); }
#define FORWARD(name) static XY name(LP lp, PJ *P) { XY xy = {0.0,0.0}
#define INVERSE(name) static LP name(XY xy, PJ *P) { LP lp = {0.0,0.0}
#define FREEUP static void freeup(PJ *P) {
#define SPECIAL(name) static void name(LP lp, PJ *P, struct FACTORS *fac)
#endif
#define MAX_TAB_ID 80
typedef struct { float lam, phi; } FLP;
typedef struct { int lam, phi; } ILP;

struct CTABLE {
	char id[MAX_TAB_ID]; /* ascii info */
	LP ll;      /* lower left corner coordinates */
	LP del;     /* size of cells */
	ILP lim;    /* limits of conversion matrix */
	FLP *cvs;   /* conversion matrix */
};

typedef struct _pj_gi {
    char *gridname;   /* identifying name of grid, eg "conus" or ntv2_0.gsb */
    char *filename;   /* full path to filename */
    
    const char *format; /* format of this grid, ie "ctable", "ntv1", 
                           "ntv2" or "missing". */

    int   grid_offset; /* offset in file, for delayed loading */

    struct CTABLE *ct;

    struct _pj_gi *next;
    struct _pj_gi *child;
} PJ_GRIDINFO;

/* procedure prototypes */
double dmstor(const char *, char **);
double dmstor_ctx(projCtx ctx, const char *, char **);
void set_rtodms(int, int);
char *rtodms(char *, double, int, int);
double adjlon(double);
double aacos(projCtx,double), aasin(projCtx,double), asqrt(double), aatan2(double, double);
PVALUE pj_param(projCtx ctx, paralist *, const char *);
paralist *pj_mkparam(char *);
int pj_ell_set(projCtx ctx, paralist *, double *, double *);
int pj_datum_set(projCtx,paralist *, PJ *);
int pj_prime_meridian_set(paralist *, PJ *);
int pj_angular_units_set(paralist *, PJ *);

paralist *pj_clone_paralist( const paralist* );
paralist*pj_search_initcache( const char *filekey );
void pj_insert_initcache( const char *filekey, const paralist *list);

double *pj_enfn(double);
double pj_mlfn(double, double, double, double *);
double pj_inv_mlfn(projCtx, double, double, double *);
double pj_qsfn(double, double, double);
double pj_tsfn(double, double, double);
double pj_msfn(double, double, double);
double pj_phi2(projCtx, double, double);
double pj_qsfn_(double, PJ *);
double *pj_authset(double);
double pj_authlat(double, double *);
COMPLEX pj_zpoly1(COMPLEX, COMPLEX *, int);
COMPLEX pj_zpolyd1(COMPLEX, COMPLEX *, int, COMPLEX *);
FILE *pj_open_lib(projCtx, char *, char *);

int pj_deriv(LP, double, PJ *, struct DERIVS *);
int pj_factors(LP, PJ *, double, struct FACTORS *);

struct PW_COEF {/* row coefficient structure */
    int m;		/* number of c coefficients (=0 for none) */
    double *c;	/* power coefficients */
};
 
/* Approximation structures and procedures */
typedef struct {	/* Chebyshev or Power series structure */
	projUV a, b;		/* power series range for evaluation */
					/* or Chebyshev argument shift/scaling */
	struct PW_COEF *cu, *cv;
	int mu, mv;		/* maximum cu and cv index (+1 for count) */
	int power;		/* != 0 if power series, else Chebyshev */
} Tseries;
Tseries *mk_cheby(projUV, projUV, double, projUV *, projUV (*)(projUV), int, int, int);
projUV bpseval(projUV, Tseries *);
projUV bcheval(projUV, Tseries *);
projUV biveval(projUV, Tseries *);
void *vector1(int, int);
void **vector2(int, int, int);
void freev2(void **v, int nrows);
int bchgen(projUV, projUV, int, int, projUV **, projUV(*)(projUV));
int bch2bps(projUV, projUV, projUV **, int, int);
/* nadcon related protos */
LP nad_intr(LP, struct CTABLE *);
LP nad_cvt(LP, int, struct CTABLE *);
struct CTABLE *nad_init(projCtx ctx, char *);
struct CTABLE *nad_ctable_init( projCtx ctx, FILE * fid );
int nad_ctable_load( projCtx ctx, struct CTABLE *, FILE * fid );
struct CTABLE *nad_ctable2_init( projCtx ctx, FILE * fid );
int nad_ctable2_load( projCtx ctx, struct CTABLE *, FILE * fid );
void nad_free(struct CTABLE *);

/* higher level handling of datum grid shift files */

int pj_apply_vgridshift( PJ *defn, const char *listname,
                         PJ_GRIDINFO ***gridlist_p, 
                         int *gridlist_count_p,
                         int inverse, 
                         long point_count, int point_offset,
                         double *x, double *y, double *z );
int pj_apply_gridshift_2( PJ *defn, int inverse, 
                          long point_count, int point_offset,
                          double *x, double *y, double *z );
int pj_apply_gridshift_3( projCtx ctx, 
                          PJ_GRIDINFO **gridlist, int gridlist_count,
                          int inverse, long point_count, int point_offset,
                          double *x, double *y, double *z );

PJ_GRIDINFO **pj_gridlist_from_nadgrids( projCtx, const char *, int * );
void pj_deallocate_grids();

PJ_GRIDINFO *pj_gridinfo_init( projCtx, const char * );
int pj_gridinfo_load( projCtx, PJ_GRIDINFO * );
void pj_gridinfo_free( projCtx, PJ_GRIDINFO * );

void *proj_mdist_ini(double);
double proj_mdist(double, double, double, const void *);
double proj_inv_mdist(projCtx ctx, double, const void *);
void *pj_gauss_ini(double, double, double *,double *);
LP pj_gauss(projCtx, LP, const void *);
LP pj_inv_gauss(projCtx, LP, const void *);

extern char const pj_release[];

struct PJ_ELLPS *pj_get_ellps_ref( void );
struct PJ_DATUMS *pj_get_datums_ref( void );
struct PJ_UNITS *pj_get_units_ref( void );
struct PJ_LIST  *pj_get_list_ref( void );
struct PJ_PRIME_MERIDIANS  *pj_get_prime_meridians_ref( void );
 
#ifndef DISABLE_CVSID
#  if defined(__GNUC__) && __GNUC__ >= 4
#    define PJ_CVSID(string)     static char pj_cvsid[] __attribute__((used)) = string;
#  else
#    define PJ_CVSID(string)     static char pj_cvsid[] = string; \
static char *cvsid_aw() { return( cvsid_aw() ? ((char *) NULL) : pj_cvsid ); }
#  endif
#else
#  define PJ_CVSID(string)
#endif

#ifdef __cplusplus
}
#endif

#endif /* end of basic projections header */
