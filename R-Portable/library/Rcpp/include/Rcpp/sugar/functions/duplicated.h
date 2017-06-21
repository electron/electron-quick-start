// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// duplicated.h: Rcpp R/C++ interface class library -- duplicated
//
// Copyright (C) 2012   Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp__sugar__duplicated_h
#define Rcpp__sugar__duplicated_h

namespace Rcpp{

template <int RTYPE, bool NA, typename T>
inline LogicalVector duplicated( const VectorBase<RTYPE,NA,T>& x ){
    Vector<RTYPE> vec(x) ;
    sugar::IndexHash<RTYPE> hash(vec) ;
    return hash.fill_and_get_duplicated() ;
}


} // Rcpp
#endif

