/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1995, 1996  Robert Gentleman and Ross Ihaka
 *  Copyright (C) 1997--2016 The R Core Team.
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
 *  Much of this is from Doug Bates.
 */

/* 
   This is a legacy header and no longer documented.
   Code using it should be converted to use R.h
*/

/* This header includes C headers and so is not safe for inclusion
   from C++: use R.h instead. */

#ifndef R_S_H
#define R_S_H

#ifndef USING_R
# define USING_R
/* is this a good idea? - conflicts with many versions of f2c.h */
# define longint int
#endif

#ifdef __cplusplus
# error S.h can not be used from C++ code: use R.h instead
#endif

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <float.h>
#include <math.h>

#include <Rconfig.h>
#include <R_ext/Constants.h>
#include <R_ext/Memory.h>	/* S_alloc */

/* subset of those in Random.h */
extern void seed_in(long *);
extern void seed_out(long *);
extern double unif_rand(void);
extern double norm_rand(void);

/* Macros for S/R Compatibility */

#include <R_ext/RS.h>
/* for PROBLEM ... Calloc, Realloc, Free, Memcpy, F77_xxxx */

/* S4 uses macros equivalent to */
#define Salloc(n,t) (t*)S_alloc(n, sizeof(t))
#define Srealloc(p,n,old,t) (t*)S_realloc(p,n,old,sizeof(t))

/* S's complex is different, and is a define to S_complex now */
typedef struct {
	double re;
	double im;
} S_complex;

#ifdef S_OLD_COMPLEX
# define complex S_complex
#endif

#ifndef NO_CALL_R
/* Not quite full compatibility: beware! */
/* void	call_R(char*, long, void**, char**, long*, char**, long, char**);*/
#define call_S call_R
#endif

#endif /* !R_S_H */
