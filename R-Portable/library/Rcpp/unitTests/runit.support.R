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

    .setUp <- Rcpp:::unitTestSetup("support.cpp")

    test.plus.REALSXP <- function(){
        checkEquals(
            plus_REALSXP(),
            list(NA_real_,NA_real_,NA_real_) ,
            msg = " REALSXP + REALSXP" )
    }

    test.times.REALSXP <- function(){
        checkEquals(
            times_REALSXP(),
            list(NA_real_,NA_real_,NA_real_) ,
            msg = " REALSXP * REALSXP" )
    }

    test.divides.REALSXP <- function(){
        checkEquals(
            divides_REALSXP(),
            list(NA_real_,NA_real_,NA_real_) ,
            msg = " REALSXP / REALSXP" )
    }

    test.minus.REALSXP <- function(){
        checkEquals(
            minus_REALSXP(),
            list(NA_real_,NA_real_,NA_real_) ,
            msg = " REALSXP - REALSXP" )
    }

    test.functions.REALSXP <- function(){
        checkEquals(
            functions_REALSXP(),
            list( rep(NA_real_, 20L), rep(NA_real_, 6L) ) ,
            msg = "function(NA_REAL)" )
    }

}
