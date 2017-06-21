#!/usr/bin/env r
#       hey emacs, please make this use  -*- tab-width: 4 -*-
#
# Copyright (C) 2014 Christian Authmann
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

if( .runThisTest ) {

    .tearDown <- function(){
        gc()
    }

    .setUp <- Rcpp:::unitTestSetup("InternalFunction.cpp")
    
    test.internal_function_add <- function(){
    	fun <- getAdd()
        checkEquals( fun(10,32), 42 )
    }

    test.internal_function_concatenate <- function(){
    	fun <- getConcatenate()
        checkEquals( fun("Hello"," World"), "Hello World" )
    }

}
