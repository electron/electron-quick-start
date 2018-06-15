// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// DottedPair.h: Rcpp R/C++ interface class library -- dotted pair list template
//
// Copyright (C) 2010 - 2013 Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp_DottedPair_h
#define Rcpp_DottedPair_h

namespace Rcpp{

RCPP_API_CLASS(DottedPair_Impl),
    public DottedPairProxyPolicy<DottedPair_Impl<StoragePolicy> >,
    public DottedPairImpl<DottedPair_Impl<StoragePolicy> > {
public:
    RCPP_GENERATE_CTOR_ASSIGN(DottedPair_Impl)

	DottedPair_Impl(){}

	DottedPair_Impl(SEXP x) {
	    Storage::set__(x) ;
	}

	#include <Rcpp/generated/DottedPair__ctors.h>

	void update(SEXP){}

};

typedef DottedPair_Impl<PreserveStorage> DottedPair ;

} // namespace Rcpp

#endif
