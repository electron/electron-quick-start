// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-
//
// longlong.h: Rcpp R/C++ interface class library -- long long support
//
// Copyright (C) 2013  Dirk Eddelbuettel and Romain Francois
//
// This file is part of Rcpp.
//
// Rcpp is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// Rcpp is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Rcpp.  If not, see <http://www.gnu.org/licenses/>.

#ifndef RCPP_LONG_LONG_H
#define RCPP_LONG_LONG_H

// 'long long' is a C99 extension and (as of fall 2013) still
// forbidden by CRAN which stick with the C++98 standard predating it.
// One way to get 'long long' is to switch to C++11, another is to use
// clang++ from the llvm project.
#ifdef __GNUC__
#if defined(__GXX_EXPERIMENTAL_CXX0X__) || (defined (__clang__) && defined(__LP64__))

#if defined(__GNUC__) &&  defined(__LONG_LONG_MAX__)
__extension__ typedef long long int rcpp_long_long_type;
__extension__ typedef unsigned long long int rcpp_ulong_long_type;
#define RCPP_HAS_LONG_LONG_TYPES
#endif

#endif
#endif

#endif
