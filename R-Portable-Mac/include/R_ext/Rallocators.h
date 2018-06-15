/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2014-2016  The R Core Team
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
 *  Definition of the R_allocator_t structure for custom allocators
 *  to be used with allocVector3()
 */

#ifndef R_EXT_RALLOCATORS_H_
#define R_EXT_RALLOCATORS_H_

#if defined(__cplusplus) && !defined(DO_NOT_USE_CXX_HEADERS)
# include <cstddef>
#else
# include <stddef.h> /* for size_t */
#endif

/* R_allocator_t typedef is also declared in Rinternals.h 
   so we guard against random inclusion order */
#ifndef R_ALLOCATOR_TYPE
#define R_ALLOCATOR_TYPE
typedef struct R_allocator R_allocator_t;
#endif

typedef void *(*custom_alloc_t)(R_allocator_t *allocator, size_t);
typedef void  (*custom_free_t)(R_allocator_t *allocator, void *);

struct R_allocator {
    custom_alloc_t mem_alloc; /* malloc equivalent */
    custom_free_t  mem_free;  /* free equivalent */
    void *res;                /* reserved (maybe for copy) - must be NULL */
    void *data;               /* custom data for the allocator implementation */
};

#endif /* R_EXT_RALLOCATORS_H_ */
