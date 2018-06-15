#### Testing consistency  of  "abIndex" == "abstract-indexing vectors" class :
library(Matrix)

source(system.file("test-tools.R", package = "Matrix"))# identical3() etc

validObject(ab <- new("abIndex"))
str(ab)

set.seed(1)
ex. <- list(2:1000, 0:10, sample(100), c(-3:40, 20:70),
            c(1:100,77L, 50:40, 10L), c(17L, 3L*(12:3)))
## we know which kinds will come out: "compressed" for all but random:
rD <- "rleDiff"; kinds <- c(rD,rD,"int32", rD, rD, rD)
isCmpr <- kinds == rD
ab. <- lapply(ex., as, Class = "abIndex")
nu. <- lapply(ab., as, Class = "numeric")
in. <- lapply(ab., as, Class = "integer")
rles <- lapply(ab.[isCmpr], function(u) u@rleD@rle)
r.x <-  lapply(ex.[isCmpr], function(.) rle(diff(.)))

stopifnot(sapply(ab., validObject),
          identical(ex., nu.),
          identical(ex., in.),
          ## Check that the relevant cases really *are* "compressed":
          sapply(ab., slot, "kind") == kinds,
          ## Using rle(diff(.)) is equivalent to using our C code:
          identical(rles, r.x),
          ## Checking Group Methods - "Summary" :
          sapply(ab., range) == sapply(ex., range),
          sapply(ab., any) == sapply(ex., any),
          TRUE)

## testing c() method, i.e.  currently c.abIndex():
tst.c.abI <- function(lii) {
    stopifnot(is.list(lii),
              all(unlist(lapply(lii, mode)) == "numeric"))
    aii <- lapply(lii, as, "abIndex")
    v.i <- do.call(c, lii)
    a.i <- do.call(c, aii)
    avi <- as(v.i, "abIndex")
    ## identical() is too hard, as values & lengths can be double/integer
    stopifnot(all.equal(a.i, avi, tolerance = 0))
}
tst.c.abI(list(2:6, 70:50, 5:-2))
## now an example where *all* are uncompressed:
tst.c.abI(list(c(5, 3, 2, 4, 7, 1, 6), 3:4, 1:-1))
## and one with parts that are already non-trivial:
exc <- ex.[isCmpr]
tst.c.abI(exc)
set.seed(101)
N <- length(exc) # 5
for(i in 1:10) {
    tst.c.abI(exc[sample(N, replace=TRUE)])
    tst.c.abI(exc[sample(N, N-1)])
    tst.c.abI(exc[sample(N, N-2)])
}

for(n in 1:120) {
    cat(".")
    k <- 1 + 4*rpois(1, 5) # >= 1
    ## "random" rle -- NB: consecutive values *must* differ (for uniqueness)
    v <- as.integer(1+ 10*rnorm(k))
    while(any(dv <- duplicated(v)))
        v[dv] <- v[dv] + 1L
    rl <- structure(list(lengths = as.integer(1 + rpois(k, 10)), values  = v),
                    class = "rle")
    ai <- new("abIndex", kind = "rleDiff",
              rleD = new("rleDiff", first = rpois(1, 20), rle = rl))
    validObject(ai)
    ii <- as(ai, "numeric")
    iN <- ii; iN[180] <- NA; aiN <- as(iN,"abIndex")
    iN <- as(aiN, "numeric") ## NA from 180 on
    stopifnot(is.numeric(ii), ii == round(ii),
	      identical(ai, as(ii, "abIndex")),
	      identical(is.na(ai), is.na(ii)),
	      identical(is.na(aiN), is.na(iN)),
	      identical(is.finite  (aiN),   is.finite(iN)),
	      identical(is.infinite(aiN), is.infinite(iN))
              )
    if(n %% 40 == 0) cat(n,"\n")
}

## we have :  identical(lapply(ex., as, "abIndex"), ab.)

mkStr <- function(ch, n) paste(rep.int(ch, n), collapse="")

##O for(grMeth in getGroupMembers("Ops")) {
##O     cat(sprintf("\n%s :\n%s\n", grMeth, mkStr("=", nchar(grMeth))))
grMeth <- "Arith"
    for(ng in getGroupMembers(grMeth)) {
        cat(ng, ": ")
        G <- get(ng)
	t.tol <- if(ng == "/") 1e-12 else 0
	## "/" with no long double (e.g. on Sparc Solaris): 1.125e-14
	AEq <- function(a,b, ...) assert.EQ(a, b, tol=t.tol, giveRE=TRUE)
        for(v in ex.) {
            va <- as(v, "abIndex")
            for(s in list(-1, 17L, TRUE, FALSE)) # numeric *and* logical
		if(!((identical(s, FALSE) && ng == "/"))) { ## division by 0 may "fail"

		    AEq(as(G(v, s), "abIndex"), G(va, s))
		    AEq(as(G(s, v), "abIndex"), G(s, va))
		}
            cat(".")
        }
        cat(" [Ok]\n")
    }
##O }

## check the abIndex versions of  indDiag() and indTri() :
for(n in 1:7) {
    stopifnotValid(ii <- Matrix:::abIindDiag(n), "abIndex")
    stopifnot(ii@kind == "rleDiff",
	      Matrix:::indDiag(n) == as(ii, "numeric"))
}

for(n in 0:7)
 for(diag in c(TRUE,FALSE))
  for(upper in c(TRUE,FALSE)) {
      stopifnotValid(ii <- Matrix:::abIindTri(n, diag=diag,upper=upper), "abIndex")
      stopifnot(Matrix:::indTri(n, diag=diag,upper=upper) == as(ii, "numeric"))
  }
cat('Time elapsed: ', (.pt <- proc.time()),'\n') # "stats"
