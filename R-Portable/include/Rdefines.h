/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 1999-2016 The R Core Team.
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

/* From 'Writing R Extensions:

   'these are not kept up to date and are not recommended for new projects.'

   As from R 3.3.0 they have been adjusted to work when R_NO_REMAP is defined.
*/

#ifndef R_DEFINES_H
#define R_DEFINES_H

#if !defined(R_R_H) && !defined(R_S_H)
/* user forgot to include R.h or S.h */
# include <R_ext/Memory.h>
# include <R_ext/RS.h>
#endif

#include <Rinternals.h>

/*
 *  Much is from John Chambers' "Programming With Data".
 *  Some of this is from Doug Bates.
 *
 *  It is presented here to support a joint programming style which
 *  will work in both R and S.  In particular it helps with:
 *
 *    1. S/R <-> CORBA code.
 *    2. S/R <-> Java Code.
 *
 *  And to hide some internal nastiness.
 */


/*
 *  Added some macros defined in S.h from Splus 5.1
 */

#define NULL_USER_OBJECT	R_NilValue

#define AS_LOGICAL(x)		Rf_coerceVector(x,LGLSXP)
#define AS_INTEGER(x)		Rf_coerceVector(x,INTSXP)
#define AS_NUMERIC(x)		Rf_coerceVector(x,REALSXP)
#define AS_CHARACTER(x)		Rf_coerceVector(x,STRSXP)
#define AS_COMPLEX(x)		Rf_coerceVector(x,CPLXSXP)
#define AS_VECTOR(x)		Rf_coerceVector(x,VECSXP)
#define AS_LIST(x)		Rf_coerceVector(x,VECSXP)
#define AS_RAW(x)		Rf_coerceVector(x,RAWSXP)

#ifdef USE_RINTERNALS
// This is not documented to be supported, and may not be in future
# define IS_LOGICAL(x)		isLogical(x)
# define IS_INTEGER(x)		isInteger(x)
# define IS_NUMERIC(x)		isReal(x)
# define IS_CHARACTER(x)	isString(x)
# define IS_COMPLEX(x)		isComplex(x)
#else
# define IS_LOGICAL(x)		Rf_isLogical(x)
# define IS_INTEGER(x)		Rf_isInteger(x)
# define IS_NUMERIC(x)		Rf_isReal(x)
# define IS_CHARACTER(x)	Rf_isString(x)
# define IS_COMPLEX(x)		Rf_isComplex(x)
#endif
/* NB: is this right?  It means atomic or VECSXP or EXPRSXP */
#define IS_VECTOR(x)		Rf_isVector(x)
/* And this cannot be right: isVectorList(x)? */
#define IS_LIST(x)		IS_VECTOR(x)
#define IS_RAW(x)		(TYPEOF(x) == RAWSXP)

#define NEW_LOGICAL(n)		Rf_allocVector(LGLSXP,n)
#define NEW_INTEGER(n)		Rf_allocVector(INTSXP,n)
#define NEW_NUMERIC(n)		Rf_allocVector(REALSXP,n)
#define NEW_CHARACTER(n)	Rf_allocVector(STRSXP,n)
#define NEW_COMPLEX(n)		Rf_allocVector(CPLXSXP,n)
#define NEW_LIST(n)		Rf_allocVector(VECSXP,n)
#define NEW_STRING(n)		NEW_CHARACTER(n)
#define NEW_RAW(n)		Rf_allocVector(RAWSXP,n)

#define LOGICAL_POINTER(x)	LOGICAL(x)
#define INTEGER_POINTER(x)	INTEGER(x)
#define NUMERIC_POINTER(x)	REAL(x)
#define CHARACTER_POINTER(x)	STRING_PTR(x)
#define COMPLEX_POINTER(x)	COMPLEX(x)
/* Use of VECTOR_PTR will fail unless USE_RINTERNALS is in use
   This is probably unused.
*/
#define LIST_POINTER(x)		VECTOR_PTR(x)
#define RAW_POINTER(x)		RAW(x)

/* The following are not defined in `Programming with Data' but are
   defined in S.h in Svr4 */

/*
 * Note that LIST_DATA and RAW_DATA are missing.
 * This is consistent with Svr4.
 */

#define LOGICAL_DATA(x)		(LOGICAL(x))
#define INTEGER_DATA(x)		(INTEGER(x))
#define DOUBLE_DATA(x)		(REAL(x))
#define NUMERIC_DATA(x)		(REAL(x))
#define CHARACTER_DATA(x)	(STRING_PTR(x))
#define COMPLEX_DATA(x)		(COMPLEX(x))
/* Use of VECTOR_PTR will fail unless USE_RINTERNALS is in use
   VECTOR_DATA seems unused, and RECURSIVE_DATA is used only in
   the Expat part of XML.
*/
#define RECURSIVE_DATA(x)	(VECTOR_PTR(x))
#define VECTOR_DATA(x)		(VECTOR_PTR(x))

#define LOGICAL_VALUE(x)	Rf_asLogical(x)
#define INTEGER_VALUE(x)	Rf_asInteger(x)
#define NUMERIC_VALUE(x)	Rf_asReal(x)
#define CHARACTER_VALUE(x)	CHAR(Rf_asChar(x))
#define STRING_VALUE(x)		CHAR(Rf_asChar(x))
#define LIST_VALUE(x)		Rf_error("the 'value' of a list object is not defined")
#define RAW_VALUE(x)		Rf_error("the 'value' of a raw object is not defined")

#define SET_ELEMENT(x, i, val)	SET_VECTOR_ELT(x, i, val)
#define GET_ATTR(x,what)       	Rf_getAttrib(x, what)
#define GET_CLASS(x)       	Rf_getAttrib(x, R_ClassSymbol)
#define GET_DIM(x)       	Rf_getAttrib(x, R_DimSymbol)
#define GET_DIMNAMES(x)       	Rf_getAttrib(x, R_DimNamesSymbol)
#define GET_COLNAMES(x)       	Rf_GetColNames(x)
#define GET_ROWNAMES(x)       	Rf_GetRowNames(x)
#define GET_LEVELS(x)       	Rf_getAttrib(x, R_LevelsSymbol)
#define GET_TSP(x)       	Rf_getAttrib(x, R_TspSymbol)
#define GET_NAMES(x)		Rf_getAttrib(x, R_NamesSymbol)
#define SET_ATTR(x, what, n)    Rf_setAttrib(x, what, n)
#define SET_CLASS(x, n)     	Rf_setAttrib(x, R_ClassSymbol, n)
#define SET_DIM(x, n)     	Rf_setAttrib(x, R_DimSymbol, n)
#define SET_DIMNAMES(x, n)     	Rf_setAttrib(x, R_DimNamesSymbol, n)
#define SET_LEVELS(x, l)       	Rf_setAttrib(x, R_LevelsSymbol, l)
#define SET_NAMES(x, n)		Rf_setAttrib(x, R_NamesSymbol, n)
/* These do not support long vectors */
#define GET_LENGTH(x)		Rf_length(x)
#define SET_LENGTH(x, n)	(x = Rf_lengthgets(x, n))

#define GET_SLOT(x, what)       R_do_slot(x, what)
#define SET_SLOT(x, what, value)  R_do_slot_assign(x, what, value)

#define MAKE_CLASS(what)	R_do_MAKE_CLASS(what)
/* NEW_OBJECT is recommended; NEW is for green book compatibility */
#define NEW_OBJECT(class_def)	R_do_new_object(class_def)
#define NEW(class_def)		R_do_new_object(class_def)

#define s_object                SEXPREC
#define S_EVALUATOR             /**/

/* These conflict with definitions in R_ext/Boolean.h,
   but spatstat relies on them in a C file */
#ifdef __cplusplus
# ifndef R_EXT_BOOLEAN_H_
#  ifndef TRUE
#   define TRUE 1
#  endif
#  ifndef FALSE
#   define FALSE 0
#  endif
# endif
#else
#  ifndef TRUE
#   define TRUE 1
#  endif
#  ifndef FALSE
#   define FALSE 0
#  endif
#endif

#define COPY_TO_USER_STRING(x)	mkChar(x)
#define CREATE_STRING_VECTOR(x)	mkChar(x)

#define CREATE_FUNCTION_CALL(name, argList) createFunctionCall(name, argList)

#define EVAL(x)			eval(x,R_GlobalEnv)


#endif
