#!/usr/bin/env r
# -*- mode: R; ess-indent-level: 4; tab-width: 4; indent-tabs-mode: nil; -*
#
# Copyright (C) 2012 - 2016  Dirk Eddelbuettel and Romain Francois
# Copyright (C) 2016         Dirk Eddelbuettel and James J Balamuta
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

    .setUp <- Rcpp:::unitTestSetup("rmath.cpp")

    test.rmath.norm <- function() {
        x <- 0.25
        a <- 1.25
        b <- 2.50
        checkEquals(runit_dnorm(x, a, b),
                    c(dnorm(x, a, b, log=FALSE), dnorm(x, a, b, log=TRUE)),
                    msg = " rmath.dnorm")

        checkEquals(runit_pnorm(x, a, b),
                    c(pnorm(x, a, b, lower=TRUE, log=FALSE),  pnorm(log(x), a, b, lower=TRUE, log=TRUE),
                      pnorm(x, a, b, lower=FALSE, log=FALSE), pnorm(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pnorm")

        checkEquals(runit_qnorm(x, a, b),
                    c(qnorm(x, a, b, lower=TRUE, log=FALSE),  qnorm(log(x), a, b, lower=TRUE,  log=TRUE),
                      qnorm(x, a, b, lower=FALSE, log=FALSE), qnorm(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qnorm")
        
        set.seed(333)
        r_result <- rnorm(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rnorm(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rnorm")
        
        set.seed(333)
        rcpp_result_sugar <- runit_rnorm_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rnorm.sugar")
    }

    test.rmath.unif <- function() {
        x <- 0.25
        a <- 1.25
        b <- 2.50
        checkEquals(runit_dunif(x, a, b),
                    c(dunif(x, a, b, log=FALSE), dunif(x, a, b, log=TRUE)),
                    msg = " rmath.dunif")

        checkEquals(runit_punif(x, a, b),
                    c(punif(x, a, b, lower=TRUE, log=FALSE),  punif(log(x), a, b, lower=TRUE, log=TRUE),
                      punif(x, a, b, lower=FALSE, log=FALSE), punif(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.punif")

        checkEquals(runit_qunif(x, a, b),
                    c(qunif(x, a, b, lower=TRUE, log=FALSE),  qunif(log(x), a, b, lower=TRUE,  log=TRUE),
                      qunif(x, a, b, lower=FALSE, log=FALSE), qunif(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qunif")
        
        set.seed(333)
        r_result <- runif(5, a, b)
        set.seed(333)
        rcpp_result <- runit_runif(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.runif")

        set.seed(333)
        rcpp_result_sugar <- runit_runif_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.runif.sugar")
    }

    test.rmath.gamma <- function() {
        x <- 0.25
        a <- 1.0
        b <- 1.0
        checkEquals(runit_dgamma(x, a, b),
                    c(dgamma(x, a, b, log=FALSE), dgamma(x, a, b, log=TRUE)),
                    msg = " rmath.dgamma")

        checkEquals(runit_pgamma(x, a, b),
                    c(pgamma(x, a, b, lower=TRUE, log=FALSE),  pgamma(log(x), a, b, lower=TRUE, log=TRUE),
                      pgamma(x, a, b, lower=FALSE, log=FALSE), pgamma(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pgamma")

        checkEquals(runit_qgamma(x, a, b),
                    c(qgamma(x, a, b, lower=TRUE, log=FALSE),  qgamma(log(x), a, b, lower=TRUE,  log=TRUE),
                      qgamma(x, a, b, lower=FALSE, log=FALSE), qgamma(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qgamma")
        
        set.seed(333)
        r_result <- rgamma(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rgamma(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rgamma")

        set.seed(333)
        rcpp_result_sugar <- runit_rgamma_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rgamma.sugar")
    }

    test.rmath.beta <- function() {
        x <- 0.25
        a <- 0.8
        b <- 2.5
        checkEquals(runit_dbeta(x, a, b),
                    c(dbeta(x, a, b, log=FALSE), dbeta(x, a, b, log=TRUE)),
                    msg = " rmath.dbeta")

        checkEquals(runit_pbeta(x, a, b),
                    c(pbeta(x, a, b, lower=TRUE, log=FALSE),  pbeta(log(x), a, b, lower=TRUE, log=TRUE),
                      pbeta(x, a, b, lower=FALSE, log=FALSE), pbeta(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pbeta")

        checkEquals(runit_qbeta(x, a, b),
                    c(qbeta(x, a, b, lower=TRUE, log=FALSE),  qbeta(log(x), a, b, lower=TRUE,  log=TRUE),
                      qbeta(x, a, b, lower=FALSE, log=FALSE), qbeta(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qbeta")
        
        set.seed(333)
        r_result <- rbeta(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rbeta(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rbeta")

        set.seed(333)
        rcpp_result_sugar <- runit_rbeta(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rbeta.sugar")
        
    }


    test.rmath.lnorm <- function() {
        x <- 0.25
        a <- 0.8
        b <- 2.5
        checkEquals(runit_dlnorm(x, a, b),
                    c(dlnorm(x, a, b, log=FALSE), dlnorm(x, a, b, log=TRUE)),
                    msg = " rmath.dlnorm")

        checkEquals(runit_plnorm(x, a, b),
                    c(plnorm(x, a, b, lower=TRUE, log=FALSE),  plnorm(log(x), a, b, lower=TRUE, log=TRUE),
                      plnorm(x, a, b, lower=FALSE, log=FALSE), plnorm(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.plnorm")

        checkEquals(runit_qlnorm(x, a, b),
                    c(qlnorm(x, a, b, lower=TRUE, log=FALSE),  qlnorm(log(x), a, b, lower=TRUE,  log=TRUE),
                      qlnorm(x, a, b, lower=FALSE, log=FALSE), qlnorm(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qlnorm")
        
        set.seed(333)
        r_result <- rlnorm(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rlnorm(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rlnorm")

        set.seed(333)
        rcpp_result_sugar <- runit_rlnorm_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rlnorm.sugar")
    }


    test.rmath.chisq <- function() {
        x <- 0.25
        a <- 0.8
        checkEquals(runit_dchisq(x, a),
                    c(dchisq(x, a, log=FALSE), dchisq(x, a, log=TRUE)),
                    msg = " rmath.dchisq")

        checkEquals(runit_pchisq(x, a),
                    c(pchisq(x, a, lower=TRUE, log=FALSE),  pchisq(log(x), a, lower=TRUE, log=TRUE),
                      pchisq(x, a, lower=FALSE, log=FALSE), pchisq(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.pchisq")

        checkEquals(runit_qchisq(x, a),
                    c(qchisq(x, a, lower=TRUE, log=FALSE),  qchisq(log(x), a, lower=TRUE,  log=TRUE),
                      qchisq(x, a, lower=FALSE, log=FALSE), qchisq(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.qchisq")
        
        set.seed(333)
        r_result <- rchisq(5, a)
        set.seed(333)
        rcpp_result <- runit_rchisq(a)
        checkEquals(rcpp_result, r_result, msg = " rmath.rchisq")

        set.seed(333)
        rcpp_result_sugar <- runit_rchisq_sugar(a)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rchisq.sugar")
    }


    test.rmath.nchisq <- function() {
        x <- 0.25
        a <- 0.8
        b <- 2.5
        checkEquals(runit_dnchisq(x, a, b),
                    c(dchisq(x, a, b, log=FALSE), dchisq(x, a, b, log=TRUE)),
                    msg = " rmath.dnchisq")

        checkEquals(runit_pnchisq(x, a, b),
                    c(pchisq(x, a, b, lower=TRUE, log=FALSE),  pchisq(log(x), a, b, lower=TRUE, log=TRUE),
                      pchisq(x, a, b, lower=FALSE, log=FALSE), pchisq(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pnchisq")

        checkEquals(runit_qnchisq(x, a, b),
                    c(qchisq(x, a, b, lower=TRUE, log=FALSE),  qchisq(log(x), a, b, lower=TRUE,  log=TRUE),
                      qchisq(x, a, b, lower=FALSE, log=FALSE), qchisq(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qnchisq")
    }


    test.rmath.f <- function() {
        x <- 0.25
        a <- 0.8
        b <- 2.5
        checkEquals(runit_df(x, a, b),
                    c(df(x, a, b, log=FALSE), df(x, a, b, log=TRUE)),
                    msg = " rmath.df")

        checkEquals(runit_pf(x, a, b),
                    c(pf(x, a, b, lower=TRUE, log=FALSE),  pf(log(x), a, b, lower=TRUE, log=TRUE),
                      pf(x, a, b, lower=FALSE, log=FALSE), pf(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pf")

        checkEquals(runit_qf(x, a, b),
                    c(qf(x, a, b, lower=TRUE, log=FALSE),  qf(log(x), a, b, lower=TRUE,  log=TRUE),
                      qf(x, a, b, lower=FALSE, log=FALSE), qf(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qf")
        
        set.seed(333)
        r_result <- rf(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rf(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rf")

        set.seed(333)
        rcpp_result_sugar <- runit_rf_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rf.sugar")
    }


    test.rmath.t <- function() {
        x <- 0.25
        a <- 0.8
        checkEquals(runit_dt(x, a),
                    c(dt(x, a, log=FALSE), dt(x, a, log=TRUE)),
                    msg = " rmath.dt")

        checkEquals(runit_pt(x, a),
                    c(pt(x, a, lower=TRUE, log=FALSE),  pt(log(x), a, lower=TRUE, log=TRUE),
                      pt(x, a, lower=FALSE, log=FALSE), pt(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.pt")

        checkEquals(runit_qt(x, a),
                    c(qt(x, a, lower=TRUE, log=FALSE),  qt(log(x), a, lower=TRUE,  log=TRUE),
                      qt(x, a, lower=FALSE, log=FALSE), qt(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.qt")
        
        set.seed(333)
        r_result <- rt(5, a)
        set.seed(333)
        rcpp_result <- runit_rt(a)
        checkEquals(rcpp_result, r_result, msg = " rmath.rt")

        set.seed(333)
        rcpp_result_sugar <- runit_rt_sugar(a)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rt.sugar")
    }


    test.rmath.binom <- function() {
        x <- 5
        a <- 10
        b <- 0.5
        checkEquals(runit_dbinom(x, a, b),
                    c(dbinom(x, a, b, log=FALSE), dbinom(x, a, b, log=TRUE)),
                    msg = " rmath.dbinom")

        checkEquals(runit_pbinom(x, a, b),
                    c(pbinom(x, a, b, lower=TRUE, log=FALSE),  pbinom(log(x), a, b, lower=TRUE, log=TRUE),
                      pbinom(x, a, b, lower=FALSE, log=FALSE), pbinom(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pbinom")

        x <- x/a
        checkEquals(runit_qbinom(x, a, b),
                    c(qbinom(x, a, b, lower=TRUE, log=FALSE),  qbinom(log(x), a, b, lower=TRUE,  log=TRUE),
                      qbinom(x, a, b, lower=FALSE, log=FALSE), qbinom(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qbinom")
        
        set.seed(333)
        r_result <- rbinom(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rbinom(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rbinom")

        set.seed(333)
        rcpp_result_sugar <- runit_rbinom_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rbinom.sugar")
    }


    test.rmath.cauchy <- function() {
        x <- 0.25
        a <- 0.8
        b <- 2.5
        checkEquals(runit_dcauchy(x, a, b),
                    c(dcauchy(x, a, b, log=FALSE), dcauchy(x, a, b, log=TRUE)),
                    msg = " rmath.dcauchy")

        checkEquals(runit_pcauchy(x, a, b),
                    c(pcauchy(x, a, b, lower=TRUE, log=FALSE),  pcauchy(log(x), a, b, lower=TRUE, log=TRUE),
                      pcauchy(x, a, b, lower=FALSE, log=FALSE), pcauchy(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pcauchy")

        checkEquals(runit_qcauchy(x, a, b),
                    c(qcauchy(x, a, b, lower=TRUE, log=FALSE),  qcauchy(log(x), a, b, lower=TRUE,  log=TRUE),
                      qcauchy(x, a, b, lower=FALSE, log=FALSE), qcauchy(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qcauchy")
        
        set.seed(333)
        r_result <- rcauchy(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rcauchy(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rcauchy")

        set.seed(333)
        rcpp_result_sugar <- runit_rcauchy_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rcauchy.sugar")
    }


    test.rmath.exp <- function() {
        x <- 0.25
        a <- 1.0
        checkEquals(runit_dexp(x, a),
                    c(dexp(x, a, log=FALSE), dexp(x, a, log=TRUE)),
                    msg = " rmath.dexp")

        checkEquals(runit_pexp(x, a),
                    c(pexp(x, a, lower=TRUE, log=FALSE),  pexp(log(x), a, lower=TRUE, log=TRUE),
                      pexp(x, a, lower=FALSE, log=FALSE), pexp(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.pexp")

        checkEquals(runit_qexp(x, a),
                    c(qexp(x, a, lower=TRUE, log=FALSE),  qexp(log(x), a, lower=TRUE,  log=TRUE),
                      qexp(x, a, lower=FALSE, log=FALSE), qexp(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.qexp")
        
        set.seed(333)
        r_result <- rexp(5, a)
        set.seed(333)
        rcpp_result <- runit_rexp(a)
        checkEquals(rcpp_result, r_result, msg = " rmath.rexp")

        set.seed(333)
        rcpp_result_sugar <- runit_rexp_sugar(a)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rexp.sugar")
    }


    test.rmath.geom <- function() {
        x <- 1
        a <- 0.75
        checkEquals(runit_dgeom(x, a),
                    c(dgeom(x, a, log=FALSE), dgeom(x, a, log=TRUE)),
                    msg = " rmath.dgeom")

        checkEquals(runit_pgeom(x, a),
                    c(pgeom(x, a, lower=TRUE, log=FALSE),  pgeom(log(x), a, lower=TRUE, log=TRUE),
                      pgeom(x, a, lower=FALSE, log=FALSE), pgeom(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.pgeom")

        checkEquals(runit_qgeom(x, a),
                    c(qgeom(x, a, lower=TRUE, log=FALSE),  qgeom(log(x), a, lower=TRUE,  log=TRUE),
                      qgeom(x, a, lower=FALSE, log=FALSE), qgeom(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.qgeom")
        
        set.seed(333)
        r_result <- rgeom(5, a)
        set.seed(333)
        rcpp_result <- runit_rgeom(a)
        checkEquals(rcpp_result, r_result, msg = " rmath.rgeom")

        set.seed(333)
        rcpp_result_sugar <- runit_rgeom_sugar(a)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rgeom.sugar")
    }

    test.rmath.hyper <- function() {
        x <- 5
        a <- 10
        b <- 7
        c <- 8
        checkEquals(runit_dhyper(x, a, b, c),
                    c(dhyper(x, a, b, c, log=FALSE), dhyper(x, a, b, c, log=TRUE)),
                    msg = " rmath.dhyper")

        checkEquals(runit_phyper(x, a, b, c),
                    c(phyper(x, a, b, c, lower=TRUE, log=FALSE),  phyper(log(x), a, b, c, lower=TRUE, log=TRUE),
                      phyper(x, a, b, c, lower=FALSE, log=FALSE), phyper(log(x), a, b, c, lower=FALSE, log=TRUE)),
                    msg = " rmath.phyper")

        x <- x/a
        checkEquals(runit_qhyper(x, a, b, c),
                    c(qhyper(x, a, b, c, lower=TRUE, log=FALSE),  qhyper(log(x), a, b, c, lower=TRUE,  log=TRUE),
                      qhyper(x, a, b, c, lower=FALSE, log=FALSE), qhyper(log(x), a, b, c, lower=FALSE, log=TRUE)),
                    msg = " rmath.qhyper")
        
        set.seed(333)
        r_result <- rhyper(5, a, b, c)
        set.seed(333)
        rcpp_result <- runit_rhyper(a, b, c)
        checkEquals(rcpp_result, r_result, msg = " rmath.rhyper")

        set.seed(333)
        rcpp_result_sugar <- runit_rhyper_sugar(a, b, c)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rhyper.sugar")
    }


    test.rmath.nbinom <- function() {
        x <- 2
        a <- 8
        b <- 0.25
        checkEquals(runit_dnbinom(x, a, b),
                    c(dnbinom(x, a, b, log=FALSE), dnbinom(x, a, b, log=TRUE)),
                    msg = " rmath.dnbinom")

        checkEquals(runit_pnbinom(x, a, b),
                    c(pnbinom(x, a, b, lower=TRUE, log=FALSE),  pnbinom(log(x), a, b, lower=TRUE, log=TRUE),
                      pnbinom(x, a, b, lower=FALSE, log=FALSE), pnbinom(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pnbinom")

        x <- x/a
        checkEquals(runit_qnbinom(x, a, b),
                    c(qnbinom(x, a, b, lower=TRUE, log=FALSE),  qnbinom(log(x), a, b, lower=TRUE,  log=TRUE),
                      qnbinom(x, a, b, lower=FALSE, log=FALSE), qnbinom(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qnbinom")
        
        set.seed(333)
        r_result <- rnbinom(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rnbinom(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rnbinom")

        set.seed(333)
        rcpp_result_sugar <- runit_rnbinom_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rnbinom.sugar")
    }


    test.rmath.pois <- function() {
        x <- 2
        a <- 1.0
        checkEquals(runit_dpois(x, a),
                    c(dpois(x, a, log=FALSE), dpois(x, a, log=TRUE)),
                    msg = " rmath.dpois")

        checkEquals(runit_ppois(x, a),
                    c(ppois(x, a, lower=TRUE, log=FALSE),  ppois(log(x), a, lower=TRUE, log=TRUE),
                      ppois(x, a, lower=FALSE, log=FALSE), ppois(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.ppois")

        x <- 1/x
        checkEquals(runit_qpois(x, a),
                    c(qpois(x, a, lower=TRUE, log=FALSE),  qpois(log(x), a, lower=TRUE,  log=TRUE),
                      qpois(x, a, lower=FALSE, log=FALSE), qpois(log(x), a, lower=FALSE, log=TRUE)),
                    msg = " rmath.qpois")
        
        set.seed(333)
        r_result <- rpois(5, a)
        set.seed(333)
        rcpp_result <- runit_rpois(a)
        checkEquals(rcpp_result, r_result, msg = " rmath.rpois")

        set.seed(333)
        rcpp_result_sugar <- runit_rpois_sugar(a)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rpois.sugar")
    }


    test.rmath.weibull <- function() {
        x <- 2
        a <- 8
        b <- 0.25
        checkEquals(runit_dweibull(x, a, b),
                    c(dweibull(x, a, b, log=FALSE), dweibull(x, a, b, log=TRUE)),
                    msg = " rmath.dweibull")

        checkEquals(runit_pweibull(x, a, b),
                    c(pweibull(x, a, b, lower=TRUE, log=FALSE),  pweibull(log(x), a, b, lower=TRUE, log=TRUE),
                      pweibull(x, a, b, lower=FALSE, log=FALSE), pweibull(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pweibull")

        x <- x/a
        checkEquals(runit_qweibull(x, a, b),
                    c(qweibull(x, a, b, lower=TRUE, log=FALSE),  qweibull(log(x), a, b, lower=TRUE,  log=TRUE),
                      qweibull(x, a, b, lower=FALSE, log=FALSE), qweibull(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qweibull")
        
        set.seed(333)
        r_result <- rweibull(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rweibull(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rweibull")

        set.seed(333)
        rcpp_result_sugar <- runit_rweibull_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rweibull.sugar")
    }


    test.rmath.logis <- function() {
        x <- 2
        a <- 8
        b <- 0.25
        checkEquals(runit_dlogis(x, a, b),
                    c(dlogis(x, a, b, log=FALSE), dlogis(x, a, b, log=TRUE)),
                    msg = " rmath.dlogis")

        checkEquals(runit_plogis(x, a, b),
                    c(plogis(x, a, b, lower=TRUE, log=FALSE),  plogis(log(x), a, b, lower=TRUE, log=TRUE),
                      plogis(x, a, b, lower=FALSE, log=FALSE), plogis(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.plogis")

        x <- x/a
        checkEquals(runit_qlogis(x, a, b),
                    c(qlogis(x, a, b, lower=TRUE, log=FALSE),  qlogis(log(x), a, b, lower=TRUE,  log=TRUE),
                      qlogis(x, a, b, lower=FALSE, log=FALSE), qlogis(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qlogis")  
        
        set.seed(333)
        r_result <- rlogis(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rlogis(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rlogis")

        set.seed(333)
        rcpp_result_sugar <- runit_rlogis_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rlogis.sugar")
    }


    test.rmath.nbeta <- function() {
        x <- 5
        a <- 10
        b <- 7
        c <- 8
        checkEquals(runit_dnbeta(x, a, b, c),
                    c(dbeta(x, a, b, c, log=FALSE), dbeta(x, a, b, c, log=TRUE)),
                    msg = " rmath.dnbeta")

        checkEquals(runit_pnbeta(x, a, b, c),
                    c(pbeta(x, a, b, c, lower=TRUE, log=FALSE),  pbeta(log(x), a, b, c, lower=TRUE, log=TRUE),
                      pbeta(x, a, b, c, lower=FALSE, log=FALSE), pbeta(log(x), a, b, c, lower=FALSE, log=TRUE)),
                    msg = " rmath.pnbeta")

        x <- x/a
        checkEquals(runit_qnbeta(x, a, b, c),
                    c(qbeta(x, a, b, c, lower=TRUE, log=FALSE),  qbeta(log(x), a, b, c, lower=TRUE,  log=TRUE),
                      qbeta(x, a, b, c, lower=FALSE, log=FALSE), qbeta(log(x), a, b, c, lower=FALSE, log=TRUE)),
                    msg = " rmath.qnbeta")
    }


    test.rmath.nf <- function() {
        x <- 5
        a <- 10
        b <- 7
        c <- 8
        checkEquals(runit_dnf(x, a, b, c),
                    c(df(x, a, b, c, log=FALSE), df(x, a, b, c, log=TRUE)),
                    msg = " rmath.dnf")

        checkEquals(runit_pnf(x, a, b, c),
                    c(pf(x, a, b, c, lower=TRUE, log=FALSE),  pf(log(x), a, b, c, lower=TRUE, log=TRUE),
                      pf(x, a, b, c, lower=FALSE, log=FALSE), pf(log(x), a, b, c, lower=FALSE, log=TRUE)),
                    msg = " rmath.pnf")

        x <- x/a
        checkEquals(runit_qnf(x, a, b, c),
                    c(qf(x, a, b, c, lower=TRUE, log=FALSE),  qf(log(x), a, b, c, lower=TRUE,  log=TRUE),
                      qf(x, a, b, c, lower=FALSE, log=FALSE), qf(log(x), a, b, c, lower=FALSE, log=TRUE)),
                    msg = " rmath.qnf")
    }

    test.rmath.nt <- function() {
        x <- 5
        a <- 10
        b <- 7
        checkEquals(runit_dnt(x, a, b),
                    c(dt(x, a, b, log=FALSE), dt(x, a, b, log=TRUE)),
                    msg = " rmath.dnt")

        checkEquals(runit_pnt(x, a, b),
                    c(pt(x, a, b, lower=TRUE, log=FALSE),  pt(log(x), a, b, lower=TRUE, log=TRUE),
                      pt(x, a, b, lower=FALSE, log=FALSE), pt(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pnt")

        x <- x/a
        checkEquals(runit_qnt(x, a, b),
                    c(qt(x, a, b, lower=TRUE, log=FALSE),  qt(log(x), a, b, lower=TRUE,  log=TRUE),
                      qt(x, a, b, lower=FALSE, log=FALSE), qt(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qnt")
    }

    test.rmath.wilcox <- function() {
        x <- 2
        a <- 4
        b <- 6
        checkEquals(runit_dwilcox(x, a, b),
                    c(dwilcox(x, a, b, log=FALSE), dwilcox(x, a, b, log=TRUE)),
                    msg = " rmath.dwilcox")

        checkEquals(runit_pwilcox(x, a, b),
                    c(pwilcox(x, a, b, lower=TRUE, log=FALSE),  pwilcox(log(x), a, b, lower=TRUE, log=TRUE),
                      pwilcox(x, a, b, lower=FALSE, log=FALSE), pwilcox(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.pwilcox")

        x <- x/a
        checkEquals(runit_qwilcox(x, a, b),
                    c(qwilcox(x, a, b, lower=TRUE, log=FALSE),  qwilcox(log(x), a, b, lower=TRUE,  log=TRUE),
                      qwilcox(x, a, b, lower=FALSE, log=FALSE), qwilcox(log(x), a, b, lower=FALSE, log=TRUE)),
                    msg = " rmath.qwilcox")
        
        
        set.seed(333)
        r_result <- rwilcox(5, a, b)
        set.seed(333)
        rcpp_result <- runit_rwilcox(a, b)
        checkEquals(rcpp_result, r_result, msg = " rmath.rwilcox")

        set.seed(333)
        rcpp_result_sugar <- runit_rwilcox_sugar(a, b)
        checkEquals(rcpp_result_sugar, r_result, msg = " rmath.rwilcox_sugar")
    }

}



