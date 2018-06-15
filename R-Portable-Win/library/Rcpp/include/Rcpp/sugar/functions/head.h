// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// head.h: Rcpp R/C++ interface class library -- head
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

#ifndef Rcpp__sugar__head_h
#define Rcpp__sugar__head_h

namespace Rcpp{
namespace sugar{

template <int RTYPE, bool NA, typename T>
class Head : public Rcpp::VectorBase< RTYPE ,NA, Head<RTYPE,NA,T> > {
public:
	typedef typename Rcpp::VectorBase<RTYPE,NA,T> VEC_TYPE ;
	typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE ;

	Head( const VEC_TYPE& object_, R_xlen_t n_ ) : object(object_), n(n_) {
		if( n < 0 ){
			n = object.size() + n ;
		}
	}

	inline STORAGE operator[]( R_xlen_t i ) const {
		return object[ i ] ;
	}
	inline R_xlen_t size() const { return n; }

private:
	const VEC_TYPE& object ;
	int n ;
} ;

} // sugar

template <int RTYPE,bool NA, typename T>
inline sugar::Head<RTYPE,NA,T> head(
	const VectorBase<RTYPE,NA,T>& t,
	R_xlen_t n
	){
	return sugar::Head<RTYPE,NA,T>( t, n ) ;
}

} // Rcpp
#endif

