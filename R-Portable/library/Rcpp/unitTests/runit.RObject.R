#!/usr/bin/env r
# -*- mode: R; tab-width: 4; -*-
#
# Copyright (C) 2009 - 2014  Romain Francois and Dirk Eddelbuettel
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

    .setUp <- Rcpp:::unitTestSetup("RObject.cpp") 

    test.RObject.asDouble <- function(){
        checkEquals( asDouble(2.123), 4.246, msg = "as<double>( REALSXP ) " )
        checkEquals( asDouble(2L), 4.0, msg = "as<double>( INTSXP ) " )
        checkEquals( asDouble(as.raw(2L)), 4.0, msg = "as<double>( RAWSXP )" )
        checkException( asDouble('2'), msg = "as<double>( STRSXP ) -> exception" )
        checkException( asDouble(2:3), msg = "as<double> expects the vector to be of length 1" )
    }

    test.RObject.asInt <- function(){
        checkEquals( asInt(2.123), 4L, msg = "as<int>( REALSXP )" )
        checkEquals( asInt(2), 4L, msg = "as<int>( REALSXP )" )
        checkEquals( asInt(2L), 4.0, msg = "as<int>( INTSXP )" )
        checkEquals( asInt(as.raw(2L)), 4.0, msg = "as<int>( RAWSXP )" )
        checkException( asInt( '2'), msg = "as<int> can not convert character" )
        checkException( asInt( 2:3), msg = "as<int> expects the vector to be of length 1" )
    }

    test.RObject.asStdString <- function(){
        checkEquals( asStdString("abc"), "abcabc", msg = "as<std::string>" )
        checkException( asStdString(NULL), msg = "as<std::string> expects character vector" )
        checkException( asStdString(0L), msg = "as<std::string> expects character vector" )
        checkException( asStdString(0.1), msg = "as<std::string> expects character vector" )
        checkException( asStdString(as.raw(0L)), msg = "as<std::string> expects character vector" )

        checkException( asStdString(letters), msg = "as<std::string> expects single string" )
    }

    test.RObject.asRaw <- function(){
        checkEquals( asRaw(1L), as.raw(2L), msg = "as<Rbyte>(integer)" )
        checkEquals( asRaw(1.3), as.raw(2L), msg = "as<Rbyte>(numeric)" )
        checkEquals( asRaw(as.raw(1)), as.raw(2L), msg = "as<Rbyte>(raw)" )
        checkException( asRaw(NULL) , msg = "as<Rbyte>(NULL) -> exception" )
        checkException( asRaw("foo") , msg = "as<Rbyte>(character) -> exception" )
        checkException( asRaw(1:2), msg = "as<Rbyte>(>1 integer) -> exception" )
        checkException( asRaw(as.numeric(1:2)), msg = "as<Rbyte>(>1 numeric) -> exception" )
        checkException( asRaw(as.raw(1:3)), msg = "as<Rbyte>(>1 raw) -> exception" )
        checkException( asRaw(integer(0)), msg = "as<Rbyte>(0 integer) -> exception" )
        checkException( asRaw(numeric(0)), msg = "as<Rbyte>(0 numeric) -> exception" )
        checkException( asRaw(raw(0)), msg = "as<Rbyte>(0 raw) -> exception" )
    }

    test.RObject.asLogical <- function(){
        checkTrue( !asLogical(TRUE), msg = "as<bool>(TRUE) -> true" )
        checkTrue( asLogical(FALSE), msg = "as<bool>(FALSE) -> false" )
        checkTrue( !asLogical(1L), msg = "as<bool>(1L) -> true" )
        checkTrue( asLogical(0L), msg = "as<bool>(0L) -> false" )
        checkTrue( !asLogical(1.0), msg = "as<bool>(1.0) -> true" )
        checkTrue( asLogical(0.0), msg = "as<bool>0.0) -> false" )
        checkTrue( !asLogical(as.raw(1)), msg = "as<bool>(aw.raw(1)) -> true" )
        checkTrue( asLogical(as.raw(0)), msg = "as<bool>(as.raw(0)) -> false" )

        checkException( asLogical(NULL), msg = "as<bool>(NULL) -> exception" )
        checkException( asLogical(c(TRUE,FALSE)), msg = "as<bool>(>1 logical) -> exception" )
        checkException( asLogical(1:2), msg = "as<bool>(>1 integer) -> exception" )
        checkException( asLogical(1:2+.1), msg = "as<bool>(>1 numeric) -> exception" )
        checkException( asLogical(as.raw(1:2)), msg = "as<bool>(>1 raw) -> exception" )

        checkException( asLogical(integer(0)), msg = "as<bool>(0 integer) -> exception" )
        checkException( asLogical(numeric(0)), msg = "as<bool>(0 numeric) -> exception" )
        checkException( asLogical(raw(0)), msg = "as<bool>(0 raw) -> exception" )
    }

    test.RObject.asStdVectorInt <- function(){
        checkEquals( asStdVectorInt(x=2:5), 2:5*2L, msg = "as< std::vector<int> >(integer)" )
        checkEquals( asStdVectorInt(x=2:5+.1), 2:5*2L, msg = "as< std::vector<int> >(numeric)" )
        checkEquals( asStdVectorInt(x=as.raw(2:5)), 2:5*2L, msg = "as< std::vector<int> >(raw)" )
        checkException( asStdVectorInt("foo"), msg = "as< std::vector<int> >(character) -> exception" )
        checkException( asStdVectorInt(NULL), msg = "as< std::vector<int> >(NULL) -> exception" )
    }

    test.RObject.asStdVectorDouble <- function(){
        checkEquals( asStdVectorDouble(x=0.1+2:5), 2*(0.1+2:5), msg = "as< std::vector<double> >( numeric )" )
        checkEquals( asStdVectorDouble(x=2:5), 2*(2:5), msg = "as< std::vector<double> >(integer)" )
        checkEquals( asStdVectorDouble(x=as.raw(2:5)), 2*(2:5), msg = "as< std::vector<double> >(raw)" )
        checkException( asStdVectorDouble("foo"), msg = "as< std::vector<double> >(character) -> exception" )
        checkException( asStdVectorDouble(NULL), msg = "as< std::vector<double> >(NULL) -> exception" )
    }

    test.RObject.asStdVectorRaw <- function(){
        checkEquals( asStdVectorRaw(x=as.raw(0:9)), as.raw(2*(0:9)), msg = "as< std::vector<Rbyte> >(raw)" )
        checkEquals( asStdVectorRaw(x=0:9), as.raw(2*(0:9)), msg = "as< std::vector<Rbyte> >( integer )" )
        checkEquals( asStdVectorRaw(x=as.numeric(0:9)), as.raw(2*(0:9)), msg = "as< std::vector<Rbyte> >(numeric)" )
        checkException( asStdVectorRaw("foo"), msg = "as< std::vector<Rbyte> >(character) -> exception" )
        checkException( asStdVectorRaw(NULL), msg = "as< std::vector<Rbyte> >(NULL) -> exception" )
    }

    test.RObject.asStdVectorBool <- function(){
        checkEquals( asStdVectorBool(x=c(TRUE,FALSE)), c(FALSE, TRUE), msg = "as< std::vector<bool> >(logical)" )
        checkEquals( asStdVectorBool(x=c(1L, 0L)), c(FALSE, TRUE), msg = "as< std::vector<bool> >(integer)" )
        checkEquals( asStdVectorBool(x=c(1.0, 0.0)), c(FALSE, TRUE), msg = "as< std::vector<bool> >(numeric)" )
        checkEquals( asStdVectorBool(x=as.raw(c(1,0))), c(FALSE, TRUE), msg = "as< std::vector<bool> >(raw)" )
        checkException( asStdVectorBool("foo"), msg = "as< std::vector<bool> >(character) -> exception" )
        checkException( asStdVectorBool(NULL), msg = "as< std::vector<bool> >(NULL) -> exception" )
    }

    test.RObject.asStdVectorString <- function(){
        checkEquals( asStdVectorString(c("foo", "bar")), c("foofoo", "barbar"), msg = "as< std::vector<std::string> >(character)" )
        checkException( asStdVectorString(1L), msg = "as< std::vector<std::string> >(integer) -> exception" )
        checkException( asStdVectorString(1.0), msg = "as< std::vector<std::string> >(numeric) -> exception" )
        checkException( asStdVectorString(as.raw(1)), msg = "as< std::vector<std::string> >(raw) -> exception" )
        checkException( asStdVectorString(TRUE), msg = "as< std::vector<std::string> >(logical) -> exception" )
        checkException( asStdVectorString(NULL), msg = "as< std::vector<std::string> >(NULL) -> exception" )
    }

    test.RObject.stdsetint <- function(){
        checkEquals( stdsetint(), c(0L, 1L), msg = "wrap( set<int> )" )
    }

    test.RObject.stdsetdouble <- function(){
        checkEquals( stdsetdouble(), as.numeric(0:1), msg = "wrap( set<double>" )
    }

    test.RObject.stdsetraw <- function(){
        checkEquals( stdsetraw(), as.raw(0:1), msg = "wrap(set<raw>)" )
    }

    test.RObject.stdsetstring <- function(){
        checkEquals( stdsetstring(), c("bar", "foo"), msg = "wrap(set<string>)" )
    }

    test.RObject.attributeNames <- function(){
        df <- data.frame( x = 1:10, y = 1:10 )
        checkTrue( all( c("names","row.names","class") %in% attributeNames(df)), msg = "RObject.attributeNames" )
    }

    test.RObject.hasAttribute <- function(){
        df <- data.frame( x = 1:10 )
        checkTrue( hasAttribute( df ), msg = "RObject.hasAttribute" )
    }

    test.RObject.attr <- function(){
        df <- data.frame( x = 1:150 )
        rownames(df) <- 1:150
        checkEquals( attr_( iris ), 1:150, msg = "RObject.attr" )
    }

    test.RObject.attr.set <- function(){
        checkEquals( attr(attr_set(), "foo"), 10L, msg = "RObject.attr() = " )
    }

    test.RObject.isNULL <- function(){
        df <- data.frame( x = 1:10 )
        checkTrue( !isNULL( df ), msg = "RObject.isNULL(data frame) -> false" )
        checkTrue( !isNULL(1L), msg = "RObject.isNULL(integer) -> false" )
        checkTrue( !isNULL(1.0), msg = "RObject.isNULL(numeric) -> false" )
        checkTrue( !isNULL(as.raw(1)), msg = "RObject.isNULL(raw) -> false" )
        checkTrue( !isNULL(letters), msg = "RObject.isNULL(character) -> false")
        checkTrue( !isNULL(test.RObject.isNULL), msg = "RObject.isNULL(function) -> false" )
        checkTrue( !isNULL(.GlobalEnv), msg = "RObject.isNULL(environment) -> false" )
        checkTrue( isNULL(NULL), msg = "RObject.isNULL(NULL) -> true" )
    }

    test.RObject.inherits <- function(){
        x <- 1:10
        checkTrue( !inherits_(x) )
        class(x) <- "foo"
        checkTrue( inherits_(x) )
        class(x) <- c("foo", "bar" )
        checkTrue( inherits_(x) )
    }

}
