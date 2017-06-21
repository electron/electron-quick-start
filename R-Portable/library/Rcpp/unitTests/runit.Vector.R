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

if (.runThisTest) {

    .setUp <- Rcpp:::unitTestSetup("Vector.cpp")

    test.RawVector <- function(){
        funx <- raw_
        checkEquals( funx(), as.raw(0:9), msg = "RawVector(int)" )
    }

    test.RawVector.REALSXP <- function(){
        funx <- raw_REALSXP
        checkEquals( funx(as.raw(0:9)), as.raw(2*0:9), msg = "RawVector( RAWSXP) " )
    }

    test.ExpressionVector <- function(){
        funx <- expression_
        ex <- parse( text = "rnorm; rnorm(10)" )
                                        # get rid of the srcref stuff so that we can compare
                                        # more easily
        attributes(ex) <- NULL
        checkEquals( funx(),  ex , msg = "ExpressionVector" )
    }

    test.ExpressionVector.variadic <- function(){
        funx <- expression_variadic
        ex <- parse( text = "rnorm; rnorm(10)" )
        attributes(ex) <- NULL
        checkEquals( funx(),  ex , msg = "ExpressionVector (using variadic templates) " )
    }

    test.ExpressionVector.parse <- function( ){
        funx <- expression_parse
        code <- funx()
        results <- eval( code )
        checkEquals( results, 1:10, msg = "ExpressionVector parsing" )
    }

    test.ExpressionVector.parse.error <- function(){
        funx <- expression_parseerror
        checkException( funx(), msg = "parse error" )
    }

    test.ExpressionVector.eval <- function(){
        funx <- expression_eval
        checkEquals( funx(), 1:10, msg = "ExpressionVector::eval" )
    }

    test.ExpressionVector.eval.env <- function(){
        funx <- expression_evalenv
        e <- new.env()
        e[["x"]] <- sample(1:10)
        checkEquals( funx(e), 1:10, msg = "ExpressionVector::eval in specific environment" )
    }

    test.ComplexVector <- function(){
        funx <- complex_
        checkEquals( funx(), 0:9*(1+1i), msg = "ComplexVector" )
    }
    test.ComplexVector.CPLXSXP <- function(){
        funx <- complex_CPLXSXP
        vv = (0:9)*(1+1i) ## not working - funx changes its argument
                                        #checkEquals( funx(vv), 2*vv, msg = "ComplexVector( CPLXSXP) " )
        checkEquals( funx((0:9)*(1+1i)), 2*(0:9)*(1+1i), msg = "ComplexVector( CPLXSXP) " )
    }
    test.ComplexVector.INTSXP <- function(){
        funx <- complex_INTSXP
        vv <- 0L:9L
        checkEquals( funx(vv), (2+0i)*vv, msg = "ComplexVector( INTSXP) " )
    }
    test.ComplexVector.REALSXP <- function(){
        funx <- complex_REALSXP
        vv <- as.numeric(0:9)
        checkEquals( funx(vv), (3+0i)*vv, msg = "ComplexVector( REALSXP) " )
    }




    test.IntegerVector <- function(){
        fun <- integer_ctor
        checkEquals( fun(), 0:9, msg = "IntegerVector" )
    }

    test.IntegerVector.INTSXP_ <- function(){
        fun <- integer_INTSXP
        checkEquals( fun(0:9), 2*0:9, msg = "IntegerVector( INTSXP) " )
    }


    test.IntegerVector.Dimension.constructor <- function(){
        fun <- integer_dimension_ctor_1
        checkEquals(fun(),
                    integer(5) ,
                    msg = "IntegerVector( Dimension(5))" )

        fun <- integer_dimension_ctor_2
        checkEquals(fun(),
                    matrix( 0L, ncol = 5, nrow = 5) ,
                    msg = "IntegerVector( Dimension(5,5))" )

        fun <- integer_dimension_ctor_3
        checkEquals(fun(),
                    array( 0L, dim = c(2,3,4) ) ,
                    msg = "IntegerVector( Dimension(2,3,4))" )
    }

    test.IntegerVector.range.constructors <- function(){
        fun <- integer_range_ctor_1
        checkEquals( fun(), 0:3, msg = "assign(int*, int*)" )

        fun <- integer_range_ctor_2
        checkEquals( fun(), 0:3, msg = "assign(int*, int*)" )
    }

    test.IntegerVector.names.set <- function(){
        fun <- integer_names_set
        checkEquals(names(fun()), c("foo", "bar"), msg = "Vector::names" )
    }

    test.IntegerVector.names.get <- function(){
        fun <- integer_names_get
        checkEquals(fun( c("foo" = 1L, "bar" = 2L) ),
                    c("foo", "bar"),
                    msg = "Vector::names get" )
    }

    test.IntegerVector.names.indexing <- function(){
        fun <- integer_names_indexing
        x <- c( "foo" = 1L, "bar" = 2L )
        checkEquals( fun( x ), 1L, msg = "IntegerVector names based indexing" )
    }

    test.IntegerVector.push.back <- function(){
        fun <- integer_push_back
        checkEquals( fun(1:4), 1:5, msg = "IntegerVector push back" )

        x <- 1:4
        names(x) <- letters[1:4]

        target <- 1:5
        names(target) <- c( letters[1:4], "")
        checkEquals( fun(x), target, msg = "IntegerVector push back names" )
    }

    test.IntegerVector.push.front <- function(){
        fun <- integer_push_front
        checkEquals( fun(1:4), c(5L,1:4), msg = "IntegerVector push front" )

        x <- 1:4
        names(x) <- letters[1:4]

        target <- c( 5L, 1:4 )
        names(target) <- c( "", letters[1:4])

        checkEquals( fun(x), target, msg = "IntegerVector push front names" )
    }

    test.IntegerVector.insert <- function(){
        fun <- integer_insert
        checkEquals( fun(1:4), c(5L,1L, 7L, 2:4), msg = "IntegerVector insert" )

        x <- 1:4
        names(x) <- letters[1:4]

        target <- c( 5L, 1L, 7L, 2:4 )
        names(target) <- c( "", "a", "", letters[2:4])

        checkEquals( fun(x), target, msg = "IntegerVector insert names" )
    }

    test.IntegerVector.erase <- function(){
        fun <- integer_erase
        checkEquals( fun(1:4), c(1L, 2L, 4L), msg = "IntegerVector erase" )

        x <- 1:4
        names(x) <- letters[1:4]

        target <- c(1L, 2L, 4L)
        names(target) <- c( "a", "b", "d" )

        checkEquals( fun(x), target, msg = "IntegerVector erase" )
    }

    test.IntegerVector.erase.range <- function(){
        x <- y <- 1:10
        names(y) <- letters[1:10]
        res <- integer_erase_range( x, y )
        checkEquals( res[[1L]], c(1:5, 10L) , msg = "IntegerVector erase range unnamed" )

        z <- y[-(6:9)]
        checkEquals( res[[2L]], z , msg = "IntegerVector erase range named" )
    }

    test.IntegerVector.erase.range.2 <- function(){
        x <- y <- 1:10
        names(y) <- letters[1:10]
        res <- integer_erase_range_2( x, y )
        checkEquals( res[[1L]], 1L , msg = "IntegerVector erase range 2 unnamed" )
        checkEquals( res[[2L]], c("a" = 1L ) , msg = "IntegerVector erase range 2 named" )
    }


    test.IntegerVector.erase.range.2 <- function(){
        x <- y <- as.list(1:10)
        names(y) <- letters[1:10]
        res <- List_erase_range_2( x, y )
        checkEquals( res[[1L]], list( 1L ) , msg = "List erase range 2 unnamed" )
        checkEquals( res[[2L]], list("a" = 1L ) , msg = "List erase range 2 named" )
    }

    test.IntegerVector.erase2 <- function(){
        checkEquals( integer_erase2(1:4), c(1L, 3L, 4L), msg = "IntegerVector erase2" )

        x <- 1:4
        names(x) <- letters[1:4]

        target <- c(1L, 3L, 4L)
        names(target) <- c( "a", "c", "d" )

        checkEquals( integer_erase2(x), target, msg = "IntegerVector erase2" )
    }

    test.IntegerVector.fill <- function(){
        fun <- integer_fill
        x <- 1:10
        checkEquals( fun(x), rep(10L, 10 ), msg = "IntegerVector.fill" )
    }

    test.IntegerVector.zero <- function( ){
        fun <- integer_zero
        checkEquals( fun(), integer(0), msg = "IntegerVector(0)" )
    }

    test.IntegerVector.create.zero <- function( ){
        fun <- integer_create_zero
        checkEquals( fun(), integer(0), msg = "IntegerVector::create()" )
    }

    test.IntegerVector.create <- function(){
        fun <- integer_create_
        checkEquals( fun(), list( c( 10L, 20L) , c(foo = 20L, bar = 30L) ),
                    msg = "IntegerVector::create" )
    }

    test.IntegerVector.clone <- function(){
        x <- 1:10
        fun <- integer_clone_
        y <- fun(x)
        checkEquals( x, 1:10, msg = "clone" )
        checkEquals( y, 10:1, msg = "clone" )
    }





    test.NumericVector <- function(){
        funx <- numeric_
        checkEquals( funx(), as.numeric(0:9), msg = "NumericVector(int)" )
    }

    test.NumericVector.REALSXP <- function(){
        funx <- numeric_REALSXP
        checkEquals( funx(as.numeric(0:9)), 2*0:9, msg = "NumericVector( REALSXP) " )
    }


    test.NumericVector.import <- function(){
        funx <- numeric_import
        checkEquals( funx(), 0:9, msg = "IntegerVector::import" )
    }

    test.NumericVector.import.transform <- function(){
        funx <- numeric_importtransform
        checkEquals( funx(), (0:9)^2, msg = "NumericVector::import_transform" )
    }





    test.List <- function(){
        fun <- list_ctor
        checkEquals( fun(), as.list( 2*0:9), msg = "GenericVector" )
    }

    test.List.template <- function(){
        fun <- list_template_
        checkEquals(fun(), list( "foo", 10L, 10.2, FALSE), msg = "GenericVector" )
    }

    test.List.VECSXP <- function(){
        fun <- list_VECSXP_
        checkEquals( fun(list(1,2)), list(1,2), msg = "GenericVector( VECSXP) " )
    }

    test.List.matrix.indexing <- function(){
        fun <- list_matrix_indexing_1
        ## a matrix of integer vectors
        x <- structure( lapply( 1:16, function(x) seq.int(x) ), dim = c( 4, 4) )
        checkEquals( fun(x), diag(x), msg = "matrix indexing 1" )

        fun <- list_matrix_indexing_2
        checkEquals(diag(fun(x)), rep(list("foo"), 4) , msg = "matrix indexing lhs" )

        ## drop dimensions
        dim(x) <- NULL
        checkException( fun(x) , msg = "not a matrix" )
    }

    test.List.Dimension.constructor <- function(){
        fun <- list_Dimension_constructor_1
        checkEquals(fun(),
                    rep(list(NULL),5) ,
                    msg = "List( Dimension(5))" )

        fun <- list_Dimension_constructor_2
        checkEquals(fun(),
                    structure( rep( list(NULL), 25), dim = c(5,5) ),
                    msg = "List( Dimension(5,5))" )

        fun <- list_Dimension_constructor_3
        checkEquals(fun(),
                    array( rep(list(NULL)), dim = c(2,3,4) ) ,
                    msg = "List( Dimension(2,3,4))" )
    }

    test.List.iterator <- function() {
        fun <- list_iterator_
        data <- list( x = letters, y = LETTERS, z = 1:4 )
        checkEquals(fun( data, length ),
                    list( x = 26L, y = 26L, z = 4L),
                    msg = "c++ version of lapply" )
    }

    test.List.name.indexing <- function(){
        fun <- list_name_indexing
        d <- data.frame( x = 1:10, y = letters[1:10] )
        checkEquals( fun( d ), sum(1:10), msg = "List names based indexing" )
    }

    test.List.push.back <- function(){
        fun <- list_push_back
        d <- list( x = 1:10, y = letters[1:10] )
        checkEquals(fun( d ),
                    list( x = 1:10, y = letters[1:10], 10L, foo = "bar" ),
                    msg = "List.push_back" )
    }

    test.List.push.front <- function(){
        fun <- list_push_front
        d <- list( x = 1:10, y = letters[1:10] )
        checkEquals(fun(d),
                    list( foo = "bar", 10L, x = 1:10, y = letters[1:10] ),
                    msg = "List.push_front" )
    }

    test.List.erase <- function(){
        fun <- list_erase
        d <- list( x = 1:10, y = letters[1:10] )
        checkEquals(fun(d),
                    list( y = letters[1:10] ),
                    msg = "List.erase" )
    }

    test.List.erase.range <- function(){
        fun <- list_erase_range
        d <- list( x = 1:10, y = letters[1:10], z = 1:10 )
        checkEquals(fun(d),
                    list( z = 1:10 ),
                    msg = "List.erase (range version)" )
    }

    test.List.implicit.push.back <- function(){
        fun <- list_implicit_push_back
        checkEquals( fun(), list( foo = 10, bar = "foobar" ), msg = "List implicit push back" )
    }

    test.List.create <- function(){
        fun <- list_create_
        checkEquals( fun(), list( list( 10L, "foo" ), list(foo = 10L, bar =  TRUE ) ),
                    msg = "List::create" )
    }

    test.List.stdcomplex <- function(){
        fun <- list_stdcomplex
        checkEquals(
            fun(),
            list( float = rep(0+0i, 10), double = rep(0+0i, 10) ),
            msg = "range wrap over std::complex" )
    }





    test.CharacterVector <- function(){
        fun <- character_ctor
        checkEquals( fun(), rep("foo",10L), msg = "CharacterVector" )
    }

    test.CharacterVector.STRSXP <- function(){
        fun <- character_STRSXP_
        checkEquals( fun(letters), paste(letters,collapse="" ), msg = "CharacterVector( STRSXP) " )
    }


    test.CharacterVector.plusequals <- function(){
        fun <- character_plusequals
        checkEquals( fun(), c("foobar", "barfoobar"), msg = "StringProxy::operator+=" )
    }

    test.CharacterVector.matrix.indexing <- function() {
        fun <- character_matrix_indexing
        x <- matrix( as.character(1:16), ncol = 4 )
        checkEquals( fun(x), paste(diag(x), collapse = ""), msg = "matrix indexing" )

        y <- as.vector( x )
        checkException( fun(y) , msg = "not a matrix" )

        fun <- character_matrix_indexing_lhs
        checkEquals( diag(fun(x)), rep("foo", 4) , msg = "matrix indexing lhs" )
    }

    test.CharacterVector.matrix.row.iteration <- function() {
        x <- matrix(letters[1:16], nrow = 4)

        fun <- character_matrix_row_iteration_incr
        checkEquals( fun(x), "bfjn", msg = "matrix row iteration post-incr" )

        fun <- character_matrix_row_iteration_decr
        checkEquals( fun(x), "njf", msg = "matrix row iteration post-decr" )
    }

    test.CharacterVector.assign <- function(){
        fun <- character_assign1
        checkEquals( fun(), c("foo", "bar", "bling", "boom"), msg = "assign(char**, char**)" )

        fun <- character_assign2
        checkEquals( fun(), c("foo", "bar", "bling", "boom"), msg = "assign(char**, char**)" )

    }

    test.CharacterVector.range.constructors <- function(){
        fun <- character_range_ctor1
        checkEquals( fun(), c("foo", "bar", "bling", "boom"), msg = "assign(char**, char**)" )

        fun <- character_range_ctor2
        checkEquals( fun(), c("foo", "bar", "bling", "boom"), msg = "assign(char**, char**)" )
    }

    test.CharacterVector.Dimension.constructor <- function(){
        fun <- character_dimension_ctor1
        checkEquals(fun(),
                    character(5),
                    msg = "CharacterVector( Dimension(5))" )

        fun <- character_dimension_ctor2
        checkEquals(fun(),
                    matrix( "", ncol = 5, nrow = 5),
                    msg = "CharacterVector( Dimension(5,5))" )

        fun <- character_dimension_ctor3
        checkEquals(fun(),
                    array( "", dim = c(2,3,4) ) ,
                    msg = "CharacterVector( Dimension(2,3,4))" )
    }

    test.CharacterVector.iterator <- function(){
        fun <- character_iterator1
        checkEquals(fun(letters),
                    paste(letters, collapse=""),
                    msg = "CharacterVector::iterator explicit looping" )

        fun <- character_iterator2
        checkEquals(fun(letters),
                    paste(letters, collapse=""),
                    msg = "CharacterVector::iterator using std::accumulate" )
    }
    
    test.CharacterVector.iterator <- function(){
        fun <- character_const_iterator1
        checkEquals(fun(letters),
                    paste(letters, collapse=""),
                    msg = "CharacterVector::iterator explicit looping" )

        fun <- character_const_iterator2
        checkEquals(fun(letters),
                    paste(letters, collapse=""),
                    msg = "CharacterVector::iterator using std::accumulate" )
    }

    test.CharacterVector.reverse <- function(){
        fun <- character_reverse
        x <- c("foo", "bar", "bling")
        x <- fun(x)
        checkEquals( x, c("bling", "bar", "foo"), msg = "reverse" )
        x <- fun(x)
        checkEquals( x, c("foo", "bar", "bling"), msg = "reverse" )
    }

    test.CharacterVector.names.indexing <- function(){
        fun <- character_names_indexing
        x <- c( foo = "foo", bar = "bar" )
        checkEquals( fun(x), "foo", msg = "CharacterVector names based indexing" )
    }

    test.CharacterVector.listOf <- function() {
        fun <- character_listOf
        checkEquals(fun(list(foo=c("tic","tac","toe"),
                             bar=c("Eenie","Meenie","Moe"))),
                    list(foo="tictactoe", bar="EenieMeenieMoe"),
                    msg="CharacterVector from list")
    }

    test.CharacterVector.find <- function(){
        fun <- character_find_
        checkEquals( fun( c("bar", "foo", "bob") ), 1L, msg = "support for std::find in CharacterVector" )
    }

    test.CharacterVector.create <- function(){
        fun <- character_create_
        checkEquals( fun(), list( c( "foo", "bar" ), c(foo = "bar", bar = "foo" ) ),
                    msg = "CharacterVector::create" )
    }

    test.ComplexVector.binary.operators <- function(){
        fun <- complex_binary_sugar
        x <- (1+1i) * 1:10
        y <- (2-3i) * 1:10

        checkEquals(
            fun(x, y),
            list(
                "+" = x + y,
                "-" = x - y,
                "*" = x * y,
                "/" = x / y
                ), msg = "complex binary operators" )
    }

    test.ComplexVector.binary.operators <- function(){
        fun <- List_extract
        checkEquals( fun(list(TRUE, 4)), list(TRUE, 4L) )
        checkEquals( fun(list(FALSE, -4L)), list(FALSE,-4L) )
    }

    test.factors <- function(){
        fun <-    factors
        x <- as.factor( c("c3", "c2", "c1") )
        y <- fun(x)
        checkEquals( y, as.character(x) )
    }

    test.IntegerVector_int_init <- function(){
        fun <-    IntegerVector_int_init
        checkEquals( fun(), c(4L,4L), msg = "IntegerVector int init regression test" )
    }

    test.containsElementNamed <- function() {
        fun <- containsElementNamed

        x <- list( foo = 2, bla = 1:10 )

        checkEquals(fun(x, "foo"), TRUE, msg = "containsElementNamed with element")
        checkEquals(fun(x, "bar"), FALSE, msg = "containsElementNamed without element")
        checkEquals(fun(x, ""), FALSE, msg = "containsElementNamed with empty element")
    }

    test.CharacterVector.equality.operator <- function(){
        res <- CharacterVectorEqualityOperator( letters, letters )
        checkEquals( res,
                    list( rep( TRUE, 26L ), rep( FALSE, 26L) ),
                    msg = 'CharacterVector element equality operator' )
    }

    test.List.rep.ctor <- function(){
        x <- 1:10
        res <- List_rep_ctor(x)
        expected <- rep( list(x), 3 )
        checkEquals( res, expected, msg = "List rep constructor" )
    }

    test.std.vector.double <- function() {
        fun <- stdVectorDouble
        x <- seq(1.0, 5.0, by=1.0)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorDouble")
    }

    test.std.vector.double.const <- function() {
        fun <- stdVectorDoubleConst
        x <- seq(1.0, 5.0, by=1.0)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorDoubleConst")
    }

    test.std.vector.double.ref <- function() {
        fun <- stdVectorDoubleRef
        x <- seq(1.0, 5.0, by=1.0)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorDoubleRef")
    }

    test.std.vector.double.const.ref <- function() {
        fun <- stdVectorDoubleConstRef
        x <- seq(1.0, 5.0, by=1.0)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorDoubleConstRef")
    }

    test.std.vector.int <- function() {
        fun <- stdVectorInt
        x <- seq(1L, 5L, by=1L)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorInt")
    }

    test.std.vector.int.const <- function() {
        fun <- stdVectorIntConst
        x <- seq(1L, 5L, by=1L)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorIntConst")
    }

    test.std.vector.int.ref <- function() {
        fun <- stdVectorIntRef
        x <- seq(1L, 5L, by=1L)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorIntRef")
    }

    test.std.vector.int.const.ref <- function() {
        fun <- stdVectorIntConstRef
        x <- seq(1L, 5L, by=1L)
        checkEquals(fun(x), 5, msg = "automatic conversion of stdVectorIntConstRef")
    }

    test.character.vector.const.proxy <- function(){
        res <- character_vector_const_proxy( "fooo" )
        checkEquals( res, "fooo", msg = "CharacterVector const proxy. #32" )
    }
    
    test.CharacterVector.test.const.proxy <- function(){
        res <- CharacterVector_test_const_proxy( letters )
        checkEquals( res, letters )
    }
  
    test.sort <- function() {
        num <- setNames( c(1, -1, 4, NA, 5, NaN), letters[1:5] )
        checkIdentical( sort_numeric(num), sort(num, na.last=TRUE) )
        int <- as.integer(num)
        checkIdentical( sort_integer(int), sort(int, na.last=TRUE) )
        char <- setNames( sample(letters, 5), LETTERS[1:5] )
        checkIdentical( sort_character(char), sort(char, na.last=TRUE) )
        lgcl <- as.logical(int)
        checkIdentical( sort_logical(lgcl), sort(lgcl, na.last=TRUE) )
    }
    
    test.sort_desc <- function() {
        num <- setNames(c(1, -1, 4, NA, 5, NaN), letters[1:5])
        checkIdentical(
            sort_numeric_desc(num), 
            sort(num, decreasing = TRUE, na.last = FALSE)
        )
        
        int <- as.integer(num)
        checkIdentical(
            sort_integer_desc(int), 
            sort(int, decreasing = TRUE, na.last = FALSE) 
        )
        
        char <- setNames(sample(letters, 5), LETTERS[1:5])
        checkIdentical(
            sort_character_desc(char), 
            sort(char, decreasing = TRUE, na.last = FALSE) 
        )
        
        lgcl <- as.logical(int)
        checkIdentical(
            sort_logical_desc(lgcl), 
            sort(lgcl, decreasing = TRUE, na.last = FALSE) 
        )
    }
    
    test.List.assign.SEXP <- function() {
        l <- list(1, 2, 3)
        other <- list_sexp_assign(l)
        checkIdentical(l, other)
    }

    test.logical.vector.from.bool <- function() {
        checkIdentical(logical_vector_from_bool(), TRUE)
    }

    test.logical.vector.from.bool.assign <- function() {
        checkIdentical(logical_vector_from_bool_assign(), TRUE)
    }
    
    test.noprotect_vector <- function(){
        x <- rnorm(10)
        checkIdentical( noprotect_vector(x), 10L )
    }
    
    test.noprotect_matrix <- function(){
        x <- matrix(rnorm(10), nrow=2)
        checkIdentical( noprotect_matrix(x), 2L )
    }

    test.IntegerVector.accessor.with.bounds.checking <- function() {
        x <- seq(1L, 5L, by=1L)
        checkEquals(vec_access_with_bounds_checking(x, 3), 4)
        checkException(vec_access_with_bounds_checking(x, 5) , msg = "index out of bounds not detected" )
        checkException(vec_access_with_bounds_checking(x, -1) , msg = "index out of bounds not detected" )
    }

    test.NumericVector.print <- function() {
        v <- c(1.1, 2.2, 3.3, 4.4)
        s <- vec_print_numeric(v)
        checkEquals(s, "1.1 2.2 3.3 4.4")
    }

    test.IntegerVector.print <- function() {
        v <- c(1, 2, 3, 4)
        s <-vec_print_integer(v)
        checkEquals(s, "1 2 3 4")
    }

    test.CharacterVector.print <- function() {
        v <- c("a", "b", "c", "d")
        s <- vec_print_character(v)
        checkEquals(s, '"a" "b" "c" "d"')
    }

    test.IntegerVector.subset.under.gc <- function() {
        x <- 1:1E6
        y <- 1:1E6
        gctorture(TRUE)
        z <- vec_subset(x, y)
        gctorture(FALSE)
        checkEquals(x[y], z)
    }
}

