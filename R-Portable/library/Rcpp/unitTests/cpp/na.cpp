// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; tab-width: 8 -*-
//
// na.cpp: Rcpp R/C++ interface class library -- na unit tests
//
// Copyright (C) 2014 Kevin Ushey
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

#include <Rcpp.h>
using namespace Rcpp ;

// [[Rcpp::export]]
bool Rcpp_IsNA(double x) {
    return internal::Rcpp_IsNA(x);
}

// [[Rcpp::export]]
bool Rcpp_IsNaN(double x) {
    return internal::Rcpp_IsNaN(x);
}

// [[Rcpp::export]]
bool R_IsNA_(double x) {
    return ::R_IsNA(x);
}

// [[Rcpp::export]]
bool R_IsNaN_(double x) {
    return ::R_IsNaN(x);
}

