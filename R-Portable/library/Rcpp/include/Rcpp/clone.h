// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// clone.h: Rcpp R/C++ interface class library -- clone RObject's
//
// Copyright (C) 2010 - 2012 Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp_clone_h
#define Rcpp_clone_h

#include <RcppCommon.h>

namespace Rcpp{

/* cloning type T is possible if :
   - T can be converted to SEXP
   - T has a SEXP constructor
*/
template <typename T> T clone(const T& object) {
    SEXP x = const_cast<T&>(object) ;
    return T( Rf_duplicate( x ) ) ;
}

} // namespace Rcpp

#endif
