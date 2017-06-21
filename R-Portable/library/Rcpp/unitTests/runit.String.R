#!/usr/bin/env r
# -*- mode: R; tab-width: 4; -*-
#
# Copyright (C) 2012 - 2014  Dirk Eddelbuettel and Romain Francois
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

    .setUp <- Rcpp:::unitTestSetup("String.cpp")

    test.replace_all <- function(){
        checkEquals( String_replace_all("abcdbacdab", "ab", "AB"), "ABcdbacdAB")
    }
    test.replace_first <- function(){
        checkEquals( String_replace_first("abcdbacdab", "ab", "AB"), "ABcdbacdab")
    }
    test.replace_last <- function(){
        checkEquals( String_replace_last("abcdbacdab", "ab", "AB"), "abcdbacdAB")
    }

    test.String.sapply <- function(){
        res <- test_sapply_string( "foobar", c("o", "a" ), c("*", "!" ) )
        checkEquals( res, "f**b!r" )    
    }

    test.compare.Strings <- function(){
        res <- test_compare_Strings( "aaa", "aab" )
        target <- list( 
            "a  < b" = TRUE, 
            "a  > b" = FALSE,  
            "a == b" = FALSE,
            "a == a" = TRUE
            )
        checkEquals( res, target )
    }
    
    test.compare.String.string_proxy <- function(){
        v <- c("aab")
        res <- test_compare_String_string_proxy( "aaa", v )
        target <- list( 
            "a == b" = FALSE, 
            "a != b" = TRUE,  
            "b == a" = FALSE,
            "b != a" = TRUE
            )
        checkEquals( res, target )
    }
    
    test.compare.String.const_string_proxy <- function(){
        v <- c("aab")
        res <- test_compare_String_const_string_proxy( "aaa", v )
        target <- list( 
            "a == b" = FALSE, 
            "a != b" = TRUE,  
            "b == a" = FALSE,
            "b != a" = TRUE
            )
        checkEquals( res, target )
    }

    test.String.ctor <- function() {
        res <- test_ctor("abc")
        checkIdentical(res, "abc")
    }

    test.push.front <- function() {
        res <- test_push_front("def")
        checkIdentical(res, "abcdef")
    }

    test.String.encoding <- function() {
        a <- b <- "å"
        Encoding(a) <- "unknown"
        Encoding(b) <- "UTF-8"
        checkEquals(test_String_encoding(a), 0)
        checkEquals(test_String_encoding(b), 1)
        checkEquals(Encoding(test_String_set_encoding(a)), "UTF-8")
        checkEquals(Encoding(test_String_ctor_encoding(a)), "UTF-8")
        checkEquals(Encoding(test_String_ctor_encoding2()), "UTF-8")
    }

}
