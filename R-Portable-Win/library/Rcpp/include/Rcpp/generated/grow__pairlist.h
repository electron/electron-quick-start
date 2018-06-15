// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// grow__pairlist.h: Rcpp R/C++ interface class library -- generated helper code for grow.h
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

#ifndef Rcpp__generated__grow_pairlist_h
#define Rcpp__generated__grow_pairlist_h

/* <code-bloat>

template <TYPENAMES>
SEXP pairlist( ARGUMENTS ){
	return GROW ;
}

*/
template <typename T1>
SEXP pairlist( const T1& t1 ){
	return grow( t1, R_NilValue ) ;
}

template <typename T1, typename T2>
SEXP pairlist( const T1& t1, const T2& t2 ){
	return grow( t1, grow( t2, R_NilValue ) ) ;
}

template <typename T1, typename T2, typename T3>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3 ){
	return grow( t1, grow( t2, grow( t3, R_NilValue ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, R_NilValue ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, R_NilValue ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, R_NilValue ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, R_NilValue ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, R_NilValue ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, R_NilValue ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, R_NilValue ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13, typename T14>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13, const T14& t14 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, grow( t14, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13, typename T14, typename T15>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13, const T14& t14, const T15& t15 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, grow( t14, grow( t15, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13, typename T14, typename T15, typename T16>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13, const T14& t14, const T15& t15, const T16& t16 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, grow( t14, grow( t15, grow( t16, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13, typename T14, typename T15, typename T16, typename T17>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13, const T14& t14, const T15& t15, const T16& t16, const T17& t17 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, grow( t14, grow( t15, grow( t16, grow( t17, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13, typename T14, typename T15, typename T16, typename T17, typename T18>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13, const T14& t14, const T15& t15, const T16& t16, const T17& t17, const T18& t18 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, grow( t14, grow( t15, grow( t16, grow( t17, grow( t18, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13, typename T14, typename T15, typename T16, typename T17, typename T18, typename T19>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13, const T14& t14, const T15& t15, const T16& t16, const T17& t17, const T18& t18, const T19& t19 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, grow( t14, grow( t15, grow( t16, grow( t17, grow( t18, grow( t19, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

template <typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8, typename T9, typename T10, typename T11, typename T12, typename T13, typename T14, typename T15, typename T16, typename T17, typename T18, typename T19, typename T20>
SEXP pairlist( const T1& t1, const T2& t2, const T3& t3, const T4& t4, const T5& t5, const T6& t6, const T7& t7, const T8& t8, const T9& t9, const T10& t10, const T11& t11, const T12& t12, const T13& t13, const T14& t14, const T15& t15, const T16& t16, const T17& t17, const T18& t18, const T19& t19, const T20& t20 ){
	return grow( t1, grow( t2, grow( t3, grow( t4, grow( t5, grow( t6, grow( t7, grow( t8, grow( t9, grow( t10, grow( t11, grow( t12, grow( t13, grow( t14, grow( t15, grow( t16, grow( t17, grow( t18, grow( t19, grow( t20, R_NilValue ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
}

/* </code-bloat> */

#endif
