/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2001-12  The R Core Team.
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
  Macros to help defining vectorized functions with proper recycling
  and periodic interrupt checks.
 */

#ifndef  R_EXT_ITERMACROS_H_
#define  R_EXT_ITERMACROS_H_

#define LOOP_WITH_INTERRUPT_CHECK(LOOP, ncheck, n, ...) do {		\
	for (size_t __intr_threshold__ = ncheck;			\
	     TRUE;							\
	     __intr_threshold__ += ncheck) {				\
	    size_t __intr_end__ = n < __intr_threshold__ ?		\
		n : __intr_threshold__;					\
	    LOOP(__intr_end__, __VA_ARGS__);				\
	    if (__intr_end__ == n) break;				\
	    else R_CheckUserInterrupt();				\
	}								\
    } while (0)

#define R_ITERATE_CORE(n, i, loop_body) do {	\
	for (; i < n; ++i) { loop_body }	\
    } while (0)

#define R_ITERATE(n, i, loop_body) do {		\
	i = 0;					\
	R_ITERATE_CORE(n, i, loop_body);		\
    } while (0)

#define R_ITERATE_CHECK(ncheck, n, i, loop_body) do {			\
	i = 0;								\
	LOOP_WITH_INTERRUPT_CHECK(R_ITERATE_CORE, ncheck, n, i, loop_body); \
    } while (0)


#define MOD_ITERATE1_CORE(n, n1, i, i1, loop_body) do {	\
	for (; i < n;							\
	     i1 = (++i1 == n1) ? 0 : i1,				\
		 ++i) {							\
	    loop_body							\
		}							\
    } while (0)

#define MOD_ITERATE1(n, n1, i, i1, loop_body) do {	\
	i = i1 = 0;					\
	MOD_ITERATE1_CORE(n, n1, i, i1, loop_body);	\
    } while (0)

#define MOD_ITERATE1_CHECK(ncheck, n, n1, i, i1, loop_body) do {	\
	i = i1 = 0;							\
	LOOP_WITH_INTERRUPT_CHECK(MOD_ITERATE1_CORE, ncheck, n,		\
				  n1, i, i1, loop_body);		\
    } while (0)

#define MOD_ITERATE2_CORE(n, n1, n2, i, i1, i2, loop_body) do {	\
	for (; i < n;							\
	     i1 = (++i1 == n1) ? 0 : i1,				\
		 i2 = (++i2 == n2) ? 0 : i2,				\
		 ++i) {							\
	    loop_body							\
		}							\
    } while (0)

#define MOD_ITERATE2(n, n1, n2, i, i1, i2, loop_body) do {	\
	i = i1 = i2 = 0;					\
	MOD_ITERATE2_CORE(n, n1, n2, i, i1, i2, loop_body);	\
    } while (0)

#define MOD_ITERATE2_CHECK(ncheck, n, n1, n2, i, i1, i2, loop_body) do {	\
	i = i1 = i2 = 0;						\
	LOOP_WITH_INTERRUPT_CHECK(MOD_ITERATE2_CORE, ncheck, n,		\
				  n1, n2, i, i1, i2, loop_body);	\
    } while (0)

#define MOD_ITERATE MOD_ITERATE2
#define MOD_ITERATE_CORE MOD_ITERATE2_CORE
#define MOD_ITERATE_CHECK MOD_ITERATE2_CHECK

#define MOD_ITERATE3_CORE(n, n1, n2, n3, i, i1, i2, i3, loop_body) do {	\
	for (; i < n;							\
	     i1 = (++i1 == n1) ? 0 : i1,				\
		 i2 = (++i2 == n2) ? 0 : i2,				\
		 i3 = (++i3 == n3) ? 0 : i3,				\
		 ++i) {							\
	    loop_body							\
		}							\
    } while (0)

#define MOD_ITERATE3(n, n1, n2, n3, i, i1, i2, i3, loop_body) do {	\
	i = i1 = i2 = i3 = 0;						\
	MOD_ITERATE3_CORE(n, n1, n2, n3, i, i1, i2, i3, loop_body);	\
    } while (0)

#define MOD_ITERATE3_CHECK(ncheck, n, n1, n2, n3, i, i1, i2, i3, loop_body) \
    do {								\
	i = i1 = i2 = i3 = 0;						\
	LOOP_WITH_INTERRUPT_CHECK(MOD_ITERATE3_CORE, ncheck, n,		\
				  n1, n2, n3, i, i1, i2, i3, loop_body); \
    } while (0)

#define MOD_ITERATE4_CORE(n, n1, n2, n3, n4, i, i1, i2, i3, i4, loop_body) \
    do {								\
	for (; i < n;							\
	     i1 = (++i1 == n1) ? 0 : i1,				\
		 i2 = (++i2 == n2) ? 0 : i2,				\
		 i3 = (++i3 == n3) ? 0 : i3,				\
		 i4 = (++i4 == n4) ? 0 : i4,				\
		 ++i) {							\
	    loop_body							\
		}							\
    } while (0)

#define MOD_ITERATE4(n, n1, n2, n3, n4, i, i1, i2, i3, i4, loop_body) do { \
	i = i1 = i2 = i3 = i4 = 0;					\
	MOD_ITERATE4_CORE(n, n1, n2, n3, n4, i, i1, i2, i3, i4, loop_body); \
    } while (0)

#define MOD_ITERATE4_CHECK(ncheck, n, n1, n2, n3, n4, i, i1, i2, i3, i4, \
			   loop_body)					\
    do {								\
	i = i1 = i2 = i3 = i4 = 0;					\
	LOOP_WITH_INTERRUPT_CHECK(MOD_ITERATE4_CORE, ncheck, n,	\
				  n1, n2, n3, n4,			\
				  i, i1, i2, i3, i4, loop_body);	\
    } while (0)

#define MOD_ITERATE5_CORE(n, n1, n2, n3, n4, n5, i, i1, i2, i3, i4, i5, \
			  loop_body)					\
    do {								\
	for (; i < n;							\
	     i1 = (++i1 == n1) ? 0 : i1,				\
		 i2 = (++i2 == n2) ? 0 : i2,				\
		 i3 = (++i3 == n3) ? 0 : i3,				\
		 i4 = (++i4 == n4) ? 0 : i4,				\
		 i5 = (++i5 == n5) ? 0 : i5,				\
		 ++i) {							\
	    loop_body							\
		}							\
    } while (0)

#define MOD_ITERATE5(n, n1, n2, n3, n4, n5, i, i1, i2, i3, i4, i5, loop_body) \
    do {								\
	i = i1 = i2 = i3 = i4 = i5 = 0;					\
	MOD_ITERATE5_CORE(n, n1, n2, n3, n4, n5, i, i1, i2, i3, i4, i5, \
			  loop_body);					\
    } while (0)

#define MOD_ITERATE5_CHECK(ncheck, n, n1, n2, n3, n4, n5, \
			   i, i1, i2, i3, i4, i5,			\
			   loop_body)					\
    do {								\
	i = i1 = i2 = i3 = i4 = i5 = 0;					\
	LOOP_WITH_INTERRUPT_CHECK(MOD_ITERATE5_CORE, ncheck, n,	\
				  n1, n2, n3, n4, n5,			\
				  i, i1, i2, i3, i4, i5, loop_body);	\
    } while (0)

#define GET_REGION_BUFSIZE 512
#define GET_REGION_PTR(x, i, n, buf, type)				\
    (ALTREP(x) == 0 ? type##0(x) + (i) : (type##_GET_REGION(x, i, n, buf), buf))

#define ITERATE_BY_REGION0(sx, px, idx, nb, etype, vtype, expr) do {	\
	etype __ibr_buf__[GET_REGION_BUFSIZE];				\
	R_xlen_t __ibr_n__ = XLENGTH(sx);				\
	R_xlen_t nb;							\
	for (R_xlen_t idx = 0; idx < __ibr_n__; idx += nb) {		\
	    nb = __ibr_n__  - idx > GET_REGION_BUFSIZE ?		\
		GET_REGION_BUFSIZE :  __ibr_n__ - idx;			\
	    etype *px = GET_REGION_PTR(sx, idx, nb, __ibr_buf__, vtype); \
	    expr							\
	 }							        \
    } while (0)

#define ITERATE_BY_REGION(sx, px, idx, nb, etype, vtype, expr) do {	\
	const etype *px = DATAPTR_OR_NULL(sx);				\
	if (px != NULL) {						\
	    R_xlen_t __ibr_n__ = XLENGTH(sx);				\
	    R_xlen_t nb = __ibr_n__;					\
	    for (R_xlen_t idx = 0; idx < __ibr_n__; idx += nb) {	\
		expr							\
	     }								\
	}								\
	else ITERATE_BY_REGION0(sx, px, idx, nb, etype, vtype, expr);	\
    } while (0)

#endif /* R_EXT_ITERMACROS_H_ */
