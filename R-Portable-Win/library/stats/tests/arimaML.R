### PR#14682 : https://bugs.r-project.org/bugzilla3/show_bug.cgi?id=14682
##  ========
## Subject:    getQ0() returns a non-positive covariance matrix
## Date:       Tue, 20 Sep 2011 12:06:16 -0400
## ReportedBy: raphaelrossignol@...

## ...........

## I tried to replace getQ0 in two ways. The first one is to compute first the
## covariance matrix of (X_{t-1},...,X_{t-p},Z_t,...,Z_{t-q}) and this is achieved
## through the method of difference equations
## (eq. (3.3.8), (3.3.9), p.93 of Brockwell and Davis).
## This way was apparently suggested by a referee to Gardner et al. paper (see
## page 314 of their paper).

Q0bis <- function(phi,theta, tol=.Machine$double.eps) {
    ## Computes the initial covariance matrix for the state space representation
    ## of Gardner et al.
    p <- length(phi)
    q <- length(theta)
    r <- max(p,q+1)
    ttheta <- c(1,theta,rep(0,r-q-1))

    A1 <- matrix(0,r,p)
    C <- (col(A1)+row(A1)-1)
    B <- (C <= p) ## == (col(A1)+row(A1) <= p+1)
    A1[B] <- phi[C[B]]

    A2 <- matrix(0,r,q+1)
    C <- (col(A2)+row(A2)-1)
    B <- (C <= q+1)
    A2[B] <- ttheta[C[B]]

    A <- cbind(A1,A2)
    if (p==0) {
        S <- diag(q+1)
    }
    else {
        ## Compute the autocovariance function of U, the AR part of X
        r2 <- max(p+q, p+1)
        tphi <- c(1,-phi)

        C1 <- C2 <- matrix(0,r2,r2)
        F <- row(C1)-col(C1)+1
        E <- (1 <= F) & (F <= p+1)
        C1[E] <- tphi[F[E]]

        F <- col(C2)+row(C2)-1
        E <- (F <= p+1) & col(C2) >= 2
        C2[E] <- tphi[F[E]]

        Gam <- C1 + C2
        g <- matrix(0,r2,1)
        g[1] <- 1
        rU <- solve(Gam, g, tol=tol)
        ##    ---------  --
        SU <- toeplitz(rU[1:(p+q),1])
        ## End of the difference equations method

        ## Then, compute correlation matrix of X
        A2 <- matrix(0,p,p+q)
        C <- col(A2)-row(A2)+1
        B <- (1 <= C) & (C <= q+1)
        A2[B] <- ttheta[C[B]]
        SX <- A2 %*% SU %*% t(A2)

        ## Now, compute correlation matrix between X and Z
        C1 <- matrix(0,q,q)
        F <- row(C1)-col(C1)+1
        E <- 1 <= F & F <= p+1
        C1[E] <- tphi[F[E]]
        g <- matrix(0,q,1)
        if (q) {
            g[1:q,1] <- ttheta[1:q]
            rXZ <- forwardsolve(C1,g)
        } else rXZ <- numeric()
        SXZ <- matrix(0, p, q+1)
        F <- col(SXZ)-row(SXZ)
        E <- F >= 1
        SXZ[E] <- rXZ[F[E]]
        S <- rbind(cbind(  SX  ,   SXZ),
                   cbind(t(SXZ), diag(q+1)))
    }
    A %*% S %*% t(A)
    ## == 2 x 2 Block matrix product; A = [A1 | A2 ]
    ## == A1 SX A1' + A1 SXZ A2' + (A1 SXZ A2')' + A2 A2'

}## {Q0bis}

## The second way is to resolve brutally the equation of Gardner et al. in the
## form (12), page 314 of their paper.

Q0ter <- function(phi,theta) {
  p <- length(phi)
  q <- length(theta)
  r <- max(p,q+1)
  T <- V <- matrix(0,r,r)
  if (p) T[1:p,1] <- phi
  if (r >= 2) T[1:(r-1),2:r] <- diag(r-1)
  ttheta <- c(1,theta)
  V[1:(q+1),1:(q+1)] <- ttheta %x% t(ttheta)
  S <- diag(r*r) - T %x% T
  Q0 <- solve(S, c(V))
  matrix(Q0, ncol=r)
}

Q0.orig <- function(phi,theta) .Call(stats:::C_getQ0, phi, theta)

Q0bisC <- function(phi,theta, tol=.Machine$double.eps)
    .Call(stats:::C_getQ0bis, phi, theta, tol=tol)

##' The k smallest eigenvalues of m
EV.k <- function(m, k = 2) {
    ev <- eigen(m, only.values=TRUE)$values
    m <- length(ev)
    ev[m:(m-k+1)]
}

chkQ0 <- function(phi,theta, tol=.Machine$double.eps^0.5,
                  tolC=1e-15, strict=TRUE, doEigen=FALSE)
{
  Q0  <- Q0.orig(phi, theta)
  Q0bis <- Q0bis(phi, theta)
  Q0ter <- Q0ter(phi, theta)

  eig <- if(doEigen) rbind("0" = EV.k(Q0), bis = EV.k(Q0bis), ter = EV.k(Q0ter))
  ## else NULL

  a.eq <- list(cRC = all.equal(Q0bis,Q0bisC(phi,theta), tol= tolC),
               c12 = all.equal(Q0,   Q0bis, tol=tol),
               c13 = all.equal(Q0,   Q0ter, tol=tol),
               c23 = all.equal(Q0bis,Q0ter, tol=tol))
  if(strict) do.call(stopifnot, a.eq)
  invisible(list(Q0 = Q0, Q0bis = Q0bis, Q0ter = Q0ter,
                 all.eq = a.eq, eigen = eig))
}

##' @title AR-phi corresponding to AR(1) + Seasonality(s)
##' @param s: seasonality
##' @param phi1, phis: phi[1], phi[s] .. defaults: close to non-stationarity
mkPhi <- function(s, phi1 = 0.0001, phis = 0.99) {
    stopifnot(length(s) > 0, s == as.integer(s), s >= 2,
              length(phi1) == 1, is.numeric(phi1), length(phis) == 1)
    c(phi1, rep(0, s-2), phis, -phi1*phis)
}

##--{end of function defs}-------------------------------------------------------

## cases with p=0, q=0 :
chkQ0(numeric(), numeric())
chkQ0(   .5,     numeric())
chkQ0(numeric(), .7)
chkQ0(numeric(), c(.7, .2))

chkQ <- function(s, theta) chkQ0(mkPhi(s=s), theta=theta, tol = 0, strict=FALSE)
all.eq2num <- function(ae) as.numeric(sub(".* difference: ", '', ae))
getN12 <- function(r) all.eq2num(r$all.eq$c12)
ss <- setNames(,2:20)
chk0 <- lapply(ss, chkQ, theta= numeric())
chk1 <- lapply(ss, chkQ, theta= 0.75)
chk2 <- lapply(ss, chkQ, theta= c(0.75, -0.5))
chks <- list(q0 = chk0, q1 = chk1, q2 = chk2)
## Quite platform dependent, in F19, 32 bit looks slightly better than 64:
(re <- sapply(chks, function(C) sapply(C, getN12)))
matplot(ss, re, type = "b", log="y", pch = paste(0:2))
stopifnot(re[paste(2:7),] < 1e-7, # max(.) seen 9.626e-9
          re < 0.9) # max(.) seen 0.395

## The smallest few eigen values:
round(t(sapply(lapply(chk1, `[[`, "Q0"), EV.k, k=3)), 3)
ev3.0 <- lapply(chks, function(ck) t(sapply(lapply(ck, `[[`, "Q0"), EV.k, k=3)))
lapply(ev3.0, round, digits=3) ## problem for q >= 1 (none for q=0)
ev3.bis <- lapply(chks, function(ck) t(sapply(lapply(ck, `[[`, "Q0bis"), EV.k, k=3)))
lapply(ev3.bis[-1], round, digits=3) ## all fine
e1.bis <- sapply(ev3.bis, function(m) m[,1])
min(e1.bis) # -7.1e-15 , -7.5e-15
stopifnot(e1.bis > -1e-12)


## Now Rossignol's example
phi <- mkPhi(s = 12)
theta <- 0.7
true.cf <- c(ar1=phi[1], ma1=theta, sar1=phi[12])
tt <- chkQ0(phi,theta, tol=0.50, doEigen=TRUE)
tt$eigen

out.0 <- makeARIMA(phi, theta, NULL)
out.R <- makeARIMA(phi, theta, NULL, SSinit="Rossignol")

set.seed(7)
x <- arima.sim(1000,model=list(ar=phi,ma=theta))
str(k0 <- KalmanLike(x, mod=out.0))
str(kS <- KalmanLike(x, mod=out.R))
stopifnot(sapply(kS, is.finite))

ini.ph <- true.cf
## Default  method = "CSS-ML" works fine
fm1 <- arima(x, order= c(1,0,1), seasonal= list(period=12, order=c(1,0,0)),
             include.mean=FALSE, init=ini.ph)
stopifnot(all.equal(true.cf, coef(fm1), tol = 0.05))

## Using  'ML'  seems "harder" :
e1 <- try(
arima(x, order= c(1,0,1), seasonal= list(period=12, order=c(1,0,0)),
      include.mean=FALSE, init=ini.ph, method='ML')
)
## Error: NAs in 'phi'
e2 <- try(
arima(x, order= c(1,0,1), seasonal= list(period=12, order=c(1,0,0)),
      include.mean=FALSE, init=ini.ph, method='ML', transform.pars=FALSE)
)
## Error in optim(init[mask], armafn, ..): initial value in 'vmmin' is not finite

## MM: The new Q0 does *not* help here, really:
e3 <- try(
arima(x, order= c(1,0,1), seasonal= list(period=12, order=c(1,0,0)),
      include.mean=FALSE, init=ini.ph, method='ML', SSinit = "Rossi")
 )
## actually fails still, but *not* transforming parameters works :
fm2 <-
arima(x, order= c(1,0,1), seasonal= list(period=12, order=c(1,0,0)),
      include.mean=FALSE, init=ini.ph, method='ML', SSinit = "Rossi", transform.p=FALSE)

stopifnot(all.equal(confint(fm1),
                    confint(fm2), tol = 4e-4))

###---------- PR#16278 --------------------------------------

##  xreg  *and*  differentiation order d >= 1 :
set.seed(0)
n <- 5
x <- cumsum(rnorm(n, sd=0.01))
Vr <- var(diff(x))                 # 6.186e-5 : REML
V. <- var(diff(x)) * (n-2) / (n-1) # 4.640e-5 : ML

f00   <- arima0(x, c(0,1,0), method="ML", xreg=1:n)
(fit1 <- arima (x, c(0,1,0), method="ML", xreg=1:n))
stopifnot(all.equal(fit1$sigma2, V.), fit1$nobs == n-1,
	  all.equal(fit1$loglik, 14.28, tol=4e-4),
	  all.equal(f00$sigma2, fit1$sigma2),
	  all.equal(f00$loglik, fit1$loglik))

(fit2 <- arima (x, c(0,2,0), method="ML", xreg=(1:n)^2))
stopifnot(all.equal(fit2$sigma2, 0.000109952342),
          all.equal(fit2$loglik, 9.4163797), fit2$nobs == n-2)

## "well"-fitting higher order model  {optim failed in R <= 3.0.1)
n <- length(x. <- c(1:4,3:-2,2*(0:3),4:5,5:-4)/32)
xr <- poly(x., 3)
x. <- cumsum(cumsum(cumsum(x.))) + xr %*% 10^(0:2)
(fit3 <- arima (x., c(0,3,0), method="ML", xreg = xr))
stopifnot(fit3$ nobs == n-3,
	  all.equal(fit3$ sigma2, 0.00859843, tol = 1e-6),
	  all.equal(fit3$ loglik, 22.06043, tol = 1e-6),
          all.equal(unname(coef(fit3)),
                    c(0.70517, 9.9415, 100.106), tol = 1e-5))

x.[5:6] <- NA
(fit3N <- arima (x., c(0,3,0), method="ML", xreg = xr))
stopifnot(fit3N$ nobs == n-3-2, # ==  #{obs} - d - #{NA}
	  all.equal(fit3N$ sigma2, 0.009297345, tol = 1e-6),
	  all.equal(fit3N$ loglik, 16.73918,    tol = 1e-6),
	  all.equal(unname(coef(fit3N)),
		    c(0.64904, 9.92660, 100.126), tol = 1e-5))

