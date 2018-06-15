// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
/* :tabSize=4:indentSize=4:noTabs=false:folding=explicit:collapseFolds=1: */
//
// expands_to_logical.h: Rcpp R/C++ interface class library --
//
// Copyright (C) 2010 - 2011 Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp__traits__expands_to_logical_h
#define Rcpp__traits__expands_to_logical_h

// helper trait to disambiguate things that want to be logical vectors
// from containers of int

namespace Rcpp{
namespace traits{

	template <int RTYPE>
	struct expands_to_logical__impl{} ;

	template <>
	struct expands_to_logical__impl<LGLSXP> {
		struct r_expands_to_logical{};
	} ;

	template<typename T>
	class _has_rtype_helper : __sfinae_types {
      template<typename U> struct _Wrap_type { };

      template<typename U>
        static __one __test(_Wrap_type<typename U::r_expands_to_logical>*);

      template<typename U>
        static __two __test(...);

    public:
      static const bool value = sizeof(__test<T>(0)) == 1;
    };

  template<typename T> struct expands_to_logical :
  	integral_constant<bool, _has_rtype_helper<T>::value >{ };


}
}

#endif
