
require("SQUAREM")  # master funcion and the 4 different SQUAREM algorithms
require("setRNG")   # only needed to reproduce the same results

# data for Poisson mixture estimation 
data(Hasselblad1969, package="SQUAREM")

y <- poissmix.dat$freq
tol <- 1.e-08

# generate a random initial guess for 3 parameters
setRNG(list(kind="Wichmann-Hill", normal.kind="Box-Muller", seed=123))
p0 <- c(runif(1),runif(2,0,4))    

# fixptfn = function that computes a single update of fixed-point iteration
# objfn = underlying objective function that needs to be minimized  (here it is the negative log-likelihood)
#

# EM algorithm
pf1 <- fpiter(p=p0, y=y, fixptfn=poissmix.em, objfn=poissmix.loglik, control=list(tol=tol))

# First-order SQUAREM algorithm with SqS3 method
pf2 <- squarem(par=p0, y=y, fixptfn=poissmix.em, objfn=poissmix.loglik, control=list(tol=tol))

# First-order SQUAREM algorithm with SqS2 method
pf3 <- squarem(par=p0, y=y, fixptfn=poissmix.em, objfn=poissmix.loglik, control=list(method=2, tol=tol))

# First-order SQUAREM algorithm with SqS3 method; non-monotone 
# Note: the objective function is not evaluated when objfn.inc = Inf 
pf4 <- squarem(par=p0,y=y, fixptfn=poissmix.em, control=list(tol=tol, objfn.inc=Inf))

# First-order SQUAREM algorithm with SqS3 method; objective function is not specified
pf5 <- squarem(par=p0,y=y, fixptfn=poissmix.em, control=list(tol=tol, kr=0.1))

# Second-order (K=2) SQUAREM algorithm with SqRRE 
pf6 <- squarem(par=p0, y=y, fixptfn=poissmix.em, objfn=poissmix.loglik, control=list (K=2, tol=tol))

# Second-order SQUAREM algorithm with SqRRE; objective function is not specified
pf7 <- squarem(par=p0, y=y, fixptfn=poissmix.em, control=list(K=2, tol=tol))

# Number of fixed-point evaluations
c(pf1$fpeval, pf2$fpeval, pf3$fpeval, pf4$fpeval, pf5$fpeval, pf6$fpeval, pf7$fpeval)

# Number of objective function evaluations
c(pf1$objfeval, pf2$objfeval, pf3$objfeval, pf4$objfeval, pf5$objfeval, pf6$objfeval, pf7$objfeval)

# Comparison of converged parameter estimates
par.mat <- rbind(pf1$par, pf2$par, pf3$par, pf4$par, pf5$par, pf6$par, pf7$par)
par.mat

