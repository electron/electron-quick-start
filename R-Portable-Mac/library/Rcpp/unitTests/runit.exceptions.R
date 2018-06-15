#!/usr/bin/env r
# -*- mode: R; tab-width: 4; -*-
#
# Copyright (C) 2010 - 2013  Dirk Eddelbuettel and Romain Francois
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
    .setUp <- Rcpp:::unitTestSetup("exceptions.cpp")

test.stdException <- function() {

  # Code works normally without an exception
  checkIdentical(takeLog(1L), log(1L))

  # C++ exceptions are converted to R conditions
  condition <- tryCatch(takeLog(-1L), error = identity)

  checkIdentical(condition$message, "Inadmissible value")
  checkIdentical(class(condition), c("std::range_error", "C++Error", "error", "condition"))

  # C++ stack only available for Rcpp::exceptions
  checkTrue(is.null(condition$cppstack))

  checkIdentical(condition$call, quote(takeLog(-1L)))
}


test.rcppException <- function() {

  # Code works normally without an exception
  checkIdentical(takeLog(1L), log(1L))

  # C++ exceptions are converted to R conditions
  condition <- tryCatch(takeLogRcpp(-1L), error = identity)

  checkIdentical(condition$message, "Inadmissible value")
  checkIdentical(class(condition), c("Rcpp::exception", "C++Error", "error", "condition"))

  checkTrue(!is.null(condition$cppstack))

  checkIdentical(class(condition$cppstack), "Rcpp_stack_trace")

  checkEquals(condition$call, quote(takeLogRcpp(-1L)))
}

test.rcppStop <- function() {

  # Code works normally without an exception
  checkIdentical(takeLog(1L), log(1L))

  # C++ exceptions are converted to R conditions
  condition <- tryCatch(takeLogStop(-1L), error = identity)

  checkIdentical(condition$message, "Inadmissible value")
  checkIdentical(class(condition), c("Rcpp::exception", "C++Error", "error", "condition"))

  checkTrue(!is.null(condition$cppstack))

  checkIdentical(class(condition$cppstack), "Rcpp_stack_trace")

  checkEquals(condition$call, quote(takeLogStop(-1L)))
}

test.rcppExceptionLocation <- function() {

  # Code works normally without an exception
  checkIdentical(takeLog(1L), log(1L))

  # C++ exceptions are converted to R conditions
  condition <- tryCatch(takeLogRcppLocation(-1L), error = identity)

  checkIdentical(condition$message, "Inadmissible value")
  checkIdentical(class(condition), c("Rcpp::exception", "C++Error", "error", "condition"))

  checkTrue(!is.null(condition$cppstack))
  checkIdentical(class(condition$cppstack), "Rcpp_stack_trace")

  checkIdentical(condition$cppstack$file, "exceptions.cpp")
  checkIdentical(condition$cppstack$line, 44L)

  checkEquals(condition$call, quote(takeLogRcppLocation(-1L)))
}

test.rcppExceptionLocation <- function() {

  # Nested exceptions work the same way
  normal <- tryCatch(takeLogRcppLocation(-1L), error = identity)
  f1 <- function(x) takeLogNested(x)

  nested <- tryCatch(f1(-1), error = identity)

  # Message the same
  checkIdentical(normal$message, nested$message)

  checkEquals(nested$call, quote(takeLogNested(x)))
}

test.rcppExceptionNoCall <- function() {

  # Can throw exceptions that don't include a call stack
  e <- tryCatch(noCall(), error = identity)

  checkIdentical(e$message, "Testing")
  checkIdentical(e$call, NULL)
  checkIdentical(e$cppstack, NULL)
  checkIdentical(class(e), c("Rcpp::exception", "C++Error", "error", "condition"))
}
}
