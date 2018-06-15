## testing trace_lev settings
require(robustbase)

## fit a model with categorical, continuous and mixed variables
selDays <- c(
    ## days ranked according to number of outliers:
    "403", "407", "693", "405", "396", "453", "461",
    ## "476", "678", "730", "380", "406", "421", "441"
    ## ,"442", "454", "462", "472", "480", "488"
    ## some other days
    ## "712", "503", "666", "616", "591", "552",
    "624", "522", "509", "388", "606", "580",
    "573", "602", "686", "476", "708", "600", "567")
contr <- list(julday=contr.sum)

## using this seed and the default configuration options,
## the fast_S algorithm stops with some "local exact fits",
## i.e., coefficients with std. error 0.
set.seed(711)
lseed <- .Random.seed
r1 <- lmrob(LNOx ~ (LNOxEm + sqrtWS)*julday, NOxEmissions,
            julday %in% selDays, contrasts=contr, seed=lseed,
            max.it=10000, nResample=5, trace.lev=1)
## change best.r.s to 11 and it works properly
## (for this seed at least)
res <- update(r1, k.max=10000, best.r.s = 3, nResample=1000, trace.lev=2)

#####
## fast_S (non-large strategy)
## test non-convergence warnings / trace output:
res <- update(r1, max.it = 1)
res <- update(r1, k.max = 1)

## test trace_levs:
res <- update(r1, trace.lev = 0)
res <- update(r1, trace.lev = 1)
res <- update(r1, trace.lev = 2)
res <- update(r1, trace.lev = 3)
res <- update(r1, trace.lev = 4)
res <- update(r1, trace.lev = 5)

#####
## M-S estimator
r2 <- update(r1, init="M-S", split.type="fi", subsampling="simple", mts=10000)

## test non-convergence warnings / trace output:
res <- update(r2, max.it = 1)
res <- update(r2, k.m_s = 1) ## does not converge anyway

## test trace_levs:
res <- update(r2, trace.lev = 0)
res <- update(r2, trace.lev = 1)
res <- update(r2, trace.lev = 2)
res <- update(r2, trace.lev = 3)
res <- update(r2, trace.lev = 4)
## this produces _a_lot_ of output:
## res <- update(r2, trace.lev = 5)

#####
## fast_S (large-n strategy)
## need to use continuous only design
r3 <- update(r1, LNOx ~ LNOxEm + sqrtWS, subset=NULL, contrasts=NULL)

## test non-convergence warnings / trace output:
res <- update(r3, max.it = 1)
res <- update(r3, k.max = 1)

## test trace_levs:
res <- update(r3, trace.lev = 0)
res <- update(r3, trace.lev = 1)
res <- update(r3, trace.lev = 2)
res <- update(r3, trace.lev = 3)
res <- update(r3, trace.lev = 4)
## (there is no level 5)
