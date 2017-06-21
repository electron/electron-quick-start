#!/usr/bin/env r
#       hey emacs, please make this use  -*- tab-width: 4 -*-
#
# Copyright (C) 2009 - 2014	 Dirk Eddelbuettel and Romain Francois
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

    .setUp <- Rcpp:::unitTestSetup("XPtr.cpp")
    
    test.XPtr <- function(){
        xp <- xptr_1()
        checkEquals(typeof( xp ), "externalptr", msg = "checking external pointer creation" )
        
        front <- xptr_2(xp)
        checkEquals( front, 1L, msg = "check usage of external pointer" )

        checkTrue(xptr_release(xp), msg = "check release of external pointer")

        checkTrue(xptr_access_released(xp), msg = "check access of released external pointer")

        checkException(xptr_use_released(xp),
                       msg = "check exception on use of released external pointer",
                       silent = TRUE)
    }

}
