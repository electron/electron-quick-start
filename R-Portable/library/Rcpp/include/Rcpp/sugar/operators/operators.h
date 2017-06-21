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

#ifndef Rcpp__sugar__operators__operators_h
#define Rcpp__sugar__operators__operators_h

// binary operators
#include <Rcpp/sugar/operators/Comparator.h>
#include <Rcpp/sugar/operators/Comparator_With_One_Value.h>

#include <Rcpp/sugar/operators/logical_operators__Vector__Vector.h>
#include <Rcpp/sugar/operators/logical_operators__Vector__primitive.h>
#include <Rcpp/sugar/operators/plus.h>
#include <Rcpp/sugar/operators/minus.h>
#include <Rcpp/sugar/operators/times.h>
#include <Rcpp/sugar/operators/divides.h>

// unary operators
#include <Rcpp/sugar/operators/not.h>
#include <Rcpp/sugar/operators/unary_minus.h>

#endif
