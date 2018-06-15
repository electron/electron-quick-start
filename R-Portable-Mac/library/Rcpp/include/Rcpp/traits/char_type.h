// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
/* :tabSize=4:indentSize=4:noTabs=false:folding=explicit:collapseFolds=1: */
//
// char_type.h: Rcpp R/C++ interface class library --
//
// Copyright (C) 2013 Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp__traits__char_type__h
#define Rcpp__traits__char_type__h

namespace Rcpp{
namespace traits{

    template <typename T>
    struct char_type {
    	typedef typename T::value_type type ;
    } ;

    template <> struct char_type< const wchar_t* > {
    	typedef wchar_t type ;
    } ;
    template <> struct char_type< const char* > {
    	typedef char type ;
    } ;

} // traits
} // Rcpp

#endif
