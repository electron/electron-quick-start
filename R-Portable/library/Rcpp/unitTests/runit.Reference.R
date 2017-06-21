#!/usr/bin/env r
#
# Copyright (C) 2013 - 2014  Dirk Eddelbuettel and Romain Francois
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

    .setUp <- Rcpp:::unitTestSetup("Reference.cpp")

    test.Reference <- function(){
        Instrument <- setRefClass(
            Class="Instrument",
            fields=list("id"="character", "description"="character")
            )
        Instrument$accessors(c("id", "description"))
        
        instrument <- Instrument$new(id="AAPL", description="Apple")
        
        checkEquals( runit_Reference_getId(instrument), "AAPL", msg = ".field" )
    }

}
