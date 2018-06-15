#!/usr/bin/env r
# -*- mode: R; tab-width: 4; -*-
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

    .setUp <- Rcpp:::unitTestSetup("DataFrame.cpp")

    test.DataFrame.FromSEXP <- function() {
        DF <- data.frame(a=1:3, b=c("a","b","c"))
        checkEquals( FromSEXP(DF), DF, msg = "DataFrame pass-through")
    }

    test.DataFrame.index.byName <- function() {
        DF <- data.frame(a=1:3, b=c("a","b","c"))
        checkEquals( index_byName(DF, "a"), DF$a, msg = "DataFrame column by name 'a'")
        checkEquals( index_byName(DF, "b"), DF$b, msg = "DataFrame column by name 'b'")
    }

    test.DataFrame.index.byPosition <- function() {
        DF <- data.frame(a=1:3, b=c("a","b","c"))
        checkEquals( index_byPosition(DF, 0), DF$a, msg = "DataFrame column by position 0")
        checkEquals( index_byPosition(DF, 1), DF$b, msg = "DataFrame column by position 1")
    }

    test.DataFrame.string.element <- function() {
        DF <- data.frame(a=1:3, b=c("a","b","c"), stringsAsFactors=FALSE)
        checkEquals( string_element(DF), DF[2,"b"], msg = "DataFrame string element")
    }

    test.DataFrame.CreateOne <- function() {
        DF <- data.frame(a=1:3)
        checkEquals( createOne(), DF, msg = "DataFrame create1")
    }

    test.DataFrame.CreateTwo <- function() {
        DF <- data.frame(a=1:3, b=c("a","b","c"))
        checkEquals( createTwo(), DF, msg = "DataFrame create2")
    }

    test.DataFrame.SlotProxy <- function(){
        setClass("track", representation(x="data.frame", y = "function"))
        df <- data.frame( x = 1:10, y = 1:10 )
        tr1 <- new( "track", x = df, y = rnorm )
        checkTrue( identical( SlotProxy(tr1, "x"), df ), msg = "DataFrame( SlotProxy )" )
        checkException( SlotProxy(tr1, "y"), msg = "DataFrame( SlotProxy ) -> exception" )
    }

    test.DataFrame.AttributeProxy <- function(){
        df <- data.frame( x = 1:10, y = 1:10 )
        tr1 <- structure( NULL, x = df, y = rnorm )
        checkTrue( identical( AttributeProxy(tr1, "x"), df) , msg = "DataFrame( AttributeProxy )" )
        checkException( AttributeProxy(tr1, "y"), msg = "DataFrame( AttributeProxy ) -> exception" )
    }

    test.DataFrame.CreateTwo.stringsAsFactors <- function() {
        DF <- data.frame(a=1:3, b=c("a","b","c"), stringsAsFactors = FALSE )
        checkEquals( createTwoStringsAsFactors(), DF, msg = "DataFrame create2 stringsAsFactors = false")
    }

    test.DataFrame.nrow <- function(){
        df <- data.frame( x = 1:10, y = 1:10 )
        checkEquals( DataFrame_nrow( df ), rep(nrow(df), 2) )
    }

    test.DataFrame.ncol <- function(){
        df <- data.frame( x = 1:10, y = 1:10 )
        checkEquals( DataFrame_ncol( df ), rep(ncol(df), 2) )
    }


}
