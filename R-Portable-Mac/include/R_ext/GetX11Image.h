/*
 *  R : A Computer Language for Statistical Data Analysis
 *  Copyright (C) 2003-2016  R Core Team
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, a copy is available at
 *  https://www.R-project.org/Licenses/
 */

/* Unix-only header */

#ifndef GETX11IMAGE_H_
#define GETX11IMAGE_H_

#ifdef  __cplusplus
extern "C" {
#endif

/* used by package tkrplot */

Rboolean R_GetX11Image(int d, void *pximage, int *pwidth, int *pheight);
/* pximage is really (XImage **) */

#ifdef  __cplusplus
}
#endif

#endif
