## error.distributions.R: additional error distributions for use in simulations

## require(skewt) ## loaded in vignette if required

## centered skewed t distribution
Eskt <- function(nu, gam) {
  M <- if (is.infinite(nu)) sqrt(2/pi) else
       gamma((nu+1)/2)/sqrt(nu*pi)/gamma(nu/2)*2*nu/(nu-1)
  M*(gam^2-1/gam^2)/(gam + 1/gam)
}

dcskt <- function(x, df, gamma=2) {
  ncp <- Eskt(df, gamma)
  dskt(x + ncp, df, gamma)
}

pcskt <- function(q, df, gamma=2) {
  ncp <- Eskt(df, gamma)
  pskt(q + ncp, df, gamma)
}

qcskt <- function(p, df, gamma=2) {
  ncp <- Eskt(df, gamma)
  qskt(p, df, gamma) - ncp
}

rcskt <- function(n, df, gamma=2) {
  ncp <- Eskt(df, gamma)
  rskt(n, df, gamma) - ncp
}


####################################################################################
## contaminated normal
####################################################################################

rcnorm <- function (n,mean=0,sd=1,epsilon=0.1,meanc=mean,sdc=sqrt(10)*sd) {
  e <- rnorm(n,mean,sd)
  nc <- floor(epsilon*n)
  idx <- sample(1:n,nc)
  e[idx] <- rnorm(nc,meanc,sdc)
  e
}

## ignore other arguments for the moment
pcnorm <- function(q,mean=0,sd=1,lower.tail=TRUE,log.p=FALSE,...)
  pnorm(q,mean,sd,lower.tail,log.p)

## ignore other arguments for the moment
qcnorm <- function(p,mean=0,sd=1,lower.tail=TRUE,log.p=FALSE,...)
  qnorm(p,mean,sd,lower.tail,log.p)

## ignore other arguments for the moment
dcnorm <- function(x,mean=0,sd=1,log=FALSE,...)
  dnorm(x,mean,sd,log)
