/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2001-2017  The R Core Team.
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

/*
  C functions used to register compiled code in packages.

  Those needed for that purpose are part of the API.

  Cleaned up for R 3.4.0, some changes require recompilation of packages.
 */

#ifndef  R_EXT_DYNLOAD_H_
#define  R_EXT_DYNLOAD_H_

#include <R_ext/Boolean.h>

/* called with a variable argument set */
typedef void * (*DL_FUNC)();

typedef unsigned int R_NativePrimitiveArgType;

/* For interfaces to objects created with as.single */
#define SINGLESXP 302

/*
 These are very similar to those in Rdynpriv.h,
 but we maintain them separately to give us more freedom to do
 some computations on the internal versions that are derived from
 these definitions.
*/
typedef struct {
    const char *name;
    DL_FUNC     fun;
    int         numArgs;
    R_NativePrimitiveArgType *types;
} R_CMethodDef;

typedef R_CMethodDef R_FortranMethodDef;


typedef struct {
    const char *name;
    DL_FUNC     fun;
    int         numArgs;
} R_CallMethodDef;

typedef R_CallMethodDef R_ExternalMethodDef;


typedef struct _DllInfo DllInfo;

/*
  Currently ignore the graphics routines, accessible via .External.graphics()
  and .Call.graphics().
 */
#ifdef __cplusplus
extern "C" {
#endif
int R_registerRoutines(DllInfo *info, const R_CMethodDef * const croutines,
		       const R_CallMethodDef * const callRoutines,
		       const R_FortranMethodDef * const fortranRoutines,
		       const R_ExternalMethodDef * const externalRoutines);

Rboolean R_useDynamicSymbols(DllInfo *info, Rboolean value);
Rboolean R_forceSymbols(DllInfo *info, Rboolean value);

DllInfo *R_getDllInfo(const char *name);

/* To be used by applications embedding R to register their symbols
   that are not related to any dynamic module */
DllInfo *R_getEmbeddingDllInfo(void);

typedef struct Rf_RegisteredNativeSymbol R_RegisteredNativeSymbol;
typedef enum {R_ANY_SYM=0, R_C_SYM, R_CALL_SYM, R_FORTRAN_SYM, R_EXTERNAL_SYM} NativeSymbolType;


DL_FUNC R_FindSymbol(char const *, char const *,
		       R_RegisteredNativeSymbol *symbol);


/* Interface for exporting and importing functions from one package
   for use from C code in a package.  The registration part probably
   ought to be integrated with the other registrations.  The naming of
   these routines may be less than ideal.
*/

void R_RegisterCCallable(const char *package, const char *name, DL_FUNC fptr);
DL_FUNC R_GetCCallable(const char *package, const char *name);

#ifdef __cplusplus
}
#endif

#endif /* R_EXT_DYNLOAD_H_ */
