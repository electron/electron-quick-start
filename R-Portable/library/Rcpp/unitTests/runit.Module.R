#!/usr/bin/env r
#       hey emacs, please make this use  -*- tab-width: 4 -*-
#
# Copyright (C) 2010 - 2015  Dirk Eddelbuettel and Romain Francois
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

if( .runThisTest && Rcpp:::capabilities()[["Rcpp modules"]] ) {

    .tearDown <- function(){
        gc()
    }

    .setUp <- Rcpp:::unitTestSetup("Module.cpp")
    
    test.Module <- function(){
        checkEquals( bar( 2L ), 4L )
        checkEquals( foo( 2L, 10.0 ), 20.0 )
        checkEquals( hello(), "hello" )
        
        w <- new( ModuleWorld )
        checkEquals( w$greet(), "hello" )
        w$set( "hello world" )
        checkEquals( w$greet(), "hello world" )
        w$set_ref( "hello world ref" )
        checkEquals( w$greet(), "hello world ref" )
        w$set_const_ref( "hello world const ref" )
        checkEquals( w$greet(), "hello world const ref" )
        w$clear( )
        checkEquals( w$greet(), "" )
    }

    test.Module.exposed.class <- function(){
        test <- new( ModuleTest, 3.0 )
        checkEquals( Test_get_x_const_ref(test), 3.0 )
        checkEquals( Test_get_x_const_pointer(test), 3.0 )
        checkEquals( Test_get_x_ref(test), 3.0 )
        checkEquals( Test_get_x_pointer(test), 3.0 )
        
        checkEquals( attr_Test_get_x_const_ref(test), 3.0 )
        checkEquals( attr_Test_get_x_const_pointer(test), 3.0 )
        checkEquals( attr_Test_get_x_ref(test), 3.0 )
        checkEquals( attr_Test_get_x_pointer(test), 3.0 )
    }

    test.Module.property <- function(){
        w <- new( ModuleNum )
        checkEquals( w$x, 0.0 )
        checkEquals( w$y, 0L )

        w$x <- 2.0
        checkEquals( w$x, 2.0 )

        checkException( { w$y <- 3 } )
    }

    test.Module.member <- function(){
        w <- new( ModuleNumber )
        checkEquals( w$x, 0.0 )
        checkEquals( w$y, 0L )

        w$x <- 2.0
        checkEquals( w$x, 2.0 )

        checkException( { w$y <- 3 } )
    }

    test.Module.Constructor <- function() {
        r <- new( ModuleRandomizer, 10.0, 20.0 )
        set.seed(123)
        x10 <- runif(10, 10.0, 20.0)
        set.seed(123)
        checkEquals(r$get(10), x10)
    }

    test.Module.flexible.semantics <- function( ){
        checkEquals( test_reference( seq(0,10) ), 11L )
        checkEquals( test_const_reference( seq(0,10) ), 11L )
        checkEquals( test_const( seq(0,10) ), 11L )
    }

}
