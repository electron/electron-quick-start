#!/usr/bin/env r
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

    .setUp <- Rcpp:::unitTestSetup("S4.cpp")

    test.RObject.S4methods <- function(){
	setClass("track", representation(x="numeric", y="numeric"))
	tr <- new( "track", x = 2, y = 2 )
	checkEquals(
	    S4_methods(tr),
            list( TRUE, TRUE, FALSE, 2.0, 2.0 ),
            msg = "slot management" )

	S4_getslots( tr )
	checkEquals( tr@x, 10.0 , msg = "slot('x') = 10" )
	checkEquals( tr@y, 20.0 , msg = "slot('y') = 20" )

	checkException( S4_setslots( tr ), msg = "slot does not exist" )
	checkException( S4_setslots_2( tr ), msg = "slot does not exist" )

    }

    test.S4 <- function(){
	setClass("track",
                 representation(x="numeric", y="numeric"))
	tr <- new( "track", x = 2, y = 3 )
	checkEquals( S4_get_slot_x( tr ), 2, msg = "S4( SEXP )" )
	checkException( S4_get_slot_x( list( x = 2, y = 3 ) ), msg = "not S4" )
	checkException( S4_get_slot_x( structure( list( x = 2, y = 3 ), class = "track" ) ), msg = "S3 is not S4" )

	tr <- S4_ctor( "track" )
	checkTrue( inherits( tr, "track" ) )
	checkEquals( tr@x, numeric(0) )
	checkEquals( tr@y, numeric(0) )
	checkException( S4_ctor( "someclassthatdoesnotexist" ) )
    }


    test.S4.is <- function(){
	setClass("track", representation(x="numeric", y="numeric"))
	setClass("trackCurve", representation(smooth = "numeric"), contains = "track")

	tr1 <- new( "track", x = 2, y = 3 )
	tr2 <- new( "trackCurve", x = 2, y = 3, smooth = 5 )

	checkTrue( S4_is_track( tr1 ), msg = 'track is track' )
	checkTrue( S4_is_track( tr2 ), msg = 'trackCurve is track' )

	checkTrue( !S4_is_trackCurve( tr1 ), msg = 'track is not trackCurve' )
	checkTrue( S4_is_trackCurve( tr2 ), msg = 'trackCurve is trackCurve' )

    }

    test.Vector.SlotProxy.ambiguity <- function(){
	setClass("track", representation(x="numeric", y="numeric"))
	setClass("trackCurve", representation(smooth = "numeric"), contains = "track")

	tr1 <- new( "track", x = 2, y = 3 )
	checkEquals( S4_get_slot_x(tr1), 2, "Vector( SlotProxy ) ambiguity" )

    }

    test.Vector.AttributeProxy.ambiguity <- function(){
	x <- 1:10
	attr( x, "foo" ) <- "bar"

	checkEquals( S4_get_attr_x(x), "bar", "Vector( AttributeProxy ) ambiguity" )

    }

    test.S4.dotdataslot <- function(){
	setClass( "Foo", contains = "character", representation( x = "numeric" ) )
	foo <- S4_dotdata( new( "Foo", "bla", x = 10 ) )
	checkEquals( as.character( foo) , "foooo" )
    }

    test.S4.proxycoerce <- function() {
        setClass("Foo", list(data="integer"))
        foo <- new("Foo", data=1:3)
        checkEquals( S4_proxycoerce(foo), c(1, 2, 3) )
    }

}
