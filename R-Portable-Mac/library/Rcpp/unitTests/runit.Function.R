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

    .setUp <- Rcpp:::unitTestSetup("Function.cpp", "stats")

    test.Function <- function(){
        checkEquals( function_( rnorm ), rnorm, msg = "Function( CLOSXP )" )
        checkEquals( function_( is.function ), is.function, msg = "Pairlist( BUILTINSXP )" )

        checkException( function_(1:10), msg = "Function( INTSXP) " )
        checkException( function_(TRUE), msg = "Function( LGLSXP )" )
        checkException( function_(1.3), msg = "Function( REALSXP) " )
        checkException( function_(as.raw(1) ), msg = "Function( RAWSXP)" )
        checkException( function_(new.env()), msg = "Function not compatible with environment" )
    }

    test.Function.variadic <- function(){
        checkEquals( function_variadic( sort, sample(1:20) ), 20:1, msg = "calling function" )
        checkException( function_variadic(sort, sort), msg = "Function, R error -> exception" )
    }

    test.Function.env <- function(){
        checkEquals( function_env(rnorm), asNamespace("stats" ), msg = "Function::environment" )
        checkException( function_env(is.function),
                       msg = "Function::environment( builtin) : exception" )
        checkException( function_env(`~`),
                       msg = "Function::environment( special) : exception" )
    }

    test.Function.unary.call <- function(){
        checkEquals(
            function_unarycall( lapply( 1:10, function(n) seq(from=n, to = 0 ) ) ),
            2:11 ,
            msg = "unary_call(Function)" )
    }

    test.Function.binary.call <- function(){
        data <- lapply( 1:10, function(n) seq(from=n, to = 0 ) )
        res <- function_binarycall( data , rep(5L,10) )
        expected <- lapply( data, pmin, 5 )
        checkEquals( res, expected,
                    msg = "binary_call(Function)" )
    }

    test.Function.namespace.env <- function() {
        exportedfunc <- function_namespace_env()
        checkEquals( stats:::.asSparse, exportedfunc, msg = "namespace_env(Function)" )
    }

    test.Function.cons.env <- function() {
        parent_env <- new.env()
        parent_env$fun_parent <- rbinom
        child_env <- new.env(parent = parent_env)
        child_env$fun_child <- rnorm

        checkEquals(rnorm, function_cons_env("fun_child", child_env), msg = "env-lookup constructor")
        checkEquals(rbinom, function_cons_env("fun_parent", child_env), msg = "env-lookup constructor: search function in parent environments")
        checkException(function_cons_env("fun_child", parent_env), msg = "env-lookup constructor: fail when function not found")
    }

    test.Function.cons.ns <- function() {
        checkEquals(Rcpp::sourceCpp, function_cons_ns("sourceCpp", "Rcpp"), msg = "namespace-lookup constructor")
        checkException(function_cons_ns("sourceCpp", "Rcppp"), msg = "namespace-lookup constructor: fail when ns does not exist")
        checkException(function_cons_ns("sourceCppp", "Rcpp"), msg = "namespace-lookup constructor: fail when function not found")
    }
    
    test.Function.eval <- function() {
        checkException(exec(stop))
        # should not throw exception
        exec(function() try(silent = TRUE, exec(stop)))
    }

    # also check function is found in parent env

}
