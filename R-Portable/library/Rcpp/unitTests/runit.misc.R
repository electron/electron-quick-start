#!/usr/bin/env r
#
# Copyright (C) 2010 - 2017  Dirk Eddelbuettel and Romain Francois
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

    .setUp <- Rcpp:::unitTestSetup("misc.cpp")

    test.Symbol <- function(){
	res <- symbol_()
	checkTrue( res[1L], msg = "Symbol creation - SYMSXP " )
	checkTrue( res[2L], msg = "Symbol creation - CHARSXP " )
	checkTrue( res[3L], msg = "Symbol creation - STRSXP " )
	checkTrue( res[4L], msg = "Symbol creation - std::string " )
    }

    test.Symbol.notcompatible <- function(){
	checkException( symbol_ctor(symbol_ctor), msg = "Symbol not compatible with function" )
	checkException( symbol_ctor(asNamespace("Rcpp")), msg = "Symbol not compatible with environment" )
	checkException( symbol_ctor(1:10), msg = "Symbol not compatible with integer" )
	checkException( symbol_ctor(TRUE), msg = "Symbol not compatible with logical" )
	checkException( symbol_ctor(1.3), msg = "Symbol not compatible with numeric" )
	checkException( symbol_ctor(as.raw(1) ), msg = "Symbol not compatible with raw" )
    }


    test.Argument <- function(){
        checkEquals( Argument_(), list( x = 2L, y = 3L ) , msg = "Argument")
    }

    test.Dimension.const <- function(){
        checkEquals( Dimension_const( c(2L, 2L)) , 2L, msg = "testing const operator[]" )
    }

    test.evaluator.error <- function(){
        checkException( evaluator_error(), msg = "Rcpp_eval( stop() )" )
    }

    test.evaluator.ok <- function(){
	checkEquals( sort(evaluator_ok(1:10)), 1:10, msg = "Rcpp_eval running fine" )
    }

    test.exceptions <- function(){
	can.demangle <- Rcpp:::capabilities()[["demangling"]]

	e <- tryCatch(  exceptions_(), "C++Error" = function(e) e )
	checkTrue( "C++Error" %in% class(e), msg = "exception class C++Error" )

	if( can.demangle ){
            checkTrue( "std::range_error" %in% class(e), msg = "exception class std::range_error" )
	}
	checkEquals( e$message, "boom", msg = "exception message" )

	if( can.demangle ){
                                        # same with direct handler
            e <- tryCatch(  exceptions_(), "std::range_error" = function(e) e )
            checkTrue( "C++Error" %in% class(e), msg = "(direct handler) exception class C++Error" )
            checkTrue( "std::range_error" %in% class(e), msg = "(direct handler) exception class std::range_error" )
            checkEquals( e$message, "boom", msg = "(direct handler) exception message" )
	}
	f <- function(){
            try( exceptions_(), silent = TRUE)
            "hello world"
	}
	checkEquals( f(), "hello world", msg = "life continues after an exception" )

    }

    test.has.iterator <- function(){

        has_it <- has_iterator_()
	checkTrue( has_it[1L] , msg = "has_iterator< std::vector<int> >" )
	checkTrue( has_it[2L] , msg = "has_iterator< std::ist<int> >" )
	checkTrue( has_it[3L] , msg = "has_iterator< std::deque<int> >" )
	checkTrue( has_it[4L] , msg = "has_iterator< std::set<int> >" )
	checkTrue( has_it[5L] , msg = "has_iterator< std::map<string,int> >" )

	checkTrue( ! has_it[6L] , msg = "has_iterator< std::pair<string,int> >" )
	checkTrue( ! has_it[7L] , msg = "Rcpp::Symbol" )

    }

    test.AreMacrosDefined <- function(){
        checkTrue( Rcpp:::areMacrosDefined( "__cplusplus" ) )
    }

    test.rcout <- function(){
        ## define test string that is written to two files
        teststr <- "First line.\nSecond line."

        rcppfile <- tempfile()
        rfile <- tempfile()

        ## write to test_rcpp.txt from Rcpp
        test_rcout(rcppfile,  teststr )

        ## write to test_r.txt from R
        cat( teststr, file=rfile, sep='\n' )

        ## compare whether the two files have the same data
        checkEquals( readLines(rcppfile), readLines(rfile), msg="Rcout output")
    }

    test.rcout.complex <- function(){

        rcppfile <- tempfile()
        rfile <- tempfile()

        z <- complex(real=sample(1:10, 1), imaginary=sample(1:10, 1))

        ## write to test_rcpp.txt from Rcpp
        test_rcout_rcomplex(rcppfile,  z )

        ## write to test_r.txt from R
        cat( z, file=rfile, sep='\n' )

        ## compare whether the two files have the same data
        checkEquals( readLines(rcppfile), readLines(rfile), msg="Rcout Rcomplex")
    }

    test.na_proxy <- function(){
        checkEquals(
            na_proxy(),
            rep(c(TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE) , 2),
            msg = "Na_Proxy NA == handling"
            )
    }

    test.StretchyList <- function(){
        checkEquals(
            stretchy_list(),
            pairlist( "foo", 1L, 3.2 )
            )
    }

    test.named_StretchyList <- function(){
        checkEquals(
            named_stretchy_list(),
            pairlist( a = "foo", b = 1L, c = 3.2 )
            )
    }

    test.stop.variadic <- function(){
        m <- tryCatch( test_stop_variadic(), error = function(e){
            conditionMessage(e)
        })
        checkEquals( m, "foo 3" )
    }

    test.NullableForNull <- function() {
        M <- matrix(1:4, 2, 2)
        checkTrue(   testNullableForNull(NULL) )
        checkTrue( ! testNullableForNull(M) )
    }

    test.NullableForNotNull <- function() {
        M <- matrix(1:4, 2, 2)
        checkTrue( ! testNullableForNotNull(NULL) )
        checkTrue(   testNullableForNotNull(M) )
    }

    test.NullableAccessOperator <- function() {
        M <- matrix(1:4, 2, 2)
        checkEquals( testNullableOperator(M), M )
    }

    test.NullableAccessGet <- function() {
        M <- matrix(1:4, 2, 2)
        checkEquals( testNullableGet(M), M )
    }

    test.NullableAccessAs <- function() {
        M <- matrix(1:4, 2, 2)
        checkEquals( testNullableAs(M), M )
    }

    test.NullableAccessClone <- function() {
        M <- matrix(1:4, 2, 2)
        checkEquals( testNullableClone(M), M )
    }

    test.NullableIsUsableTrue <- function() {
	M <- matrix(1:4, 2, 2)
        checkEquals( testNullableIsUsable(M), M)
    }

    test.NullableIsUsableFalse <- function() {
        checkTrue(is.null(testNullableIsUsable(NULL)))
    }

    test.NullableString <- function() {
        checkEquals(testNullableString(), "")
        checkEquals(testNullableString("blah"), "blah")
    }

    test.bib <- function() {
        checkTrue(nchar(Rcpp:::bib()) > 0, msg="bib file")
    }

}
