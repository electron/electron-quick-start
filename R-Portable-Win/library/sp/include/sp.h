#ifndef R_SP_H
#define R_SP_H

#ifdef SP_XPORT
# define SP_PREFIX(name) SP_XPORT(name)
#else
# define SP_PREFIX(name) name
#endif
/* remember to touch local_stubs.c */

#define SP_VERSION "1.2-5"

#include <R.h>
/* RSB 091203 */
#include <Rdefines.h>
#define R_OFFSET 1
#include <Rinternals.h>
#include <Rmath.h>

/* from insiders.c 

int pipbb(double pt1, double pt2, double *bbs);
int between(double x, double low, double up); 
SEXP insiders(SEXP n1, SEXP bbs); */

/* from pip.c */

#ifndef MIN
# define MIN(a,b) ((a)>(b)?(b):(a))
#endif
#ifndef MAX
# define MAX(a,b) ((a)>(b)?(a):(b))
#endif

#define BUFSIZE 8192

/* polygon structs: */
typedef struct {
	double		x, y;
} PLOT_POINT;

typedef struct {
	PLOT_POINT	min, max;
} MBR;

typedef struct polygon {
	MBR mbr;
	int lines;
	PLOT_POINT	*p;
    int close; /* 1 - is closed polygon */
} POLYGON;

void setup_poly_minmax(POLYGON *pl);
char InPoly(PLOT_POINT q, POLYGON *Poly);
SEXP R_point_in_polygon_sp(SEXP px, SEXP py, SEXP polx, SEXP poly);
void sarea(double *heights, int *nx, int *ny, double *w, double *h, 
	double *sa, int *bycell);
void spRFindCG( int *n, double *x, double *y, double *xc, double *yc, 
		double *area );
void sp_gcdist(double *lon1, double *lon2, double *lat1, double *lat2, 
		double *dist);
void sp_dists(double *u, double *v, double *uout, double *vout, 
		int *n, double *dists, int *lonlat);
void sp_dists_NN(double *u1, double *v1, double *u2, double *v2,
        int *n, double *dists, int *lonlat);
void sp_lengths(double *u, double *v, int *n, double *lengths, int *lonlat);
SEXP sp_zerodist(SEXP pp, SEXP pncol, SEXP zero, SEXP lonlat, SEXP mcmp);
SEXP sp_duplicates(SEXP pp, SEXP pncol, SEXP zero, SEXP lonlat, SEXP mcmp);
SEXP pointsInBox(SEXP lb, SEXP px, SEXP py);
SEXP tList(SEXP nl, SEXP m);

/* RSB 091203 */

#define DIM     2               /* Dimension of points */
typedef double  tPointd[DIM];   /* type double point */

double  SP_PREFIX(Area2)(const tPointd a, const tPointd b, const tPointd c);
void    SP_PREFIX(FindCG)(int n, tPointd *P, tPointd CG, double *Areasum2);
void    SP_PREFIX(Centroid3)(const tPointd p1, const tPointd p2, 
	const tPointd p3, tPointd c);
void SP_PREFIX(spRFindCG_c)(const SEXP n, const SEXP coords, 
	double *xc, double *yc, double *area );
void SP_PREFIX(comm2comment)(char *buf, int bufsiz, int *comm, int nps);

SEXP SP_PREFIX(Polygon_c)(const SEXP coords, const SEXP n, const SEXP hole);
SEXP SP_PREFIX(Polygons_c)(const SEXP pls, const SEXP ID);
SEXP SP_PREFIX(SpatialPolygons_c)(const SEXP pls, const SEXP pO, const SEXP p4s);
SEXP SP_PREFIX(bboxCalcR_c)(const SEXP pls);
SEXP SP_PREFIX(Polygon_validate_c)(const SEXP obj);
SEXP SP_PREFIX(Polygons_validate_c)(const SEXP obj);
SEXP SP_PREFIX(SpatialPolygons_validate_c)(const SEXP obj);
SEXP SP_PREFIX(SpatialPolygons_getIDs_c)(const SEXP obj);
SEXP SP_PREFIX(SpatialPolygons_plotOrder_c)(const SEXP pls);
SEXP SP_PREFIX(comment2comm)(const SEXP obj);
SEXP SP_PREFIX(sp_linkingTo_version)();
#endif
/* remember to touch local_stubs.c */

