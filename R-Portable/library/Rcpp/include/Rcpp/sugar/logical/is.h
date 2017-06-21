// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// is.h: Rcpp R/C++ interface class library --
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

#ifndef RCPP_SUGAR_LOGICAL_IS_H
#define RCPP_SUGAR_LOGICAL_IS_H

namespace Rcpp{

	template <bool NA, typename T>
	inline bool is_true( const Rcpp::sugar::SingleLogicalResult<NA,T>& x){
		return const_cast< Rcpp::sugar::SingleLogicalResult<NA,T>& >(x).is_true() ;
	}

	template <bool NA, typename T>
	inline bool is_false( const Rcpp::sugar::SingleLogicalResult<NA,T>& x){
		return const_cast< Rcpp::sugar::SingleLogicalResult<NA,T>& >(x).is_false() ;
	}

	template <bool NA, typename T>
	inline bool is_na( const Rcpp::sugar::SingleLogicalResult<NA,T>& x){
		return const_cast< Rcpp::sugar::SingleLogicalResult<NA,T>& >(x).is_na() ;
	}


}
#endif
