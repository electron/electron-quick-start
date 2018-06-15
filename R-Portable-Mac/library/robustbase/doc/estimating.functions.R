## Called from ./lmrob_simulation.Rnw
##              ~~~~~~~~~~~~~~~~~~~~~

###########################################################################
## Prediction
###########################################################################

f.predict <- function (object, newdata = NULL, scale = sigma(object),
                       se.fit = FALSE, df = object$df.residual,
                       interval = c('none', 'confidence', 'prediction'),
                       level = 0.95, type = c('response'),
                       terms = NULL, na.action = na.pass,
                       pred.var = res.var/weights, weights = 1,
                       cov = covariance.matrix(object), ...)
{
  ## Purpose: replace predict.lmrob from robustbase package
  ## ----------------------------------------------------------------------
  ## Arguments: See ?predict.lm
  ##            type = 'presponse' ('term' is not supported)
  ##            terms argument is ignored
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Sept 2009, 12:16
  ## take as much from predict.lm as possible
  ## check arguments
  if (!missing(terms)) stop('predict.lmrob: terms argument is ignored')
  ## set data
  tt <- terms(object)
  if (missing(newdata) || is.null(newdata)) {
    mm <- X <- model.matrix(object)
    mmDone <- TRUE
    offset <- object$offset
  }
  else {
    Terms <- delete.response(tt)
    m <- model.frame(Terms, newdata, na.action = na.action,
                     xlev = object$xlevels)
    if (!is.null(cl <- attr(Terms, "dataClasses")))
      .checkMFClasses(cl, m)
    X <- model.matrix(Terms, m, contrasts.arg = object$contrasts)
    offset <- rep(0, nrow(X))
    if (!is.null(off.num <- attr(tt, "offset")))
      for (i in off.num) offset <- offset +
        eval(attr(tt, "variables")[[i + 1]], newdata)
    if (!is.null(object$call$offset))
      offset <- offset + eval(object$call$offset, newdata)
    mmDone <- FALSE
  }
  n <- length(object$residuals)
  p <- object$rank
  if (p < ncol(X) && !(missing(newdata) || is.null(newdata)))
    warning("prediction from a rank-deficient fit may be misleading")
  beta <- coef(object)
  ## ignoring piv here
  predictor <- drop(X %*% beta)
  if (!is.null(offset))
    predictor <- predictor + offset
  interval <- match.arg(interval)
  type <- match.arg(type)
  if (se.fit || interval != "none") {
    res.var <- scale^2
    if (type != "terms") {
      if (p > 0) {
        ## this is probably not optimal...
        ## cov <- covariance.matrix(object) ## set as argument
        ip <- diag(X %*% tcrossprod(cov, X))
      }
      else ip <- rep(0, n)
    }
  }
  if (interval != "none") {
    tfrac <- qt((1 - level)/2, df)
    hwid <- tfrac * switch(interval, confidence = sqrt(ip),
                           prediction = sqrt(ip + pred.var))
    if (type != "terms") {
      predictor <- cbind(predictor, predictor + hwid %o%
                         c(1, -1))
      colnames(predictor) <- c("fit", "lwr", "upr")
    }
  }
  if (se.fit || interval != "none")
    se <- sqrt(ip)
  if (missing(newdata) && !is.null(na.act <- object$na.action)) {
    predictor <- napredict(na.act, predictor)
    if (se.fit)
      se <- napredict(na.act, se)
  }
  if (se.fit)
    list(fit = predictor, se.fit = se, df = df, residual.scale = sqrt(res.var))
  else predictor
}

## predict(obj, pred, interval = 'prediction')
## f.predict(obj, pred, interval = 'prediction')

predict.lmRob <- function(object, newdata = NULL, scale = NULL, ...) {
  ## Purpose: extend predict() functionality to lmRob objects
  ## ----------------------------------------------------------------------
  ## Arguments:
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Sept 2009, 12:16

  class(object) <- c(class(object), "lm")
  object$qr <- qr(sqrt(weights(object)) * model.matrix(object))
  if (missing(scale)) scale <- object$scale
  predict.lm(object, newdata = newdata, scale = scale, ...)
}

###########################################################################
## some helper functions
###########################################################################

f.lmRob <- function(...)
{
  ## Purpose: wrapper for lmRob
  ## ----------------------------------------------------------------------
  ## Arguments: see ?lmRob
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 10:28
  ## get arguments
  args <- list(...)
  ## update defaults:
  if (is.null(args$mxr)) args$mxr <- 2000
  if (is.null(args$mxf)) args$mxf <- 500
  if (is.null(args$mxs)) args$mxs <- 2000
  ## get all arguments except the arguments of lmRob:
  uw <- c('formula', 'data', 'weights', 'subset', 'na.action', 'model',
          'x', 'y', 'contrasts', 'nrep', 'genetic.control')
  ind <-
    if (is.null(names(args))) rep(FALSE, length(args))
    else names(args) != '' & !names(args) %in% uw
  ## they go into control:
  control <- do.call("lmRob.control", args[ind])
  ## now call lmRob
  do.call("lmRob", c(args[!ind], list(control = control)))
}

## lmRob(y ~ x, d.data, control = lmRob.control(initial.alg = 'fast', efficiency = 0.95, weight = c('bisquare', 'bisquare')))
## lmRob(y ~ x, d.data, initial.alg = 'fast', efficiency = 0.95, weight = c('bisquare', 'bisquare'))
## f.lmRob(y ~ x, d.data, initial.alg = 'fast', efficiency = 0.95, weight = c('bisquare', 'bisquare'))

f.lmRob.S <- function(... , robust.control = lmRob.control()) {
  ## Purpose: call the S estimation procedure of lmRob
  ## ----------------------------------------------------------------------
  ## Arguments: x: design matrix x
  ##            y: vector of observations
  ##            robust.control: control list of lmRob.control()
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 29 Oct 2009, 14:54
  ## code: from lmRob.fit.compute, robust package version 0.3-9

  robust.control$initial.alg = 'random'
  robust.control$estim = 'Initial'

  z <- lmRob(..., control = robust.control)
  class(z) <- 'lmrob.S'
  z
}

## f.lmRob.S(rep(1,10), rnorm(10), lmRob.control(weight = c('bisquare', 'bisquare')))

f.eff2c.psi <- function(eff, weight='bisquare') {
  ## Purpose: convert lmRob efficiencies to c.psi
  ## ----------------------------------------------------------------------
  ## Arguments: eff: lmRob efficiency
  ##            weight: type of weight (weight argument in lmRob.control)
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  8 Oct 2009, 15:36

  if(is.null(eff)) return(NULL)

  lw = casefold(weight)

  if (lw == 'bisquare') {
    if (eff == 0.95)      4.685061
    else if (eff == 0.9)  3.882646
    else if (eff == 0.85) 3.443689
    else if (eff == 0.8)  3.136909
    else NA
  } else if (lw == 'optimal') {
    if (eff == 0.95)	  1.060158
    else if (eff == 0.9)  0.9440982
    else if (eff == 0.85) 0.8684
    else if (eff == 0.8)  0.8097795
    else NA
  } else NA
}

f.psi2c.chi <- function(weight) {
  ## Purpose: return lmRob defaults for c.chi
  ## ----------------------------------------------------------------------
  ## Arguments: weight: type of weight
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 28 Jan 2010, 10:05

  switch(weight,
         'bisquare' = 1.5477,
         'optimal' = 0.4047)
}


residuals.lmrob.S <- function(obj)
  obj$residuals

robustness.weights <- function(x, ...) UseMethod("robustness.weights")
  ## Purpose: retrieve robustness weights from robust regression return
  ##          object
  ## ----------------------------------------------------------------------
  ## Arguments: obj: robust regression output object
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Oct 2009, 13:42

robustness.weights.lmrob <- robustness.weights.default <- function(obj)
  naresid(obj$na.action, obj$w)

robustness.weights.lm <- function(obj) {
  if (any(class(obj) %in% c('lmrob', 'f.lmrob')))
    stop('Caution: returning incorrect weights')
  naresid(obj$na.action, rep(1, length(obj$resid)))
}
robustness.weights.rlm <- function(obj)
  naresid(obj$na.action, obj$w)

robustness.weights.lmRob <- function(obj) {
  if (obj$robust.control$weight[2] != 'Optimal') {
    c.psi <- f.eff2c.psi(obj$robust.control$efficiency, obj$robust.control$weight[2])
    rs <- obj$residuals / obj$scale
    obj$M.weights <- Mwgt(rs, c.psi, obj$robust.control$weight[2])
  }
  naresid(obj$na.action, obj$M.weights)
}

## t <- f.lmRob(y ~ x, d.data)
## t <- f.lmrob(y ~ x, d.data, method = 'SM')
## t <- f.lmRob(y ~ x, d.data, initial.alg = 'fast', efficiency = 0.95, weight = c('bisquare', 'bisquare'))
## t <- lmRob(y ~ x, d.data, control = lmRob.control(initial.alg = 'fast', efficiency = 0.95, weight = c('bisquare', 'bisquare')))
## robustness.weights(t)

robustness.weights.lmrob.S <- function(obj) {
  rstand <- resid(obj)/sigma(obj)
  Mwgt(rstand, obj$control$tuning.chi, obj$control$psi)
}

## MM: Why on earth is this called  covariance.matrix() ?? -- S and R standard is vcov() !!
## -- For lm, they are indeed identical;  for  lmrob, too
## HOWEVER, the *.rlm() method of cov..matrix() *differs* from vcov.rlm() -- why?

covariance.matrix <- function(x, ...) UseMethod("covariance.matrix")
  ## Purpose: retrieve covariance matrix from robust regression return
  ##          object
  ## ----------------------------------------------------------------------
  ## Arguments: obj: robust regression output object
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Oct 2009, 13:42

covariance.matrix.lmrob <- covariance.matrix.default <- function(obj) obj$cov

covariance.matrix.rlm <- function(obj, method = 'XtWX')
  summary(obj, method)$cov

covariance.matrix.lm <- function(obj) {
  s <- summary(obj)
  s$cov * s$sigma^2
}

sigma <- function(x, ...) UseMethod("sigma")
  ## Purpose: retrieve scale estimate from robust regression return
  ##          object
  ## ----------------------------------------------------------------------
  ## Arguments: obj: robust regression output object
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Oct 2009, 13:42

sigma.lmrob <- sigma.default <- function(obj)
  obj$scale

sigma.lm <- function(obj)
  summary(obj)$sigma

sigma.rlm <- function(obj)
  obj$s

converged <- function(x, ...) UseMethod("converged")
  ## Purpose: check convergence status of return object
  ## ----------------------------------------------------------------------
  ## Arguments: obj: robust regression output object
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date:  6 Oct 2009, 13:42

converged.default <- function(obj) is.list(obj) && !is.null(obj$converged) && obj$converged
converged.lm <- function(obj)
  if (is.null(obj$converged)) TRUE else obj$converged
converged.lmRob <- function(obj) is.list(obj) && !is.null(obj$est) && obj$est == 'final'

###########################################################################
## alternative estimation methods
###########################################################################

lmrob.u <- function(formula, data, subset, weights, na.action, ..., start)
{
  ## Purpose: update lmrob object if possible
  ## ----------------------------------------------------------------------
  ## Arguments: (lmrob arguments)
  ##            start: object to update
  ## ----------------------------------------------------------------------
  ## Author: Manuel Koller, Date: 28 Jul 2010, 08:30

  args <- as.list(match.call())[-1]
  args$start <- NULL
  if (!missing(start)) {
    ## if start is a string, get start from parent
    if (is.character(start)) start <- get(start, envir=parent.frame())
    if (class(start) == 'lmrob') {
      ## check whether we can update start easily
      oldargs <- as.list(start$call)[-1]
      if (isTRUE(all.equal(args, oldargs))) return(start)
      else {
        ret <- start
        ## check method argument (ignore cov argument)
        if (is.null(oldargs$method)) oldargs$method <- start$control$method
        if (oldargs$method == 'MM') oldargs$method <- 'SM'
        if (is.null(args$method) || args$method == 'MM') args$method <- 'SM'
        rest.ok <-
          isTRUE(all.equal(oldargs[!names(oldargs) %in% c('method', 'cov')],
                           args[!names(args) %in% c('method', 'cov')]))
        if (is.null(start$x))
          stop('x matrix not found. Use lmrob(..., x = TRUE).')
        if (args$method != oldargs$method && rest.ok) {
          ## method is different, but the rest is the same
          oldsteps <- strsplit(oldargs$method, "")[[1]]
          steps    <- strsplit(args   $method, "")[[1]]
          ## reduce start to largest common initial estimator
          while(length(oldsteps) > length(steps) ||
                any(oldsteps != steps[seq_along(oldsteps)])) {
            elems <- c('na.action', 'offset', 'contrasts',
                       'xlevels', 'terms', 'model', 'x', 'y',
                       'degree.freedom', 'df.residual', 'call')
            ret <- c(ret$init, start[elems[elems %in% names(ret)]])
            class(ret) <- 'lmrob'
            oldsteps <- oldsteps[-length(oldsteps)]
          }
          ret$call$method <- args$method
          steps <- steps[- seq_along(oldsteps)]
          if (length(steps) > 0) {
            ret$cov <- NULL
            for (step in steps) {
              ret <- switch(step, D = lmrob..D..fit(ret),
                            M = lmrob..M..fit(obj = ret),
                            N = {
                              y <- model.response(ret$model)
                              ## taus are standardized because otherwise
                              ## the resulting efficiency is lower
                              tau <- ret$tau / mean(ret$tau)
                              tmp <- lmrob..M..fit(x = ret$x/tau, y = y/tau,
                                                   obj = ret)
                              tmp$residuals <- y - ret$x %*% ret$coef
                              tmp$qr <- NULL
                              tmp
                            },
                            stop("only M or D steps supported"))
              if (!ret$converged) {
                warning(step, "-step did NOT converge.")
                break
              }
            }
          } else {
            if (is.null(ret$qr))  ret$qr <- qr(ret$x * sqrt(ret$weights))
            ret$rank <- ret$qr$rank
          }
        }
        ## update covariance matrix
        if (rest.ok) {
          if (is.null(args$cov))
            args$cov <- lmrob.control(method=ret$control$method)$cov
          ret$cov <- vcov(ret, args$cov)
          ret$control$cov <- args$cov
          ret$call$cov <- args$cov

          return(ret)
        }
      }
    }
  }
  ## if we're here, update failed or there was no start
  cl <- match.call()
  cl$start <- NULL
  cl[[1]] <- as.symbol("lmrob")
  eval(cl, envir = parent.frame())
}

## lmrob.u <- function(formula, data, subset, weights, na.action, ..., start)
## {
##   cl <- match.call()
##   cl$start <- NULL
##   cl[[1]] <- as.symbol("lmrob")
##   eval(cl, envir = parent.frame())
##   ## do.call('lmrob', args, envir = parent.frame())
## }

## set.seed(0); d.data <- data.frame(y = rnorm(10), x = 1:10)

## lres <- lmrob(y ~ x, d.data, method = 'SM', psi = 'lgw', cov = '.vcov.avar1')
## obj1 <- lmrob(y ~ x, d.data, method = 'SM', psi = 'lgw', cov = '.vcov.w')
## test <- lmrob.u(y ~ x, d.data, method = 'SM', psi = 'lgw', cov = '.vcov.w',
##                 start = 'lres')
## all.equal(obj1, test)

## obj2 <- lmrob(y ~ x, d.data, method = 'SMD', psi = 'lgw', cov = '.vcov.w')
## test <- lmrob.u(y ~ x, d.data, method = 'SMD', psi = 'lgw',
##                 start = 'lres')
## all.equal(obj2, test[names(obj2)], check.attr = FALSE)

## obj3 <- lmrob(y ~ x, d.data, method = 'SMDM', psi = 'lgw', cov = '.vcov.w')
## test <- lmrob.u(y ~ x, d.data, method = 'SMDM', psi = 'lgw',
##                 start = 'lres')
## all.equal(obj3, test[names(obj3)], check.attr = FALSE)

## test <- lmrob.u(y ~ x, d.data, method = 'SMDM', psi = 'lgw',
##                 start = 'obj2')
## all.equal(obj3, test[names(obj3)], check.attr = FALSE)

## test <- lmrob.u(y ~ x, d.data, method = 'SM', psi = 'lgw', cov = '.vcov.w',
##                 start = obj3)
## all.equal(obj1, test[names(obj1)], check.attr = FALSE)

##' Compute the MM-estimate with corrections qE or qT as in
##' 	Maronna, R. A., Yohai, V. J., 2010.
##' 	Correcting MM estimates for "fat" data sets.
##' 	Computational Statistics & Data Analysis 54 (12), 3168–3173.
##' @title MM-estimate with Maronna-Yohai(2010) corrections
##' @param formula
##' @param data
##' @param subset
##' @param weights
##' @param na.action
##' @param ...
##' @param type
##' @return
##' @author Manuel Koller
lmrob.mar <- function(formula, data, subset, weights, na.action, ...,
                      type = c("qE", "qT"))
{
  ## get call and modify it so that
  ## lmrob returns the appropriate S-estimate
  cl <- match.call()
  method <- if (is.null(cl$method)) {
    if (!is.null(cl$control)) list(...)[["control"]]$method else 'MM'
  } else cl$method
  cl$type <- NULL
  cl$method <- 'S'
  cov <- if(!is.null(cl$cov)) cl$cov else '.vcov.w'
  cl$cov <- 'none'
  cl[[1]] <- as.symbol("lmrob")
  ## get S-estimate
  obj <- eval(cl, envir = parent.frame())
  ## correct S-scale estimate according to formula
  n <- length(obj$resid)
  p <- obj$rank
  type <- match.arg(type)
  ## for type qE: adjust tuning.chi (h0) to account for different delta
  if (type == 'qE') {
    if (obj$control$psi != 'bisquare')## FIXME: "tukey" should work, too
      stop('lmrob.mar: type qE is only available for bisquare psi')
    h0 <- uniroot(function(c) robustbase:::lmrob.bp('bisquare', c) - (1-p/n)/2,
                  c(1, 3))$root
    ## update scale
    obj$scale <- obj$scale * obj$control$tuning.chi / h0
    obj$control$tuning.chi <- h0
  }
  ## calculate q
  q <- switch(type,
              "qT" = {
                  rs <- obj$resid / obj$scale
                  ## \hat a = \mean \rho(r/sigma)^2
                  ## obj$control$tuning.chi == h_0
                  ahat <- mean(Mpsi(rs, obj$control$tuning.chi,
                                    obj$control$psi)^2)
                  ## \hat b = \mean \rho''(r/sigma)
                  bhat <- mean(Mpsi(rs, obj$control$tuning.chi,
                                    obj$control$psi, 1))
                  ## \hat c = \mean \rho'(r/sigma) * r/sigma
                  chat <- mean(Mpsi(rs, obj$control$tuning.chi,
                                    obj$control$psi)*rs)
                  ## qT:
                  1 + p*ahat/n/2/bhat/chat
              },
              "qE" = 1 / (1 - (1.29 - 6.02/n)*p/n)
              ,
              stop("unknown type ", type))
  ## update scale
  obj$scale.uncorrected <- obj$scale
  obj$scale <- q * obj$scale
  ## add M step if requested
  if (method %in% c('MM', 'SM')) {
    obj$control$cov <- cov
    obj <- lmrob..M..fit(obj = obj)
    ## construct a proper lmrob object
    elems <- c('na.action', 'offset', 'contrasts',
               'xlevels', 'terms', 'model', 'x', 'y')
    obj <- c(obj, obj$init.S[elems[elems %in% names(obj$init.S)]])
    obj$degree.freedom <- obj$df.residual <- n - obj$rank
  } else if (method != 'S')
    stop("lmrob.mar: Only method = S, SM and MM supported.")
  ## update class
  class(obj) <- 'lmrob'
  ## return
  obj
}

## summary(lmrob(y ~ x, d.data))
## summary(lmrob.mar(y ~ x, d.data, type = 'qE'))
## summary(tmp <- lmrob.mar(y ~ x, d.data, type = 'qT'))

## this function calculates M-estimate of scale
## with constants as used for S-estimate with maximum breakdown point
lmrob.mscale <- function(e, control, p = 0L) {
  ret <- .C("R_lmrob_S",
            x = as.double(e), ## this is ignored
            y = as.double(e),
            n = as.integer(length(e)),
            p = as.integer(p), ## divide the sum by n - p
            nResample = 0L, ## find scale only
            scale = as.double(mad(e)),
            coef = double(1),
            as.double(control$tuning.chi),
            as.integer(.psi2ipsi(control$psi)),
            as.double(control$bb), ## delta
            best_r = as.integer(control$best.r.s),
            groups = as.integer(control$groups),
            n.group = as.integer(control$n.group),
            k.fast.s = as.integer(control$k.fast.s),
            k.max = as.integer(control$k.max),
            maxit.scale = as.integer(control$maxit.scale),
            refine.tol = as.double(control$refine.tol),
            inv.tol = as.double(control$solve.tol),
            converged = logical(1),
            trace.lev = as.integer(0),
            mts = as.integer(control$mts),
            ss = robustbase:::.convSs(control$subsampling),
            fast.s.large.n = as.integer(length(e)+1),
            PACKAGE = 'robustbase')

  ret$scale
}

lmrob.dscale <- function(r, control,
                         kappa = robustbase:::lmrob.kappa(control = control)) {
  tau <- rep.int(1, length(r))
  w <- Mwgt(r, control$tuning.psi, control$psi)
  scale <- sqrt(sum(w * r^2) / kappa / sum(tau^2*w))
  psi <- control$psi
  c.psi <- robustbase:::.psi.conv.cc(psi, control$tuning.psi)
  ret <- .C("R_find_D_scale",
            r = as.double(r),
            kappa = as.double(kappa),
            tau = as.double(tau),
            length = as.integer(length(r)),
            scale = as.double(scale),
            c = as.double(c.psi),
            ipsi = .psi2ipsi(psi),
            type = 3L, ## dt1 as only remaining option
            rel.tol = as.double(control$rel.tol),
            k.max = as.integer(control$k.max),
            converged = logical(1),
            PACKAGE = 'robustbase')
  ret$scale
}



## sd.trim function by Gregor Gorjanc
## from http://ggorjan.blogspot.com/2008/11/trimmed-standard-deviation.html
## with added correction factor to be unbiased at the normal
sd.trim <- function(x, trim=0, na.rm=FALSE, ...)
{
  if(!is.numeric(x) && !is.complex(x) && !is.logical(x)) {
    warning("argument is not numeric or logical: returning NA")
    return(NA_real_)
  }
  if(na.rm) x <- x[!is.na(x)]
  if(!is.numeric(trim) || length(trim) != 1)
    stop("'trim' must be numeric of length one")
  n <- length(x)
  if(trim > 0 && n > 0) {
    if(is.complex(x)) stop("trimmed sd are not defined for complex data")
    if(trim >= 0.5) return(0)
    lo <- floor(n * trim) + 1
    hi <- n + 1 - lo
    x <- sort.int(x, partial = unique(c(lo, hi)))[lo:hi]
  }
  corr <- if (0 < trim && trim < 0.5) {
    z <- qnorm(trim, lower.tail=FALSE)# = Phi^{-1}(1 - tr)
    sqrt(1 - 2/(1-2*trim) *z*dnorm(z))
  } else 1

  sd(x)/corr
}
