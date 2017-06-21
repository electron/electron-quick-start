#!/usr/bin/env r
#       hey emacs, please make this use  -*- tab-width: 4 -*-
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

    .setUp <- Rcpp:::unitTestSetup("language.cpp") 

    test.Language <- function(){
        checkEquals( runit_language( call("rnorm") ), call("rnorm" ), msg = "Language( LANGSXP )" )
        checkException( runit_language(test.Language), msg = "Language not compatible with function" )
        checkException( runit_language(new.env()), msg = "Language not compatible with environment" )
        checkException( runit_language(1:10), msg = "Language not compatible with integer" )
        checkException( runit_language(TRUE), msg = "Language not compatible with logical" )
        checkException( runit_language(1.3), msg = "Language not compatible with numeric" )
        checkException( runit_language(as.raw(1) ), msg = "Language not compatible with raw" )
    }

    test.Language.variadic <- function(){
        checkEquals( runit_lang_variadic_1(), call("rnorm", 10L, 0.0, 2.0 ), 
                    msg = "variadic templates" )

        checkEquals( runit_lang_variadic_2(), call("rnorm", 10L, mean = 0.0, 2.0 ),
                    msg = "variadic templates (with names)" )
    }

                                        # same as above but without variadic templates
    test.Language.push.back <- function(){
        checkEquals( runit_lang_push_back(),
                    call("rnorm", 10L, mean = 0.0, 2.0 ),
                    msg = "Language::push_back" )
    }

    test.Language.square <- function(){
        checkEquals( runit_lang_square_rv(), 10.0, msg = "Language::operator[] used as rvalue" )
        checkEquals( runit_lang_square_lv(), call("rnorm", "foobar", 20.0, 20.0) , msg = "Pairlist::operator[] used as lvalue" )
    }

    test.Language.function <- function(){
        checkEquals( runit_lang_fun(sort, sample(1:10)), 1:10, msg = "Language( Function ) " )
    }

    test.Language.inputoperator <- function(){
        checkEquals( runit_lang_inputop(), call("rnorm", 10L, sd = 10L ) , msg = "Language<<" )
    }

    test.Language.unary.call <- function(){
        checkEquals(
            runit_lang_unarycall( 1:10 ),
            lapply( 1:10, function(n) seq(from=n, to = 0 ) ),
            msg = "c++ lapply using calls" )

    }

    test.Language.unary.call.index <- function(){
        checkEquals(
            runit_lang_unarycallindex( 1:10 ),
            lapply( 1:10, function(n) seq(from=10, to = n ) ),
            msg = "c++ lapply using calls" )
    }

    test.Language.binary.call <- function(){
        checkEquals(
            runit_lang_binarycall( 1:10, 11:20 ),
            lapply( 1:10, function(n) seq(n, n+10) ),
            msg = "c++ lapply using calls" )
    }

    test.Language.fixed.call <- function(){
        set.seed(123)
        res <- runit_lang_fixedcall()
        set.seed(123)
        exp <- lapply( 1:10, function(n) rnorm(10) )
        checkEquals( res, exp, msg = "std::generate" )
    }

    test.Language.in.env <- function(){
        e <- new.env()
        e[["y"]] <- 1:10
        checkEquals( runit_lang_inenv(e), sum(1:10), msg = "Language::eval( SEXP )" )
    }

    test.Pairlist <- function(){
        checkEquals( runit_pairlist( pairlist("rnorm") ), pairlist("rnorm" ), msg = "Pairlist( LISTSXP )" )
        checkEquals( runit_pairlist( call("rnorm") ), pairlist(as.name("rnorm")), msg = "Pairlist( LANGSXP )" )
        checkEquals( runit_pairlist(1:10), as.pairlist(1:10) , msg = "Pairlist( INTSXP) " )
        checkEquals( runit_pairlist(TRUE), as.pairlist( TRUE) , msg = "Pairlist( LGLSXP )" )
        checkEquals( runit_pairlist(1.3), as.pairlist(1.3), msg = "Pairlist( REALSXP) " )
        checkEquals( runit_pairlist(as.raw(1) ), as.pairlist(as.raw(1)), msg = "Pairlist( RAWSXP)" )

        checkException( runit_pairlist(runit_pairlist), msg = "Pairlist not compatible with function" )
        checkException( runit_pairlist(new.env()), msg = "Pairlist not compatible with environment" )

    }

    test.Pairlist.variadic <- function(){
        checkEquals( runit_pl_variadic_1(), pairlist("rnorm", 10L, 0.0, 2.0 ),
                    msg = "variadic templates" )
        checkEquals( runit_pl_variadic_2(), pairlist("rnorm", 10L, mean = 0.0, 2.0 ),
                    msg = "variadic templates (with names)" )
    }

    test.Pairlist.push.front <- function(){
        checkEquals( runit_pl_push_front(),
                    pairlist( foobar = 10, "foo", 10.0, 1L),
                    msg = "Pairlist::push_front" )
    }

    test.Pairlist.push.back <- function(){
        checkEquals( runit_pl_push_back(),
                    pairlist( 1L, 10.0, "foo", foobar = 10),
                    msg = "Pairlist::push_back" )
    }

    test.Pairlist.insert <- function(){
        checkEquals( runit_pl_insert(),
                    pairlist( 30.0, 1L, bla = "bla", 10.0, 20.0, "foobar" ),
                    msg = "Pairlist::replace" )
    }

    test.Pairlist.replace <- function(){
        checkEquals( runit_pl_replace(),
                    pairlist( first = 1, 20.0 , FALSE), msg = "Pairlist::replace" )
    }

    test.Pairlist.size <- function(){
        checkEquals( runit_pl_size(), 3L, msg = "Pairlist::size()" )
    }

    test.Pairlist.remove <- function(){
        checkEquals( runit_pl_remove_1(), pairlist(10.0, 20.0), msg = "Pairlist::remove(0)" )
        checkEquals( runit_pl_remove_2(), pairlist(1L, 10.0), msg = "Pairlist::remove(0)" )
        checkEquals( runit_pl_remove_3(), pairlist(1L, 20.0), msg = "Pairlist::remove(0)" )
    }

    test.Pairlist.square <- function(){
        checkEquals( runit_pl_square_1(), 10.0, msg = "Pairlist::operator[] used as rvalue" )
        checkEquals( runit_pl_square_2(), pairlist(1L, "foobar", 1L) , msg = "Pairlist::operator[] used as lvalue" )
    }


    test.Formula <- function(){
        checkEquals( runit_formula_(), x ~ y + z, msg = "Formula( string )" )
    }

    test.Formula.SEXP <- function(){
        checkEquals( runit_formula_SEXP( x ~ y + z), x ~ y + z, msg = "Formula( SEXP = formula )" )
        checkEquals( runit_formula_SEXP( "x ~ y + z" ), x ~ y + z, msg = "Formula( SEXP = STRSXP )" )
        checkEquals( runit_formula_SEXP( parse( text = "x ~ y + z") ), x ~ y + z, msg = "Formula( SEXP = EXPRSXP )" )
        checkEquals( runit_formula_SEXP( list( "x ~ y + z") ), x ~ y + z, msg = "Formula( SEXP = VECSXP(1 = STRSXP) )" )
        checkEquals( runit_formula_SEXP( list( x ~ y + z) ), x ~ y + z, msg = "Formula( SEXP = VECSXP(1 = formula) )" )
    }

}
