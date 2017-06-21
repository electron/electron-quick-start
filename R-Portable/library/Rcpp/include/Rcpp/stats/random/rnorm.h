// -*- mode: C++; c-indent-level: 4; c-basic-offset: 4; indent-tabs-mode: nil; -*-
//
// rnorm.h: Rcpp R/C++ interface class library --
//
// Copyright (C) 2010 - 2016  Douglas Bates, Dirk Eddelbuettel and Romain Francois
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

#ifndef Rcpp__stats__random_rnorm_h
#define Rcpp__stats__random_rnorm_h

namespace Rcpp {
namespace stats {

class NormGenerator : public Generator<double> {
public:

    NormGenerator( double mean_ = 0.0 , double sd_ = 1.0 ) :
        mean(mean_), sd(sd_) {}

    inline double operator()() const {
        return mean + sd * ::norm_rand() ;
    }

private:
    double mean ;
    double sd ;
};

class NormGenerator__sd1 : public Generator<double> {
public:

    NormGenerator__sd1( double mean_ = 0.0 ) : mean(mean_) {}

    inline double operator()() const {
        return mean + ::norm_rand() ;
    }

private:
    double mean ;
};

class NormGenerator__mean0 : public Generator<double> {
public:

    NormGenerator__mean0( double sd_ = 1.0 ) : sd(sd_) {}

    inline double operator()() const {
        return sd * ::norm_rand() ;
    }

private:
    double sd ;
};

class NormGenerator__mean0__sd1 : public Generator<double> {
public:

    NormGenerator__mean0__sd1( ) {}

    inline double operator()() const {
        return ::norm_rand() ;
    }

};

} // stats
} // Rcpp

#endif
