/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2016  The R Core Team.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2.1 of the License, or
 *  (at your option) any later version.
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

#ifndef R_EXT_ALTREP_H_
#define R_EXT_ALTREP_H_

#define STRUCT_SUBTYPES
#ifdef STRUCT_SUBTYPES
# define R_SEXP(x) (x).ptr
# define R_SUBTYPE_INIT(x) { x }
  typedef struct { SEXP ptr; } R_altrep_class_t;
#else
# define R_SEXP(x) ((SEXP) (x))
# define R_SUBTYPE_INIT(x) (void *) (x)
  typedef struct R_altcls *R_altrep_class_t;
#endif

SEXP
R_new_altrep(R_altrep_class_t class, SEXP data1, SEXP data2);

R_altrep_class_t
R_make_altstring_class(const char *cname, const char *pname, DllInfo *info);
R_altrep_class_t
R_make_altinteger_class(const char *cname, const char *pname, DllInfo *info);
R_altrep_class_t
R_make_altreal_class(const char *cname, const char *pname, DllInfo *info);
Rboolean R_altrep_inherits(SEXP x, R_altrep_class_t);

typedef SEXP (*R_altrep_UnserializeEX_method_t)(SEXP, SEXP, SEXP, int, int);
typedef SEXP (*R_altrep_Unserialize_method_t)(SEXP, SEXP);
typedef SEXP (*R_altrep_Serialized_state_method_t)(SEXP);
typedef SEXP (*R_altrep_DuplicateEX_method_t)(SEXP, Rboolean);
typedef SEXP (*R_altrep_Duplicate_method_t)(SEXP, Rboolean);
typedef SEXP (*R_altrep_Coerce_method_t)(SEXP, int);
typedef Rboolean (*R_altrep_Inspect_method_t)(SEXP, int, int, int,
					      void (*)(SEXP, int, int, int));
typedef R_xlen_t (*R_altrep_Length_method_t)(SEXP);

typedef void *(*R_altvec_Dataptr_method_t)(SEXP, Rboolean);
typedef const void *(*R_altvec_Dataptr_or_null_method_t)(SEXP);
typedef SEXP (*R_altvec_Extract_subset_method_t)(SEXP, SEXP, SEXP);

typedef int (*R_altinteger_Elt_method_t)(SEXP, R_xlen_t);
typedef R_xlen_t
(*R_altinteger_Get_region_method_t)(SEXP, R_xlen_t, R_xlen_t, int *);
typedef int (*R_altinteger_Is_sorted_method_t)(SEXP);
typedef int (*R_altinteger_No_NA_method_t)(SEXP);
typedef SEXP (*R_altinteger_Sum_method_t)(SEXP, Rboolean); 
typedef SEXP (*R_altinteger_Min_method_t)(SEXP, Rboolean);
typedef SEXP (*R_altinteger_Max_method_t)(SEXP, Rboolean);

typedef double (*R_altreal_Elt_method_t)(SEXP, R_xlen_t);
typedef R_xlen_t
(*R_altreal_Get_region_method_t)(SEXP, R_xlen_t, R_xlen_t, double *);
typedef int (*R_altreal_Is_sorted_method_t)(SEXP);
typedef int (*R_altreal_No_NA_method_t)(SEXP);
typedef SEXP (*R_altreal_Sum_method_t)(SEXP, Rboolean); 
typedef SEXP (*R_altreal_Min_method_t)(SEXP, Rboolean);
typedef SEXP (*R_altreal_Max_method_t)(SEXP, Rboolean);

typedef SEXP (*R_altstring_Elt_method_t)(SEXP, R_xlen_t);
typedef void (*R_altstring_Set_elt_method_t)(SEXP, R_xlen_t, SEXP);
typedef int (*R_altstring_Is_sorted_method_t)(SEXP);
typedef int (*R_altstring_No_NA_method_t)(SEXP);

#define DECLARE_METHOD_SETTER(CNAME, MNAME)				\
    void								\
    R_set_##CNAME##_##MNAME##_method(R_altrep_class_t cls,		\
				     R_##CNAME##_##MNAME##_method_t fun);

DECLARE_METHOD_SETTER(altrep, UnserializeEX)
DECLARE_METHOD_SETTER(altrep, Unserialize)
DECLARE_METHOD_SETTER(altrep, Serialized_state)
DECLARE_METHOD_SETTER(altrep, DuplicateEX)
DECLARE_METHOD_SETTER(altrep, Duplicate)
DECLARE_METHOD_SETTER(altrep, Coerce)
DECLARE_METHOD_SETTER(altrep, Inspect)
DECLARE_METHOD_SETTER(altrep, Length)

DECLARE_METHOD_SETTER(altvec, Dataptr)
DECLARE_METHOD_SETTER(altvec, Dataptr_or_null)
DECLARE_METHOD_SETTER(altvec, Extract_subset)

DECLARE_METHOD_SETTER(altinteger, Elt)
DECLARE_METHOD_SETTER(altinteger, Get_region)
DECLARE_METHOD_SETTER(altinteger, Is_sorted)
DECLARE_METHOD_SETTER(altinteger, No_NA)
DECLARE_METHOD_SETTER(altinteger, Sum)
DECLARE_METHOD_SETTER(altinteger, Min)
DECLARE_METHOD_SETTER(altinteger, Max)

DECLARE_METHOD_SETTER(altreal, Elt)
DECLARE_METHOD_SETTER(altreal, Get_region)
DECLARE_METHOD_SETTER(altreal, Is_sorted)
DECLARE_METHOD_SETTER(altreal, No_NA)
DECLARE_METHOD_SETTER(altreal, Sum)
DECLARE_METHOD_SETTER(altreal, Min)
DECLARE_METHOD_SETTER(altreal, Max)

DECLARE_METHOD_SETTER(altstring, Elt)
DECLARE_METHOD_SETTER(altstring, Set_elt)
DECLARE_METHOD_SETTER(altstring, Is_sorted)
DECLARE_METHOD_SETTER(altstring, No_NA)

#endif /* R_EXT_ALTREP_H_ */
