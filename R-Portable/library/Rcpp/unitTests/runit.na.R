#!/usr/bin/env r
# -*- mode: R; tab-width: 4; -*-
#
# Copyright (C) 2014  Kevin Ushey
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
    
.setUp <- Rcpp:::unitTestSetup("na.cpp")

test.na <- function() {
    checkIdentical( R_IsNA_(NA_real_), Rcpp_IsNA(NA_real_) )
    checkIdentical( R_IsNA_(NA_real_+1), Rcpp_IsNA(NA_real_+1) )
    checkIdentical( R_IsNA_(NA_real_+NaN), Rcpp_IsNA(NA_real_+NaN) )
    checkIdentical( R_IsNA_(NaN+NA_real_), Rcpp_IsNA(NaN+NA_real_) )
    checkIdentical( R_IsNaN_(NA_real_), Rcpp_IsNaN(NA_real_) )
    checkIdentical( R_IsNaN_(NaN), Rcpp_IsNaN(NaN) )
    checkIdentical( R_IsNaN_(NaN+1), Rcpp_IsNaN(NaN+1) )
}
    
}
