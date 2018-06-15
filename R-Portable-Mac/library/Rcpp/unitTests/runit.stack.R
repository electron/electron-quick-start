#!/usr/bin/env r
#
# Copyright (C) 2010 - 2017  Dirk Eddelbuettel and Romain Francois
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
.onLinux <- .Platform$OS.type == "unix" && unname(Sys.info()["sysname"]) == "Linux"

## As of release 0.12.15, the stack unwinding is experimental and not used
## See the #define in RcppCommon.h to change it

.runThisTest <- FALSE


if (.runThisTest) {

    .setUp <- Rcpp:::unitTestSetup("stack.cpp")

    # On old versions of R, Rcpp_fast_eval() falls back to Rcpp_eval() and
    # leaks on longjumps
    hasUnwind <- getRversion() >= "3.5.0"
    checkUnwound <- if (hasUnwind) checkTrue else function(x) checkTrue(!x)
    EvalUnwind <- function(expr, indicator) {
        testFastEval(expr, parent.frame(), indicator)
    }

    # Stack is always unwound on errors and interrupts
    test.stackUnwindsOnErrors <- function() {
        unwound <- FALSE
        out <- tryCatch(EvalUnwind(quote(stop("err")), unwound), error = identity)
        checkTrue(unwound)
        msg <- if (hasUnwind) "err" else "Evaluation error: err."
        checkIdentical(out$message, msg)
    }

    test.stackUnwindsOnInterrupts <- function() {
        unwound <- FALSE
        expr <- quote({
            repeat testSendInterrupt()
            "returned"
        })
        out <- tryCatch(EvalUnwind(expr, unwound), interrupt = function(c) "onintr")
        checkTrue(unwound)
        checkIdentical(out, "onintr")

    }

    test.stackUnwindsOnCaughtConditions <- function() {
        unwound <- FALSE
        expr <- quote(signalCondition(simpleCondition("cnd")))
        cnd <- tryCatch(EvalUnwind(expr, unwound), condition = identity)
        checkTrue(inherits(cnd, "simpleCondition"))
        checkUnwound(unwound)

    }

    test.stackUnwindsOnRestartJumps <- function() {
        unwound <- FALSE
        expr <- quote(invokeRestart("rst"))
        out <- withRestarts(EvalUnwind(expr, unwound), rst = function(...) "restarted")
        checkIdentical(out, "restarted")
        checkUnwound(unwound)

    }

    test.stackUnwindsOnReturns <- function() {
        unwound <- FALSE
        expr <- quote(signalCondition(simpleCondition(NULL)))
        out <- callCC(function(k) {
            withCallingHandlers(EvalUnwind(expr, unwound),
                simpleCondition = function(e) k("jumped")
            )
        })
        checkIdentical(out, "jumped")
        checkUnwound(unwound)

    }

    test.stackUnwindsOnReturnedConditions <- function() {
        unwound <- FALSE
        cnd <- simpleError("foo")
        out <- tryCatch(EvalUnwind(quote(cnd), unwound),
            error = function(c) "abort"
        )
        checkTrue(unwound)

        # The old mechanism cannot differentiate between a returned error and a
        # thrown error
        if (hasUnwind) {
            checkIdentical(out, cnd)
        } else {
            checkIdentical(out, "abort")
        }
    }
}
