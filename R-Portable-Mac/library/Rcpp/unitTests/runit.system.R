#!/usr/bin/env r
# -*- mode: R; tab-width: 4; -*-
#
# Copyright (C) 2016          Dirk Eddelbuettel
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

    test.Rcpp.system.file <- function() {
        inc_rcpp <- Rcpp:::Rcpp.system.file("include")
        inc_sys <- tools::file_path_as_absolute( base::system.file("include", package = "Rcpp"))
        checkEquals(inc_rcpp, inc_sys, msg = "Rcpp.system.file")

    }

    test.RcppLd <- function() {
        checkTrue(Rcpp:::RcppLdPath() == "", msg = "RcppLdPath")
        checkTrue(Rcpp:::RcppLdFlags() == "", msg = "RcppLdFlags")
        checkEquals(Rcpp:::LdFlags(), NULL, msg = "LdFlags")
    }

    test.RcppCxx <- function() {
        checkTrue(Rcpp:::canUseCXX0X(), msg = "canUseCXX0X")
        checkTrue(Rcpp:::RcppCxxFlags() != "", msg = "RcppCxxFlags()")
        checkEquals(Rcpp:::CxxFlags(), NULL, msg = "CxxFlags()")

        checkTrue(length(Rcpp:::RcppCapabilities()) >= 13, msg = "RcppCapabilities()")
    }
}
