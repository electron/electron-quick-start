#### Some examples of the KS and Wilcoxon tests

### ------ Kolmogorov Smirnov (KS) --------------

## unrealistic one of PR#14561
ds1 <- c(1.7,2,3,3,4,4,5,5,6,6)
ks.test(ds1, "pnorm", mean = 3.3, sd = 1.55216)
# how on earth can sigma = 1.55216 be known?

# R >= 2.14.0 allows the equally invalid
ks.test(ds1, "pnorm", mean = 3.3, sd = 1.55216, exact = TRUE)

## Try out the effects of rounding
set.seed(123)
ds2 <- rnorm(1000)
ks.test(ds2, "pnorm") # exact = FALSE is default for n = 1000
ks.test(ds2, "pnorm", exact = TRUE)
## next two are still close
ks.test(round(ds2, 2), "pnorm")
ks.test(round(ds2, 2), "pnorm", exact = TRUE)
# now D has doubled, but p-values remain similar (if very different from ds2)
ks.test(round(ds2, 1), "pnorm")
ks.test(round(ds2, 1), "pnorm", exact = TRUE)


### ------ Wilkoxon (Mann Whitney) --------------

options(nwarnings = 1000)
(alts <- setNames(, eval(formals(stats:::wilcox.test.default)$alternative)))
x0 <- 0:4
(x.set <- list(s0 = lapply(x0, function(m) 0:m),
               s. = lapply(x0, function(m) c(1e-9, seq_len(m)))))
stats <- setNames(nm = c("statistic", "p.value", "conf.int", "estimate"))

## Even with  conf.int = TRUE, do not want errors :
RR <-
    lapply(x.set, ## for all data sets
           function(xs)
               lapply(alts, ## for all three alternatives
                      function(alt)
                          lapply(xs, function(x)
                              ## try(
                              wilcox.test(x, exact=TRUE, conf.int=TRUE, alternative = alt)
                              ## )
                              )))
length(ww <- warnings()) # 52 (or 43 for x0 <- 0:3)
unique(ww) # 4 different ones

cc <- lapply(RR, function(A) lapply(A, function(bb) lapply(bb, class)))
table(unlist(cc))
## in R <= 3.3.1,  with try( .. ) above, we got
## htest try-error
##    23         7
uc <- unlist(cc[["s0"]]); noquote(names(uc)[uc != "htest"]) ## these 7 cases :
## two.sided1 two.sided2 two.sided3
## less1      less2
## greater1   greater2

##--- How close are the stats of  (0:m)  to those of  (eps, 1:m) ------------

## a version that still works with above try(.) and errors there:
getC <- function(L, C) if(inherits(L,"try-error")) c(L) else L[[C]]
stR <- lapply(stats, function(COMP)
           lapply(RR, function(A)
               lapply(A, function(bb)
                   lapply(bb, getC, C=COMP) )))

## a) P-value
pv <- stR[["p.value"]]
## only the first is NaN, all others in [0,1]:
sapply(pv$s0, unlist)
sapply(pv$s., unlist) # not really close, but ..

pv$s0$two.sided[1] <-  1 ## artificially
stopifnot(all.equal(pv$s0, pv$s., tol = 0.5 + 1e-6), # seen 0.5
	  ## "less" are close:
	  all.equal(unlist(pv[[c("s0","less")]]),
		    unlist(pv[[c("s.","less")]]), tol = 0.03),
	  0 <= unlist(pv), unlist(pv) <= 1) # <- no further NA ..
## b)
sapply(stR[["statistic"]], unlist)
## Conf.int.:
## c)
sapply(stR[["estimate" ]], unlist)
## d) confidence interval
formatCI <- function(ci)
    sprintf("[%g, %g] (%g%%)", ci[[1]], ci[[2]],
	    round(100*attr(ci,"conf.level")))
nx <- length(x0)
noquote(vapply(stR[["conf.int"]], function(ss)
    vapply(ss, function(alt) vapply(alt, formatCI, ""), character(nx)),
    matrix("", nx, length(alts))))


##-------- 2-sample tests (working unchanged) ------------------

R2 <- lapply(alts, ## for all three alternatives
             function(alt)
                 lapply(seq_along(x0), function(k)
                         wilcox.test(x = x.set$s0[[k]], y = x.set$s.[[k]],
                                     exact=TRUE, conf.int=TRUE, alternative = alt)))
length(w2 <- warnings()) # 27
unique(w2) # 3 different ones

table(uc2 <- unlist(c2 <- lapply(R2, function(A) lapply(A, class))))
stopifnot(uc2 == "htest")

stR2 <- lapply(stats,
               function(COMP)
                   lapply(R2, function(A) lapply(A, getC, C=COMP)))

lapply(stats[-3], ## -3: "conf.int" separately
       function(ST) sapply(stR2[[ST]], unlist))

noquote(sapply(stR2[["conf.int"]], function(.) vapply(., formatCI, "")))

