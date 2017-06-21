# Copyright (C) 2014  Dirk Eddelbuettel, Romain Francois and Kevin Ushey
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
    
    .setUp <- Rcpp:::unitTestSetup("VectorOld.cpp")
    
    test.IntegerVector.comma <- function(){
        fun <- integer_comma
        checkEquals( fun(), 0:3, msg = "IntegerVector comma initialization" )
    }
    
    test.CharacterVector.comma <- function(){
        fun <- character_comma
        checkEquals( fun(), c("foo","bar", "bling" ), msg = "CharacterVector comma operator" )
    }
    
}
