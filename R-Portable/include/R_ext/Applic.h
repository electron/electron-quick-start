/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1998-2015   The R Core Team
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
 *
 *
 * Application Routines, typically implemented in  ../appl/
 * ----------------------------------------------  ========
 */

/* This header file contains routines which are in the R API and ones which
   are not.

   Those which are not can be used only at the user's risk and may change
   or disappear in a future release of R.
*/


#ifndef R_APPLIC_H_
#define R_APPLIC_H_

#include <R_ext/Boolean.h>
#include <R_ext/RS.h>		/* F77_... */
#include <R_ext/BLAS.h>

#ifdef  __cplusplus
extern "C" {
#endif

/* Entry points in the R API */

/* ../../appl/integrate.c */
typedef void integr_fn(double *x, int n, void *ex);
/* vectorizing function   f(x[1:n], ...) -> x[]  {overwriting x[]}. */

void Rdqags(integr_fn f, void *ex, double *a, double *b,
	    double *epsabs, double *epsrel,
	    double *result, double *abserr, int *neval, int *ier,
	    int *limit, int *lenw, int *last, int *iwork, double *work);

void Rdqagi(integr_fn f, void *ex, double *bound, int *inf,
	    double *epsabs, double *epsrel,
	    double *result, double *abserr, int *neval, int *ier,
	    int *limit, int *lenw, int *last,
	    int *iwork, double *work);

/* main/optim.c */
typedef double optimfn(int, double *, void *);
typedef void optimgr(int, double *, double *, void *);

void vmmin(int n, double *b, double *Fmin,
	   optimfn fn, optimgr gr, int maxit, int trace,
	   int *mask, double abstol, double reltol, int nREPORT,
	   void *ex, int *fncount, int *grcount, int *fail);
void nmmin(int n, double *Bvec, double *X, double *Fmin, optimfn fn,
	   int *fail, double abstol, double intol, void *ex,
	   double alpha, double bet, double gamm, int trace,
	   int *fncount, int maxit);
void cgmin(int n, double *Bvec, double *X, double *Fmin,
	   optimfn fn, optimgr gr,
	   int *fail, double abstol, double intol, void *ex,
	   int type, int trace, int *fncount, int *grcount, int maxit);
void lbfgsb(int n, int m, double *x, double *l, double *u, int *nbd,
	    double *Fmin, optimfn fn, optimgr gr, int *fail, void *ex,
	    double factr, double pgtol, int *fncount, int *grcount,
	    int maxit, char *msg, int trace, int nREPORT);
void samin(int n, double *pb, double *yb, optimfn fn, int maxit,
	   int tmax, double ti, int trace, void *ex);

/* appl/interv.c: Also in Utils.h, used in package eco */
int findInterval(double *xt, int n, double x,
		 Rboolean rightmost_closed,  Rboolean all_inside, int ilo,
		 int *mflag);
// findInterval2() is only in Utils.h (and hence Rinternals.h)


/* ------------------ Entry points NOT in the R API --------------- */

/* The following are registered for use in .C/.Fortran */

/* appl/dqrutl.f: interfaces to dqrsl */
void F77_NAME(dqrqty)(double *x, int *n, int *k, double *qraux,
		      double *y, int *ny, double *qty);
void F77_NAME(dqrqy)(double *x, int *n, int *k, double *qraux,
		     double *y, int *ny, double *qy);
void F77_NAME(dqrcf)(double *x, int *n, int *k, double *qraux,
		     double *y, int *ny, double *b, int *info);
void F77_NAME(dqrrsd)(double *x, int *n, int *k, double *qraux,
		     double *y, int *ny, double *rsd);
void F77_NAME(dqrxb)(double *x, int *n, int *k, double *qraux,
		     double *y, int *ny, double *xb);

/* end of registered */

/* hidden, for use in R.bin/R.dll/libR.so */

/* appl/pretty.c: for use in engine.c and util.c */
double R_pretty(double *lo, double *up, int *ndiv, int min_n,
		double shrink_sml, double high_u_fact[],
		int eps_correction, int return_bounds);


/* For use in package stats */

/* appl/uncmin.c : */

/* type of pointer to the target and gradient functions */
typedef void (*fcn_p)(int, double *, double *, void *);

/* type of pointer to the hessian functions */
typedef void (*d2fcn_p)(int, int, double *, double *, void *);

void fdhess(int n, double *x, double fval, fcn_p fun, void *state,
	    double *h, int nfd, double *step, double *f, int ndigit,
	    double *typx);

/* Also used in packages nlme, pcaPP */
void optif9(int nr, int n, double *x,
	    fcn_p fcn, fcn_p d1fcn, d2fcn_p d2fcn,
	    void *state, double *typsiz, double fscale, int method,
	    int iexp, int *msg, int ndigit, int itnlim, int iagflg,
	    int iahflg, double dlt, double gradtl, double stepmx,
	    double steptl, double *xpls, double *fpls, double *gpls,
	    int *itrmcd, double *a, double *wrk, int *itncnt);

/* find qr decomposition, dqrdc2() is basis of R's qr(),
   also used by nlme and many other packages. */
void F77_NAME(dqrdc2)(double *x, int *ldx, int *n, int *p,
		      double *tol, int *rank,
		      double *qraux, int *pivot, double *work);
void F77_NAME(dqrls)(double *x, int *n, int *p, double *y, int *ny,
		     double *tol, double *b, double *rsd,
		     double *qty, int *k,
		     int *jpvt, double *qraux, double *work);

#ifdef  __cplusplus
}
#endif

#endif /* R_APPLIC_H_ */
