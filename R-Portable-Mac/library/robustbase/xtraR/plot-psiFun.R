#### Functions to plot and check psi-functions
#### -----------------------------------------
## used in ../../tests/lmrob-psifns.R,
##	   ../../tests/psi-rho-etc.R
##     and ../../vignettes/psi_functions.Rnw  vignette

## Original Author of functions: Martin Maechler, Date: 13 Aug 2010, 10:17

p.psiFun <- function(x, psi, par, main=FALSE, ...)
{
    m.psi <- cbind(rho  = Mpsi(x, par, psi,deriv=-1),
                   psi  = Mpsi(x, par, psi,deriv= 0),
                   Dpsi = Mpsi(x, par, psi,deriv= 1),
                   wgt  = Mwgt(x, par, psi))
    robustbase:::matplotPsi(x, m.psi, psi=psi, par=par, main=main, ...) ## -> cbind(x, m.psi)
}
p.psiFun2 <- function(x, psi, par, main="short", ...)
    p.psiFun(x, psi, par, main=main, leg.loc= "bottomright", ylim = c(-2.2, 6))
## for psi_func class objects: simply use plot() method.

mids <- function(x) (x[-1]+x[-length(x)])/2

##' is 'psi' the name of redescending psi (i.e. with *finite* rejection point)
isPsi.redesc <- function(psi) {
    psi != "Huber" ## <- must be adapted when we introduce more
}


##' @title Check consistency of psi/chi/wgt/.. functions
##' @param m.psi matrix as from p.psiFun()
##' @param tol
##' @return concatenation of \code{\link{all.equal}} results
##' @author Martin Maechler
chkPsiDeriv <- function(m.psi, tol = 1e-4) {
    stopifnot(length(tol) > 0, tol >= 0,
              is.numeric(psi <- m.psi[,"psi"]),
              is.numeric(dx  <- diff(x <- m.psi[,"x"])))
    if(length(tol) < 2) tol[2] <- 10*tol[1]
    xn0 <- abs(x) > 1e-5
    c(all.equal(mids(psi), diff(m.psi[,"rho"])/dx, tolerance=tol[1]), # rho'  == psi
      all.equal(mids(m.psi[,"Dpsi"]), diff(psi)/dx, tolerance=tol[2]),# psi'  == psip
      all.equal(m.psi[xn0,"wgt"], (psi/x)[xn0], tolerance= tol[1]/10))# psi/x == wgt
}

##' This version "starts from scratch" instead of from p.psiFun() result:
##'
##' @title Check consistency of psi/chi/wgt/.. functions
##' @param x  range or vector of abscissa values
##' @param psi psi() function spec., passed to  M.psi() etc
##' @param par tuning parameter,     passed to  M.psi() etc
##' @param tol tolerance for equality checking of numeric derivatives
##' @return concatenation of \code{\link{all.equal}} results
##' @author Martin Maechler
chkPsi.. <- function(x, psi, par, tol = 1e-4, doD2, quiet=FALSE)
{
    stopifnot(length(tol) > 0, tol >= 0, is.numeric(x), is.finite(x))
    is.redesc <- isPsi.redesc(psi)
    if(length(x) == 2) ## it is a *range* -> produce vector
	x <- seq(x[1], x[2], length = 1025L)
    dx <- diff(x)
    x0 <- sort(x)
    x <- c(-Inf, Inf, NA, NaN, x0)
    if(is.redesc)
	rho  <- Mpsi(x, par, psi, deriv=-1)
    psix <- Mpsi(x, par, psi, deriv= 0)
    Dpsi <- Mpsi(x, par, psi, deriv= 1)
    wgt  <- Mwgt(x, par, psi)

    chi  <- Mchi(x, par, psi)
    if(is.redesc) {
	chi1 <- Mchi(x, par, psi, deriv=1)
	chi2 <- Mchi(x, par, psi, deriv=2)
    }
    rho.Inf <- MrhoInf(par, psi)
    if(is.redesc)
        stopifnot(all.equal(rep(rho.Inf,2), rho[1:2]),
                  all.equal(chi, rho  / rho.Inf),
                  all.equal(chi1,psix / rho.Inf),
                  all.equal(chi2,Dpsi / rho.Inf)
                  )
    else { ## check any here?  From ../src/lmrob.c :
        ##  chi = C-function rho(x) which is unscaled
        rho <- chi # for checks below
    }
    D2psi <- tryCatch(Mpsi(x, par, psi, deriv= 2), error=function(e)e)
    has2 <- !inherits(D2psi, "error")
    doD2 <- if(missing(doD2)) has2 else doD2 && has2
    if(!quiet & !doD2) message("Not checking psi''() := Mpsi(*, deriv=2)")
    stopifnot(is.numeric(psix),
              ## check NA / NaN :
              identical5(x[3:4], chi[3:4], psix[3:4], Dpsi[3:4], wgt[3:4]),
              if(has2) identical(x[3:4], D2psi[3:4]) else TRUE)

    if(length(tol) < 2) tol[2] <- 16*tol[1]
    if(length(tol) < 3) tol[3] <- tol[1]/10
    if(length(tol) < 4) tol[4] <-  8*tol[2]
    i <- 5:length(x) # leaving away the first 4 (+-Inf, NA..)
    xn0 <- is.finite(x) & abs(x) > 1e-5
    c("rho' = psi" = all.equal(mids(psix[i]), diff(rho [i])/dx, tolerance=tol[1]),
      "psi' = psip"= all.equal(mids(Dpsi[i]), diff(psix[i])/dx, tolerance=tol[2]),
      "psi/x= wgt" = all.equal(  wgt[xn0],       (psix/x)[xn0], tolerance=tol[3]),
      "psi''=D2psi"= if(doD2)
		     all.equal(mids(D2psi[i]), diff(Dpsi[i])/dx,tolerance=tol[4])
      else NA)
}

