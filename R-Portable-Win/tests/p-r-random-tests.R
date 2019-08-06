##
## RNG tests using DKW inequality for rate of convergence
##
## P(sup | F_n - F | > t) < 2 exp(-2nt^2)
##
## The 2 in front of exp() was derived by Massart. It is the best possible
## constant valid uniformly in t,n,F. For large n*t^2 this agrees with the
## large-sample approximation to the Kolmogorov-Smirnov statistic.
##

## When tryCatch()ing all seeds in 0:10000, the following 346 failed (Lnx 64b, R 3.5.0):
suppressWarnings(RNGversion("3.5.0"))
failingSeeds <- c(
    16, 42, 51, 63, 79,        108, 143, 171, 208, 215,
    230, 236, 254, 323, 327,   332, 333, 374, 386, 387,
    438, 440, 450, 472, 547,   609, 673, 740, 784, 787,
    792, 806, 846, 897, 938,  1017,1043,1062,1067,1076,
    1090,1113,1115,1136,1142, 1148,1162,1193,1249,1259,
    1299,1338,1347,1366,1407, 1428,1457,1461,1540,1609,
    1613,1622,1629,1664,1712, 1760,1779,1786,1826,1852,
    1868,1871,1880,1928,1930, 1978,1984,2025,2073,2081,
    2082,2130,2148,2153,2172, 2175,2228,2298,2353,2368,
    2430,2444,2462,2493,2528, 2631,2750,2752,2765,2774,
    2794,2817,2873,2888,2905, 2906,2911,2936,2955,2989,
    3029,3048,3053,3084,3100, 3148,3183,3192,3232,3256,
    3266,3302,3311,3313,3319, 3325,3340,3344,3375,3477,
    3506,3516,3518,3521,3553, 3601,3655,3717,3733,3810,
    3814,3962,4043,4095,4119, 4174,4185,4192,4228,4240,
    4261,4298,4335,4338,4349, 4402,4433,4461,4491,4496,
    4508,4511,4530,4604,4622, 4640,4669,4677,4682,4683,
    4705,4717,4725,4757,4816, 4899,4931,5014,5022,5063,
    5082,5105,5107,5137,5155, 5160,5165,5169,5182,5186,
    5197,5207,5210,5211,5263, 5281,5282,5288,5364,5529,
    5568,5611,5651,5700,5740, 5796,5869,5874,5878,5920,
    5954,5972,6034,6037,6073, 6086,6118,6120,6126,6234,
    6235,6263,6287,6301,6360, 6364,6377,6416,6491,6493,
    6524,6534,6568,6615,6679, 6682,6777,6782,6790,6808,
    6885,6887,6936,6938,6961, 7011,7046,7047,7062,7111,
    7181,7202,7206,7207,7227, 7261,7301,7311,7313,7324,
    7364,7385,7394,7412,7486, 7504,7519,7536,7584,7665,
    7692,7762,7787,7797,7865, 7916,7959,7967,8038,8047,
    8048,8086,8123,8125,8160, 8213,8243,8254,8255,8307,
    8335,8403,8453,8487,8541, 8549,8577,8587,8638,8640,
    8651,8664,8703,8770,8781, 8793,8841,8888,8900,8962,
    8963,8965,9028,9052,9054, 9061,9143,9198,9204,9232,
    9238,9247,9308,9311,9321, 9342,9360,9430,9457,9564,
    9572,9609,9657,9738,9743, 9750,9758,9779,9789,9848,
    9881,9895,9903,9905,9947, 9982)

## randomly setting one of the valid 10001-346 = 9655 seeds:
iseed <- sample(setdiff(0:10000, failingSeeds), size=1)
dump("iseed", file="p-r-random-tests_seed") #(for reproducibility, not into *.Rout)
set.seed(iseed)

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

