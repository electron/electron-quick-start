#!/usr/bin/r -t
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

    .setUp <- Rcpp:::unitTestSetup("algorithm.cpp")

    test.sum <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(sum(v), sumTest(v, 1, 5))
        v <- c(NA, 1.0, 2.0, 3.0, 4.0)
	checkEquals(sum(v), sumTest(v, 1, 5))
    }

    test.sum.nona <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(sum(v), sumTest_nona(v, 1, 5))
    }

    test.prod <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(prod(v), prodTest(v, 1, 5))
        v <- c(NA, 1.0, 2.0, 3.0, 4.0)
        checkEquals(prod(v), prodTest(v, 1, 5))
    }

    test.prod.nona <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(prod(v), prodTest_nona(v, 1, 5))
    }

    test.log <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(log(v), logTest(v))
        v <- c(NA, 1.0, 2.0, 3.0, 4.0)
	checkEquals(log(v), logTest(v))
    }

    test.exp <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(exp(v), expTest(v))
        v <- c(NA, 1.0, 2.0, 3.0, 4.0)
        checkEquals(exp(v), expTest(v))
    }

    test.sqrt <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(sqrt(v), sqrtTest(v))
        v <- c(NA, 1.0, 2.0, 3.0, 4.0)
        checkEquals(sqrt(v), sqrtTest(v))
    }

    test.min <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(min(v), minTest(v))
        v <- c(NA, 1.0, 2.0, 3.0, 4.0)
        checkEquals(min(v), minTest(v))
    }

    test.min.nona <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(min(v), minTest_nona(v))
    }

    test.min.int <- function() {
	v <- c(1, 2, 3, 4, 5)
        checkEquals(min(v), minTest_int(v))
        v <- c(NA, 1, 2, 3, 4)
        checkEquals(min(v), minTest_int(v))
    }

    test.min.int.nona <- function() {
        v <- c(1, 2, 3, 4, 5)
        checkEquals(min(v), minTest_int_nona(v))
    }

    test.max <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(max(v), maxTest(v))
        v <- c(NA, 1.0, 2.0, 3.0, 4.0)
        checkEquals(max(v), maxTest(v))
    }

    test.max.nona <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(max(v), maxTest_nona(v))
    }

    test.max.int <- function() {
	v <- c(1, 2, 3, 4, 5)
        checkEquals(max(v), maxTest_int(v))
        v <- c(NA, 1, 2, 3, 4)
        checkEquals(max(v), maxTest_int(v))
    }

    test.max.int.nona <- function() {
        v <- c(1, 2, 3, 4, 5)
        checkEquals(max(v), maxTest_int_nona(v))
    }

    test.mean <- function() {
        v <- c(1.0, 2.0, 3.0, 4.0, 5.0)
        checkEquals(mean(v), meanTest(v))
        v <- c(1.0, 2.0, 3.0, 4.0, NA)
        checkEquals(mean(v), meanTest(v))
        v <- c(1.0, 2.0, 3.0, 4.0, NaN)
        checkEquals(mean(v), meanTest(v))
        v <- c(1.0, 2.0, 3.0, 4.0, 1.0/0.0)
        checkEquals(mean(v), meanTest(v))
        v <- c(1.0, 2.0, 3.0, 4.0, -1.0/0.0)
        checkEquals(mean(v), meanTest(v))
        v <- c(1.0, 2.0, 1.0/0.0, NA, NaN)
        checkEquals(mean(v), meanTest(v))
        v <- c(1.0, 2.0, 1.0/0.0, NaN, NA)
    }

    test.mean.int <- function() {
        v <- c(1, 2, 3, 4, 5)
        checkEquals(mean(v), meanTest_int(v))
        v <- c(1, 2, 3, 4, NA)
        checkEquals(mean(v), meanTest_int(v))
    }

    test.mean.logical <- function() {
        v <- c(TRUE, FALSE, FALSE)
        checkEquals(mean(v), meanTest_logical(v))
        v <- c(TRUE, FALSE, FALSE, NA)
        checkEquals(mean(v), meanTest_logical(v))
    }
}
