// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-
//
// binom.h: Rcpp R/C++ interface class library --
//
// Copyright (C) 2010 - 2016 Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp__stats__stats_h
#define Rcpp__stats__stats_h

#include <Rcpp/stats/dpq/dpq.h>

#define ML_POSINF       R_PosInf
#define ML_NEGINF       R_NegInf
#define ML_NAN          R_NaN

#include <Rcpp/stats/unif.h>
#include <Rcpp/stats/norm.h>
#include <Rcpp/stats/gamma.h>
#include <Rcpp/stats/chisq.h>
#include <Rcpp/stats/beta.h>
#include <Rcpp/stats/t.h>
#include <Rcpp/stats/lnorm.h>
#include <Rcpp/stats/weibull.h>
#include <Rcpp/stats/logis.h>
#include <Rcpp/stats/f.h>
#include <Rcpp/stats/exp.h>
#include <Rcpp/stats/cauchy.h>
#include <Rcpp/stats/geom.h>
#include <Rcpp/stats/hyper.h>

#include <Rcpp/stats/nt.h>
#include <Rcpp/stats/nchisq.h>
#include <Rcpp/stats/nbeta.h>
#include <Rcpp/stats/nf.h>
#include <Rcpp/stats/nbinom.h>
#include <Rcpp/stats/nbinom_mu.h>

#include <Rcpp/stats/binom.h>
#include <Rcpp/stats/pois.h>

#include <Rcpp/stats/random/random.h>

#endif
