##
## RNG tests using DKW inequality for rate of convergence
##
## P(sup | F_n - F | > t) < 2 exp(-2nt^2)
##
## The 2 in front of exp() was derived by Massart. It is the best possible
## constant valid uniformly in t,n,F. For large n*t^2 this agrees with the
## large-sample approximation to the Kolmogorov-Smirnov statistic.
##


superror <- function(rfoo,pfoo,sample.size,...) {
    x <- rfoo(sample.size,...)
    tx <- table(signif(x, 12)) # such that xi will be sort(unique(x))
    xi <- as.numeric(names(tx))
    f <- pfoo(xi,...)
    fhat <- cumsum(tx)/sample.size
    max(abs(fhat-f))
}

pdkwbound <- function(n,t) 2*exp(-2*n*t*t)

qdkwbound <- function(n,p) sqrt(log(p/2)/(-2*n))

dkwtest <- function(stub = "norm", ...,
                    sample.size = 10000, pthreshold = 0.001,
                    print.result = TRUE, print.detail = FALSE,
                    stop.on.failure = TRUE)
{
    rfoo <- eval(as.name(paste("r", stub, sep="")))
    pfoo <- eval(as.name(paste("p", stub, sep="")))
    s <- superror(rfoo, pfoo, sample.size, ...)
    if (print.result || print.detail) {
        printargs <- substitute(list(...))
        printargs[[1]] <- as.name(stub)
        cat(deparse(printargs))
        if (print.detail)
            cat("\nsupremum error = ",signif(s,2),
                " with p-value=",min(1,round(pdkwbound(sample.size,s),4)),"\n")
    }
    rval <- (s < qdkwbound(sample.size,pthreshold))
    if (print.result)
        cat(c(" FAILED\n"," PASSED\n")[rval+1])
    if (stop.on.failure && !rval)
        stop("dkwtest failed")
    rval
}

.proctime00 <- proc.time() # start timing


dkwtest("binom",size =   1,prob = 0.2)
dkwtest("binom",size =   2,prob = 0.2)
dkwtest("binom",size = 100,prob = 0.2)
dkwtest("binom",size = 1e4,prob = 0.2)
dkwtest("binom",size =   1,prob = 0.8)
dkwtest("binom",size = 100,prob = 0.8)
dkwtest("binom",size = 100,prob = 0.999)

dkwtest("pois",lambda =  0.095)
dkwtest("pois",lambda =  0.95)
dkwtest("pois",lambda =  9.5)
dkwtest("pois",lambda = 95)

dkwtest("nbinom",size =   1,prob = 0.2)
dkwtest("nbinom",size =   2,prob = 0.2)
dkwtest("nbinom",size = 100,prob = 0.2)
dkwtest("nbinom",size = 1e4,prob = 0.2)
dkwtest("nbinom",size =   1,prob = 0.8)
dkwtest("nbinom",size = 100,prob = 0.8)
dkwtest("nbinom",size = 100,prob = 0.999)

dkwtest("norm")
dkwtest("norm",mean = 5,sd = 3)

dkwtest("gamma",shape =  0.1)
dkwtest("gamma",shape =  0.2)
dkwtest("gamma",shape = 10)
dkwtest("gamma",shape = 20)

dkwtest("hyper",m = 40,n = 30,k = 20)
dkwtest("hyper",m = 40,n =  3,k = 20)
dkwtest("hyper",m =  6,n =  3,k =  2)
dkwtest("hyper",m =  5,n =  3,k =  2)
dkwtest("hyper",m =  4,n =  3,k =  2)


dkwtest("signrank",n =  1)
dkwtest("signrank",n =  2)
dkwtest("signrank",n = 10)
dkwtest("signrank",n = 30)

dkwtest("wilcox",m = 40,n = 30)
dkwtest("wilcox",m = 40,n = 10)
dkwtest("wilcox",m =  6,n =  3)
dkwtest("wilcox",m =  5,n =  3)
dkwtest("wilcox",m =  4,n =  3)

dkwtest("chisq",df =  1)
dkwtest("chisq",df = 10)

dkwtest("logis")
dkwtest("logis",location = 4,scale = 2)

dkwtest("t",df =  1)
dkwtest("t",df = 10)
dkwtest("t",df = 40)

dkwtest("beta",shape1 = 1, shape2 = 1)
dkwtest("beta",shape1 = 2, shape2 = 1)
dkwtest("beta",shape1 = 1, shape2 = 2)
dkwtest("beta",shape1 = 2, shape2 = 2)
dkwtest("beta",shape1 = .2,shape2 = .2)

dkwtest("cauchy")
dkwtest("cauchy",location = 4,scale = 2)

dkwtest("f",df1 =  1,df2 =  1)
dkwtest("f",df1 =  1,df2 = 10)
dkwtest("f",df1 = 10,df2 = 10)
dkwtest("f",df1 = 30,df2 =  3)

dkwtest("weibull",shape = 1)
dkwtest("weibull",shape = 4,scale = 4)

## regression test for PR#7314
dkwtest("hyper", m=60, n=100, k=50)
dkwtest("hyper", m=6, n=10, k=5)
dkwtest("hyper", m=600, n=1000, k=500)

## regression test for non-central t bug
dkwtest("t", df=20, ncp=3)
## regression test for non-central F bug
dkwtest("f", df1=10, df2=2, ncp=3)


cat('Time elapsed: ', proc.time() - .proctime00,'\n')

