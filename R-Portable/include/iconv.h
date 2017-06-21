/* Copyright (C) 1999-2003, 2005-2006 Free Software Foundation, Inc.
   This file is part of the GNU LIBICONV Library.

   The GNU LIBICONV Library is free software; you can redistribute it
   and/or modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   The GNU LIBICONV Library is distributed in the hope that it will be
   useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU LIBICONV Library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation, Inc., 51 Franklin Street,
   Fifth Floor, Boston, MA 02110-1301, USA.  */

/* When installed, this file is called "iconv.h". */

/* A subset for use in R */

#ifndef _LIBICONV_H
#define _LIBICONV_H


#ifdef BUILDING_LIBICONV
#define LIBICONV_DLL_EXPORTED __declspec(dllexport)
#else
#define LIBICONV_DLL_EXPORTED __declspec(dllimport)
#endif
//#define LIBICONV_DLL_EXPORTED

#undef iconv_t
#define iconv_t libiconv_t
typedef void* iconv_t;

/* Get size_t declaration */
#include <stddef.h>


#ifdef __cplusplus
extern "C" {
#endif


#define iconv_open libiconv_open
extern LIBICONV_DLL_EXPORTED 
iconv_t iconv_open (const char* tocode, const char* fromcode);

#define iconv libiconv
extern LIBICONV_DLL_EXPORTED 
size_t iconv (iconv_t cd, const char* * inbuf, size_t *inbytesleft, 
	      char* * outbuf, size_t *outbytesleft);

#define iconv_close libiconv_close
extern LIBICONV_DLL_EXPORTED int iconv_close (iconv_t cd);

#define iconvlist libiconvlist
extern LIBICONV_DLL_EXPORTED 
void iconvlist (int (*do_one) (unsigned int namescount,
			       const char * const * names,
			       void* data),
		void* daXta);

#ifdef __cplusplus
}
#endif


#endif /* _LIBICONV_H */
