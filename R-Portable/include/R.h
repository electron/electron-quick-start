/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2000-2016 The R Core Team.
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

#ifndef R_R_H
#define R_R_H

#ifndef USING_R
# define USING_R
#endif

/* same as Rmath.h: needed for cospi etc */
#ifndef __STDC_WANT_IEC_60559_FUNCS_EXT__
# define __STDC_WANT_IEC_60559_FUNCS_EXT__ 1
#endif
/* The C++ headers in Solaris Studio are strict C++98, and 100+ 
   packages would fail because of not using e.g. std::floor 
   or using C99 functions such as 

   erf exmp1 floorf fmin fminf fmax lgamma lround loglp round
   snprintf strcasecmp trunc

   We workaround the first, here and in Rmath.h.

   DO_NOT_USE_CXX_HEADERS is legacy, left as a last resort.
*/
#if defined(__cplusplus) && !defined(DO_NOT_USE_CXX_HEADERS)
# include <cstdlib>
# include <cstdio>
# include <climits>
# include <cmath>
# ifdef __SUNPRO_CC
using namespace std;
# endif
#else
# include <stdlib.h> /* Not used by R itself, but widely assumed in packages */
# include <stdio.h>  /* Used by ca 200 packages, but not in R itself */
# include <limits.h> /* for INT_MAX */
# include <math.h>
#endif 
/* 
   math.h is also included by R_ext/Arith.h, except in C++ code
   stddef.h (or cstddef) is included by R_ext/Memory.h
   string.h (or cstring) is included by R_ext/RS.h
*/
#if defined(__sun)
/* Solaris' stdlib.h includes a header which defines these (and more) */
# undef CS
# undef DO
# undef DS
# undef ES
# undef FS
# undef GS
# undef SO
# undef SS
#endif

#ifdef NO_C_HEADERS
# warning "use of NO_C_HEADERS is defunct and will be ignored"
#endif

#include <Rconfig.h>
#include <R_ext/Arith.h>      /* R_FINITE, ISNAN, ... */
#include <R_ext/Boolean.h>    /* Rboolean type */
#include <R_ext/Complex.h>    /* Rcomplex type */
#include <R_ext/Constants.h>  /* PI, DOUBLE_EPS, etc */
#include <R_ext/Error.h>      /* error and warning */
#include <R_ext/Memory.h>     /* R_alloc and S_alloc */
#include <R_ext/Print.h>      /* Rprintf etc */
#include <R_ext/Random.h>     /* RNG interface */
#include <R_ext/Utils.h>      /* sort routines et al */
#include <R_ext/RS.h>
/* for PROBLEM ... Calloc, Realloc, Free, Memcpy, F77_xxxx */


typedef double Sfloat;
typedef int Sint;
#define SINT_MAX INT_MAX
#define SINT_MIN INT_MIN

#ifdef __cplusplus
extern "C" {
#endif

void R_FlushConsole(void);
/* always declared, but only usable under Win32 and Aqua */
void R_ProcessEvents(void);
#ifdef Win32
void R_WaitEvent(void);
#endif

#ifdef __cplusplus
}
#endif

#endif /* !R_R_H */
