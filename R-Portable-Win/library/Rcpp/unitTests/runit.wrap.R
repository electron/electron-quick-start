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

    .setUp <- Rcpp:::unitTestSetup("wrap.cpp") 

    test.wrap.map.string.int <- function(){
        checkEquals(map_string_int(),
                    c( a = 200L, b = 100L, c = 300L),
                    msg = "wrap( map<string,int>) " )
    }

    test.wrap.map.string.double <- function(){
        checkEquals(map_string_double(),
                    c( a = 200, b = 100, c = 300),
                    msg = "wrap( map<string,double>) " )
    }

    test.wrap.map.string.bool <- function(){
        checkEquals(map_string_bool(),
                    c( a = FALSE, b = TRUE, c = TRUE ),
                    msg = "wrap( map<string,bool>) " )
    }

    test.wrap.map.string.Rbyte <- function(){
        checkEquals(map_string_Rbyte(),
                    c( a = as.raw(1), b = as.raw(0), c = as.raw(2) ),
                    msg = "wrap( map<string,Rbyte>) " )
    }

    test.wrap.map.string.string <- function(){
        checkEquals(map_string_string(),
                    c( a = "bar", b = "foo", c = "bling" ),
                    msg = "wrap( map<string,string>) " )
    }

    test.wrap.map.string.generic <- function(){
        checkEquals(map_string_generic(),
                    list( a = c(1L, 2L, 2L), b = c(1L, 2L), c = c(1L,2L,2L,2L) ) ,
                    msg = "wrap( map<string,vector<int>>) " )
    }

    test.wrap.multimap.string.int <- function(){
        checkEquals(multimap_string_int(),
                    c( a = 200L, b = 100L, c = 300L),
                    msg = "wrap( multimap<string,int>) ")
    }

    test.wrap.multimap.string.double <- function(){
        checkEquals(multimap_string_double(),
                    c( a = 200, b = 100, c = 300),
                    msg = "wrap( multimap<string,double>) " )
    }

    test.wrap.multimap.string.bool <- function(){
        checkEquals(multimap_string_bool(),
                    c( a = FALSE, b = TRUE, c = TRUE ),
                    msg = "wrap( multimap<string,bool>)")
    }

    test.wrap.multimap.string.Rbyte <- function(){
        checkEquals(multimap_string_Rbyte(),
                    c( a = as.raw(1), b = as.raw(0), c = as.raw(2) ),
                    msg = "wrap( multimap<string,Rbyte>) " )
    }

    test.wrap.multimap.string.string <- function(){
        checkEquals(multimap_string_string(),
                    c( a = "bar", b = "foo", c = "bling" ),
                    msg = "wrap( multimap<string,string>) " )
    }

    test.wrap.multimap.string.generic <- function(){
        checkEquals(multimap_string_generic(),
                    list( a = c(1L, 2L, 2L), b = c(1L, 2L), c = c(1L,2L,2L,2L) ) ,
                    msg = "wrap( multimap<string,vector<int>>) " )
    }

    test.nonnull.const.char <- function() {
        checkEquals(nonnull_const_char(),
                    "foo",
                    msg = "null const char*")
    }

    test.wrap.unordered.map.string.int <- function(){
        res <- unordered_map_string_int()
        checkEquals( res[["a"]], 200L,  msg = "wrap( tr1::unordered_map<string,int>) " )
        checkEquals( res[["b"]], 100L,  msg = "wrap( tr1::unordered_map<string,int>) " )
        checkEquals( res[["c"]], 300L,  msg = "wrap( tr1::unordered_map<string,int>) " )
    }

    test.wrap.unordered.map.rcpp.string.int <- function(){
        res <- unordered_map_rcpp_string_int(c("a", "b", "c"))
        checkEquals( res[["a"]], 200L,  msg = "wrap( tr1::unordered_map<Rcpp::String,int>) " )
        checkEquals( res[["b"]], 100L,  msg = "wrap( tr1::unordered_map<Rcpp::String,int>) " )
        checkEquals( res[["c"]], 300L,  msg = "wrap( tr1::unordered_map<Rcpp::String,int>) " )
    }

    test.unordered.set.rcpp.string <- function(){
        checkEquals(unordered_set_rcpp_string(c("a", "b", "c", "b")),
            c(FALSE, FALSE, FALSE, TRUE), msg = "wrap( tr1::unordered_set<Rcpp::String>) " )
    }

    test.wrap.unordered.map.string.double <- function(){
        res <- unordered_map_string_double()
        checkEquals( res[["a"]], 200,  msg = "wrap( tr1::unordered_map<string,double>) " )
        checkEquals( res[["b"]], 100,  msg = "wrap( tr1::unordered_map<string,double>) " )
        checkEquals( res[["c"]], 300,  msg = "wrap( tr1::unordered_map<string,double>) " )
    }

    test.wrap.unordered.map.string.bool <- function(){
        res <- unordered_map_string_bool()
        checkEquals( res[["a"]], FALSE,  msg = "wrap( tr1::unordered_map<string,bool>) " )
        checkEquals( res[["b"]], TRUE ,  msg = "wrap( tr1::unordered_map<string,bool>) " )
        checkEquals( res[["c"]], TRUE ,  msg = "wrap( tr1::unordered_map<string,bool>) " )
    }

    test.wrap.unordered.map.string.Rbyte <- function(){
        res <- unordered_map_string_Rbyte()
        checkEquals( res[["a"]], as.raw(1),  msg = "wrap( tr1::unordered_map<string,Rbyte>) " )
        checkEquals( res[["b"]], as.raw(0),  msg = "wrap( tr1::unordered_map<string,Rbyte>) " )
        checkEquals( res[["c"]], as.raw(2),  msg = "wrap( tr1::unordered_map<string,Rbyte>) " )
    }

    test.wrap.unordered.map.string.string <- function(){
        res <- unordered_map_string_string()
        checkEquals( res[["a"]], "bar"   ,  msg = "wrap( tr1::unordered_map<string,string>) " )
        checkEquals( res[["b"]], "foo"   ,  msg = "wrap( tr1::unordered_map<string,string>) " )
        checkEquals( res[["c"]], "bling" ,  msg = "wrap( tr1::unordered_map<string,string>) " )
    }

    test.wrap.unordered.map.string.generic <- function(){
        res <- unordered_map_string_generic()
        checkEquals( res[["a"]], c(1L,2L,2L) ,  msg = "wrap( tr1::unordered_map<string,vector<int>>) " )
        checkEquals( res[["b"]], c(1L,2L) ,  msg = "wrap( tr1::unordered_map<string,vector<int>>) " )
        checkEquals( res[["c"]], c(1L,2L,2L,2L) ,  msg = "wrap( tr1::unordered_map<string,vector<int>>) " )
    }

    test.wrap.map.int.double <- function(){
        checkEquals( 
            map_int_double(), 
            c("-1" = 3, "0" = 2 ), 
            msg = "std::map<int,double>"
            )    
    }

    test.wrap.map.double.double <- function(){
        checkEquals( 
            map_double_double(), 
            c("0" = 2, "1.2" = 3 ), 
            msg = "std::map<double,double>"
            )    
    }

    test.wrap.map.int.vector_double <- function(){
        checkEquals( 
            map_int_vector_double(), 
            list("0" = c(1,2), "1" = c(2,3) ), 
            msg = "std::map<double, std::vector<double> >"
            )    
    }

    test.wrap.map.int.Foo <- function(){
        checkEquals( 
            sapply( map_int_Foo(), function(.) .$get() ), 
            c("0" = 2, "1" = 3 ), 
            msg = "std::map<int, MODULE EXPOSED CLASS >"
            )    
    }

    test.wrap.vector.Foo <- function(){
        checkEquals( 
            sapply( vector_Foo(), function(.) .$get() ), 
            c(2, 3), 
            msg = "std::vector< MODULE EXPOSED CLASS >"
            )    
    }

    test.wrap.custom.class <- function() {
        checkEquals(test_wrap_custom_class(), 42)
    }

}

