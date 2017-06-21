// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// any.h: Rcpp R/C++ interface class library -- any
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

#ifndef Rcpp__sugar__any_h
#define Rcpp__sugar__any_h

namespace Rcpp{
namespace sugar{

template <bool NA, typename T>
class Any : public SingleLogicalResult< true, Any<NA,T> >{
public:
	typedef Rcpp::VectorBase<LGLSXP,NA,T> VEC_TYPE ;
	typedef SingleLogicalResult< true , Any<NA,T> > PARENT ;
	Any( const VEC_TYPE& t ) : PARENT() , object(t) {}

	void apply(){
		R_xlen_t n = object.size() ;
		int current = 0 ;
		PARENT::reset() ;
		for( R_xlen_t i=0 ; i<n ; i++){
			current = object[i] ;
			if( current == TRUE ) {
				PARENT::set_true() ;
				return ;
			}
			if( Rcpp::traits::is_na<LGLSXP>(current)  ) {
				PARENT::set_na();
			}
		}
		if( PARENT::is_unresolved() ){
			PARENT::set_false() ;
		}
	}
private:
	const VEC_TYPE& object ;
} ;

template <typename T>
class Any<false,T> : public SingleLogicalResult< false, Any<false,T> >{
public:
	typedef Rcpp::VectorBase<LGLSXP,false,T> VEC_TYPE ;
	typedef SingleLogicalResult< false , Any<false,T> > PARENT ;
	Any( const VEC_TYPE& t ) : PARENT() , object(t) {}

	void apply(){
		R_xlen_t n = object.size() ;
		PARENT::set_false() ;
		for( R_xlen_t i=0 ; i<n ; i++){
			if( object[i] == TRUE ) {
				PARENT::set_true() ;
				return ;
			}
		}
	}
private:
	const VEC_TYPE& object ;
} ;

} // sugar

template <bool NA, typename T>
inline sugar::Any<NA,T> any( const Rcpp::VectorBase<LGLSXP,NA,T>& t){
	return sugar::Any<NA,T>( t ) ;
}

} // Rcpp
#endif

