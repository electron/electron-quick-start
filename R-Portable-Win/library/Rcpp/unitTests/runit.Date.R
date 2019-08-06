#!/usr/bin/env r
# -*- mode: R; tab-width: 4; -*-
#
# Copyright (C) 2010 - 2017   Dirk Eddelbuettel and Romain Francois
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

    .setUp <- Rcpp:::unitTestSetup("dates.cpp")

    test.Date.ctor.sexp <- function() {
        fun <- ctor_sexp
        d <- as.Date("2005-12-31"); checkEquals(fun(d), d, msg = "Date.ctor.sexp.1")
        d <- as.Date("1970-01-01"); checkEquals(fun(d), d, msg = "Date.ctor.sexp.2")
        d <- as.Date("1969-12-31"); checkEquals(fun(d), d, msg = "Date.ctor.sexp.3")
        d <- as.Date("1954-07-04"); checkEquals(fun(d), d, msg = "Date.ctor.sexp.4") # cf 'Miracle of Berne' ;-)
        d <- as.Date("1789-07-14"); checkEquals(fun(d), d, msg = "Date.ctor.sexp.5") # cf 'Quatorze Juillet' ;-)
    }

    test.Date.ctor.notFinite <- function() {
        fun <- ctor_sexp
        checkEquals(fun(NA),  as.Date(NA,  origin="1970-01-01"), msg = "Date.ctor.na")
        checkEquals(fun(NaN), as.Date(NaN, origin="1970-01-01"), msg = "Date.ctor.nan")
        checkEquals(fun(Inf), as.Date(Inf, origin="1970-01-01"), msg = "Date.ctor.inf")
    }

    test.Date.ctor.diffs <- function() {
        fun <- ctor_sexp
        now <- Sys.Date()
        checkEquals(as.numeric(difftime(fun(now+0.025),  fun(now), units="days")), 0.025, msg = "Date.ctor.diff.0025")
        checkEquals(as.numeric(difftime(fun(now+0.250),  fun(now), units="days")), 0.250, msg = "Date.ctor.diff.0250")
        checkEquals(as.numeric(difftime(fun(now+2.500),  fun(now), units="days")), 2.500, msg = "Date.ctor.diff.2500")
    }

    test.Date.ctor.mdy <- function() {
        checkEquals(ctor_mdy(), as.Date("2005-12-31"), msg = "Date.ctor.mdy")
    }

    test.Date.ctor.ymd <- function() {
        checkEquals(ctor_ymd(), as.Date("2005-12-31"), msg = "Date.ctor.ymd")
    }

    test.Date.ctor.int <- function() {
        fun <- ctor_int
        d <- as.Date("2005-12-31")
        checkEquals(fun(as.numeric(d)), d, msg = "Date.ctor.int")
        checkEquals(fun(-1), as.Date("1970-01-01")-1, msg = "Date.ctor.int")
        checkException(fun("foo"), msg = "Date.ctor -> exception" )
    }

    test.Date.ctor.string <- function() {
        fun <- ctor_string
        dtstr <- "1991-02-03"
        dtfun <- fun(dtstr)
        dtstr <- as.Date(strptime(dtstr, "%Y-%m-%d"))
        ddstr <- as.Date(dtstr, "%Y-%m-%d")
        checkEquals(dtfun, dtstr, msg = "Date.fromString.strptime")
        checkEquals(dtfun, ddstr, msg = "Date.fromString.asDate")
    }

    test.Date.operators <- function() {
        checkEquals(operators(),
                    list(diff=-1, bigger=TRUE, smaller=FALSE, equal=FALSE, ge=TRUE, le=FALSE, ne=TRUE),
                    msg = "Date.operators")
    }

    test.Date.components <- function() {
        checkEquals(components(),
                    list(day=31, month=12, year=2005, weekday=7, yearday=365),
                    msg = "Date.components")
    }

    test.vector.Date <- function(){
        checkEquals(vector_Date(), rep(as.Date("2005-12-31"),2), msg = "Date.vector.wrap")
    }

    test.DateVector.wrap <- function(){
        checkEquals(Datevector_wrap(), rep(as.Date("2005-12-31"),2), msg = "DateVector.wrap")
    }

    test.DateVector.operator.SEXP <- function(){
        checkEquals(Datevector_sexp(), rep(as.Date("2005-12-31"),2), msg = "DateVector.SEXP")
    }

    test.Date.getFunctions <- function(){
        fun <- Date_get_functions
        checkEquals(fun(as.Date("2010-12-04")),
                    list(year=2010, month=12, day=4, wday=7, yday=338), msg = "Date.get.functions.1")
        checkEquals(fun(as.Date("2010-01-01")),
                    list(year=2010, month=1, day=1, wday=6, yday=1), msg = "Date.get.functions.2")
        checkEquals(fun(as.Date("2009-12-31")),
                    list(year=2009, month=12, day=31, wday=5, yday=365), msg = "Date.get.functions.3")
    }

    test.Datetime.get.functions <- function() {
        fun <- Datetime_get_functions
        checkEquals(fun(as.numeric(as.POSIXct("2001-02-03 01:02:03.123456", tz="UTC"))),
                    list(year=2001, month=2, day=3, wday=7, hour=1, minute=2, second=3, microsec=123456),
                    msg = "Datetime.get.functions")
    }

    test.Datetime.operators <- function() {
        checkEquals(Datetime_operators(),
                    list(diff=-60*60, bigger=TRUE, smaller=FALSE, equal=FALSE, ge=TRUE, le=FALSE, ne=TRUE),
                    msg = "Datetime.operators")
    }

    test.Datetime.wrap <- function() {
        checkEquals(as.numeric(Datetime_wrap()), as.numeric(as.POSIXct("2001-02-03 01:02:03.123456", tz="UTC")),
                    msg = "Datetime.wrap")
    }

    test.Datetime.fromString <- function() {
        fun <- Datetime_from_string
        dtstr <- "1991-02-03 04:05:06.789"
        dtfun <- fun(dtstr)
        dtstr <- as.POSIXct(strptime(dtstr, "%Y-%m-%d %H:%M:%OS"))
        checkEquals(as.numeric(dtfun), as.numeric(dtstr), msg = "Datetime.fromString")
    }

    ## TZ difference ...
    ##test.Datetime.ctor <- function() {
    ##    fun <- .Rcpp.Date$Datetime_ctor_sexp
    ##    checkEquals(fun(1234567),  as.POSIXct(1234567,  origin="1970-01-01"), msg = "Datetime.ctor.1")
    ##    checkEquals(fun(-120.25),  as.POSIXct(-120.5,   origin="1970-01-01"), msg = "Datetime.ctor.2")
    ##    checkEquals(fun( 120.25),  as.POSIXct( 120.25,  origin="1970-01-01"), msg = "Datetime.ctor.3")
    ##}

    test.Datetime.ctor.notFinite <- function() {
        fun <- Datetime_ctor_sexp
        posixtNA <- as.POSIXct(NA,  origin="1970-01-01")
        checkEquals(fun(NA),  posixtNA, msg = "Datetime.ctor.na")
        checkEquals(fun(NaN), posixtNA, msg = "Datetime.ctor.nan")
        checkEquals(fun(Inf), posixtNA, msg = "Datetime.ctor.inf")
    }

    test.Datetime.ctor.diffs <- function() {
        fun <- Datetime_ctor_sexp
        now <- Sys.time()
        ## first one is Ripley's fault as he decreed that difftime of POSIXct should stop at milliseconds
        checkEquals(round(as.numeric(difftime(fun(now+0.025),  fun(now), units="sec")), digits=4), 0.025, msg = "Datetime.ctor.diff.0025")
        checkEquals(as.numeric(difftime(fun(now+0.250),  fun(now), units="sec")), 0.250, msg = "Datetime.ctor.diff.0250")
        checkEquals(as.numeric(difftime(fun(now+2.500),  fun(now), units="sec")), 2.500, msg = "Datetime.ctor.diff.2500")
    }

    test.DatetimeVector.ctor <- function() {
        fun <- DatetimeVector_ctor
        now <- Sys.time()
        checkEquals(fun(now + (0:4)*60), now+(0:4)*60, msg = "Datetime.ctor.sequence")
        if (Rcpp:::capabilities()[["new date(time) vectors"]]) {
            vec <- c(now, NA, NaN, now+2.345)
            posixtNA <- as.POSIXct(NA,  origin="1970-01-01")
            checkEquals(fun(vec), c(now, rep(posixtNA, 2), now+2.345), msg = "Datetime.ctor.NA.NaN.set")
            vec <- c(now, -Inf, Inf, now+2.345)
            checkEquals(sum(is.finite(fun(vec))), 2, msg = "Datetime.ctor.Inf.finite.set")
            checkEquals(sum(is.infinite(fun(vec))), 2, msg = "Datetime.ctor.Inf.notfinite.set")
            vec <- c(now, NA, NaN, Inf, now+2.345)
            posixtNA <- as.POSIXct(NA, origin="1970-01-01")
            posixtInf <- as.POSIXct(Inf, origin="1970-01-01")
            checkEquals(fun(vec), c(now, rep(posixtNA, 2), posixtInf, now+2.345),
                        msg = "Datetime.ctor.NA.NaN.Inf.set")
        } else {
            vec <- c(now, NA, NaN, Inf, now+2.345)
            posixtNA <- as.POSIXct(NA, origin="1970-01-01")
            checkEquals(fun(vec), c(now, rep(posixtNA, 3), now+2.345), msg = "Datetime.ctor.NA.NaN.Inf.set")
        }
    }

    test.DatetimeVector.assignment <- function() {
        now <- Sys.time()
        v1 <- c(now, now + 1, now + 2)
        v2 <- c(now + 3, now + 4, now + 5)
        checkEquals(v2, DatetimeVector_assignment(v1, v2))
    }

    test.DateVector.assignment <- function() {
        now <- Sys.Date()
        v1 <- c(now, now + 1, now + 2)
        v2 <- c(now + 3, now + 4, now + 5)
        checkEquals(v2, DateVector_assignment(v1, v2))
    }


    ## formatting
    test.Date.formating <- function() {
        oldTZ <- Sys.getenv("TZ")
        Sys.setenv(TZ="America/Chicago")
        d <- as.Date("2011-12-13")

        checkEquals(Date_format(d, "%Y-%m-%d"),
                    format(d),
                    msg="Date.formating.default")
        checkEquals(Date_format(d, "%Y/%m/%d"),
                    format(d, "%Y/%m/%d"),
                    msg="Date.formating.given.format")
        checkEquals(Date_ostream(d),
                    format(d),
                    msg="Date.formating.ostream")

        Sys.setenv(TZ=oldTZ)
    }

    test.Datetime.formating <- function() {
        olddigits <- getOption("digits.secs")
        options("digits.secs"=6)

        d <- as.POSIXct("2016-12-13 14:15:16.123456")
        checkEquals(Datetime_format(d,"%Y-%m-%d %H:%M:%S"),
                    format(d, "%Y-%m-%d %H:%M:%OS"),
                    msg="Datetime.formating.default")
        checkEquals(Datetime_format(d, "%Y/%m/%d %H:%M:%S"),
                    format(d, "%Y/%m/%d %H:%M:%OS"),
                    msg="Datetime.formating.given.format")
        checkEquals(Datetime_ostream(d),
                    format(d, "%Y-%m-%d %H:%M:%OS"),
                    msg="Datetime.formating.ostream")

        options("digits.secs"=olddigits)
    }


    test.mktime_gmtime <- function() {
        d <- as.Date("2015-12-31")
        checkEquals(d, gmtime_mktime(d), msg="Date.mktime_gmtime.2015")

        d <- as.Date("1965-12-31")
        checkEquals(d, gmtime_mktime(d), msg="Date.mktime_gmtime.1965")
    }

    test.mktime <- function() {
        d <- as.Date("2015-12-31")
        checkEquals(test_mktime(d), as.numeric(as.POSIXct(d)), msg="Date.test_mktime.2015")

        d <- as.Date("1970-01-01")
        checkEquals(test_mktime(d), as.numeric(as.POSIXct(d)), msg="Date.test_mktime.1970")

        d <- as.Date("1954-07-04")
        checkEquals(test_mktime(d), as.numeric(as.POSIXct(d)), msg="Date.test_mktime.1954")
    }

    test.gmtime <- function() {
        oldTZ <- Sys.getenv("TZ")
        Sys.setenv(TZ="UTC")
        checkEquals(test_gmtime(1441065600), as.Date("2015-09-01"), msg="Date.test_gmtime.2015")

        checkEquals(test_gmtime(0),          as.Date("1970-01-01"), msg="Date.test_gmtime.1970")

        checkEquals(test_gmtime(-489024000), as.Date("1954-07-04"), msg="Date.test_gmtime.1954")
        Sys.setenv(TZ=oldTZ)
    }

    test.NA <- function() {
        dv <- Sys.Date() + 0:2
        checkTrue(has_na_dv(dv) == FALSE, msg="DateVector.NAtest.withoutNA")
        dv[1] <- NA
        checkTrue(has_na_dv(dv) == TRUE, msg="DateVector.NAtest.withNA")

        dvt <- Sys.time() + 0:2
        checkTrue(has_na_dtv(dvt) == FALSE, msg="DatetimeVector.NAtest.withoutNA")
        dvt[1] <- NA
        checkTrue(has_na_dtv(dvt) == TRUE, msg="DatetimeVector.NAtest.withNA")
    }
}
