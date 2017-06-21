library(cluster)
options(digits = 6)
data(votes.repub)

## From Matrix' test-tools-1.R :
showProc.time <- local({ ## function + 'pct' variable
    pct <- proc.time()
    function(final="\n") { ## CPU elapsed __since last called__
	ot <- pct ; pct <<- proc.time()
	## 'Time ..' *not* to be translated:  tools::Rdiff() skips its lines!
	cat('Time elapsed: ', (pct - ot)[1:3], final)
    }
})

agn1 <- agnes(votes.repub, metric = "manhattan", stand = TRUE)
summary(agn1)
Dvr <- daisy(votes.repub)
agn2 <- agnes(Dvr, method = "complete")
summary(agn2)
## almost same:
(ag2. <- agnes(Dvr, method= "complete", keep.diss=FALSE))
ag22  <- agnes(votes.repub, method= "complete", keep.diss=FALSE,keep.data=FALSE)
stopifnot(identical(agn2[-5:-6], ag2.[-5:-6]),
          identical(Dvr, daisy(votes.repub)), # DUP=FALSE (!)
          identical(ag2.[-6], ag22[-6])
         )

data(agriculture)
summary(agnes(agriculture))

data(ruspini)
summary(ar0 <- agnes(ruspini, keep.diss=FALSE, keep.data=FALSE))
summary(ar1 <- agnes(ruspini, metric = "manhattan"))
str(ar1)

showProc.time()

summary(ar2 <- agnes(ruspini, metric="manhattan", method = "weighted"))
print  (ar3 <- agnes(ruspini, metric="manhattan", method = "flexible",
                     par.meth = 0.5))
stopifnot(all.equal(ar2[1:4], ar3[1:4], tol=1e-12))

showProc.time()

## Small example, testing "flexible" vs "single"
i8 <- -c(1:2, 9:10)
dim(agr8 <- agriculture[i8, ])
i5 <- -c(1:2, 8:12)
dim(agr5 <- agriculture[i5, ])


chk <- function(d, method=c("single", "complete", "weighted"),
                trace.lev = 1,
                iC = -(6:7), # <- not using 'call' and 'method' for comparisons
                doplot = FALSE, tol = 1e-12)
{
    if(!inherits(d, "dist")) d <- daisy(d, "manhattan")
    method <- match.arg(method)
    par.meth <- list("single" =  c(.5, .5, 0, -.5),
                     "complete"= c(.5, .5, 0, +.5),
                     "weighted"= c(0.5))
    a.s <- agnes(d, method=method, trace.lev=trace.lev)
    ## From theory, this should give the same, but it does not --- why ???
    a.f <- agnes(d, method="flex", par.method = par.meth[[method]], trace.lev=trace.lev)

    if(doplot) {
	op <- par(mfrow = c(2,2), mgp = c(1.6, 0.6, 0), mar = .1 + c(4,4,2,1))
        on.exit(par(op))
        plot(a.s)
        plot(a.f)
    }
    structure(all.equal(a.s[iC], a.f[iC], tolerance = tol),
              fits = list(s = a.s, f = a.f))
}

chk(agr5, trace = 3)

stopifnot(chk(agr5), chk(agr5, "complete", trace = 2), chk(agr5, "weighted"),
          chk(agr8), chk(agr8, "complete"), chk(agr8, "weighted", trace.lev=2),
          chk(agriculture), chk(agriculture, "complete"),
          chk(ruspini), chk(ruspini, "complete"), chk(ruspini, "weighted"))

showProc.time()

## an invalid "flexible" case - now must give error early:
x <- rbind(c( -6, -9), c(  0, 13),
           c(-15,  6), c(-14,  0), c(12,-10))
(dx <- daisy(x, "manhattan"))
a.x <- tryCatch(agnes(dx, method="flexible", par = -.2),
                error = function(e)e)
##  agnes(method=6, par.method=*) lead to invalid merge; step 4, D(.,.)=-26.1216
if(!inherits(a.x, "error")) stop("invalid 'par' in \"flexible\" did not give error")
if(!all(vapply(c("par[.]method", "merge"), grepl, NA, x=a.x$message)))
   stop("error message did not contain expected words")

