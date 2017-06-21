/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2000-2014 The R Core Team.
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
  Experimental: included by src/library/stats/src/distance.c

  Note that only uses R_num_math_threads: it is not clear
  R_num_math_threads should be exposed at all.

  This is not used currently on Windows, where R_num_math_threads
  used not to be exposed.
*/

#ifndef R_EXT_MATHTHREADS_H_
#define R_EXT_MATHTHREADS_H_

#ifdef  __cplusplus
extern "C" {
#endif

#include <R_ext/libextern.h>
LibExtern int R_num_math_threads;
LibExtern int R_max_num_math_threads;

#ifdef  __cplusplus
}
#endif

#endif /* R_EXT_MATHTHREADS_H_ */
