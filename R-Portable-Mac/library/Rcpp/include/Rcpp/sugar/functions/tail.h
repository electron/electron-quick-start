// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// tail.h: Rcpp R/C++ interface class library -- tail
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

#ifndef Rcpp__sugar__tail_h
#define Rcpp__sugar__tail_h

namespace Rcpp{
namespace sugar{

template <int RTYPE, bool NA, typename T>
class Tail : public Rcpp::VectorBase< RTYPE ,NA, Tail<RTYPE,NA,T> > {
public:
	typedef typename Rcpp::VectorBase<RTYPE,NA,T> VEC_TYPE ;
	typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE ;

        Tail( const VEC_TYPE& object_, R_xlen_t n_ ) : object(object_), start(0), n(n_) {
		if( n > 0 ){
			start = object.size() - n ;
		} else {
			start = -n ;
			n = object.size() - start ;
		}
	}

        inline STORAGE operator[]( R_xlen_t i ) const {
		return object[ start + i ] ;
	}
        inline R_xlen_t size() const { return n; }

private:
	const VEC_TYPE& object ;
        R_xlen_t start, n ;
} ;

} // sugar

template <int RTYPE,bool NA, typename T>
inline sugar::Tail<RTYPE,NA,T> tail(
	const VectorBase<RTYPE,NA,T>& t,
	R_xlen_t n
	){
	return sugar::Tail<RTYPE,NA,T>( t, n ) ;
}

} // Rcpp
#endif

