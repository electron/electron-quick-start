/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1998-2014    The R Core Team
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
 *  These functions are not part of the API.
 */
#ifndef PRTUTIL_H_
#define PRTUTIL_H_

#include <Rinternals.h> // for R_xlen_t
#include <R_ext/Complex.h>

#define formatLogical      Rf_formatLogical
#define formatInteger      Rf_formatInteger
#define formatReal         Rf_formatReal
#define formatComplex      Rf_formatComplex
#define EncodeLogical      Rf_EncodeLogical
#define EncodeInteger      Rf_EncodeInteger
#define EncodeReal         Rf_EncodeReal
#define EncodeReal0        Rf_EncodeReal0
#define EncodeComplex      Rf_EncodeComplex
#define VectorIndex        Rf_VectorIndex
#define printIntegerVector Rf_printIntegerVector
#define printRealVector    Rf_printRealVector
#define printComplexVector Rf_printComplexVector

#ifdef  __cplusplus
extern "C" {
#endif

/* Computation of printing formats */
void formatLogical(int *, R_xlen_t, int *);
void formatInteger(int *, R_xlen_t, int *);
void formatReal(double *, R_xlen_t, int *, int *, int *, int);
void formatComplex(Rcomplex *, R_xlen_t, int *, int *, int *, int *, int *, int *, int);

/* Formating of values */
const char *EncodeLogical(int, int);
const char *EncodeInteger(int, int);
const char *EncodeReal0(double, int, int, int, const char *);
const char *EncodeComplex(Rcomplex, int, int, int, int, int, int, const char *);

/* Legacy, misused by packages RGtk2 and qtbase */
const char *EncodeReal(double, int, int, int, char);


/* Printing */
int	IndexWidth(R_xlen_t);
void VectorIndex(R_xlen_t, int);

//void printLogicalVector(int *, R_xlen_t, int);
void printIntegerVector(int *, R_xlen_t, int);
void printRealVector   (double *, R_xlen_t, int);
void printComplexVector(Rcomplex *, R_xlen_t, int);

#ifdef  __cplusplus
}
#endif

#endif /* PRTUTIL_H_ */
