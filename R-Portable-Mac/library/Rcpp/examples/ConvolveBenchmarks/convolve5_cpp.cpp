// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-

// This is a rewrite of the 'Writing R Extensions' section 5.10.1 example

#include <Rcpp.h>
using namespace Rcpp ;


RcppExport SEXP convolve5cpp(SEXP a, SEXP b) {
    NumericVector xa(a); int n_xa = xa.size() ;
    NumericVector xb(b); int n_xb = xb.size() ;
    NumericVector xab(n_xa + n_xb - 1,0.0);

    Range r( 0, n_xb-1 );
    for(int i=0; i<n_xa; i++, r++){
    	xab[ r ] += xa[i] * xb ;
    }
    return xab ;
}

#include "loopmacro.h"
LOOPMACRO_CPP(convolve5cpp)

