#!/usr/bin/env r
#
# Copyright (C) 2010 - 2014  Dirk Eddelbuettel and Romain Francois
#
# This file is part of Rcpp.
#
# Rcpp is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Rcpp is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rcpp.  If not, see <http://www.gnu.org/licenses/>.

.runThisTest <- Sys.getenv("RunAllRcppTests") == "yes"

if (.runThisTest) {

    .setUp <- Rcpp:::unitTestSetup("as.cpp")

    test.as.int <- function(){
        checkEquals( as_int(10), 10L, msg = "as<int>( REALSXP ) " )
        checkEquals( as_int(10L), 10L, msg = "as<int>( INTSXP ) " )
        checkEquals( as_int(as.raw(10L)), 10L, msg = "as<int>( RAWSXP ) " )
        checkEquals( as_int(TRUE), 1L, msg = "as<int>( LGLSXP ) " )
    }

    test.as.double <- function(){
        checkEquals( as_double(10), 10.0, msg = "as<double>( REALSXP ) " )
        checkEquals( as_double(10L), 10.0, msg = "as<double>( INTSXP ) " )
        checkEquals( as_double(as.raw(10L)), 10.0, msg = "as<double>( RAWSXP ) " )
        checkEquals( as_double(TRUE), 1.0, msg = "as<double>( LGLSXP ) " )
    }

    test.as.raw <- function(){
        checkEquals( as_raw(10), as.raw(10), msg = "as<Rbyte>( REALSXP ) " )
        checkEquals( as_raw(10L), as.raw(10), msg = "as<Rbyte>( INTSXP ) " )
        checkEquals( as_raw(as.raw(10L)), as.raw(10), msg = "as<Rbyte>( RAWSXP ) " )
        checkEquals( as_raw(TRUE), as.raw(1), msg = "as<Rbyte>( LGLSXP ) " )
    }

    test.as.bool <- function(){
        checkEquals( as_bool(10), as.logical(10), msg = "as<bool>( REALSXP ) " )
        checkEquals( as_bool(10L), as.logical(10), msg = "as<bool>( INTSXP ) " )
        checkEquals( as_bool(as.raw(10L)), as.logical(10), msg = "as<bool>( RAWSXP ) " )
        checkEquals( as_bool(TRUE), as.logical(1), msg = "as<bool>( LGLSXP ) " )
    }

    test.as.string <- function(){
        checkEquals( as_string("foo"), "foo", msg = "as<string>( STRSXP ) " )
    }

    test.as.vector.int <- function(){
        checkEquals( as_vector_int(1:10), 1:10 , msg = "as<vector<int>>( INTSXP ) " )
        checkEquals( as_vector_int(as.numeric(1:10)), 1:10 , msg = "as<vector<int>>( REALSXP ) " )
        checkEquals( as_vector_int(as.raw(1:10)), 1:10 , msg = "as<vector<int>>( RAWSXP ) " )
        checkEquals( as_vector_int(c(TRUE,FALSE)), 1:0 , msg = "as<vector<int>>( LGLSXP ) " )
    }

    test.as.vector.double <- function(){
        checkEquals( as_vector_double(1:10), as.numeric(1:10) , msg = "as<vector<double>>( INTSXP ) " )
        checkEquals( as_vector_double(as.numeric(1:10)), as.numeric(1:10) , msg = "as<vector<double>>( REALSXP ) " )
        checkEquals( as_vector_double(as.raw(1:10)), as.numeric(1:10), msg = "as<vector<double>>( RAWSXP ) " )
        checkEquals( as_vector_double(c(TRUE,FALSE)), c(1.0, 0.0) , msg = "as<vector<double>>( LGLSXP ) " )
    }

    test.as.vector.raw <- function(){
        checkEquals( as_vector_raw(1:10), as.raw(1:10) , msg = "as<vector<Rbyte>>( INTSXP ) " )
        checkEquals( as_vector_raw(as.numeric(1:10)), as.raw(1:10) , msg = "as<vector<Rbyte>>( REALSXP ) " )
        checkEquals( as_vector_raw(as.raw(1:10)), as.raw(1:10) , msg = "as<vector<Rbyte>>( RAWSXP ) " )
        checkEquals( as_vector_raw(c(TRUE,FALSE)), as.raw(1:0) , msg = "as<vector<Rbyte>>( LGLSXP ) " )
    }

    test.as.vector.bool <- function(){
        checkEquals( as_vector_bool(0:10), as.logical(0:10) , msg = "as<vector<bool>>( INTSXP ) " )
        checkEquals( as_vector_bool(as.numeric(0:10)), as.logical(0:10) , msg = "as<vector<bool>>( REALSXP ) " )
        checkEquals( as_vector_bool(as.raw(0:10)), as.logical(0:10) , msg = "as<vector<bool>>( RAWSXP ) " )
        checkEquals( as_vector_bool(c(TRUE,FALSE)), as.logical(1:0) , msg = "as<vector<bool>>( LGLSXP ) " )
    }


    test.as.vector.string <- function(){
        checkEquals( as_vector_string(letters), letters , msg = "as<vector<string>>( STRSXP ) " )
    }

    test.as.deque.int <- function(){
        checkEquals( as_deque_int(1:10), 1:10 , msg = "as<deque<int>>( INTSXP ) " )
    }

    test.as.list.int <- function(){
        checkEquals( as_list_int(1:10), 1:10 , msg = "as<list<int>>( INTSXP ) " )
    }

}
