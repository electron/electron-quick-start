#!/usr/bin/env r
#       hey emacs, please make this use  -*- tab-width: 4 -*-
#
# Copyright (C) 2009 - 2014  Dirk Eddelbuettel and Romain Francois
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

    .setUp <- Rcpp:::unitTestSetup("Environment.cpp")

    test.environment.ls <- function(){
        e <- new.env( )
        e$a <- 1:10
        e$b <- "foo"
        e$.c <- "hidden"
        checkEquals( sort(runit_ls(e)), sort(c("a","b", ".c")), msg = "Environment::ls(true)" )
        checkEquals( runit_ls(asNamespace("Rcpp")), ls(envir=asNamespace("Rcpp"), all = TRUE),
                    msg = "Environment(namespace)::ls()" )

        checkEquals( runit_ls2(e), c("a","b"), msg = "Environment::ls(false)" )
        checkEquals( runit_ls2(asNamespace("Rcpp")), ls(envir=asNamespace("Rcpp"), all = FALSE),
                    msg = "Environment(namespace)::ls()" )

    }

    test.environment.get <- function(){
        e <- new.env( )
        e$a <- 1:10
        e$b <- "foo"
        
        # Access with string
        checkEquals( runit_get( e, "a" ), e$a, msg = "Environment::get(string)" )
        checkEquals( runit_get( e, "foobar" ), NULL, msg = "Environment::get(string)" )
        checkEquals( runit_get( asNamespace("Rcpp"), "CxxFlags"), Rcpp:::CxxFlags,
                     msg = "Environment(namespace)::get(string) " )
        
        # Access with Symbol constructed on call from string
        checkEquals( runit_get_symbol( e, "a" ), e$a, msg = "Environment::get(Symbol)" )
        checkEquals( runit_get_symbol( e, "foobar" ), NULL, msg = "Environment::get(Symbol)" )
        checkEquals( runit_get_symbol( asNamespace("Rcpp"), "CxxFlags"), Rcpp:::CxxFlags,
                     msg = "Environment(namespace)::get(Symbol) " )
        
    }    

    test.environment.find <- function(){
        e <- new.env( )
        e$a <- 1:10
        e$b <- "foo"
        bar <- "me"
        
        # Access with string
        checkEquals( runit_find( e, "a" ), e$a, msg = "Environment::find(string)" )
        checkException( runit_find( e, "foobar" ), NULL, msg = "Environment::find(string) not found" )
        checkEquals( runit_find( e, "bar"), bar, msg = "Environment::find(string) inheritance" )
        checkEquals( runit_find( asNamespace("Rcpp"), "CxxFlags"), Rcpp:::CxxFlags,
                     msg = "Environment(namespace)::find(string)" )
        
        # Access with Symbol constructed on call from string
        checkEquals( runit_find_symbol( e, "a" ), e$a, msg = "Environment::find(Symbol)" )
        checkException( runit_find_symbol( e, "foobar" ), NULL, msg = "Environment::find(Symbol) not found" )
        checkEquals( runit_find_symbol( e, "bar"), bar, msg = "Environment::find(Symbol) inheritance" )
        checkEquals( runit_find_symbol( asNamespace("Rcpp"), "CxxFlags"), Rcpp:::CxxFlags,
                     msg = "Environment(namespace)::find(Symbol)" )
        
    }    
    
        
    test.environment.exists <- function(){
        e <- new.env( )
        e$a <- 1:10
        e$b <- "foo"

        checkTrue( runit_exists( e, "a" ), msg = "Environment::get()" )
        checkTrue( !runit_exists( e, "foobar" ), msg = "Environment::get()" )
        checkTrue( runit_exists( asNamespace("Rcpp"), "CxxFlags"),
                  msg = "Environment(namespace)::get() " )
    }

    test.environment.assign <- function(){
        e <- new.env( )
        checkTrue( runit_assign(e, "a", 1:10 ), msg = "Environment::assign" )
        checkTrue( runit_assign(e, "b", Rcpp:::CxxFlags ), msg = "Environment::assign" )
        checkEquals( ls(e), c("a", "b"), msg = "Environment::assign, checking names" )
        checkEquals( e$a, 1:10, msg = "Environment::assign, checking value 1" )
        checkEquals( e$b, Rcpp:::CxxFlags, msg = "Environment::assign, checking value 2" )

        lockBinding( "a", e )
        can.demangle <- Rcpp:::capabilities()[["demangling"]]
        if( can.demangle ){
            checkTrue(
                tryCatch( { runit_assign(e, "a", letters ) ; FALSE}, "Rcpp::binding_is_locked" = function(e) TRUE ),
                msg = "cannot assign to locked binding (catch exception)" )
        } else {
            checkTrue(
                tryCatch( { runit_assign(e, "a", letters ) ; FALSE}, "error" = function(e) TRUE ),
                msg = "cannot assign to locked binding (catch exception)" )
        }
    }

    test.environment.isLocked <- function(){
        e <- new.env()
        runit_islocked(e)
        checkEquals( e[["x1"]], 1L  , msg = "Environment::assign( int ) " )
        checkEquals( e[["x2"]], 10.0, msg = "Environment::assign( double ) " )
        checkEquals( e[["x3"]], "foobar", msg = "Environment::assign( char* ) " )
        checkEquals( e[["x4"]], "foobar", msg = "Environment::assign( std::string ) " )
        checkEquals( e[["x5"]], c("foo", "bar" ), msg = "Environment::assign( vector<string> ) " )
    }

    test.environment.bindingIsActive <- function(){
        e <- new.env()
        e$a <- 1:10
        makeActiveBinding( "b", function(x) 10, e )

        checkTrue( !runit_bindingIsActive(e, "a" ), msg = "Environment::bindingIsActive( non active ) -> false" )
        checkTrue( runit_bindingIsActive(e, "b" ), msg = "Environment::bindingIsActive( active ) -> true" )

        can.demangle <- Rcpp:::capabilities()[["demangling"]]
        if( can.demangle ){
            checkTrue(
                tryCatch( { runit_bindingIsActive(e, "xx" ) ; FALSE}, "Rcpp::no_such_binding" = function(e) TRUE ),
                msg = "Environment::bindingIsActive(no binding) -> exception)" )
        } else {
            checkTrue(
                tryCatch( { runit_bindingIsActive(e, "xx" ) ; FALSE}, error = function(e) TRUE ),
                msg = "Environment::bindingIsActive(no binding) -> exception)" )
        }
    }

    test.environment.bindingIsLocked <- function(){
        e <- new.env()
        e$a <- 1:10
        e$b <- letters
        lockBinding( "b", e )

        checkTrue( !runit_bindingIsLocked(e, "a" ), msg = "Environment::bindingIsActive( non active ) -> false" )
        checkTrue( runit_bindingIsLocked(e, "b" ), msg = "Environment::bindingIsActive( active ) -> true" )

        can.demangle <- Rcpp:::capabilities()[["demangling"]]
        if( can.demangle ){
            checkTrue(
                tryCatch( { runit_bindingIsLocked(e, "xx" ) ; FALSE}, "Rcpp::no_such_binding" = function(e) TRUE ),
                msg = "Environment::bindingIsLocked(no binding) -> exception)" )
        } else {
            checkTrue(
                tryCatch( { runit_bindingIsLocked(e, "xx" ) ; FALSE}, error = function(e) TRUE ),
                msg = "Environment::bindingIsLocked(no binding) -> exception)" )
        }
    }

    test.environment.NotAnEnvironment <- function(){
        checkException( runit_notanenv( runit_notanenv ), msg = "not an environment" )
        checkException( runit_notanenv( letters ), msg = "not an environment" )
        checkException( runit_notanenv( NULL ), msg = "not an environment" )
    }


    test.environment.lockBinding <- function(){
        e <- new.env()
        e$a <- 1:10
        e$b <- letters
        runit_lockbinding(e, "b")
        checkTrue( bindingIsLocked("b", e ), msg = "Environment::lockBinding()" )

        can.demangle <- Rcpp:::capabilities()[["demangling"]]
        if( can.demangle ){
            checkTrue(
                tryCatch( { runit_lockbinding(e, "xx" ) ; FALSE}, "Rcpp::no_such_binding" = function(e) TRUE ),
                msg = "Environment::lockBinding(no binding) -> exception)" )
        } else {
            checkTrue(
                tryCatch( { runit_lockbinding(e, "xx" ) ; FALSE}, error = function(e) TRUE ),
                msg = "Environment::lockBinding(no binding) -> exception)" )
        }
    }

    test.environment.unlockBinding <- function(){
        e <- new.env()
        e$a <- 1:10
        e$b <- letters
        lockBinding( "b", e )
        runit_unlockbinding(e, "b")
        checkTrue( !bindingIsLocked("b", e ), msg = "Environment::lockBinding()" )

        can.demangle <- Rcpp:::capabilities()[["demangling"]]
        if( can.demangle ){
            checkTrue(
                tryCatch( { runit_unlockbinding(e, "xx" ) ; FALSE}, "Rcpp::no_such_binding" = function(e) TRUE ),
                msg = "Environment::unlockBinding(no binding) -> exception)" )
        } else {
            checkTrue(
                tryCatch( { runit_unlockbinding(e, "xx" ) ; FALSE}, error = function(e) TRUE ),
                msg = "Environment::unlockBinding(no binding) -> exception)" )
        }
    }

    test.environment.global.env <- function(){
        checkIdentical( runit_globenv(), globalenv(), msg = "Environment::global_env" )
    }

    test.environment.empty.env <- function(){
        checkIdentical( runit_emptyenv(), emptyenv(), msg = "Environment::empty_env" )
    }

    test.environment.base.env <- function(){
        checkIdentical( runit_baseenv(), baseenv(), msg = "Environment::base_env" )
    }

    test.environment.namespace.env <- function(){
        checkIdentical( runit_namespace("Rcpp"), asNamespace("Rcpp"), msg = "Environment::base_namespace" )

        can.demangle <- Rcpp:::capabilities()[["demangling"]]
        if( can.demangle ){
            checkTrue(
                tryCatch( { runit_namespace("----" ) ; FALSE}, "Rcpp::no_such_namespace" = function(e) TRUE ),
                msg = "Environment::namespace_env(no namespace) -> exception)" )
        } else {
            checkTrue(
                tryCatch( { runit_namespace("----" ) ; FALSE}, error = function(e) TRUE ),
                msg = "Environment::namespace_env(no namespace) -> exception)" )
        }
    }

    test.environment.constructor.SEXP <- function(){
        checkIdentical( runit_env_SEXP( globalenv() ), globalenv(), msg = "Environment( environment ) - 1" )
        checkIdentical( runit_env_SEXP( baseenv() ), baseenv(), msg = "Environment( environment ) - 2" )
        checkIdentical( runit_env_SEXP( asNamespace("Rcpp") ), asNamespace("Rcpp"), msg = "Environment( environment ) - 3" )

        checkIdentical( runit_env_SEXP( ".GlobalEnv" ), globalenv(), msg = "Environment( character ) - 1" )
        checkIdentical( runit_env_SEXP( "package:base" ), baseenv(), msg = "Environment( character ) - 2" )
        checkIdentical( runit_env_SEXP( "package:Rcpp" ), as.environment("package:Rcpp") , msg = 'Environment( "package:Rcpp") ' )

        checkIdentical( runit_env_SEXP(1L), globalenv(), msg = "Environment( SEXP{integer} )" )
    }

    test.environment.constructor.stdstring <- function(){
        checkIdentical( runit_env_string( ".GlobalEnv" ), globalenv(), msg = "Environment( std::string ) - 1" )
        checkIdentical( runit_env_string( "package:base" ), baseenv(), msg = "Environment( std::string ) - 2" )
        checkIdentical( runit_env_string( "package:Rcpp" ), as.environment("package:Rcpp") ,
                    msg = 'Environment( std::string ) - 3' )

    }

    test.environment.constructor.int <- function(){
        for( i in 1:length(search())){
            checkIdentical( runit_env_int(i), as.environment(i), msg = sprintf("Environment(int) - %d", i) )
        }
    }

    test.environment.remove <- function(){
        e <- new.env( )
        e$a <- 1
        e$b <- 2
        checkTrue( runit_remove( e, "a" ), msg = "Environment::remove" )
        checkEquals( ls(envir=e), "b", msg = "check that the element was removed" )
        checkException( runit_remove(e, "xx"), msg = "Environment::remove no such binding" )
        lockBinding( "b", e )
        checkException( runit_remove(e, "b"), msg = "Environment::remove binding is locked" )
        checkEquals( ls(envir=e), "b", msg = "check that the element was not removed" )

    }

    test.environment.parent <- function(){
        e <- new.env( parent = emptyenv() )
        f <- new.env( parent = e )
        checkEquals( runit_parent(f), e, msg = "Environment::parent" )
        checkEquals( runit_parent(e), emptyenv() , msg = "Environment::parent" )
    }

    test.environment.square <- function(){
        env <- new.env( )
        env[["x"]] <- 10L
        checkEquals( runit_square(env), list( 10L, 2L, "foo") )

    }

    test.environment.Rcpp <- function(){
        checkEquals( runit_Rcpp(), asNamespace("Rcpp") , msg = "cached Rcpp namespace" )
    }

    #test.environment.child <- function(){
    #    checkEquals( parent.env(runit_child()), globalenv(), msg = "child environment" )
    #}

    test.environment.new_env <- function() {
        env <- new.env()
        checkIdentical(parent.env(runit_new_env_default()), emptyenv(), msg = "new environment with default parent")
        checkIdentical(parent.env(runit_new_env_parent(env)), env, msg = "new environment with specified parent")
    }

}
