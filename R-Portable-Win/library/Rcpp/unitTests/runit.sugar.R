#!/usr/bin/env r
#                     -*- mode: R; ess-indent-level: 4; indent-tabs-mode: nil; -*-
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

    .setUp <- Rcpp:::unitTestSetup("sugar.cpp")

    test.sugar.abs <- function( ){
	x <- rnorm(10)
	y <- -10:10
	checkEquals( runit_abs(x,y) , list( abs(x), abs(y) ) )
    }

    test.sugar.all.one.less <- function( ){
	checkTrue( runit_all_one_less( 1 ) )
	checkTrue( ! runit_all_one_less( 1:10 ) )
	checkTrue( is.na( runit_all_one_less( NA ) ) )
	checkTrue( is.na( runit_all_one_less( c( NA, 1)  ) ) )
	checkTrue( ! runit_all_one_less( c( 6, NA)  ) )
    }

    test.sugar.all.one.greater <- function( ){
	checkTrue( ! runit_all_one_greater( 1 ) )
	checkTrue( ! runit_all_one_greater( 1:10 ) )
	checkTrue( runit_all_one_greater( 6:10 ) )
	checkTrue( ! runit_all_one_greater( c(NA, 1) ) )
	checkTrue( is.na( runit_all_one_greater( c(NA, 6) ) ) )
    }

    test.sugar.all.one.less.or.equal <- function( ){
	checkTrue( runit_all_one_less_or_equal( 1 ) )
	checkTrue( ! runit_all_one_less_or_equal( 1:10 ) )
	checkTrue( is.na( runit_all_one_less_or_equal( NA ) ) )
	checkTrue( is.na( runit_all_one_less_or_equal( c( NA, 1)  ) ) )
	checkTrue( ! runit_all_one_less_or_equal( c( 6, NA)  ) )
	checkTrue( runit_all_one_less_or_equal( 5 ) )

    }

    test.sugar.all.one.greater.or.equal <- function( ){
	fx <- runit_all_one_greater_or_equal
	checkTrue( ! fx( 1 ) )
	checkTrue( ! fx( 1:10 ) )
	checkTrue( fx( 6:10 ) )
	checkTrue( fx( 5 ) )
	checkTrue( ! fx( c(NA, 1) ) )
	checkTrue( is.na( fx( c(NA, 6) ) ) )
    }

    test.sugar.all.one.equal <- function( ){
	fx <- runit_all_one_equal
	checkTrue( ! fx( 1 ) )
	checkTrue( ! fx( 1:2 ) )
	checkTrue( fx( rep(5,4) ) )
	checkTrue( is.na( fx( c(5,NA) ) ) )
	checkTrue(! fx( c(NA, 1) ) )
    }

    test.sugar.all.one.not.equal <- function( ){
	fx <- runit_all_not_equal_one
	checkTrue( fx( 1 ) )
	checkTrue( fx( 1:2 ) )
	checkTrue( ! fx( 5 ) )
	checkTrue( is.na( fx( c(NA, 1) ) ) )
	checkTrue( ! fx( c(NA, 5) ) )
    }

    test.sugar.all.less <- function( ){
	fx <- runit_all_less
	checkTrue( ! fx( 1, 0 ) )
	checkTrue( fx( 1:10, 2:11 ) )
	checkTrue( fx( 0, 1 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.all.greater <- function( ){
	fx <- runit_all_greater
	checkTrue( fx( 1, 0 ) )
	checkTrue( fx( 2:11, 1:10 ) )
	checkTrue( ! fx( 0, 1 ) )
	checkTrue( ! fx( 0:9, c(0:8,10) ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.all.less.or.equal <- function( ){
	fx <- runit_all_less_or_equal
	checkTrue( fx( 1, 1 ) )
	checkTrue( ! fx( 1:2, c(1,1) ) )
	checkTrue( fx( 0, 1 ) )
	checkTrue( ! fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.all.greater.or.equal <- function( ){
	fx <- runit_all_greater_or_equal
	checkTrue( fx( 1, 1 ) )
	checkTrue( fx( 1:2, c(1,1) ) )
	checkTrue( ! fx( 0, 1 ) )
	checkTrue( fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.all.equal <- function( ){
	fx <- runit_all_equal
	checkTrue( fx( 1, 1 ) )
	checkTrue( ! fx( 1:2, c(1,1) ) )
	checkTrue( ! fx( 0, 1 ) )
	checkTrue( ! fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.all.not.equal <- function( ){
	fx <- runit_all_not_equal
	checkTrue( ! fx( 1, 1 ) )
	checkTrue( ! fx( 1:2, c(1,1) ) )
	checkTrue( fx( 0, 1 ) )
	checkTrue( fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )

    }

    test.sugar.any.less <- function( ){
	fx <- runit_any_less
	checkTrue( ! fx( 1, 0 ) )
	checkTrue( fx( 1:10, 2:11 ) )
	checkTrue( fx( 0, 1 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.any.greater <- function( ){
	fx <- runit_any_greater
	checkTrue( fx( 1, 0 ) )
	checkTrue( fx( 2:11, 1:10 ) )
	checkTrue( ! fx( 0, 1 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.any.less.or.equal <- function( ){
        fx <- runit_any_less_or_equal
	checkTrue( fx( 1, 1 ) )
	checkTrue( fx( 1:2, c(1,1) ) )
	checkTrue( fx( 0, 1 ) )
	checkTrue( ! fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.any.greater.or.equal <- function( ){
	fx <- runit_any_greater_or_equal
	checkTrue( fx( 1, 1 ) )
	checkTrue( fx( 1:2, c(1,1) ) )
	checkTrue( ! fx( 0, 1 ) )
	checkTrue( fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.any.equal <- function( ){
	fx <- runit_any_equal
	checkTrue( fx( 1, 1 ) )
	checkTrue( fx( 1:2, c(1,1) ) )
	checkTrue( ! fx( 0, 1 ) )
	checkTrue( ! fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.any.not.equal <- function( ){
	fx <- runit_any_not_equal
	checkTrue( ! fx( 1, 1 ) )
	checkTrue( fx( 1:2, c(1,1) ) )
	checkTrue( fx( 0, 1 ) )
	checkTrue( fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.constructor <- function( ){
	fx <- runit_constructor
	checkEquals( fx( 1, 0 ), FALSE )
	checkEquals( fx( 1:10, 2:11 ), rep(TRUE,10) )
	checkEquals( fx( 0, 1 ), TRUE )
	checkTrue( identical( fx( NA, 1 ), NA ) )
    }

    test.sugar.assignment <- function( ){
	fx <- runit_assignment
	checkEquals( fx( 1, 0 ), FALSE )
	checkEquals( fx( 1:10, 2:11 ), rep(TRUE,10) )
	checkEquals( fx( 0, 1 ), TRUE )
	checkTrue( identical( fx( NA, 1 ), NA ) )
    }

    test.sugar.diff <- function( ){
        x <- as.integer(round(rnorm(100,1,100)))
        checkEquals( runit_diff_int(x) , diff(x) )
        x <- rnorm( 100 )
        checkEquals( runit_diff(x) , diff(x) )
        y    <- rnorm(100)
        pred <- sample( c(T,F), 99, replace = TRUE )
        checkEquals( runit_diff_ifelse(pred, x, y ), ifelse( pred, diff(x), diff(y) ) )
    }

    test.sugar.exp <- function( ){
	fx <- runit_exp
	x <- rnorm(10)
	y <- -10:10
	checkEquals( fx(x,y) , list( exp(x), exp(y) ) )
    }

    test.sugar.floor <- function( ){
	fx <- runit_floor
	x <- rnorm(10)
	y <- -10:10
	checkEquals( fx(x,y) , list( floor(x), floor(y) ) )
    }

    test.sugar.ceil <- function( ){
	fx <- runit_ceil
	x <- rnorm(10)
	y <- -10:10
	checkEquals( fx(x,y) , list( ceiling(x), ceiling(y) ) )
    }

    test.sugar.pow <- function( ){
	fx <- runit_pow
	x <- rnorm(10)
	y <- -10:10
	checkEquals( fx(x,y) , list( x^3L , y^2.3 ) )
    }

    test.sugar.ifelse <- function( ){
	fx <- runit_ifelse
	x <- 1:10
	y <- 10:1
	checkEquals(fx( x, y),
                    list("vec_vec"   = ifelse( x<y, x*x, -(y*y) ) ,
                         "vec_prim"  = ifelse( x<y, 1.0, -(y*y) ),
                         "prim_vec"  = ifelse( x<y, x*x, 1.0    ),
                         "prim_prim" = ifelse( x<y, 1.0, 2.0    )
                         ))
    }

    test.sugar.isna <- function( ){
	fx <- runit_isna
	checkEquals( fx( 1:10) , rep(FALSE,10) )
    }

    test.sugar.isfinite <- function( ){
	checkEquals(runit_isfinite( c(1, NA, Inf, -Inf, NaN) ) ,
                    c(TRUE, FALSE, FALSE, FALSE, FALSE),
                    msg = "is_finite")
    }

    test.sugar.isinfinite <- function( ){
	checkEquals(runit_isinfinite( c(1, NA, Inf, -Inf, NaN) ) ,
                    c(FALSE, FALSE, TRUE, TRUE, FALSE),
                    msg = "is_infinite")
    }


    test.sugar.isnan <- function( ){
	checkEquals(runit_isnan( c(1, NA, Inf, -Inf, NaN) ) ,
                    c(FALSE, FALSE, FALSE, FALSE, TRUE),
                    msg = "is_nan")
    }

    test.sugar.isna.isna <- function( ){
	fx <- runit_isna_isna
	checkEquals( fx( c(1:5,NA,7:10) ) , rep(FALSE,10) )
    }

    test.sugar.any.isna <- function( ){
	fx <- runit_any_isna
	checkEquals( fx( c(1:5,NA,7:10) ) , TRUE )
    }

    test.sugar.na_omit.na <- function( ){
        fx <- runit_na_omit
        checkEquals( fx( c(1:5,NA,7:10) ), fx( c(1:5,7:10) ) )
    }

    test.sugar.na_omit.nona <- function( ){
        fx <- runit_na_omit
        checkEquals( fx( c(1:10) ), fx( c(1:10) ) )
    }

    test.sugar.lapply <- function( ){
	fx <- runit_lapply
	checkEquals( fx( 1:10 ), lapply( 1:10, seq_len ) )
    }

    test.sugar.minus <- function( ){
	fx <- runit_minus
	checkEquals(fx(1:10) ,
                    list( (1:10)-10L, 10L-(1:10), rep(0L,10), (1:10)-10L, 10L-(1:10)  ))
    }

    test.sugar.any.equal.not <- function( ){
	fx <- runit_any_equal_not
	checkTrue( ! fx( 1, 1 ) )
	checkTrue( fx( 1:2, c(1,1) ) )
	checkTrue( fx( 0, 1 ) )
	checkTrue( fx( 1, 0 ) )
	checkTrue( is.na( fx( NA, 1 ) ) )
    }

    test.sugar.plus <- function( ){
	fx <- runit_plus
	checkEquals( fx(1:10) , list( 11:20,11:20,1:10+1:10, 3*(1:10))  )
    }

    test.sugar.plus.seqlen <- function( ){
	fx <- runit_plus_seqlen
	checkEquals( fx() , list( 11:20,11:20, 1:10+1:10)  )
    }

    test.sugar.plus.all <- function( ){
	fx <- runit_plus_all
	checkEquals( fx(1:10) , FALSE )
    }

    test.sugar.pmin <- function( ){
	fx <- runit_pmin
	checkEquals( fx(1:10, 10:1) , c(1:5,5:1) )
    }

    test.sugar.pmin.one <- function( ){
	fx <- runit_pmin_one
	checkEquals(fx(1:10), list(c(1:5,rep(5,5)), c(1:5,rep(5,5))))
    }

    test.sugar.pmax <- function( ){
	fx <- runit_pmax
	checkEquals( fx(1:10, 10:1) , c(10:6,6:10) )
    }

    test.sugar.pmax.one <- function( ){
	fx <- runit_pmax_one
	checkEquals(fx(1:10), list(c(rep(5,5), 6:10), c(rep(5,5), 6:10)))
    }

    test.sugar.Range <- function( ){
	fx <- runit_Range
	checkEquals(fx(), c( exp(seq_len(4)), exp(-seq_len(4))))
    }

    test.sugar.Range.plus <- function( ){
    fx <- runit_range_plus
    checkEquals( fx(1, 10, 2), c(1:10) + 2 )
    }

    test.sugar.Range.minus <- function( ){
    fx <- runit_range_minus
    checkEquals( fx(1, 10, 2), c(1:10) - 2 )
    }

    test.sugar.sapply <- function( ){
	fx <- runit_sapply
	checkEquals( fx(1:10) , (1:10)^2 )
    }

    test.sugar.sapply.rawfun <- function( ){
	fx <- runit_sapply_rawfun
	checkEquals( fx(1:10) , (1:10)^2 )
    }

    test.sugar.sapply.square <- function( ){
	fx <- runit_sapply_square
	checkTrue( ! fx(1:10)  )
    }

    test.sugar.sapply.list <- function( ){
	fx <- runit_sapply_list
	checkEquals( fx(1:10), lapply( 1:10, seq_len ) )
    }

    test.sugar.seqlaong <- function( ){
	fx <- runit_seqalong
	checkEquals( fx( rnorm(10)) , 1:10  )
    }

    test.sugar.seqlen <- function( ){
	fx <- runit_seqlen
	checkEquals( fx() , 1:10  )
    }

    test.sugar.sign <- function( ){
	fx <- runit_sign
	checkEquals(fx( seq(-10, 10, length.out = 51), -25:25 ),
                    list(c( rep(-1L, 25), 0L, rep(1L, 25) ), c( rep(-1L, 25), 0L, rep(1L, 25) )))
    }


    test.sugar.times <- function( ){
	fx <- runit_times
	checkEquals(fx(1:10) ,
                    list(10L*(1:10), 10L*(1:10), (1:10)*(1:10), (1:10)*(1:10)*(1:10),
                         c(NA,(2:10)*(2:10)), c(NA,10L*(2:10)), c(NA,10L*(2:10)), rep( NA_integer_, 10L )))
    }

    test.sugar.divides <- function( ){
	fx <- runit_divides
	checkEquals(fx(1:10) ,
                    list(1:10/10, 10/1:10, rep(1,10)))
    }

    test.sugar.unary.minus <- function( ){
	fx <- runit_unary_minus
	checkEquals( fx( seq(0,5,by=10) ), - seq(0,5,by=10) )
	checkTrue( identical( fx( c(0,NA,2) ), c(0,NA,-2) ) )
    }

    test.sugar.wrap <- function( ){
	fx <- runit_wrap
	e <- new.env()
	fx( 1:10, 2:11, e )
	checkEquals( e[["foo"]], rep(TRUE, 10 ) )
    }

    test.sugar.complex <- function( ){
	x <- c( rnorm(10), NA ) + 1i*c( rnorm(10), NA )
	fx <- runit_complex
	checkEquals( fx(x),
                    list(Re    = Re(x),
                         Im    = Im(x),
                         Conj  = Conj(x),
                         Mod   = Mod(x),
                         Arg   = Arg(x),
                         exp   = exp(x),
                         log   = log(x),
                         sqrt  = sqrt(x),
                         cos   = cos(x),
                         sin   = sin(x),
                         tan   = tan(x),
                         acos  = acos(x),
                         asin  = asin(x),
                         atan  = atan(x),
                         ## acosh = acosh(x),
                         asinh = asinh(x),
                         atanh = atanh(x),
                         cosh  = cosh(x),
                         sinh = sinh(x),
                         tanh = tanh(x)))
    }

    test.sugar.rep <- function(){
	fx <- runit_rep
	checkEquals(fx(1:10),
                    list("rep" = rep( 1:10, 3 ),
                         "rep_each" = rep( 1:10, each = 3 ),
                         "rep_len" = rep( 1:10, length.out = 12 ),
                         "rep_prim_double" = rep( 0.0, 10 )))
    }

    test.sugar.rev <- function(){
	fx <- runit_rev
	checkEquals( fx(1:10), rev( 1:10 * 1:10 ) )
    }

    test.sugar.head <- function(){
	fx <- runit_head
	checkEquals(fx(1:100), list( pos = 1:5, neg = 1:95 ))
    }

    test.sugar.tail <- function(){
	fx <- runit_tail
	checkEquals(
            fx(1:100),
            list( pos = 96:100, neg = 6:100 )
            )
    }

    ## matrix

    test.sugar.matrix.outer <- function( ){
	fx <- runit_outer
	x <- 1:2
	y <- 1:5
	checkEquals( fx(x,y) , outer(x,y,"+") )
    }

    test.sugar.matrix.row <- function( ){
	fx <- runit_row
	m <- matrix( 1:16, nc = 4 )
	res <- fx( m )
	target <- list( row = row(m), col = col(m) )
	checkEquals( res, target )
    }

    test.sugar.diag <- function( ){
	fx <- runit_diag

	x <- 1:4
	m <- matrix( 1:16, nc = 4 )
	res <- fx(x, m)
	target <- list(diag(x), diag(m), diag( outer( x, x, "+" ) ))
	checkEquals( res, target )
    }


    ## autogenerated sugar blocks

    test.sugar.gamma <- function(){
	fx <- runit_gamma
	x <- seq( 1, 5, by = .5 )
	checkEquals(fx(x),
                    list("gamma"      = gamma(x),
                         "lgamma"     = lgamma(x),
                         "digamma"    = digamma(x),
                         "trigamma"   = trigamma(x),
                         "tetragamma" = psigamma(x, 2),
                         "pentagamma" = psigamma(x, 3),
                         "factorial"  = factorial(x),
                         "lfactorial" = lfactorial(x)))
    }

    test.sugar.log1p <- function(){
	x <- 10^-(1+2*1:9)
	fx <- runit_log1p
	checkEquals( fx(x),
                    list( log1p = log1p(x), expm1 = expm1(x) ) )
    }

    test.sugar.choose <- function(){
	fx <- runit_choose
	checkEquals(fx(10:6,5:1),
                    list(VV = choose( 10:6, 5:1),
                         PV = choose( 10, 5:1 ),
                         VP = choose( 10:6, 5 )))
    }

    test.sugar.lchoose <- function(){
	fx <- runit_lchoose
	checkEquals( fx(10:6,5:1),
                    list(VV = lchoose( 10:6, 5:1),
                         PV = lchoose( 10, 5:1 ),
                         VP = lchoose( 10:6, 5 )) )
    }

    test.sugar.beta <- function(){
	fx <- runit_beta
	checkEquals( fx(10:6,5:1),
                    list(VV = beta( 10:6, 5:1),
                         PV = beta( 10, 5:1 ),
                         VP = beta( 10:6, 5 )))
    }

    test.sugar.lbeta <- function(){
	fx <- runit_lbeta
	checkEquals(fx(10:6,5:1),
                    list(VV = lbeta( 10:6, 5:1),
                         PV = lbeta( 10, 5:1 ),
                         VP = lbeta( 10:6, 5 )))
    }

    test.sugar.psigamma <- function(){
	fx <- runit_psigamma
	checkEquals(fx(10:6,5:1),
                    list(VV = psigamma( 10:6, 5:1),
                         PV = psigamma( 10, 5:1 ),
                         VP = psigamma( 10:6, 5 )))
    }

    test.sugar.sum <- function(){
        fx <- runit_sum
        x <- rnorm( 10 )
        checkEquals( fx(x), sum(x) )
        x[4] <- NA
        checkEquals( fx(x), sum(x) )
    }

    test.sugar.cumsum <- function(){
        fx <- runit_cumsum
        x <- rnorm( 10 )
        checkEquals( fx(x), cumsum(x) )
        x[4] <- NA
        checkEquals( fx(x), cumsum(x) )
    }

    test.sugar.asvector <- function(){
        fx <- runit_asvector
        res <- fx( 1:4, 1:5, diag( 1:5 ) )
        checkEquals( res[[1]], as.vector( diag(1:5) ) )
        checkEquals( res[[2]], as.vector( outer( 1:4, 1:5, "+" ) ) )
    }

    test.sugar.asvector <- function(){
        fx <- runit_diff_REALSXP_NA
        x <- c( NA, 1.5, 2.5, NA, 3.5, 5.5, NA )
        checkEquals( fx(x), c(NA, 1.0, NA, NA, 2.0, NA) )
    }

                                        # additions 03 Sep 2012
    test.sugar.trunc <- function() {
        fx <- runit_trunc
        x <- seq(-5,5) + 0.5
        y <- seq(-5L, 5L)
        checkEquals(fx(x, y), list(trunc(x), trunc(y)))
    }
    test.sugar.round <- function() {
        fx <- runit_round
        x <- seq(-5,5) + 0.25
        checkEquals( fx(x, 0), round(x, 0) )
        checkEquals( fx(x, 1), round(x, 1) )
        checkEquals( fx(x, 2), round(x, 2) )
        checkEquals( fx(x, 3), round(x, 3) )
    }
    test.sugar.signif <- function() {
        fx <- runit_signif
        x <- seq(-5,5) + 0.25
        checkEquals( fx(x, 0), signif(x, 0) )
        checkEquals( fx(x, 1), signif(x, 1) )
        checkEquals( fx(x, 2), signif(x, 2) )
        checkEquals( fx(x, 3), signif(x, 3) )
    }

    test.RangeIndexer <- function(){
        x <- rnorm(10)
        checkEquals( runit_RangeIndexer(x), max(x[1:5]) )
    }

    test.self_match <- function(){
        x <- sample( letters, 1000, replace = TRUE )
        checkEquals( runit_self_match(x), match(x,unique(x)) )
    }

    test.unique <- function() {
        x <- sample(LETTERS[1:5], 10, TRUE)
        checkEquals(
            sort(unique(x)),
            sort(runit_unique_ch(x)),
            "unique / character / without NA"
        )

        x <- c(x, NA, NA)
        checkEquals(
            sort(unique(x), na.last = TRUE),
            sort(runit_unique_ch(x), na.last = TRUE),
            "unique / character / with NA"
        )

        x <- sample(1:5, 10, TRUE)
        checkEquals(
            sort(unique(x)),
            sort(runit_unique_int(x)),
            "unique / integer / without NA"
        )

        x <- c(x, NA, NA)
        checkEquals(
            sort(unique(x), na.last = TRUE),
            sort(runit_unique_int(x), na.last = TRUE),
            "unique / integer / with NA"
        )

        x <- sample(1:5 + 0.5, 10, TRUE)
        checkEquals(
            sort(unique(x)),
            sort(runit_unique_dbl(x)),
            "unique / numeric / without NA"
        )

        x <- c(x, NA, NA)
        checkEquals(
            sort(unique(x), na.last = TRUE),
            sort(runit_unique_dbl(x), na.last = TRUE),
            "unique / numeric / with NA"
        )
    }

    test.table <- function(){
        x <- sample( letters, 1000, replace = TRUE )
        checkTrue( all( runit_table(x) == table(x) ) )
        checkTrue( all( names(runit_table(x)) == names(table(x)) ) )
    }

    test.duplicated <- function(){
        x <- sample( letters, 1000, replace = TRUE )
        checkEquals( runit_duplicated(x), duplicated(x) )
    }

    test.setdiff <- function(){
        checkEquals(sort(runit_setdiff( 1:10, 1:5 )), sort(setdiff( 1:10, 1:5)))
    }

    test.setequal <- function() {
        checkTrue(runit_setequal_integer(1:10, 10:1))
        checkTrue(runit_setequal_character(c("a", "b", "c"), c("c", "b", "a")))
        checkTrue(!runit_setequal_character(c("a", "b"), c("c")))
    }

    test.union <- function(){
        checkEquals(sort(runit_union( 1:10, 1:5 )), sort(union( 1:10, 1:5 )))
    }

    test.intersect <- function(){
        checkEquals(sort(runit_intersect(1:10, 1:5)), intersect(1:10, 1:5))
    }

    test.clamp <- function(){
        r_clamp <- function(a, x, b) pmax(a, pmin(x, b) )
        checkEquals(runit_clamp( -1, seq(-3,3, length=100), 1 ),
                    r_clamp( -1, seq(-3,3, length=100), 1 ))
    }

    test.vector.scalar.ops <- function( ){
        x <- rnorm(10)
        checkEquals(vector_scalar_ops(x), list(x + 2, 2 - x, x * 2, 2 / x), "sugar vector scalar operations")
    }

    test.vector.scalar.logical <- function( ){
        x <- rnorm(10) + 2
        checkEquals(vector_scalar_logical(x), list(x < 2, 2 > x, x <= 2, 2 != x),
                    "sugar vector scalar logical operations")
    }

    test.vector.vector.ops <- function( ){
        x <- rnorm(10)
        y <- runif(10)
        checkEquals(vector_vector_ops(x,y),
                    list(x + y, y - x, x * y, y / x),
                    "sugar vector vector operations")
    }

    test.vector.vector.logical <- function( ){
        x <- rnorm(10)
        y <- runif(10)
        checkEquals(vector_vector_logical(x,y),
                    list(x < y, x > y, x <= y, x >= y, x == y, x != y),
                    "sugar vector vector operations")
    }

    ## Additions made 1 Jan 2015

    test.mean.integer <- function() {
        v1 <- seq(-100L, 100L)
        v2 <- c(v1, NA)
        checkEquals(mean(v1), meanInteger(v1), "mean of integer vector")
        checkEquals(mean(v2), meanInteger(v2), "mean of integer vector with NA")
    }

    test.mean.numeric <- function() {
        v1 <- seq(-100, 100)
        v2 <- c(v1, NA)
        v3 <- c(v1, Inf)
        checkEquals(mean(v1), meanNumeric(v1), "mean of numeric vector")
        checkEquals(mean(v2), meanNumeric(v2), "mean of numeric vector with NA")
        checkEquals(mean(v3), meanNumeric(v3), "mean of numeric vector with Inf")
    }

    test.mean.complex <- function() {
        v1 <- seq(-100, 100)  + 1.0i
        v2 <- c(v1, NA)
        v3 <- c(v1, Inf)
        checkEquals(mean(v1), meanComplex(v1), "mean of complex vector")
        checkEquals(mean(v2), meanComplex(v2), "mean of complex vector with NA")
        checkEquals(mean(v3), meanComplex(v3), "mean of complex vector with Inf")
    }

    test.mean.logical <- function() {
        v1 <- c(rep(TRUE, 50), rep(FALSE, 25))
        v2 <- c(v1, NA)
        checkEquals(mean(v1), meanLogical(v1), "mean of logical vector")
        checkEquals(mean(v2), meanLogical(v2), "mean of logical vector with NA")
    }


    ## 30 Oct 2015: cumprod, cummin, cummax
    # base::cumprod defined for numeric, integer, and complex vectors
    test.sugar.cumprod_nv <- function() {
        fx <- runit_cumprod_nv
        x <- rnorm(10)
        checkEquals(fx(x), cumprod(x))
        x[4] <- NA
        checkEquals(fx(x), cumprod(x))
    }

    test.sugar.cumprod_iv <- function() {
        fx <- runit_cumprod_iv
        x <- as.integer(rpois(10, 5))
        checkEquals(fx(x), cumprod(x))
        x[4] <- NA
        checkEquals(fx(x), cumprod(x))
    }

    test.sugar.cumprod_cv <- function() {
        fx <- runit_cumprod_cv
        x <- rnorm(10) + 2i
        checkEquals(fx(x), cumprod(x))
        x[4] <- NA
        checkEquals(fx(x), cumprod(x))
    }

    # base::cummin defined for numeric and integer vectors
    test.sugar.cummin_nv <- function() {
        fx <- runit_cummin_nv
        x <- rnorm(10)
        checkEquals(fx(x), cummin(x))
        x[4] <- NA
        checkEquals(fx(x), cummin(x))
    }

    test.sugar.cummin_iv <- function() {
        fx <- runit_cummin_iv
        x <- as.integer(rpois(10, 5))
        checkEquals(fx(x), cummin(x))
        x[4] <- NA
        checkEquals(fx(x), cummin(x))
    }

    # base::cummax defined for numeric and integer vectors
    test.sugar.cummax_nv <- function() {
        fx <- runit_cummax_nv
        x <- rnorm(10)
        checkEquals(fx(x), cummax(x))
        x[4] <- NA
        checkEquals(fx(x), cummax(x))
    }

    test.sugar.cummax_iv <- function() {
        fx <- runit_cummax_iv
        x <- as.integer(rpois(10, 5))
        checkEquals(fx(x), cummax(x))
        x[4] <- NA
        checkEquals(fx(x), cummax(x))
    }


    ## 18 January 2016: median
    ## median of integer vector
    test.sugar.median_int <- function() {
        fx <- median_int

        x <- as.integer(rpois(5, 20))
        checkEquals(fx(x), median(x),
                    "median_int / odd length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x), median(x),
                    "median_int / odd length / with NA / na.rm = FALSE")

        checkEquals(fx(x, TRUE), median(x, TRUE),
                    "median_int / odd length / with NA / na.rm = TRUE")

        ##
        x <- as.integer(rpois(6, 20))
        checkEquals(fx(x), median(x),
                    "median_int / even length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x), median(x),
                    "median_int / even length / with NA / na.rm = FALSE")

        checkEquals(fx(x, TRUE), median(x, TRUE),
                    "median_int / even length / with NA / na.rm = TRUE")
    }

    ## median of numeric vector
    test.sugar.median_dbl <- function() {
        fx <- median_dbl

        x <- rnorm(5)
        checkEquals(fx(x), median(x),
                    "median_dbl / odd length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x), median(x),
                    "median_dbl / odd length / with NA / na.rm = FALSE")

        checkEquals(fx(x, TRUE), median(x, TRUE),
                    "median_dbl / odd length / with NA / na.rm = TRUE")

        ##
        x <- rnorm(6)
        checkEquals(fx(x), median(x),
                    "median_dbl / even length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x), median(x),
                    "median_dbl / even length / with NA / na.rm = FALSE")

        checkEquals(fx(x, TRUE), median(x, TRUE),
                    "median_dbl / even length / with NA / na.rm = TRUE")
    }

    ## median of complex vector
    test.sugar.median_cx <- function() {
        fx <- median_cx

        x <- rnorm(5) + 2i
        checkEquals(fx(x), median(x),
                    "median_cx / odd length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x), median(x),
                    "median_cx / odd length / with NA / na.rm = FALSE")

        checkEquals(fx(x, TRUE), median(x, TRUE),
                    "median_cx / odd length / with NA / na.rm = TRUE")

        ##
        x <- rnorm(6) + 2i
        checkEquals(fx(x), median(x),
                    "median_cx / even length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x), median(x),
                    "median_cx / even length / with NA / na.rm = FALSE")

        checkEquals(fx(x, TRUE), median(x, TRUE),
                    "median_cx / even length / with NA / na.rm = TRUE")
    }

    ## median of character vector
    test.sugar.median_ch <- function() {
        fx <- median_ch

        x <- sample(letters, 5)
        checkEquals(fx(x), median(x),
                    "median_ch / odd length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x), median(x),
                    "median_ch / odd length / with NA / na.rm = FALSE")

        ## median(x, TRUE) returns NA_real_ for character vector input
        ## which results in a warning; i.e. if the vector it passes to
        ## `mean.default(sort(x, partial = half + 0L:1L)[half + 0L:1L])`
        ## has ((length(x) %% 2) == 0)

        checkEquals(fx(x, TRUE),
                    as.character(suppressWarnings(median(x, TRUE))),
                    "median_ch / odd length / with NA / na.rm = TRUE")

        ##
        x <- sample(letters, 6)
        checkEquals(fx(x),
                    as.character(suppressWarnings(median(x))),
                    "median_ch / even length / no NA / na.rm = FALSE")

        x[4] <- NA
        checkEquals(fx(x),
                    as.character(suppressWarnings(median(x))),
                    "median_ch / even length / with NA / na.rm = FALSE")

        checkEquals(fx(x, TRUE),
                    as.character(suppressWarnings(median(x, TRUE))),
                    "median_ch / even length / with NA / na.rm = TRUE")
    }


    ## 12 March 2016
    ## cbind numeric tests
    test.sugar.cbind_numeric <- function() {

        m1 <- matrix(rnorm(9), 3, 3); m2 <- matrix(rnorm(9), 3, 3)
        v1 <- rnorm(3); v2 <- rnorm(3)
        s1 <- rnorm(1); s2 <- rnorm(1)

        cbind <- function(...) {
            base::cbind(..., deparse.level = 0)
        }

        checkEquals(n_cbind_mm(m1, m2), cbind(m1, m2),
                    "numeric cbind / matrix matrix")

        checkEquals(n_cbind_mv(m1, v1), cbind(m1, v1),
                    "numeric cbind / matrix vector")

        checkEquals(n_cbind_ms(m1, s1), cbind(m1, s1),
                    "numeric cbind / matrix scalar")

        checkEquals(n_cbind_vv(v1, v2), cbind(v1, v2),
                    "numeric cbind / vector vector")

        checkEquals(n_cbind_vm(v1, m1), cbind(v1, m1),
                    "numeric cbind / vector matrix")

        checkEquals(n_cbind_vs(v1, s1), cbind(v1, s1),
                    "numeric cbind / vector scalar")

        checkEquals(n_cbind_ss(s1, s2), cbind(s1, s2),
                    "numeric cbind / scalar scalar")

        checkEquals(n_cbind_sm(s1, m1), cbind(s1, m1),
                    "numeric cbind / scalar matrix")

        checkEquals(n_cbind_sv(s1, v1), cbind(s1, v1),
                    "numeric cbind / scalar vector")

        checkEquals(n_cbind9(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    cbind(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    "numeric cbind 9")

    }

    ## cbind integer tests
    test.sugar.cbind_integer <- function() {

        m1 <- matrix(rpois(9, 20), 3, 3); m2 <- matrix(rpois(9, 20), 3, 3)
        v1 <- rpois(3, 30); v2 <- rpois(3, 30)
        s1 <- rpois(1, 40); s2 <- rpois(1, 40)

        cbind <- function(...) {
            base::cbind(..., deparse.level = 0)
        }

        checkEquals(i_cbind_mm(m1, m2), cbind(m1, m2),
                    "integer cbind / matrix matrix")

        checkEquals(i_cbind_mv(m1, v1), cbind(m1, v1),
                    "integer cbind / matrix vector")

        checkEquals(i_cbind_ms(m1, s1), cbind(m1, s1),
                    "integer cbind / matrix scalar")

        checkEquals(i_cbind_vv(v1, v2), cbind(v1, v2),
                    "integer cbind / vector vector")

        checkEquals(i_cbind_vm(v1, m1), cbind(v1, m1),
                    "integer cbind / vector matrix")

        checkEquals(i_cbind_vs(v1, s1), cbind(v1, s1),
                    "integer cbind / vector scalar")

        checkEquals(i_cbind_ss(s1, s2), cbind(s1, s2),
                    "integer cbind / scalar scalar")

        checkEquals(i_cbind_sm(s1, m1), cbind(s1, m1),
                    "integer cbind / scalar matrix")

        checkEquals(i_cbind_sv(s1, v1), cbind(s1, v1),
                    "integer cbind / scalar vector")

        checkEquals(i_cbind9(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    cbind(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    "integer cbind 9")

    }

    ## cbind complex tests
    test.sugar.cbind_complex <- function() {

        m1 <- matrix(rnorm(9), 3, 3) + 2i
        m2 <- matrix(rnorm(9), 3, 3) + 5i
        v1 <- rnorm(3) + 3i; v2 <- rnorm(3) + 4i
        s1 <- rnorm(1) + 4i; s2 <- rnorm(1) + 5i

        cbind <- function(...) {
            base::cbind(..., deparse.level = 0)
        }

        checkEquals(cx_cbind_mm(m1, m2), cbind(m1, m2),
                    "complex cbind / matrix matrix")

        checkEquals(cx_cbind_mv(m1, v1), cbind(m1, v1),
                    "complex cbind / matrix vector")

        checkEquals(cx_cbind_ms(m1, s1), cbind(m1, s1),
                    "complex cbind / matrix scalar")

        checkEquals(cx_cbind_vv(v1, v2), cbind(v1, v2),
                    "complex cbind / vector vector")

        checkEquals(cx_cbind_vm(v1, m1), cbind(v1, m1),
                    "complex cbind / vector matrix")

        checkEquals(cx_cbind_vs(v1, s1), cbind(v1, s1),
                    "complex cbind / vector scalar")

        checkEquals(cx_cbind_ss(s1, s2), cbind(s1, s2),
                    "complex cbind / scalar scalar")

        checkEquals(cx_cbind_sm(s1, m1), cbind(s1, m1),
                    "complex cbind / scalar matrix")

        checkEquals(cx_cbind_sv(s1, v1), cbind(s1, v1),
                    "complex cbind / scalar vector")

        checkEquals(cx_cbind9(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    cbind(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    "complex cbind 9")

    }

    ## cbind logical tests
    test.sugar.cbind_logical <- function() {

        m1 <- matrix(as.logical(rbinom(9, 1, .5)), 3, 3)
        m2 <- matrix(as.logical(rbinom(9, 1, .5)), 3, 3)
        v1 <- as.logical(rbinom(3, 1, .5))
        v2 <- as.logical(rbinom(3, 1, .5))
        s1 <- as.logical(rbinom(1, 1, .5))
        s2 <- as.logical(rbinom(1, 1, .5))

        cbind <- function(...) {
            base::cbind(..., deparse.level = 0)
        }

        checkEquals(l_cbind_mm(m1, m2), cbind(m1, m2),
                    "logical cbind / matrix matrix")

        checkEquals(l_cbind_mv(m1, v1), cbind(m1, v1),
                    "logical cbind / matrix vector")

        checkEquals(l_cbind_ms(m1, s1), cbind(m1, s1),
                    "logical cbind / matrix scalar")

        checkEquals(l_cbind_vv(v1, v2), cbind(v1, v2),
                    "logical cbind / vector vector")

        checkEquals(l_cbind_vm(v1, m1), cbind(v1, m1),
                    "logical cbind / vector matrix")

        checkEquals(l_cbind_vs(v1, s1), cbind(v1, s1),
                    "logical cbind / vector scalar")

        checkEquals(l_cbind_ss(s1, s2), cbind(s1, s2),
                    "logical cbind / scalar scalar")

        checkEquals(l_cbind_sm(s1, m1), cbind(s1, m1),
                    "logical cbind / scalar matrix")

        checkEquals(l_cbind_sv(s1, v1), cbind(s1, v1),
                    "logical cbind / scalar vector")

        checkEquals(l_cbind9(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    cbind(m1, v1, s1, m2, v2, s2, m1, v1, s1),
                    "logical cbind 9")

    }

    ## cbind character tests
    test.sugar.cbind_character <- function() {

        m1 <- matrix(sample(letters, 9, TRUE), 3, 3)
        m2 <- matrix(sample(LETTERS, 9, TRUE), 3, 3)
        v1 <- sample(letters, 3, TRUE)
        v2 <- sample(LETTERS, 3, TRUE)

        cbind <- function(...) {
            base::cbind(..., deparse.level = 0)
        }

        checkEquals(c_cbind_mm(m1, m2), cbind(m1, m2),
                    "logical cbind / matrix matrix")

        checkEquals(c_cbind_mv(m1, v1), cbind(m1, v1),
                    "logical cbind / matrix vector")

        checkEquals(c_cbind_vv(v1, v2), cbind(v1, v2),
                    "logical cbind / vector vector")

        checkEquals(c_cbind_vm(v1, m1), cbind(v1, m1),
                    "logical cbind / vector matrix")

        checkEquals(c_cbind6(m1, v1, m2, v2, m1, v1),
                    cbind(m1, v1, m2, v2, m1, v1),
                    "character cbind 6")

    }


    ## 04 September 2016
    ## {row,col}{Sums,Means} numeric tests
    test.sugar.rowMeans_numeric <- function() {

        x <- matrix(rnorm(9), 3)

        checkEquals(
            dbl_row_sums(x), rowSums(x),
            "numeric / rowSums / keep NA / clean input"
        )
        checkEquals(
            dbl_row_sums(x, TRUE), rowSums(x, TRUE),
            "numeric / rowSums / rm NA / clean input"
        )

        checkEquals(
            dbl_col_sums(x), colSums(x),
            "numeric / colSums / keep NA / clean input"
        )
        checkEquals(
            dbl_col_sums(x, TRUE), colSums(x, TRUE),
            "numeric / colSums / rm NA / clean input"
        )

        checkEquals(
            dbl_row_means(x), rowMeans(x),
            "numeric / rowMeans / keep NA / clean input"
        )
        checkEquals(
            dbl_row_means(x, TRUE), rowMeans(x, TRUE),
            "numeric / rowMeans / rm NA / clean input"
        )

        checkEquals(
            dbl_col_means(x), colMeans(x),
            "numeric / colMeans / keep NA / clean input"
        )
        checkEquals(
            dbl_col_means(x, TRUE), colMeans(x, TRUE),
            "numeric / colMeans / rm NA / clean input"
        )


        x[sample(1:9, 4)] <- NA

        checkEquals(
            dbl_row_sums(x), rowSums(x),
            "numeric / rowSums / keep NA / mixed input"
        )
        checkEquals(
            dbl_row_sums(x, TRUE), rowSums(x, TRUE),
            "numeric / rowSums / rm NA / mixed input"
        )

        checkEquals(
            dbl_col_sums(x), colSums(x),
            "numeric / colSums / keep NA / mixed input"
        )
        checkEquals(
            dbl_col_sums(x, TRUE), colSums(x, TRUE),
            "numeric / colSums / rm NA / mixed input"
        )

        checkEquals(
            dbl_row_means(x), rowMeans(x),
            "numeric / rowMeans / keep NA / mixed input"
        )
        checkEquals(
            dbl_row_means(x, TRUE), rowMeans(x, TRUE),
            "numeric / rowMeans / rm NA / mixed input"
        )

        checkEquals(
            dbl_col_means(x), colMeans(x),
            "numeric / colMeans / keep NA / mixed input"
        )
        checkEquals(
            dbl_col_means(x, TRUE), colMeans(x, TRUE),
            "numeric / colMeans / rm NA / mixed input"
        )


        x[] <- NA_real_

        checkEquals(
            dbl_row_sums(x), rowSums(x),
            "numeric / rowSums / keep NA / dirty input"
        )
        checkEquals(
            dbl_row_sums(x, TRUE), rowSums(x, TRUE),
            "numeric / rowSums / rm NA / dirty input"
        )

        checkEquals(
            dbl_col_sums(x), colSums(x),
            "numeric / colSums / keep NA / dirty input"
        )
        checkEquals(
            dbl_col_sums(x, TRUE), colSums(x, TRUE),
            "numeric / colSums / rm NA / dirty input"
        )

        checkEquals(
            dbl_row_means(x), rowMeans(x),
            "numeric / rowMeans / keep NA / dirty input"
        )
        checkEquals(
            dbl_row_means(x, TRUE), rowMeans(x, TRUE),
            "numeric / rowMeans / rm NA / dirty input"
        )

        checkEquals(
            dbl_col_means(x), colMeans(x),
            "numeric / colMeans / keep NA / dirty input"
        )
        checkEquals(
            dbl_col_means(x, TRUE), colMeans(x, TRUE),
            "numeric / colMeans / rm NA / dirty input"
        )

    }


    ## {row,col}{Sums,Means} integer tests
    test.sugar.rowMeans_integer <- function() {

        x <- matrix(as.integer(rnorm(9) * 1e4), 3)

        checkEquals(
            int_row_sums(x), rowSums(x),
            "integer / rowSums / keep NA / clean input"
        )
        checkEquals(
            int_row_sums(x, TRUE), rowSums(x, TRUE),
            "integer / rowSums / rm NA / clean input"
        )

        checkEquals(
            int_col_sums(x), colSums(x),
            "integer / colSums / keep NA / clean input"
        )
        checkEquals(
            int_col_sums(x, TRUE), colSums(x, TRUE),
            "integer / colSums / rm NA / clean input"
        )

        checkEquals(
            int_row_means(x), rowMeans(x),
            "integer / rowMeans / keep NA / clean input"
        )
        checkEquals(
            int_row_means(x, TRUE), rowMeans(x, TRUE),
            "integer / rowMeans / rm NA / clean input"
        )

        checkEquals(
            int_col_means(x), colMeans(x),
            "integer / colMeans / keep NA / clean input"
        )
        checkEquals(
            int_col_means(x, TRUE), colMeans(x, TRUE),
            "integer / colMeans / rm NA / clean input"
        )


        x[sample(1:9, 4)] <- NA

        checkEquals(
            int_row_sums(x), rowSums(x),
            "integer / rowSums / keep NA / mixed input"
        )
        checkEquals(
            int_row_sums(x, TRUE), rowSums(x, TRUE),
            "integer / rowSums / rm NA / mixed input"
        )

        checkEquals(
            int_col_sums(x), colSums(x),
            "integer / colSums / keep NA / mixed input"
        )
        checkEquals(
            int_col_sums(x, TRUE), colSums(x, TRUE),
            "integer / colSums / rm NA / mixed input"
        )

        checkEquals(
            int_row_means(x), rowMeans(x),
            "integer / rowMeans / keep NA / mixed input"
        )
        checkEquals(
            int_row_means(x, TRUE), rowMeans(x, TRUE),
            "integer / rowMeans / rm NA / mixed input"
        )

        checkEquals(
            int_col_means(x), colMeans(x),
            "integer / colMeans / keep NA / mixed input"
        )
        checkEquals(
            int_col_means(x, TRUE), colMeans(x, TRUE),
            "integer / colMeans / rm NA / mixed input"
        )


        x[] <- NA_integer_

        checkEquals(
            int_row_sums(x), rowSums(x),
            "integer / rowSums / keep NA / dirty input"
        )
        checkEquals(
            int_row_sums(x, TRUE), rowSums(x, TRUE),
            "integer / rowSums / rm NA / dirty input"
        )

        checkEquals(
            int_col_sums(x), colSums(x),
            "integer / colSums / keep NA / dirty input"
        )
        checkEquals(
            int_col_sums(x, TRUE), colSums(x, TRUE),
            "integer / colSums / rm NA / dirty input"
        )

        checkEquals(
            int_row_means(x), rowMeans(x),
            "integer / rowMeans / keep NA / dirty input"
        )
        checkEquals(
            int_row_means(x, TRUE), rowMeans(x, TRUE),
            "integer / rowMeans / rm NA / dirty input"
        )

        checkEquals(
            int_col_means(x), colMeans(x),
            "integer / colMeans / keep NA / dirty input"
        )
        checkEquals(
            int_col_means(x, TRUE), colMeans(x, TRUE),
            "integer / colMeans / rm NA / dirty input"
        )

    }


    ## {row,col}{Sums,Means} logical tests
    test.sugar.rowMeans_logical <- function() {

        x <- matrix(rbinom(9, 1, .5) > 0, 3)

        checkEquals(
            lgl_row_sums(x), rowSums(x),
            "logical / rowSums / keep NA / clean input"
        )
        checkEquals(
            lgl_row_sums(x, TRUE), rowSums(x, TRUE),
            "logical / rowSums / rm NA / clean input"
        )

        checkEquals(
            lgl_col_sums(x), colSums(x),
            "logical / colSums / keep NA / clean input"
        )
        checkEquals(
            lgl_col_sums(x, TRUE), colSums(x, TRUE),
            "logical / colSums / rm NA / clean input"
        )

        checkEquals(
            lgl_row_means(x), rowMeans(x),
            "logical / rowMeans / keep NA / clean input"
        )
        checkEquals(
            lgl_row_means(x, TRUE), rowMeans(x, TRUE),
            "logical / rowMeans / rm NA / clean input"
        )

        checkEquals(
            lgl_col_means(x), colMeans(x),
            "logical / colMeans / keep NA / clean input"
        )
        checkEquals(
            lgl_col_means(x, TRUE), colMeans(x, TRUE),
            "logical / colMeans / rm NA / clean input"
        )


        x[sample(1:9, 4)] <- NA

        checkEquals(
            lgl_row_sums(x), rowSums(x),
            "logical / rowSums / keep NA / mixed input"
        )
        checkEquals(
            lgl_row_sums(x, TRUE), rowSums(x, TRUE),
            "logical / rowSums / rm NA / mixed input"
        )

        checkEquals(
            lgl_col_sums(x), colSums(x),
            "logical / colSums / keep NA / mixed input"
        )
        checkEquals(
            lgl_col_sums(x, TRUE), colSums(x, TRUE),
            "logical / colSums / rm NA / mixed input"
        )

        checkEquals(
            lgl_row_means(x), rowMeans(x),
            "logical / rowMeans / keep NA / mixed input"
        )
        checkEquals(
            lgl_row_means(x, TRUE), rowMeans(x, TRUE),
            "logical / rowMeans / rm NA / mixed input"
        )

        checkEquals(
            lgl_col_means(x), colMeans(x),
            "logical / colMeans / keep NA / mixed input"
        )
        checkEquals(
            lgl_col_means(x, TRUE), colMeans(x, TRUE),
            "logical / colMeans / rm NA / mixed input"
        )


        x[] <- NA_integer_

        checkEquals(
            lgl_row_sums(x), rowSums(x),
            "logical / rowSums / keep NA / dirty input"
        )
        checkEquals(
            lgl_row_sums(x, TRUE), rowSums(x, TRUE),
            "logical / rowSums / rm NA / dirty input"
        )

        checkEquals(
            lgl_col_sums(x), colSums(x),
            "logical / colSums / keep NA / dirty input"
        )
        checkEquals(
            lgl_col_sums(x, TRUE), colSums(x, TRUE),
            "logical / colSums / rm NA / dirty input"
        )

        checkEquals(
            lgl_row_means(x), rowMeans(x),
            "logical / rowMeans / keep NA / dirty input"
        )
        checkEquals(
            lgl_row_means(x, TRUE), rowMeans(x, TRUE),
            "logical / rowMeans / rm NA / dirty input"
        )

        checkEquals(
            lgl_col_means(x), colMeans(x),
            "logical / colMeans / keep NA / dirty input"
        )
        checkEquals(
            lgl_col_means(x, TRUE), colMeans(x, TRUE),
            "logical / colMeans / rm NA / dirty input"
        )

    }


    ## {row,col}{Sums,Means} complex tests
    test.sugar.rowMeans_complex <- function() {

        x <- matrix(rnorm(9) + 2i, 3)

        checkEquals(
            cx_row_sums(x), rowSums(x),
            "complex / rowSums / keep NA / clean input"
        )
        checkEquals(
            cx_row_sums(x, TRUE), rowSums(x, TRUE),
            "complex / rowSums / rm NA / clean input"
        )

        checkEquals(
            cx_col_sums(x), colSums(x),
            "complex / colSums / keep NA / clean input"
        )
        checkEquals(
            cx_col_sums(x, TRUE), colSums(x, TRUE),
            "complex / colSums / rm NA / clean input"
        )

        checkEquals(
            cx_row_means(x), rowMeans(x),
            "complex / rowMeans / keep NA / clean input"
        )
        checkEquals(
            cx_row_means(x, TRUE), rowMeans(x, TRUE),
            "complex / rowMeans / rm NA / clean input"
        )

        checkEquals(
            cx_col_means(x), colMeans(x),
            "complex / colMeans / keep NA / clean input"
        )
        checkEquals(
            cx_col_means(x, TRUE), colMeans(x, TRUE),
            "complex / colMeans / rm NA / clean input"
        )


        x[sample(1:9, 4)] <- NA

        checkEquals(
            cx_row_sums(x), rowSums(x),
            "complex / rowSums / keep NA / mixed input"
        )
        checkEquals(
            cx_row_sums(x, TRUE), rowSums(x, TRUE),
            "complex / rowSums / rm NA / mixed input"
        )

        checkEquals(
            cx_col_sums(x), colSums(x),
            "complex / colSums / keep NA / mixed input"
        )
        checkEquals(
            cx_col_sums(x, TRUE), colSums(x, TRUE),
            "complex / colSums / rm NA / mixed input"
        )

        checkEquals(
            cx_row_means(x), rowMeans(x),
            "complex / rowMeans / keep NA / mixed input"
        )
        checkEquals(
            cx_row_means(x, TRUE), rowMeans(x, TRUE),
            "complex / rowMeans / rm NA / mixed input"
        )

        checkEquals(
            cx_col_means(x), colMeans(x),
            "complex / colMeans / keep NA / mixed input"
        )
        checkEquals(
            cx_col_means(x, TRUE), colMeans(x, TRUE),
            "complex / colMeans / rm NA / mixed input"
        )


        x[] <- NA_complex_

        checkEquals(
            cx_row_sums(x), rowSums(x),
            "complex / rowSums / keep NA / dirty input"
        )
        checkEquals(
            cx_row_sums(x, TRUE), rowSums(x, TRUE),
            "complex / rowSums / rm NA / dirty input"
        )

        checkEquals(
            cx_col_sums(x), colSums(x),
            "complex / colSums / keep NA / dirty input"
        )
        checkEquals(
            cx_col_sums(x, TRUE), colSums(x, TRUE),
            "complex / colSums / rm NA / dirty input"
        )

        checkEquals(
            cx_row_means(x), rowMeans(x),
            "complex / rowMeans / keep NA / dirty input"
        )
        checkEquals(
            cx_row_means(x, TRUE), rowMeans(x, TRUE),
            "complex / rowMeans / rm NA / dirty input"
        )

        checkEquals(
            cx_col_means(x), colMeans(x),
            "complex / colMeans / keep NA / dirty input"
        )
        checkEquals(
            cx_col_means(x, TRUE), colMeans(x, TRUE),
            "complex / colMeans / rm NA / dirty input"
        )

    }


    ## 10 December 2016
    ## sample.int tests
    test.sugar.sample_dot_int <- function() {

        set.seed(123); s1 <- sample_dot_int(10, 5)
        set.seed(123); s2 <- sample(10, 5)

        checkEquals(
            s1, s2,
            "sample.int / without replacement / without probability"
        )

        set.seed(123); s1 <- sample_dot_int(10, 5, TRUE)
        set.seed(123); s2 <- sample(10, 5, TRUE)

        checkEquals(
            s1, s2,
            "sample.int / with replacement / without probability"
        )


        px <- rep(c(3, 2, 1), length.out = 10)
        set.seed(123); s1 <- sample_dot_int(10, 5, FALSE, px)
        set.seed(123); s2 <- sample(10, 5, FALSE, px)

        checkEquals(
            s1, s2,
            "sample.int / without replacement / with probability"
        )

        set.seed(123); s1 <- sample_dot_int(10, 5, TRUE, px)
        set.seed(123); s2 <- sample(10, 5, TRUE, px)

        checkEquals(
            s1, s2,
            "sample.int / with replacement / with probability"
        )

    }


    ## sample_int tests
    test.sugar.sample_int <- function() {

        x <- as.integer(rpois(10, 10))
        px <- rep(c(3, 2, 1), length.out = 10)

        set.seed(123); s1 <- sample_int(x, 6)
        set.seed(123); s2 <- sample(x, 6)

        checkEquals(
            s1, s2,
            "sample_int / without replacement / without probability"
        )

        set.seed(123); s1 <- sample_int(x, 6, TRUE)
        set.seed(123); s2 <- sample(x, 6, TRUE)

        checkEquals(
            s1, s2,
            "sample_int / with replacement / without probability"
        )

        set.seed(123); s1 <- sample_int(x, 6, FALSE, px)
        set.seed(123); s2 <- sample(x, 6, FALSE, px)

        checkEquals(
            s1, s2,
            "sample_int / without replacement / with probability"
        )

        set.seed(123); s1 <- sample_int(x, 6, TRUE, px)
        set.seed(123); s2 <- sample(x, 6, TRUE, px)

        checkEquals(
            s1, s2,
            "sample_int / with replacement / with probability"
        )

    }


    ## sample_dbl tests
    test.sugar.sample_dbl <- function() {

        x <- rnorm(10)
        px <- rep(c(3, 2, 1), length.out = 10)

        set.seed(123); s1 <- sample_dbl(x, 6)
        set.seed(123); s2 <- sample(x, 6)

        checkEquals(
            s1, s2,
            "sample_dbl / without replacement / without probability"
        )

        set.seed(123); s1 <- sample_dbl(x, 6, TRUE)
        set.seed(123); s2 <- sample(x, 6, TRUE)

        checkEquals(
            s1, s2,
            "sample_dbl / with replacement / without probability"
        )

        set.seed(123); s1 <- sample_dbl(x, 6, FALSE, px)
        set.seed(123); s2 <- sample(x, 6, FALSE, px)

        checkEquals(
            s1, s2,
            "sample_dbl / without replacement / with probability"
        )

        set.seed(123); s1 <- sample_dbl(x, 6, TRUE, px)
        set.seed(123); s2 <- sample(x, 6, TRUE, px)

        checkEquals(
            s1, s2,
            "sample_dbl / with replacement / with probability"
        )

    }


    ## sample_chr tests
    test.sugar.sample_chr <- function() {

        x <- sample(letters, 10)
        px <- rep(c(3, 2, 1), length.out = 10)

        set.seed(123); s1 <- sample_chr(x, 6)
        set.seed(123); s2 <- sample(x, 6)

        checkEquals(
            s1, s2,
            "sample_chr / without replacement / without probability"
        )

        set.seed(123); s1 <- sample_chr(x, 6, TRUE)
        set.seed(123); s2 <- sample(x, 6, TRUE)

        checkEquals(
            s1, s2,
            "sample_chr / with replacement / without probability"
        )

        set.seed(123); s1 <- sample_chr(x, 6, FALSE, px)
        set.seed(123); s2 <- sample(x, 6, FALSE, px)

        checkEquals(
            s1, s2,
            "sample_chr / without replacement / with probability"
        )

        set.seed(123); s1 <- sample_chr(x, 6, TRUE, px)
        set.seed(123); s2 <- sample(x, 6, TRUE, px)

        checkEquals(
            s1, s2,
            "sample_chr / with replacement / with probability"
        )

    }


    ## sample_cx tests
    test.sugar.sample_cx <- function() {

        x <- rnorm(10) + 2i
        px <- rep(c(3, 2, 1), length.out = 10)

        set.seed(123); s1 <- sample_cx(x, 6)
        set.seed(123); s2 <- sample(x, 6)

        checkEquals(
            s1, s2,
            "sample_cx / without replacement / without probability"
        )

        set.seed(123); s1 <- sample_cx(x, 6, TRUE)
        set.seed(123); s2 <- sample(x, 6, TRUE)

        checkEquals(
            s1, s2,
            "sample_cx / with replacement / without probability"
        )

        set.seed(123); s1 <- sample_cx(x, 6, FALSE, px)
        set.seed(123); s2 <- sample(x, 6, FALSE, px)

        checkEquals(
            s1, s2,
            "sample_cx / without replacement / with probability"
        )

        set.seed(123); s1 <- sample_cx(x, 6, TRUE, px)
        set.seed(123); s2 <- sample(x, 6, TRUE, px)

        checkEquals(
            s1, s2,
            "sample_cx / with replacement / with probability"
        )

    }


    ## sample_lgl tests
    test.sugar.sample_lgl <- function() {

        x <- rbinom(10, 1, 0.5) > 0
        px <- rep(c(3, 2, 1), length.out = 10)

        set.seed(123); s1 <- sample_lgl(x, 6)
        set.seed(123); s2 <- sample(x, 6)

        checkEquals(
            s1, s2,
            "sample_lgl / without replacement / without probability"
        )

        set.seed(123); s1 <- sample_lgl(x, 6, TRUE)
        set.seed(123); s2 <- sample(x, 6, TRUE)

        checkEquals(
            s1, s2,
            "sample_lgl / with replacement / without probability"
        )

        set.seed(123); s1 <- sample_lgl(x, 6, FALSE, px)
        set.seed(123); s2 <- sample(x, 6, FALSE, px)

        checkEquals(
            s1, s2,
            "sample_lgl / without replacement / with probability"
        )

        set.seed(123); s1 <- sample_lgl(x, 6, TRUE, px)
        set.seed(123); s2 <- sample(x, 6, TRUE, px)

        checkEquals(
            s1, s2,
            "sample_lgl / with replacement / with probability"
        )

    }


    ## sample_list tests
    test.sugar.sample_list <- function() {

        x <- list(
            letters,
            1:5,
            rnorm(10),
            state.abb,
            state.area,
            state.center,
            matrix(1:9, 3),
            mtcars,
            AirPassengers,
            BJsales
        )
        px <- rep(c(3, 2, 1), length.out = 10)

        set.seed(123); s1 <- sample_list(x, 6)
        set.seed(123); s2 <- sample(x, 6)

        checkEquals(
            s1, s2,
            "sample_list / without replacement / without probability"
        )

        set.seed(123); s1 <- sample_list(x, 6, TRUE)
        set.seed(123); s2 <- sample(x, 6, TRUE)

        checkEquals(
            s1, s2,
            "sample_list / with replacement / without probability"
        )

        set.seed(123); s1 <- sample_list(x, 6, FALSE, px)
        set.seed(123); s2 <- sample(x, 6, FALSE, px)

        checkEquals(
            s1, s2,
            "sample_list / without replacement / with probability"
        )

        set.seed(123); s1 <- sample_list(x, 6, TRUE, px)
        set.seed(123); s2 <- sample(x, 6, TRUE, px)

        checkEquals(
            s1, s2,
            "sample_list / with replacement / with probability"
        )

    }


    ## 31 January 2017
    ## upper_tri tests
    test.sugar.upper_tri <- function() {

        x <- matrix(rnorm(9), 3)

        checkEquals(
            UpperTri(x), upper.tri(x),
            "upper_tri / symmetric / diag = FALSE"
        )

        checkEquals(
            UpperTri(x, TRUE), upper.tri(x, TRUE),
            "upper_tri / symmetric / diag = TRUE"
        )

        x <- matrix(rnorm(12), 3)

        checkEquals(
            UpperTri(x), upper.tri(x),
            "upper_tri / [3 x 4] / diag = FALSE"
        )

        checkEquals(
            UpperTri(x, TRUE), upper.tri(x, TRUE),
            "upper_tri / [3 x 4] / diag = TRUE"
        )

        x <- matrix(rnorm(12), 4)

        checkEquals(
            UpperTri(x), upper.tri(x),
            "upper_tri / [4 x 3] / diag = FALSE"
        )

        checkEquals(
            UpperTri(x, TRUE), upper.tri(x, TRUE),
            "upper_tri / [4 x 3] / diag = TRUE"
        )

    }


    ## lower_tri tests
    test.sugar.lower_tri <- function() {

        x <- matrix(rnorm(9), 3)

        checkEquals(
            LowerTri(x), lower.tri(x),
            "lower_tri / symmetric / diag = FALSE"
        )

        checkEquals(
            LowerTri(x, TRUE), lower.tri(x, TRUE),
            "lower_tri / symmetric / diag = TRUE"
        )

        x <- matrix(rnorm(12), 3)

        checkEquals(
            LowerTri(x), lower.tri(x),
            "lower_tri / [3 x 4] / diag = FALSE"
        )

        checkEquals(
            LowerTri(x, TRUE), lower.tri(x, TRUE),
            "lower_tri / [3 x 4] / diag = TRUE"
        )

        x <- matrix(rnorm(12), 4)

        checkEquals(
            LowerTri(x), lower.tri(x),
            "lower_tri / [4 x 3] / diag = FALSE"
        )

        checkEquals(
            LowerTri(x, TRUE), lower.tri(x, TRUE),
            "lower_tri / [4 x 3] / diag = TRUE"
        )

    }


    ## 22 April 2017
    ## trimws -- vector
    test.sugar.vtrimws <- function() {

        x <- c(
            "  a b c", "a b c  ", "  a b c  ",
            "\t\ta b c", "a b c\t\t", "\t\ta b c\t\t",
            "\r\ra b c", "a b c\r\r", "\r\ra b c\r\r",
            "\n\na b c", "a b c\n\n", "\n\na b c\n\n",
            NA, "", " ", "  \t\r\n  ", "\n \t \r "
        )

        checkEquals(
            vtrimws(x), trimws(x),
            "vtrimws / which = 'both'"
        )

        checkEquals(
            vtrimws(x, 'l'), trimws(x, 'l'),
            "vtrimws / which = 'left'"
        )

        checkEquals(
            vtrimws(x, 'r'), trimws(x, 'r'),
            "vtrimws / which = 'right'"
        )

        checkException(
            vtrimws(x, "invalid"),
            msg = "vtrimws -- bad `which` argument"
        )

    }


    ## trimws -- matrix
    test.sugar.mtrimws <- function() {

        x <- c(
            "  a b c", "a b c  ", "  a b c  ",
            "\t\ta b c", "a b c\t\t", "\t\ta b c\t\t",
            "\r\ra b c", "a b c\r\r", "\r\ra b c\r\r",
            "\n\na b c", "a b c\n\n", "\n\na b c\n\n",
            NA, "", " ", "  \t\r\n  ", "\n \t \r "
        )
        x <- matrix(x, nrow = length(x), ncol = 4)

        checkEquals(
            mtrimws(x), trimws(x),
            "mtrimws / which = 'both'"
        )

        checkEquals(
            mtrimws(x, 'l'), trimws(x, 'l'),
            "mtrimws / which = 'left'"
        )

        checkEquals(
            mtrimws(x, 'r'), trimws(x, 'r'),
            "mtrimws / which = 'right'"
        )

        checkException(
            mtrimws(x, "invalid"),
            msg = "mtrimws -- bad `which` argument"
        )

    }


    ## trimws -- String
    test.sugar.strimws <- function() {

        x <- c(
            "  a b c", "a b c  ", "  a b c  ",
            "\t\ta b c", "a b c\t\t", "\t\ta b c\t\t",
            "\r\ra b c", "a b c\r\r", "\r\ra b c\r\r",
            "\n\na b c", "a b c\n\n", "\n\na b c\n\n",
            NA, "", " ", "  \t\r\n  ", "\n \t \r "
        )

        lhs <- vapply(
            x, strimws, character(1),
            USE.NAMES = FALSE
        )
        rhs <- vapply(
            x, trimws, character(1),
            USE.NAMES = FALSE
        )

        checkEquals(
            lhs, rhs,
            "strimws / which = 'both'"
        )

        lhs <- vapply(
            x, strimws, character(1),
            which = 'l', USE.NAMES = FALSE
        )
        rhs <- vapply(
            x, trimws, character(1),
            which = 'l', USE.NAMES = FALSE
        )

        checkEquals(
            lhs, rhs,
            "strimws / which = 'left'"
        )

        lhs <- vapply(
            x, strimws, character(1),
            which = 'r', USE.NAMES = FALSE
        )
        rhs <- vapply(
            x, trimws, character(1),
            which = 'r', USE.NAMES = FALSE
        )

        checkEquals(
            lhs, rhs,
            "strimws / which = 'right'"
        )

        checkException(
            strimws(x[1], "invalid"),
            msg = "strimws -- bad `which` argument"
        )

    }

}
