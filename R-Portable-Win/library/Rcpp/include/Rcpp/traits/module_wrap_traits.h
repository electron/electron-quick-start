// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
/* :tabSize=4:indentSize=4:noTabs=false:folding=explicit:collapseFolds=1: */
//
// module_wrap_traits.h: Rcpp R/C++ interface class library -- traits to help module wrap
//
// Copyright (C) 2012 Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp__traits__module_wrap_traits__h
#define Rcpp__traits__module_wrap_traits__h

namespace Rcpp{
namespace traits{

struct normal_wrap_tag{} ;
struct void_wrap_tag{} ;
struct pointer_wrap_tag{} ;

template <typename T> struct module_wrap_traits     { typedef normal_wrap_tag category; } ;
template <> struct module_wrap_traits<void>         { typedef void_wrap_tag category; } ;
template <typename T> struct module_wrap_traits<T*> { typedef pointer_wrap_tag category; } ;

} // namespace traits
} // namespace Rcpp
#endif
