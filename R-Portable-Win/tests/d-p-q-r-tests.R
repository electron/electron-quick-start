####	d|ensity
####	p|robability (cumulative)
####	q|uantile
####	r|andom number generation
####
####	Functions for  ``d/p/q/r''

.ptime <- proc.time()
F <- FALSE
T <- TRUE

options(warn = 2)
##      ======== No warnings, unless explicitly asserted via
assertWarning <- tools::assertWarning

as.nan <- function(x) { x[is.na(x) & !is.nan(x)] <- NaN ; x }
###-- these are identical in ./arith-true.R ["fixme": use source(..)]
opt.conformance <- 0
Meps <- .Machine $ double.eps
xMax <- .Machine $ double.xmax
options(rErr.eps = 1e-30)
rErr <- function(approx, true, eps = getOption("rErr.eps", 1e-30))
{
    ifelse(Mod(true) >= eps,
	   1 - approx / true, # relative error
	   true - approx)     # absolute error (e.g. when true=0)
}
## Numerical equality: Here want "rel.error" almost always:
All.eq <- function(x,y) {
    all.equal.numeric(x,y, tolerance = 64*.Machine$double.eps,
                      scale = max(0, mean(abs(x), na.rm=TRUE)))
}
if(!interactive())
    set.seed(123)

## The prefixes of ALL the PDQ & R functions
PDQRinteg <- c("binom", "geom", "hyper", "nbinom", "pois","signrank","wilcox")
PDQR <- c(PDQRinteg, "beta", "cauchy", "chisq", "exp", "f", "gamma",
	  "lnorm", "logis", "norm", "t","unif","weibull")
PQonly <- c("tukey")

###--- Discrete Distributions --- Consistency Checks  pZZ = cumsum(dZZ)

##for(pre in PDQRinteg) { n <- paste("d",pre,sep=""); cat(n,": "); str(get(n))}

##__ 1. Binomial __

## Cumulative Binomial '==' Cumulative F :
## Abramowitz & Stegun, p.945-6;  26.5.24  AND	26.5.28 :
n0 <- 50; n1 <- 16; n2 <- 20; n3 <- 8
for(n in rbinom(n1, size = 2*n0, p = .4)) {
    for(p in c(0,1,rbeta(n2, 2,4))) {
	for(k in rbinom(n3, size = n,  prob = runif(1)))
	    ## For X ~ Bin(n,p), compute 1 - P[X > k] = P[X <= k] in three ways:
	    stopifnot(all.equal(       pbinom(0:k, size = n, prob = p),
				cumsum(dbinom(0:k, size = n, prob = p))),
		      all.equal(if(k==n || p==0) 1 else
				pf((k+1)/(n-k)*(1-p)/p, df1=2*(n-k), df2=2*(k+1)),
				sum(dbinom(0:k, size = n, prob = p))))
    }
}

##__ 2. Geometric __
for(pr in seq(1e-10,1,len=15)) # p=0 is not a distribution
    stopifnot(All.eq((dg <- dgeom(0:10, pr)),
		     pr * (1-pr)^(0:10)),
	      All.eq(cumsum(dg), pgeom(0:10, pr)))


##__ 3. Hypergeometric __

m <- 10; n <- 7
for(k in 2:m) {
    x <- 0:(k+1)
    stopifnot(All.eq(phyper(x, m, n, k), cumsum(dhyper(x, m, n, k))))
}

##__ 4. Negative Binomial __

## PR #842
for(size in seq(0.8,2, by=.1))
    stopifnot(all.equal(cumsum(dnbinom(0:7, size, .5)),
			       pnbinom(0:7, size, .5)))
stopifnot(All.eq(pnbinom(c(1,3), .9, .5),
		 c(0.777035760338812, 0.946945347071519)))

##__ 5. Poisson __

stopifnot(dpois(0:5,0)		 == c(1, rep(0,5)),
	  dpois(0:5,0, log=TRUE) == c(0, rep(-Inf, 5)))

## Cumulative Poisson '==' Cumulative Chi^2 :
## Abramowitz & Stegun, p.941 :	 26.4.21 (26.4.2)
n1 <- 20; n2 <- 16
for(lambda in rexp(n1))
    for(k in rpois(n2, lambda))
	stopifnot(all.equal(1 - pchisq(2*lambda, 2*(1+ 0:k)),
			    pp <- cumsum(dpois(0:k, lambda=lambda)),
			    tolerance = 100*Meps),
		  all.equal(pp, ppois(0:k, lambda=lambda), tolerance = 100*Meps),
		  all.equal(1 - pp, ppois(0:k, lambda=lambda, lower.tail = FALSE)))


##__ 6. SignRank __
for(n in rpois(32, lam=8)) {
    x <- -1:(n + 4)
    stopifnot(All.eq(psignrank(x, n), cumsum(dsignrank(x, n))))
}

##__ 7. Wilcoxon (symmetry & cumulative) __
is.sym <- TRUE
for(n in rpois(5, lam=6))
    for(m in rpois(15, lam=8)) {
	x <- -1:(n*m + 1)
	fx <- dwilcox(x, n, m)
	Fx <- pwilcox(x, n, m)
	is.sym <- is.sym & all(fx == dwilcox(x, m, n))
	stopifnot(All.eq(Fx, cumsum(fx)))
    }
stopifnot(is.sym)


###-------- Continuous Distributions ----------

##---  Gamma (incl. central chi^2) Density :
x <- round(rgamma(100, shape = 2),2)
for(sh in round(rlnorm(30),2)) {
    Ga <- gamma(sh)
    for(sig in round(rlnorm(30),2))
	stopifnot(all.equal((d1 <- dgamma(	 x,   shape = sh, scale = sig)),
                            (d2 <- dgamma(x/sig, shape = sh, scale = 1) / sig),
                            tolerance = 1e-14)## __ad interim__ was 1e-15
                  ,
                  All.eq(d1, (d3 <- 1/(Ga * sig^sh) * x^(sh-1) * exp(-x/sig)))
                  )
}

stopifnot(pgamma(1,Inf,scale=Inf) == 0)
## Also pgamma(Inf,Inf) == 1 for which NaN was slightly more appropriate
assertWarning(stopifnot(
    is.nan(c(pgamma(Inf,  1,scale=Inf),
             pgamma(Inf,Inf,scale=Inf)))))
scLrg <- c(2,100, 1e300*c(.1, 1,10,100), 1e307, xMax, Inf)
stopifnot(pgamma(Inf, 1, scale=xMax) == 1,
          pgamma(xMax,1, scale=Inf) == 0,
          all.equal(pgamma(1e300, 2, scale= scLrg, log=TRUE),
                    c(0, 0, -0.000499523968713701, -1.33089326820406,
                      -5.36470502873211, -9.91015144019122,
                      -32.9293385491433, -38.707517174609, -Inf),
                    tolerance = 2e-15)
          )

p <- 7e-4; df <- 0.9
stopifnot(
abs(1-c(pchisq(qchisq(p, df),df)/p, # was 2.31e-8 for R <= 1.8.1
        pchisq(qchisq(1-p, df,lower=FALSE),df,lower=FALSE)/(1-p),# was 1.618e-11
        pchisq(qchisq(log(p), df,log=TRUE),df, log=TRUE)/log(p), # was 3.181e-9
        pchisq(qchisq(log1p(-p),df,log=T,lower=F),df, log=T,lower=F)/log1p(-p)
        )# 32b-i386: (2.2e-16, 0,0, 3.3e-16); Opteron: (2.2e-16, 0,0, 2.2e-15)
    ) < 1e-14
)

##-- non central Chi^2 :
xB <- c(2000,1e6,1e50,Inf)
for(df in c(0.1, 1, 10))
    for(ncp in c(0, 1, 10, 100)) stopifnot(pchisq(xB, df=df, ncp=ncp) == 1)
stopifnot(all.equal(qchisq(0.025,31,ncp=1,lower.tail=FALSE),# inf.loop PR#875
                    49.7766246561514, tolerance = 1e-11))
for(df in c(0.1, 0.5, 1.5, 4.7, 10, 20,50,100)) {
    xx <- c(10^-(5:1), .9, 1.2, df + c(3,7,20,30,35,38))
    pp <- pchisq(xx, df=df, ncp = 1) #print(pp)
    dtol <- 1e-12 *(if(2 < df && df <= 50) 64 else if(df > 50) 20000 else 501)
    stopifnot(all.equal(xx, qchisq(pp, df=df, ncp=1), tolerance = dtol))
}

## p ~= 1 (<==> 1-p ~= 0) -- gave infinite loop in R <= 1.8.1 -- PR#6421
psml <- 2^-(10:54)
q0 <- qchisq(psml,    df=1.2, ncp=10, lower.tail=FALSE)
q1 <- qchisq(1-psml, df=1.2, ncp=10) # inaccurate in the tail
p0 <- pchisq(q0, df=1.2, ncp=10, lower.tail=FALSE)
p1 <- pchisq(q1, df=1.2, ncp=10, lower.tail=FALSE)
iO <- 1:30
stopifnot(all.equal(q0[iO], q1[iO], tolerance = 1e-5),# 9.86e-8
          all.equal(p0[iO], psml[iO])) # 1.07e-13

##--- Beta (need more):

## big a & b (PR #643)
stopifnot(is.finite(a <- rlnorm(20, 5.5)), a > 0,
          is.finite(b <- rlnorm(20, 6.5)), b > 0)
pab <- expand.grid(seq(0,1,by=.1), a, b)
p <- pab[,1]; a <- pab[,2]; b <- pab[,3]
stopifnot(all.equal(dbeta(p,a,b),
                    exp(pab <- dbeta(p,a,b, log = TRUE)), tolerance = 1e-11))
sp <- sample(pab, 50)
if(!interactive())
stopifnot(which(isI <- sp == -Inf) ==
              c(3, 11, 15, 20, 22, 23, 30, 39, 42, 43, 46, 47, 49),
          all.equal(range(sp[!isI]), c(-2906.123981, 2.197270387))
          )


##--- Normal (& Lognormal) :

stopifnot(
    qnorm(0) == -Inf, qnorm(-Inf, log = TRUE) == -Inf,
    qnorm(1) ==  Inf, qnorm( 0,   log = TRUE) ==  Inf)

assertWarning(stopifnot(
    is.nan(qnorm(1.1)),
    is.nan(qnorm(-.1))))

x <- c(-Inf, -1e100, 1:6, 1e200, Inf)
stopifnot(
    dnorm(x,3,s=0) == c(0,0,0,0, Inf, 0,0,0,0,0),
    pnorm(x,3,s=0) == c(0,0,0,0,  1 , 1,1,1,1,1),
    dnorm(x,3,s=Inf) == 0,
    pnorm(x,3,s=Inf) == c(0, rep(0.5, 8), 1))

## 3 Test data from Wichura (1988) :
stopifnot(
    all.equal(qnorm(c( 0.25,  .001, 1e-20)),
	      c(-0.6744897501960817, -3.090232306167814, -9.262340089798408),
	      tolerance = 1e-15)
  , ## extreme tail -- available on log scale only:
    all.equal(qnorm(-1e5, log = TRUE), -447.1974945)
)

z <- rnorm(1000); all.equal(pnorm(z),  1 - pnorm(-z), tolerance = 1e-15)
z <- c(-Inf,Inf,NA,NaN, rt(1000, df=2))
z.ok <- z > -37.5 | !is.finite(z)
for(df in 1:10) stopifnot(all.equal(pt(z, df), 1 - pt(-z,df), tolerance = 1e-15))

stopifnot(All.eq(pz <- pnorm(z), 1 - pnorm(z, lower=FALSE)),
          All.eq(pz,		    pnorm(-z, lower=FALSE)),
          All.eq(log(pz[z.ok]), pnorm(z[z.ok], log=TRUE)))
y <- seq(-70,0, by = 10)
cbind(y, "log(pnorm(y))"= log(pnorm(y)), "pnorm(y, log=T)"= pnorm(y, log=TRUE))
y <- c(1:15, seq(20,40, by=5))
cbind(y, "log(pnorm(y))"= log(pnorm(y)), "pnorm(y, log=T)"= pnorm(y, log=TRUE),
      "log(pnorm(-y))"= log(pnorm(-y)), "pnorm(-y, log=T)"= pnorm(-y, log=TRUE))
## Symmetry:
y <- c(1:50,10^c(3:10,20,50,150,250))
y <- c(-y,0,y)
for(L in c(FALSE,TRUE))
    stopifnot(identical(pnorm(-y, log= L),
			pnorm(+y, log= L, lower=FALSE)))

## Log norm
stopifnot(All.eq(pz, plnorm(exp(z))))


###==========  p <-> q	Inversion consistency =====================
ok <- 1e-5 < pz & pz < 1 - 1e-5
all.equal(z[ok], qnorm(pz[ok]), tolerance = 1e-12)

###===== Random numbers -- first, just output:

set.seed(123)
# .Random.seed <- c(0L, 17292L, 29447L, 24113L)
n <- 20
## for(pre in PDQR) { n <- paste("r",pre,sep=""); cat(n,": "); str(get(n))}
(Rbeta	  <- rbeta    (n, shape1 = .8, shape2 = 2) )
(Rbinom	  <- rbinom   (n, size = 55, prob = pi/16) )
(Rcauchy  <- rcauchy  (n, location = 12, scale = 2) )
(Rchisq	  <- rchisq   (n, df = 3) )
(Rexp	  <- rexp     (n, rate = 2) )
(Rf	  <- rf	      (n, df1 = 12, df2 = 6) )
(Rgamma	  <- rgamma   (n, shape = 2, scale = 5) )
(Rgeom	  <- rgeom    (n, prob = pi/16) )
(Rhyper	  <- rhyper   (n, m = 40, n = 30, k = 20) )
(Rlnorm	  <- rlnorm   (n, meanlog = -1, sdlog = 3) )
(Rlogis	  <- rlogis   (n, location = 12, scale = 2) )
(Rnbinom  <- rnbinom  (n, size = 7, prob = .01) )
(Rnorm	  <- rnorm    (n, mean = -1, sd = 3) )
(Rpois	  <- rpois    (n, lambda = 12) )
(Rsignrank<- rsignrank(n, n = 47) )
(Rt	  <- rt	      (n, df = 11) )
## Rt2 below (to preserve the following random numbers!)
(Runif	  <- runif    (n, min = .2, max = 2) )
(Rweibull <- rweibull (n, shape = 3, scale = 2) )
(Rwilcox  <- rwilcox  (n, m = 13, n = 17) )
(Rt2	  <- rt	      (n, df = 1.01))

(Pbeta	  <- pbeta    (Rbeta, shape1 = .8, shape2 = 2) )
(Pbinom	  <- pbinom   (Rbinom, size = 55, prob = pi/16) )
(Pcauchy  <- pcauchy  (Rcauchy, location = 12, scale = 2) )
(Pchisq	  <- pchisq   (Rchisq, df = 3) )
(Pexp	  <- pexp     (Rexp, rate = 2) )
(Pf	  <- pf	      (Rf, df1 = 12, df2 = 6) )
(Pgamma	  <- pgamma   (Rgamma, shape = 2, scale = 5) )
(Pgeom	  <- pgeom    (Rgeom, prob = pi/16) )
(Phyper	  <- phyper   (Rhyper, m = 40, n = 30, k = 20) )
(Plnorm	  <- plnorm   (Rlnorm, meanlog = -1, sdlog = 3) )
(Plogis	  <- plogis   (Rlogis, location = 12, scale = 2) )
(Pnbinom  <- pnbinom  (Rnbinom, size = 7, prob = .01) )
(Pnorm	  <- pnorm    (Rnorm, mean = -1, sd = 3) )
(Ppois	  <- ppois    (Rpois, lambda = 12) )
(Psignrank<- psignrank(Rsignrank, n = 47) )
(Pt	  <- pt	      (Rt,  df = 11) )
(Pt2	  <- pt	      (Rt2, df = 1.01) )
(Punif	  <- punif    (Runif, min = .2, max = 2) )
(Pweibull <- pweibull (Rweibull, shape = 3, scale = 2) )
(Pwilcox  <- pwilcox  (Rwilcox, m = 13, n = 17) )

dbeta	 (Rbeta, shape1 = .8, shape2 = 2)
dbinom	 (Rbinom, size = 55, prob = pi/16)
dcauchy	 (Rcauchy, location = 12, scale = 2)
dchisq	 (Rchisq, df = 3)
dexp	 (Rexp, rate = 2)
df	 (Rf, df1 = 12, df2 = 6)
dgamma	 (Rgamma, shape = 2, scale = 5)
dgeom	 (Rgeom, prob = pi/16)
dhyper	 (Rhyper, m = 40, n = 30, k = 20)
dlnorm	 (Rlnorm, meanlog = -1, sdlog = 3)
dlogis	 (Rlogis, location = 12, scale = 2)
dnbinom	 (Rnbinom, size = 7, prob = .01)
dnorm	 (Rnorm, mean = -1, sd = 3)
dpois	 (Rpois, lambda = 12)
dsignrank(Rsignrank, n = 47)
dt	 (Rt, df = 11)
dunif	 (Runif, min = .2, max = 2)
dweibull (Rweibull, shape = 3, scale = 2)
dwilcox	 (Rwilcox, m = 13, n = 17)

## Check q*(p*(.)) = identity
All.eq(Rbeta,	  qbeta	   (Pbeta, shape1 = .8, shape2 = 2))
All.eq(Rbinom,	  qbinom   (Pbinom, size = 55, prob = pi/16))
All.eq(Rcauchy,	  qcauchy  (Pcauchy, location = 12, scale = 2))
All.eq(Rchisq,	  qchisq   (Pchisq, df = 3))
All.eq(Rexp,	  qexp	   (Pexp, rate = 2))
All.eq(Rf,	  qf	   (Pf, df1 = 12, df2 = 6))
All.eq(Rgamma,	  qgamma   (Pgamma, shape = 2, scale = 5))
All.eq(Rgeom,	  qgeom	   (Pgeom, prob = pi/16))
All.eq(Rhyper,	  qhyper   (Phyper, m = 40, n = 30, k = 20))
All.eq(Rlnorm,	  qlnorm   (Plnorm, meanlog = -1, sdlog = 3))
All.eq(Rlogis,	  qlogis   (Plogis, location = 12, scale = 2))
All.eq(Rnbinom,	  qnbinom  (Pnbinom, size = 7, prob = .01))
All.eq(Rnorm,	  qnorm	   (Pnorm, mean = -1, sd = 3))
All.eq(Rpois,	  qpois	   (Ppois, lambda = 12))
All.eq(Rsignrank, qsignrank(Psignrank, n = 47))
All.eq(Rt,	  qt	   (Pt,	 df = 11))
All.eq(Rt2,	  qt	   (Pt2, df = 1.01))
All.eq(Runif,	  qunif	   (Punif, min = .2, max = 2))
All.eq(Rweibull,  qweibull (Pweibull, shape = 3, scale = 2))
All.eq(Rwilcox,	  qwilcox  (Pwilcox, m = 13, n = 17))

## Same with "upper tail":
All.eq(Rbeta,	  qbeta	   (1- Pbeta, shape1 = .8, shape2 = 2, lower=F))
All.eq(Rbinom,	  qbinom   (1- Pbinom, size = 55, prob = pi/16, lower=F))
All.eq(Rcauchy,	  qcauchy  (1- Pcauchy, location = 12, scale = 2, lower=F))
All.eq(Rchisq,	  qchisq   (1- Pchisq, df = 3, lower=F))
All.eq(Rexp,	  qexp	   (1- Pexp, rate = 2, lower=F))
All.eq(Rf,	  qf	   (1- Pf, df1 = 12, df2 = 6, lower=F))
All.eq(Rgamma,	  qgamma   (1- Pgamma, shape = 2, scale = 5, lower=F))
All.eq(Rgeom,	  qgeom	   (1- Pgeom, prob = pi/16, lower=F))
All.eq(Rhyper,	  qhyper   (1- Phyper, m = 40, n = 30, k = 20, lower=F))
All.eq(Rlnorm,	  qlnorm   (1- Plnorm, meanlog = -1, sdlog = 3, lower=F))
All.eq(Rlogis,	  qlogis   (1- Plogis, location = 12, scale = 2, lower=F))
All.eq(Rnbinom,	  qnbinom  (1- Pnbinom, size = 7, prob = .01, lower=F))
All.eq(Rnorm,	  qnorm	   (1- Pnorm, mean = -1, sd = 3,lower=F))
All.eq(Rpois,	  qpois	   (1- Ppois, lambda = 12, lower=F))
All.eq(Rsignrank, qsignrank(1- Psignrank, n = 47, lower=F))
All.eq(Rt,	  qt	   (1- Pt,  df = 11,   lower=F))
All.eq(Rt2,	  qt	   (1- Pt2, df = 1.01, lower=F))
All.eq(Runif,	  qunif	   (1- Punif, min = .2, max = 2, lower=F))
All.eq(Rweibull,  qweibull (1- Pweibull, shape = 3, scale = 2, lower=F))
All.eq(Rwilcox,	  qwilcox  (1- Pwilcox, m = 13, n = 17, lower=F))

## Check q*(p* ( log ), log) = identity
All.eq(Rbeta,	  qbeta	   (log(Pbeta), shape1 = .8, shape2 = 2, log=TRUE))
All.eq(Rbinom,	  qbinom   (log(Pbinom), size = 55, prob = pi/16, log=TRUE))
All.eq(Rcauchy,	  qcauchy  (log(Pcauchy), location = 12, scale = 2, log=TRUE))
All.eq(Rchisq,    qchisq   (log(Pchisq), df = 3, log=TRUE))
All.eq(Rexp,	  qexp	   (log(Pexp), rate = 2, log=TRUE))
All.eq(Rf,	  qf	   (log(Pf), df1= 12, df2= 6, log=TRUE))
All.eq(Rgamma,	  qgamma   (log(Pgamma), shape = 2, scale = 5, log=TRUE))
All.eq(Rgeom,	  qgeom	   (log(Pgeom), prob = pi/16, log=TRUE))
All.eq(Rhyper,	  qhyper   (log(Phyper), m = 40, n = 30, k = 20, log=TRUE))
All.eq(Rlnorm,	  qlnorm   (log(Plnorm), meanlog = -1, sdlog = 3, log=TRUE))
All.eq(Rlogis,	  qlogis   (log(Plogis), location = 12, scale = 2, log=TRUE))
All.eq(Rnbinom,	  qnbinom  (log(Pnbinom), size = 7, prob = .01, log=TRUE))
All.eq(Rnorm,	  qnorm	   (log(Pnorm), mean = -1, sd = 3, log=TRUE))
All.eq(Rpois,	  qpois	   (log(Ppois), lambda = 12, log=TRUE))
All.eq(Rsignrank, qsignrank(log(Psignrank), n = 47, log=TRUE))
All.eq(Rt,	  qt	   (log(Pt), df = 11, log=TRUE))
All.eq(Rt2,	  qt	   (log(Pt2), df = 1.01, log=TRUE))
All.eq(Runif,	  qunif	   (log(Punif), min = .2, max = 2, log=TRUE))
All.eq(Rweibull,  qweibull (log(Pweibull), shape = 3, scale = 2, log=TRUE))
All.eq(Rwilcox,	  qwilcox  (log(Pwilcox), m = 13, n = 17, log=TRUE))

## same q*(p* (log) log) with upper tail:

All.eq(Rbeta,	  qbeta	   (log1p(-Pbeta), shape1 = .8, shape2 = 2, lower=F, log=T))
All.eq(Rbinom,	  qbinom   (log1p(-Pbinom), size = 55, prob = pi/16, lower=F, log=T))
All.eq(Rcauchy,	  qcauchy  (log1p(-Pcauchy), location = 12, scale = 2, lower=F, log=T))
All.eq(Rchisq,	  qchisq   (log1p(-Pchisq), df = 3, lower=F, log=T))
All.eq(Rexp,	  qexp	   (log1p(-Pexp), rate = 2, lower=F, log=T))
All.eq(Rf,	  qf	   (log1p(-Pf), df1 = 12, df2 = 6, lower=F, log=T))
All.eq(Rgamma,	  qgamma   (log1p(-Pgamma), shape = 2, scale = 5, lower=F, log=T))
All.eq(Rgeom,	  qgeom	   (log1p(-Pgeom), prob = pi/16, lower=F, log=T))
All.eq(Rhyper,	  qhyper   (log1p(-Phyper), m = 40, n = 30, k = 20, lower=F, log=T))
All.eq(Rlnorm,	  qlnorm   (log1p(-Plnorm), meanlog = -1, sdlog = 3, lower=F, log=T))
All.eq(Rlogis,	  qlogis   (log1p(-Plogis), location = 12, scale = 2, lower=F, log=T))
All.eq(Rnbinom,	  qnbinom  (log1p(-Pnbinom), size = 7, prob = .01, lower=F, log=T))
All.eq(Rnorm,	  qnorm	   (log1p(-Pnorm), mean = -1, sd = 3, lower=F, log=T))
All.eq(Rpois,	  qpois	   (log1p(-Ppois), lambda = 12, lower=F, log=T))
All.eq(Rsignrank, qsignrank(log1p(-Psignrank), n = 47, lower=F, log=T))
All.eq(Rt,	  qt	   (log1p(-Pt ), df = 11,   lower=F, log=T))
All.eq(Rt2,	  qt	   (log1p(-Pt2), df = 1.01, lower=F, log=T))
All.eq(Runif,	  qunif	   (log1p(-Punif), min = .2, max = 2, lower=F, log=T))
All.eq(Rweibull,  qweibull (log1p(-Pweibull), shape = 3, scale = 2, lower=F, log=T))
All.eq(Rwilcox,	  qwilcox  (log1p(-Pwilcox), m = 13, n = 17, lower=F, log=T))


## Check log( upper.tail ):
All.eq(log1p(-Pbeta),	  pbeta	   (Rbeta, shape1 = .8, shape2 = 2, lower=F, log=T))
All.eq(log1p(-Pbinom),	  pbinom   (Rbinom, size = 55, prob = pi/16, lower=F, log=T))
All.eq(log1p(-Pcauchy),	  pcauchy  (Rcauchy, location = 12, scale = 2, lower=F, log=T))
All.eq(log1p(-Pchisq),	  pchisq   (Rchisq, df = 3, lower=F, log=T))
All.eq(log1p(-Pexp),	  pexp	   (Rexp, rate = 2, lower=F, log=T))
All.eq(log1p(-Pf),	  pf	   (Rf, df1 = 12, df2 = 6, lower=F, log=T))
All.eq(log1p(-Pgamma),	  pgamma   (Rgamma, shape = 2, scale = 5, lower=F, log=T))
All.eq(log1p(-Pgeom),	  pgeom	   (Rgeom, prob = pi/16, lower=F, log=T))
All.eq(log1p(-Phyper),	  phyper   (Rhyper, m = 40, n = 30, k = 20, lower=F, log=T))
All.eq(log1p(-Plnorm),	  plnorm   (Rlnorm, meanlog = -1, sdlog = 3, lower=F, log=T))
All.eq(log1p(-Plogis),	  plogis   (Rlogis, location = 12, scale = 2, lower=F, log=T))
All.eq(log1p(-Pnbinom),	  pnbinom  (Rnbinom, size = 7, prob = .01, lower=F, log=T))
All.eq(log1p(-Pnorm),	  pnorm	   (Rnorm, mean = -1, sd = 3, lower=F, log=T))
All.eq(log1p(-Ppois),	  ppois	   (Rpois, lambda = 12, lower=F, log=T))
All.eq(log1p(-Psignrank), psignrank(Rsignrank, n = 47, lower=F, log=T))
All.eq(log1p(-Pt),	  pt	   (Rt, df = 11,   lower=F, log=T))
All.eq(log1p(-Pt2),	  pt	   (Rt2,df = 1.01, lower=F, log=T))
All.eq(log1p(-Punif),	  punif	   (Runif, min = .2, max = 2, lower=F, log=T))
All.eq(log1p(-Pweibull),  pweibull (Rweibull, shape = 3, scale = 2, lower=F, log=T))
All.eq(log1p(-Pwilcox),	  pwilcox  (Rwilcox, m = 13, n = 17, lower=F, log=T))


### (Extreme) tail tests added more recently:
All.eq(1, -1e-17/ pexp(qexp(-1e-17, log=TRUE),log=TRUE))
abs(pgamma(30,100, lower=FALSE, log=TRUE) + 7.3384686328784e-24) < 1e-36
All.eq(1, pcauchy(-1e20)           /  3.18309886183791e-21)
All.eq(1, pcauchy(+1e15, log=TRUE) / -3.18309886183791e-16)## PR#6756
x <- 10^(ex <- c(1,2,5*(1:5),50,100,200,300,Inf))
for(a in x[ex > 10]) ## improve pt() : cbind(x,t= pt(-x, df=1), C=pcauchy(-x))
    stopifnot(all.equal(pt(-a, df=1), pcauchy(-a), tolerance = 1e-15))
## for PR#7902:
ex <- -c(rev(1/x), ex)
All.eq(-x, qcauchy(pcauchy(-x)))
All.eq(+x, qcauchy(pcauchy(+x, log=TRUE), log=TRUE))
All.eq(1/x, pcauchy(qcauchy(1/x)))
All.eq(ex,  pcauchy(qcauchy(ex, log=TRUE), log=TRUE))
II <- c(-Inf,Inf)
stopifnot(pcauchy(II) == 0:1, qcauchy(0:1) == II,
          pcauchy(II, log=TRUE) == c(-Inf,0),
          qcauchy(c(-Inf,0), log=TRUE) == II)
## PR#15521 :
p <- 1 - 1/4096
stopifnot(all.equal(qcauchy(p), 1303.7970381453319163, tolerance = 1e-14))

pr <- 1e-23 ## PR#6757
stopifnot(all.equal(pr^ 12, pbinom(11, 12, prob= pr,lower=FALSE),
                    tolerance = 1e-12, scale= 1e-270))
## pbinom(.) gave 0 in R 1.9.0
pp <- 1e-17 ## PR#6792
stopifnot(all.equal(2*pp, pgeom(1, pp), scale= 1e-20))
## pgeom(.) gave 0 in R 1.9.0

x <- 10^(100:295)
sapply(c(1e-250, 1e-25, 0.9, 1.1, 101, 1e10, 1e100),
       function(shape)
       All.eq(-x, pgamma(x, shape=shape, lower=FALSE, log=TRUE)))
x <- 2^(-1022:-900)
## where all completely off in R 2.0.1
all.equal(pgamma(x, 10, log = TRUE) - 10*log(x),
          rep(-15.104412573076, length(x)), tolerance = 1e-12)# 3.984e-14 (i386)
all.equal(pgamma(x, 0.1, log = TRUE) - 0.1*log(x),
          rep(0.0498724412598364, length(x)), tolerance = 1e-13)# 7e-16 (i386)

All.eq(dpois(  10*1:2, 3e-308, log=TRUE),
       c(-7096.08037610806, -14204.2875435307))
All.eq(dpois(1e20, 1e-290, log=TRUE), -7.12801378828154e+22)
## all gave -Inf in R 2.0.1


## Inf df in pf etc.
# apparently pf(df2=Inf) worked in 2.0.1 (undocumented) but df did not.
x <- c(1/pi, 1, pi)
oo <- options(digits = 8)
df(x, 3, 1e6)
df(x, 3, Inf)
pf(x, 3, 1e6)
pf(x, 3, Inf)

df(x, 1e6, 5)
df(x, Inf, 5)
pf(x, 1e6, 5)
pf(x, Inf, 5)

df(x, Inf, Inf)# (0, Inf, 0)  - since 2.1.1
pf(x, Inf, Inf)# (0, 1/2, 1)

pf(x, 5, Inf, ncp=0)
all.equal(pf(x, 5, 1e6, ncp=1), tolerance = 1e-6,
          c(0.065933194, 0.470879987, 0.978875867))
all.equal(pf(x, 5, 1e7, ncp=1), tolerance = 1e-6,
          c(0.06593309, 0.47088028, 0.97887641))
all.equal(pf(x, 5, 1e8, ncp=1), tolerance = 1e-6,
          c(0.0659330751, 0.4708802996, 0.9788764591))
pf(x, 5, Inf, ncp=1)

dt(1, Inf)
dt(1, Inf, ncp=0)
dt(1, Inf, ncp=1)
dt(1, 1e6, ncp=1)
dt(1, 1e7, ncp=1)
dt(1, 1e8, ncp=1)
dt(1, 1e10, ncp=1) # = Inf
## Inf valid as from 2.1.1: df(x, 1e16, 5) was way off in 2.0.1.

sml.x <- c(10^-c(2:8,100), 0)
cbind(x = sml.x, `dt(x,*)` = dt(sml.x, df = 2, ncp=1))
## small 'x' used to suffer from cancellation
options(oo)
x <- c(outer(1:12, 10^c(-3:2, 6:9, 10*(2:30))))
for(nu in c(.75, 1.2, 4.5, 999, 1e50)) {
    lfx <- dt(x, df=nu, log=TRUE)
    stopifnot(is.finite(lfx), All.eq(exp(lfx), dt(x, df=nu)))
}## dt(1e160, 1.2, log=TRUE) was -Inf  up to R 2.15.2

## pf() with large df1 or df2
## (was said to be PR#7099, but that is about non-central pchisq)
nu <- 2^seq(25, 34, 0.5)
target <- pchisq(1, 1) # 0.682...
y <- pf(1, 1, nu)
stopifnot(All.eq(pf(1, 1, Inf), target),
          diff(c(y, target)) > 0, # i.e. pf(1, 1, *) is monotone increasing
          abs(y[1] - (target - 7.21129e-9)) < 1e-11) # computed value
## non-monotone in R <= 2.1.0

stopifnot(pgamma(Inf, 1.1) == 1)
## didn't not terminate in R 2.1.x (only)

## qgamma(q, *) should give {0,Inf} for q={0,1}
sh <- c(1.1, 0.5, 0.2, 0.15, 1e-2, 1e-10)
stopifnot(Inf == qgamma(1, sh))
stopifnot(0   == qgamma(0, sh))
## the first gave Inf, NaN, and 99.425 in R 2.1.1 and earlier

## In extreme left tail {PR#11030}
p <- 10:123*1e-12
qg <- qgamma(p, shape=19)
qg2<- qgamma(1:100 * 1e-9, shape=11)
stopifnot(diff(qg, diff=2) < -6e-6,
          diff(qg2,diff=2) < -6e-6,
	  abs(1 - pgamma(qg, 19)/ p) < 1e-13,
          All.eq(qg  [1], 2.35047385139143),
          All.eq(qg2[30], 1.11512318734547))
## was non-continuous in R 2.6.2 and earlier

f2 <- c(0.5, 1:4)
stopifnot(df(0, 1, f2) == Inf,
          df(0, 2, f2) == 1,
          df(0, 3, f2) == 0)
## only the last one was ok in R 2.2.1 and earlier

x0 <- -2 * 10^-c(22,10,7,5) # ==> d*() warns about non-integer:
assertWarning(fx0 <- dbinom(x0, size = 3, prob = 0.1))
stopifnot(fx0 == 0,  pbinom(x0, size = 3, prob = 0.1) == 0)

## very small negatives were rounded to 0 in R 2.2.1 and earlier

## dbeta(*, ncp):
db.x <- c(0, 5, 80, 405, 1280, 3125, 6480, 12005, 20480, 32805,
	  50000, 73205, 103680, 142805, 192080, 253125, 327680)
a <- rlnorm(100)
stopifnot(All.eq(a, dbeta(0, 1, a, ncp=0)),
	  dbeta(0, 0.9, 2.2, ncp = c(0, a)) == Inf,
	  All.eq(65536 * dbeta(0:16/16, 5,1), db.x),
	  All.eq(exp(16 * log(2) + dbeta(0:16/16, 5,1, log=TRUE)), db.x)
          )
## the first gave 0, the 2nd NaN in R <= 2.3.0; others use 'TRUE' values
stopifnot(all.equal(dbeta(0.8, 0.5, 5, ncp=1000),# was way too small in R <= 2.6.2
		    3.001852308909e-35),
	  all.equal(1, integrate(dbeta, 0,1, 0.8, 0.5, ncp=1000)$value,
		    tolerance = 1e-4),
          all.equal(1, integrate(dbeta, 0,1, 0.5, 200, ncp=720)$value),
          all.equal(1, integrate(dbeta, 0,1, 125, 200, ncp=2000)$value)
          )

## df(*, ncp):
x <- seq(0, 10, length=101)
h <- 1e-7
dx.h <- (pf(x+h, 7, 5, ncp= 2.5) - pf(x-h, 7, 5, ncp= 2.5)) / (2*h)
stopifnot(all.equal(dx.h, df(x, 7, 5, ncp= 2.5), tolerance = 1e-6),# (1.50 | 1.65)e-8
          All.eq(df(0, 2, 4, ncp=x), df(1e-300, 2, 4, ncp=x))
          )

## qt(p ~ 0, df=1) - PR#9804
p <- 10^(-10:-20)
qtp <- qt(p, df = 1)
## relative error < 10^-14 :
stopifnot(abs(1 - p / pt(qtp, df=1)) < 1e-14)

## Similarly for df = 2 --- both for p ~ 0  *and*  p ~ 1/2
## P ~ 0
stopifnot(all.equal(qt(-740, df=2, log=TRUE), -exp(370)/sqrt(2)))
## P ~ 1 (=> p ~ 0.5):
p.5 <- 0.5 + 2^(-5*(5:8))
stopifnot(all.equal(qt(p.5, df = 2),
		    c(8.429369702179e-08, 2.634178031931e-09,
		      8.231806349784e-11, 2.572439484308e-12)))
## qt(<large>, log = TRUE)  is now more finite and monotone (again!):
stopifnot(all.equal(qt(-1000, df = 4, log=TRUE),
                    -4.930611e108, tolerance = 1e-6))
qtp <- qt(-(20:850), df=1.2, log=TRUE, lower=FALSE)
##almost: stopifnot(all(abs(5/6 - diff(log(qtp))) < 1e-11))
stopifnot(abs(5/6 - quantile(diff(log(qtp)), pr=c(0,0.995))) < 1e-11)

## close to df=1 (where Taylor steps are important!):
stopifnot(all.equal(-20, pt(qt(-20, df=1.02, log=TRUE),
                          df=1.02, log=TRUE), tolerance = 1e-12),
          diff(lq <- log(qt(-2^-(10:600), df=1.1, log=TRUE))) > 0.6)
lq1 <- log(qt(-2^-(20:600), df=1, log=TRUE))
lq2 <- log(qt(-2^-(20:600), df=2, log=TRUE))
stopifnot(mean(abs(diff(lq1) - log(2)      )) < 1e-8,
	  mean(abs(diff(lq2) - log(sqrt(2)))) < 4e-8)
## Case, where log.p=TRUE was fine, but log.p=FALSE (default) gave NaN:
lp <- 40:406
stopifnot(all.equal(lp, -pt(qt(exp(-lp), 1.2), 1.2, log=TRUE), tolerance = 4e-16))


## pbeta(*, log=TRUE) {toms708} -- now improved tail behavior
x <- c(.01, .10, .25, .40, .55, .71, .98)
pbval <- c(-0.04605755624088, -0.3182809860569, -0.7503593555585,
           -1.241555830932, -1.851527837938, -2.76044482378, -8.149862739881)
stopifnot(all.equal(pbeta(x, 0.8, 2, lower=FALSE, log=TRUE), pbval),
          all.equal(pbeta(1-x, 2, 0.8, log=TRUE), pbval))
qq <- 2^(0:1022)
df.set <- c(0.1, 0.2, 0.5, 1, 1.2, 2.2, 5, 10, 20, 50, 100, 500)
for(nu in df.set) {
    pqq <- pt(-qq, df = nu, log=TRUE)
    stopifnot(is.finite(pqq))
}
## PR#14230 -- more extreme beta cases {should no longer rely on denormalized}
x <- (256:512)/1024
P <- pbeta(x, 3, 2200, lower.tail=FALSE, log.p=TRUE)
stopifnot(is.finite(P), P < -600,
	  -.001 < (D3P <- diff(P, diff = 3)), D3P < 0, diff(D3P) < 0)
## all but the first 43 where -Inf in R <= 2.9.1
stopifnot(All.eq(pt(2^-30, df=10),
                 0.50000000036238542))
## = .5+ integrate(dt, 0,2^-30, df=10, rel.tol=1e-20)

## rbinom(*, size) gave NaN for large size up to R <= 2.6.1
M <- .Machine$integer.max
set.seed(7)
tt <- table(rbinom(100,    M, pr = 1e-9)) # had values in {0,2} only
t2 <- table(rbinom(100, 10*M, pr = 1e-10))
stopifnot(names(tt) == 0:6, sum(tt) == 100, sum(t2) == 100) ## no NaN there

## qf() with large df1, df2  and/or  small p:
x <- 0.01; f1 <- 1e60; f2 <- 1e90
stopifnot(qf(1/4, Inf, Inf) == 1,
	  all.equal(1, 1e-18/ pf(qf(1e-18, 12,50), 12,50), tolerance = 1e-10),
	  abs(x - qf(pf(x, f1,f2, log.p=TRUE), f1,f2, log.p=TRUE)) < 1e-4)

## qbeta(*, log.p) for "border" case:
stopifnot(is.finite(q0 <- qbeta(-1e10, 50,40, log.p=TRUE)),
          1 ==            qbeta(-1e10,  2, 3, log.p=TRUE, lower=FALSE))
## infinite loop or NaN in R <= 2.7.0

## phyper(x, 0,0,0), notably for huge x
stopifnot(all(phyper(c(0:3, 1e67), 0,0,0) == 1))
## practically infinite loop and NaN in R <= 2.7.1 (PR#11813)

## plnorm(<= 0, . , log.p=TRUE)
stopifnot(plnorm(-1:0, lower.tail=FALSE, log.p=TRUE) == 0,
	  plnorm(-1:0, lower.tail=TRUE,	 log.p=TRUE) == -Inf)
## was wrongly == 'log.p=FALSE' up to R <= 2.7.1 (PR#11867)


## pchisq(df=0) was wrong in 2.7.1; then, upto 2.10.1, P*(0,0) gave 1
stopifnot(pchisq(c(-1,0,1), df=0) == c(0,0,1),
          pchisq(c(-1,0,1), df=0, lower.tail=FALSE) == c(1,1,0),
	  ## for ncp >= 80, gave values >= 1 in 2.10.0
	  pchisq(500:700, 1.01, ncp = 80) <= 1)

## dnbinom for extreme  size and/or mu :
mu <- 20
d <- dnbinom(17, mu=mu, size = 1e11*2^(1:10)) - dpois(17, lambda=mu)
stopifnot(d < 0, diff(d) > 0, d[1] < 1e-10)
## was wrong up to 2.7.1
## The fix to the above, for x = 0, had a new cancellation problem
mu <- 1e12 * 2^(0:20)
stopifnot(all.equal(1/(1+mu), dnbinom(0, size = 1, mu = mu), tolerance = 1e-13))
## was wrong in 2.7.2 (only)
mu <- sort(outer(1:7, 10^c(0:10,50*(1:6))))
NB <- dnbinom(5, size=1e305, mu=mu, log=TRUE)
P  <- dpois  (5,                mu, log=TRUE)
stopifnot(abs(rErr(NB,P)) < 9*Meps)# seen 2.5*
## wrong in 3.1.0 and earlier


## Non-central F for large x
x <- 1e16 * 1.1 ^ (0:20)
dP <- diff(pf(x, df1=1, df2=1, ncp=20, lower.tail=FALSE, log=TRUE))
stopifnot(-0.047 < dP, dP < -0.0455)
## pf(*, log) jumped to -Inf prematurely in 2.8.0 and earlier


## Non-central Chi^2 density for large x
stopifnot(0 == dchisq(c(Inf, 1e80, 1e50, 1e40), df=10, ncp=1))
## did hang in 2.8.0 and earlier (PR#13309).


## qbinom() .. particularly for large sizes, small prob:
p.s <- c(.01, .001, .1, .25)
pr <- (2:20)*1e-7
sizes <- 1000*(5000 + c(0,6,16)) + 279
k.s <- 0:15; q.xct <- rep(k.s, each=length(pr))
for(sz in sizes) {
    for(p in p.s) {
	qb <- qbinom(p=p, size = sz, prob=pr)
	pb <- qpois (p=p, lambda = sz * pr)
	stopifnot(All.eq(qb, pb))
    }
    pp.x <- outer(pr, k.s, function(pr, q) pbinom(q, size = sz, prob=pr))
    qq.x <- apply(pp.x, 2, function(p)     qbinom(p, size = sz, prob=pr))
    stopifnot(qq.x == q.xct)
}
## do_search() in qbinom() contained a thinko up to 2.9.0 (PR#13711)


## pbeta(x, a,b, log=TRUE)  for small x and a  is ~ log-linear
x <- 2^-(200:10)
for(a in c(1e-8, 1e-12, 16e-16, 4e-16))
    for(b in c(0.6, 1, 2, 10)) {
        dp <- diff(pbeta(x, a, b, log=TRUE)) # constant approximately
        stopifnot(sd(dp) / mean(dp) < 0.0007)
    }
## had  accidental cancellation '1 - w'

## qgamma(p, a) for small a and (hence) small p
## pgamma(x, a) for very very small a
a <- 2^-seq(10,1000, .25)
q.1c <- qgamma(1e-100,a,lower.tail=FALSE)
q.3c <- qgamma(1e-300,a,lower.tail=FALSE)
p.1c <- pgamma(q.1c[q.1c > 0], a[q.1c > 0], lower.tail=FALSE)
p.3c <- pgamma(q.3c[q.3c > 0], a[q.3c > 0], lower.tail=FALSE)
x <- 1+1e-7*c(-1,1); pg <- pgamma(x, shape = 2^-64, lower.tail=FALSE)
stopifnot(qgamma(.99, .00001) == 0,
          abs(pg[2] - 1.18928249197237758088243e-20) < 1e-33,
	  abs(diff(pg) + diff(x)*dgamma(1, 2^-64)) < 1e-13 * mean(pg),
	  abs(1 - p.1c/1e-100) < 10e-13,# max = 2.243e-13 / 2.442 e-13
	  abs(1 - p.3c/1e-300) < 28e-13)# max = 7.057e-13
## qgamma() was wrong here, orders of magnitude up to R 2.10.0
## pgamma() had inaccuracies, e.g.,
## pgamma(x, shape = 2^-64, lower.tail=FALSE)  was discontinuous at x=1

stopifnot(all(qpois((0:8)/8, lambda=0) == 0))
## gave Inf as p==1 was checked *before* lambda==0

## extreme tail of non-central chisquare
stopifnot(all.equal(pchisq(200, 4, ncp=.001, log.p=TRUE), -3.851e-42))
## jumped to zero too early up to R 2.10.1 (PR#14216)
## left "extreme tail"
lp <- pchisq(2^-(0:200), 100, 1, log=TRUE)
stopifnot(is.finite(lp), lp < -184,
	  all.equal(lp[201], -7115.10693158))
dlp <- diff(lp)
dd <- abs(dlp[-(1:30)] - -34.65735902799)
stopifnot(-34.66 < dlp, dlp < -34.41, dd < 1e-8)# 2.2e-10 64bit Lnx
## underflowed to -Inf much too early in R <= 3.1.0
for(e in c(0, 2e-16))# continuity at 80 (= branch point)
stopifnot(all.equal(pchisq(1:2, 1.01, ncp = 80*(1-e), log=TRUE),
		    c(-34.57369629, -31.31514671)))

## logit() == qlogit() on the right extreme:
x <- c(10:80, 80 + 5*(1:24), 200 + 20*(1:25))
stopifnot(All.eq(x, qlogis(plogis(x, log.p=TRUE),
			   log.p=TRUE)))
## qlogis() gave Inf much too early for R <= 2.12.1
## Part 2:
x <- c(x, seq(700, 800, by=10))
stopifnot(All.eq(x, qlogis(plogis(x, lower=FALSE, log.p=TRUE),
			   lower=FALSE, log.p=TRUE)))
# plogis() underflowed to -Inf too early for R <= 2.15.0

## log upper tail pbeta():
x <- (25:50)/128
pbx <- pbeta(x, 1/2, 2200, lower.tail=FALSE, log.p=TRUE)
d2p <- diff(dp <- diff(pbx))
b <- 2200*2^(0:50)
y <- log(-pbeta(.28, 1/2, b, lower.tail=FALSE, log.p=TRUE))
stopifnot(-1094 < pbx, pbx < -481.66,
            -29 < dp,   dp < -20,
           -.36 < d2p, d2p < -.2,
          all.equal(log(b), y+1.113, tolerance = .00002)
          )
## pbx had two -Inf; y was all Inf  for R <= 2.15.3;  PR#15162

## dnorm(x) for "large" |x|
stopifnot(abs(1 - dnorm(35+3^-9)/ 3.933395747534971e-267) < 1e-15)
## has been losing up to 8 bit precision for R <= 3.0.x

## pbeta(x, <small a>,<small b>, .., log):
ldp <- diff(log(diff(pbeta(0.5, 2^-(90+ 1:25), 2^-60, log.p=TRUE))))
stopifnot(abs(ldp - log(1/2)) < 1e-9)
## pbeta(*, log) lost all precision here, for R <= 3.0.x (PR#15641)
##
## "stair function" effect (from denormalized numbers)
a <- 43779; b <- 0.06728
x. <- .9833 + (0:100)*1e-6
px <- pbeta(x., a,b, log=TRUE) # plot(x., px) # -> "stair"
d2. <- diff(dpx <- diff(px))
stopifnot(all.equal(px[1], -746.0986886924, tol=1e-12),
          0.0445741 < dpx, dpx < 0.0445783,
          -4.2e-8 < d2., d2. < -4.18e-8)
## were way off in R <= 3.1.0

c0 <- system.time(p0 <- pbeta(  .9999, 1e30, 1.001, log=TRUE))
cB <- max(.001, c0[[1]])# base time
c1 <- system.time(p1 <- pbeta(1- 1e-9, 1e30, 1.001, log=TRUE))
c2 <- system.time(p2 <- pbeta(1-1e-12, 1e30, 1.001, log=TRUE))
stopifnot(all.equal(p0, -1.000050003333e26, tol=1e-10),
          all.equal(p1, -1e21, tol = 1e-6),
          all.equal(p2, -9.9997788e17),
          c(c1[[1]], c2[[1]]) < 1000*cB)
## (almost?) infinite loop in R <= 3.1.0


## pbinom(), dbinom(), dhyper(),.. : R allows "almost integer" n
for (FUN in c(function(n) dbinom(1,n,0.5), function(n) pbinom(1,n,0.5),
              function(n) dpois(n, n), function(n) dhyper(n+1, n+5,n+5, n)))
    try( lapply(sample(10000, size=1000), function(M) {
    ## invisible(lapply(sample(10000, size=1000), function(M) {
        n <- (M/100)*10^(2:20); if(anyNA(P <- FUN(n)))
            stop("NA for M=",M, "; 10ex=",paste((2:20)[is.na(P)], collapse=", "))}))
## check was too tight for large n in R <= 3.1.0 (PR#15734)

## [dpqr]beta(*, a,b) where a and/or b are Inf
stopifnot(pbeta(.1, Inf, 40) == 0,
          pbeta(.5, 40, Inf) == 1,
          pbeta(.4, Inf,Inf) == 0,
          pbeta(.5, Inf,Inf) == 1,
          ## gave infinite loop (or NaN) in R <= 3.1.0
          qbeta(.9, Inf, 100) == 1, # Inf.loop
          qbeta(.1, Inf, Inf) == 1/2)# NaN + Warning
## range check (in "close" cases):
assertWarning(qN <- qbeta(2^-(10^(1:3)), 2,3, log.p=TRUE))
assertWarning(qn <- qbeta(c(-.1, -1e-300, 1.25), 2,3))
stopifnot(is.nan(qN), is.nan(qn))

## lognormal boundary case sdlog = 0:
p <- (0:8)/8; x <- 2^(-10:10)
stopifnot(all.equal(qlnorm(p, meanlog=1:2, sdlog=0),
		    qlnorm(p, meanlog=1:2, sdlog=1e-200)),
	  dlnorm(x, sdlog=0) == ifelse(x == 1, Inf, 0))

## qbeta(*, a,b) when  a,b << 1 : can easily fail
qbeta(2^-28, 0.125, 2^-26) # 1000 Newton it + warning
a <- 1/8; b <- 2^-(4:200); alpha <- b/4
qq <- qbeta(alpha, a,b)# gave warnings intermediately
pp <- pbeta(qq, a,b)
stopifnot(pp > 0, diff(pp) < 0, ## pbeta(qbeta(alpha,*),*) == alpha:
          abs(1 - pp/alpha) < 4e-15)# seeing 2.2e-16

## orig. qbeta() using *many* Newton steps; case where we "know the truth"
a <- 25; b <- 6; x <- 2^-c(3:15, 100, 200, 250, 300+100*(0:7))
pb <- c(## via Rmpfr's roundMpfr(pbetaI(x, a,b, log.p=TRUE, precBits = 2048), 64) :
    -40.7588797271766572448, -57.7574063441183625303, -74.9287878018119846216,
    -92.1806244636893542185, -109.471318248524419364, -126.781111923947395655,
    -144.100375042814531426, -161.424352961544612370, -178.750683324909148353,
    -196.078188674895169383, -213.406281209657976525, -230.734667259724367416,
    -248.063200048177428608, -1721.00081201679567511, -3453.86876341665894863,
    -4320.30273911659058550, -5186.73671481652222237, -6919.60466621638549567,
    -8652.47261761624876897, -10385.3405690161120427, -12118.2085204159753165,
    -13851.0764718158385902, -15583.9444232157018631, -17316.8123746155651368)
stopifnot(all.equal(pb, pbeta(x,a,b, log.p=TRUE), tol=8e-16))# seeing {1.5|1.6|2.0}e-16
qp <- qbeta(pb, a,b, log.p=TRUE)
## x == qbeta(pbeta(x, *), *) :
stopifnot(qp > 0, all.equal(x, qp, tol= 1e-15))# seeing {2.4|3.3}e-16

## qbeta(), PR#15755
a1 <- 0.0672788; b1 <- 226390
p <- 0.6948886
qp <- qbeta(p, a1,b1)
stopifnot(qp < 2e-8, # was '1' (with a warning) in R <= 3.1.0
          All.eq(p, pbeta(qp, a1,b1)))
## less extreme example, same phenomenon:
a <- 43779; b <- 0.06728
stopifnot(All.eq(0.695, pbeta(qbeta(0.695, b,a), b,a)))
x <- -exp(seq(0, 14, by=2^-9))
ct <- system.time(qx <- qbeta(x, a,b, log.p=TRUE))[[1]]
pqx <- pbeta(qx, a,b, log=TRUE)
stopifnot(all.equal(x, pqx, tol= 2e-15)) # seeing {3.51|3.54}e-16
## note that qx[x > -exp(2)] is too close to 1 to get full accuracy:
## i2 <- x > -exp(2); all.equal(x[i2], pqx[i2], tol= 0)#-> 5.849e-12
if(ct > 0.5) { cat("system.time:\n"); print(ct) }# lynne(2013): 0.048
## was Inf, and much slower, for R <= 3.1.0
x3 <- -(15450:15700)/2^11
pq3 <- pbeta(qbeta(x3, a,b, log.p=TRUE), a,b, log=TRUE)
stopifnot(mean(abs(pq3-x3)) < 4e-12,# 1.46e-12
          max (abs(pq3-x3)) < 8e-12)# 2.95e-12
##
.a <- .2; .b <- .03; lp <- -(10^-(1:323))
qq <- qbeta(lp, .a,.b, log=TRUE) # warnings in R <= 3.1.0
assertWarning(qN <- qbeta(.5, 2,3, log.p=TRUE))
assertWarning(qn <- qbeta(c(-.1, 1.25), 2,3))
stopifnot(1-qq < 1e-15, is.nan(qN), is.nan(qn))# typically qq == 1  exactly
## failed in intermediate versions
##
a <- 2^-8; b <- 2^(200:500)
pq <- pbeta(qbeta(1/8, a, b), a, b)
stopifnot(abs(pq - 1/8) < 1/8)
## whereas  qbeta() would underflow to 0 "too early", for R <= 3.1.0
#
## very extreme tails on both sides
x <- c(1e-300, 1e-12, 1e-5, 0.1, 0.21, 0.3)
stopifnot(0 == qbeta(x, 2^-12, 2^-10))## gave warnings
a <- 10^-(8:323)
qb <- qbeta(0.95, a, 20)
## had warnings and wrong value +1; also NaN
ct2 <- system.time(q2 <- qbeta(0.95, a,a))[1]
stopifnot(is.finite(qb), qb < 1e-300, q2 == 1)
if(ct2 > 0.020) { cat("system.time:\n"); print(ct2) }
## had warnings and was much slower for R <= 3.1.0

## qt(p, df= Inf, ncp)  <==> qnorm(p, m=ncp)
p <- (0:32)/32
stopifnot(all.equal(qt(p, df=Inf, ncp=5), qnorm(p, m=5)))
## qt(*, df=Inf, .)  gave NaN in  R <= 3.2.1

## rhyper(*, <large>);  PR#16489
ct3 <- system.time(N <- rhyper(100, 8000, 1e9-8000, 1e6))[1]
table(N)
summary(N)
stopifnot(abs(mean(N) - 8) < 1.5)
if(ct3 > 0.02) { cat("system.time:\n"); print(ct3) }
## N were all 0 and took very long for R <= 3.2.1
set.seed(17)
stopifnot(rhyper(1, 3024, 27466, 251) == 25,
          rhyper(1,  329,  3059, 225) == 22)
## failed for a day after a "thinko" in the above bug fix.

## *chisq(*, df=0, ncp=0) == Point mass at 0
stopifnot(rchisq(32,        df=0, ncp=0) == 0,
          dchisq((0:16)/16, df=0, ncp=0) == c(Inf, rep(0, 16)))
## gave all NaN's  for R <= 3.2.2

## pchisq(*, df=0, ncp > 0, log.p=TRUE) :
th <- 10*c(1:9,10^c(1:3,7))
pp <- pchisq(0, df = 0, ncp=th, log.p=TRUE)
stopifnot(all.equal(pp, -th/2, tol=1e-15))
## underflowed at about th ~= 60  in R <= 3.2.2

## pnbinom (-> C's bratio())
op <- options(warn = 1)# -- NaN's giving warnings
L <- 1e308; p <- suppressWarnings(pnbinom(L, L, mu = 5)) # NaN or 1 (for 64 / 32 bit)
is.nan(p) || p == 1
## gave infinite loop on some 64b platforms in R <= 3.2.3

## [dpqr]nbinom(*, mu, size=Inf) -- PR#16727
L <- 1e308; mu <- 5; pp <- (0:16)/16
x <- c(0:3, 1e10, 1e100, L, Inf)
(d <- dnbinom(x,  mu = mu, size = Inf)) # gave NaN (for 0 and L)
(p <- pnbinom(x,  mu = mu, size = Inf)) # gave all NaN
(q <- qnbinom(pp, mu = mu, size = Inf)) # gave all NaN
set.seed(1); NI <- rnbinom(32, mu = mu, size = Inf)# gave all NaN
set.seed(1); N2 <- rnbinom(32, mu = mu, size = L  )
stopifnot(all.equal(d, dpois(x, mu)),
	  all.equal(p, ppois(x, mu)),
	  q == qpois(pp, mu),
	  identical(NI, N2))
options(op)
## size = Inf -- mostly gave NaN  in R <= 3.2.3

## qpois(p, *) for invalid 'p' should give NaN -- PR#16972
stopifnot(is.nan(suppressWarnings(c(qpois(c(-2,3, NaN), 3), qpois(1, 3, log.p=TRUE),
                                    qpois(.5, 0, log.p=TRUE), qpois(c(-1,pi), 0)))))
## those in the 2nd line gave 0 in R <= 3.3.1
## Similar but different for qgeom():
stopifnot(qgeom((0:8)/8, prob=1) == 0, ## p=1 gave Inf in R <= 3.3.1
          is.nan(suppressWarnings(qgeom(c(-1/4, 1.1), prob=1))))

## all our RNG  r<dist>() functions:
##' catch all: value and warnings or error <-- demo(error.catching) :
tryCatch.W.E <- function(expr) {
    W <- NULL
    w.handler <- function(w){ # warning handler
	W <<- w
	invokeRestart("muffleWarning")
    }
    list(value = withCallingHandlers(tryCatch(expr, error = function(e) e),
				     warning = w.handler),
	 warning = W)
}
.stat.ns <- asNamespace("stats")
Ns <- 4
for(dist in PDQR) {
    fn <- paste0("r",dist)
    cat(sprintf("%-9s(%d, ..): ", fn, Ns))
    F <- get(fn, envir = .stat.ns)
    nArg <- length(fms <- formals(F))
    if(dist %in% c("nbinom", "gamma")) ## cannot specify *both* 'prob' & 'mu' / 'rate' & 'scale'
        nArg <- nArg - 1
    nA1 <- nArg - 1 # those beside the first (= 'n' mostly)
    expected <- rep(if(dist %in% PDQRinteg) NA_integer_ else NaN, Ns)
    for(ia in seq_len(nA1)) {
        aa <- rep(list(1), nA1)
        aa[[ia]] <- NA
        cat(ia,"")
        R <- tryCatch.W.E( do.call(F, c(Ns, aa)) )
        if(!inherits(R$warning, "simpleWarning")) cat(" .. did *NOT* give a warning! ")
	if(!(identical(R$value, expected))) { ## allow NA/NaN mismatch in these cases for now:
	    if(!(dist %in% c("beta","f","t") && all(is.na(R$value))))
		cat(" .. not giving expected NA/NaN's ")
        }
    }
    cat(" [Ok]\n")
}


## qbeta() in very asymmetric cases
sh2 <- 2^seq(9,16, by=1/16)
qbet <- qbeta(1e-10, 1.5, shape2=sh2, lower.tail=FALSE)
plot(sh2, 1- pbeta(qbet, 1.5, sh2, lower.tail=FALSE) * 1e10, log="x")
dqb <- diff(qbet); d2qb <- diff(dqb); d3qb <- diff(d2qb)
stopifnot(all.equal(qbet[[1]], 0.047206901483498, tol=1e-12),
	  max(abs(1- pbeta(qbet, 1.5, sh2, lower.tail=FALSE) * 1e10)) < 1e-12,# Lx 64b: 2.4e-13
	  0 > dqb, dqb > -0.002,
	  0 < d2qb, d2qb < 0.00427,
	  -3.2e-8 > d3qb, d3qb > -3.1e-6,
	  diff(d3qb) > 1e-9)
## had discontinuity (from wrong jump out of Newton) in R <= 3.3.2



cat("Time elapsed: ", proc.time() - .ptime,"\n")
