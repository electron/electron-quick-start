// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-
//
// misc.cpp: Rcpp R/C++ interface class library -- misc unit tests
//
// Copyright (C) 2013 - 2015  Dirk Eddelbuettel and Romain Francois
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

#define RCPP_PROTECTED_EVAL

#include <Rcpp.h>
using namespace Rcpp;

// Class that indicates to R caller whether C++ stack was unwound
struct unwindIndicator {
    unwindIndicator(LogicalVector indicator_) {
        // Reset the indicator to FALSE
        indicator = indicator_;
        *LOGICAL(indicator) = 0;
    }

    // Set indicator to TRUE when stack unwinds
    ~unwindIndicator() {
        *LOGICAL(indicator) = 1;
    }

    LogicalVector indicator;
};

// [[Rcpp::export]]
SEXP testFastEval(RObject expr, Environment env, LogicalVector indicator) {
    unwindIndicator my_data(indicator);
    return Rcpp::Rcpp_fast_eval(expr, env);
}

// [[Rcpp::export]]
SEXP testSendInterrupt() {
    Rf_onintr();
    return R_NilValue;
}
