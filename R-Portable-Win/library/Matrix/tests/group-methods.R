### Testing the group methods  --- some also happens in ./Class+Meth.R

library(Matrix)
source(system.file("test-tools.R", package = "Matrix"))# identical3() etc
assertV <- function(e) tools::assertError(e, verbose=TRUE)

cat("doExtras:",doExtras,"\n")

set.seed(2001)

mm <- Matrix(rnorm(50 * 7), nc = 7)
xpx <- crossprod(mm)# -> "factors" in mm !
round(xpx, 3) # works via "Math2"

y <- rnorm(nrow(mm))
xpy <- crossprod(mm, y)
res <- solve(xpx, xpy)
signif(res, 4) # 7 x 1 Matrix

stopifnot(all(signif(res) == signif(res, 6)),
	  all(round (xpx) == round (xpx, 0)))

## exp(): component wise
signif(dd <- (expm(xpx) - exp(xpx)) / 1e34, 3)# 7 x 7

validObject(xpx)
validObject(xpy)
validObject(dd)

## "Math" also, for log() and [l]gamma() which need special treatment
stopifnot(identical(exp(res)@x, exp(res@x)),
          identical(log(abs(res))@x, log(abs((res@x)))),
          identical(lgamma(res)@x, lgamma(res@x)))


###--- sparse matrices ---------

m <- Matrix(c(0,0,2:0), 3,5)
(mC <- as(m, "dgCMatrix"))
sm <- sin(mC)
stopifnot(class(sm) == class(mC), class(mC) == class(mC^2),
          dim(sm) == dim(mC),
          class(0 + 100*mC) == class(mC),
          all.equal(0.1 * ((0 + 100*mC)/10), mC),
          all.equal(sqrt(mC ^ 2), mC),
          all.equal(m^m, mC^mC),
          identical(mC^2, mC * mC),
          identical(mC*2, mC + mC)
          )

x <- Matrix(rbind(0,cbind(0, 0:3,0,0,-1:2,0),0))
x # sparse
(x2 <- x + 10*t(x))
stopifnot(is(x2, "sparseMatrix"),
          identical(x2, t(x*10 + t(x))),
	  identical(x, as((x + 10) - 10, class(x))))

(px <- Matrix(x^x - 1))#-> sparse again
stopifnot(px@i == c(3,4,1,4),
          px@x == c(3,26,-2,3))

## From: "Florent D." .. Thu, 23 Feb 2012 -- bug report
##---> MM:  Make a regression test:
tst <- function(n, i = 1) {
    stopifnot(i >= 1, n >= i)
    D <- .sparseDiagonal(n)
    ee <- numeric(n) ; ee[i] <- 1
    stopifnot(all(D - ee == diag(n) - ee),
              all(D * ee == diag(n) * ee),
              all(ee - D == ee - diag(n)),
              {C <- (ee / D == ee / diag(n)); all(is.na(C) | C)},
              TRUE)
}
nn <- if(doExtras) 27 else 7
tmp <- sapply(1:nn, tst) # failed in Matrix 1.0-4
i <- sapply(1:nn, function(i) sample(i,1))
tmp <- mapply(tst, n= 1:nn, i= i)# failed too

(lsy <- new("lsyMatrix", Dim = c(2L,2L), x=c(TRUE,FALSE,TRUE,TRUE)))
nsy <- as(lsy, "nMatrix")
(t1  <- new("ltrMatrix", Dim = c(1L,1L), x = TRUE))
(t2  <- new("ltrMatrix", Dim = c(2L,2L), x = rep(TRUE,4)))
stopifnot(all(lsy), # failed in Matrix 1.0-4
          all(nsy), #  dito
	  all(t1),  #   "
          ## ok previously (all following):
          !all(t2),
	  all(sqrt(lsy) == 1))
dsy <- lsy+1

showProc.time()
set.seed(111)
local({
    for(i in 1:(if(doExtras) 20 else 5)) {
        M <- rspMat(n=1000, 200, density = 1/20)
        v <- rnorm(ncol(M))
        m <- as(M,"matrix")
        stopifnot(all(t(M)/v == t(m)/v))
        cat(".")
    }});cat("\n")

## Now just once, with a large such matrix:
local({
    n <- 100000; m <- 30000
    AA <- rspMat(n, m, density = 1/20000)
    v <- rnorm(m)
    st <- system.time({
        BB <- t(AA)/v # should happen *fast*
        stopifnot(dim(BB) == c(m,n), is(BB, "sparseMatrix"))
    })
    str(BB)
    print(st)
    if(Sys.info()[["sysname"]] == "Linux") {
        mips <- as.numeric(sub(".*: *", '',
                               grep("bogomips", readLines("/proc/cpuinfo"),
                                    value=TRUE)[[1]]))
        stopifnot(st[1] < 1000/mips)# ensure there was no gross inefficiency
    }
})


###----- Compare methods ---> logical Matrices ------------
l3 <- upper.tri(matrix(, 3, 3))
(ll3 <- Matrix(l3))
dt3 <- (99* Diagonal(3) + (10 * ll3 + Diagonal(3)))/10
(dsc <- crossprod(ll3))
stopifnot(identical(ll3, t(t(ll3))),
	  identical(dsc, t(t(dsc))))
stopifnotValid(ll3, "ltCMatrix")
stopifnotValid(dsc, "dsCMatrix")
stopifnotValid(dsc + 3 * Diagonal(nrow(dsc)), "dsCMatrix")
stopifnotValid(dt3, "triangularMatrix")    # remained triangular
stopifnotValid(dt3 > 0, "triangularMatrix")# ditto


(lm1 <- dsc >= 1) # now ok
(lm2 <- dsc == 1) # now ok
nm1 <- as(lm1, "nMatrix")
(nm2 <- as(lm2, "nMatrix"))

stopifnot(validObject(lm1), validObject(lm2),
          validObject(nm1), validObject(nm2),
          identical(dsc, as(dsc * as(lm1, "dMatrix"), "dsCMatrix")))

crossprod(lm1) # lm1: "lsC*"
cnm1 <- crossprod(nm1)
stopifnot(is(cnm1, "symmetricMatrix"), ## whereas the %*% is not:
	  Q.eq(cnm1, nm1 %*% nm1))
dn1 <- as(nm1, "denseMatrix")
stopifnot(all(dn1 == nm1))

dsc[2,3] <- NA ## now has an NA (and no longer is symmetric)
##          ----- and "everything" is different
## also add "non-structural 0":
dsc@x[1] <- 0
dsc
dsc/ 5
dsc + dsc
dsc - dsc
dsc + 1 # -> no longer sparse
Tsc <- as(dsc, "TsparseMatrix")
dsc. <- drop0(dsc)
stopifnot(identical(dsc., Matrix((dsc + 1) -1)),
	  identical(as(-Tsc,"CsparseMatrix"), (-1) * Tsc),
	  identical(-dsc., (-1) * dsc.),
	  identical3(-Diagonal(3), Diagonal(3, -1), (-1) * Diagonal(3)),
	  identical(dsc., Matrix((Tsc + 1) -1)), # ok (exact arithmetic)
	  Q.eq(0 != dsc, dsc != Matrix(0, 3, 3)),
	  Q.eq(0 != dsc, dsc != c(0,0)) # with a warning ("not multiple ..")
	  )
str(lm1 <- dsc >= 1) # now ok (NA in proper place, however:
lm1 ## NA used to print as ' ' , now 'N'
(lm2 <- dsc == 1)# ditto
stopifnot(identical(crossprod(lm1),# "lgC": here works!
                    crossprod(as(lm1, "dMatrix"))),
          identical(lm2, lm1 & lm2),
	  identical(lm1, lm1 | lm2))

ddsc <- kronecker(Diagonal(7), dsc)
isValid(ddv <- rowSums(ddsc, sparse=TRUE), "sparseVector")
sv <- colSums(kC <- kronecker(mC,kronecker(mC,mC)), sparse=TRUE)
EQ <- ddv == rowSums(ddsc)
na.ddv <- is.na(ddv)
sM <- Matrix(pmax(0, round(rnorm(50*15, -1.5), 2)), 50,15)
stopifnot(sv == colSums(kC), is.na(as.vector(ddv)) == na.ddv,
          isValid(sM/(-7:7), "CsparseMatrix"),
	  all(EQ | na.ddv))

## Subclasses (!)
setClass("m.spV", contains = "dsparseVector")
(m.ddv <- as(ddv, "m.spV"))
stopifnot(all.equal(m.ddv, ddv))# failed
setClass("m.dgC", contains = "dgCMatrix")
(m.mC <- as(mC, "m.dgC"))
stopifnot(all(m.mC == mC))

## Just for print "show":
z <- round(rnorm(77), 2)
z[sample(77,10)] <- NA
(D <- Matrix(z, 7)) # dense
z[sample(77,15)] <- 0
(D <- Matrix(z, 7)) # sparse
abs(D) >= 0.5       # logical sparse


## For the checks below, remove some and add a few more objects:
rm(list= ls(pat="^.[mMC]?$"))
D3 <- Diagonal(x=4:2); L7 <- Diagonal(7) > 0
T3 <- Diagonal(3) > 0; stopifnot(T3@diag == "U") # "uni-diagonal"
validObject(xpp <- pack(round(xpx,2)))
validObject(dtp <- pack(as(dt3, "denseMatrix")))
lsp <- xpp > 0
isValid(lsC <- as(lsp, "sparseMatrix"), "lsCMatrix")

showProc.time()
if(!doExtras && !interactive()) q("no") ## (saving testing time)

### Systematically look at all "Ops" group generics for "all" Matrix classes
### -------------- Main issue: Detect infinite recursion problems
cl <- sapply(ls(), function(.) class(get(.)))
Mcl <- cl[vapply(cl, extends, "Matrix", FUN.VALUE=NA) |
          vapply(cl, extends, "sparseVector", FUN.VALUE=NA)]
table(Mcl)
## choose *one* of each class:
## M.objs <- names(Mcl[!duplicated(Mcl)])
## choose all
M.objs <- names(Mcl) # == the ls() from above
Mat.objs <- M.objs[vapply(M.objs, function(nm) is(get(nm), "Matrix"), NA)]
MatDims <- t(vapply(Mat.objs, function(nm) dim(get(nm)), 0:1))
noquote(cbind(Mcl[Mat.objs], format(MatDims)))
mDims <- MatDims %*% (d.sig <- c(1, 1000)) # "dim-signature" to match against

m2num <- function(m) { if(is.integer(m)) storage.mode(m) <- "double" ; m }
M.knd <- Matrix:::.M.kind
cat("Checking all Ops group generics for a set of arguments:\n",
    "-------------------------------------------------------\n", sep='')
op <- options(warn = 2)#, error=recover)
for(gr in getGroupMembers("Ops")) {
  cat(gr,"\n",paste(rep.int("=",nchar(gr)),collapse=""),"\n", sep='')
  for(f in getGroupMembers(gr)) {
    cat(sprintf("%9s :\n%9s\n", paste0('"',f,'"'), "--"))
    for(nm in M.objs) {
      if(doExtras) cat("  '",nm,"' ", sep="")
      M <- get(nm, inherits=FALSE)
      n.m <- NROW(M)
      cat("o")
      for(x in list(TRUE, -3.2, 0L, seq_len(n.m))) {
        cat(".")
        validObject(r1 <- do.call(f, list(M,x)))
        validObject(r2 <- do.call(f, list(x,M)))
        stopifnot(dim(r1) == dim(M), dim(r2) == dim(M))
      }
      ## M  o  <sparseVector>
      x <- numeric(n.m)
      x[c(1,length(x))] <- 1:2
      sv <- as(x, "sparseVector")
      cat("s.")
      validObject(r3 <- do.call(f, list(M, sv)))
      stopifnot(dim(r3) == dim(M))
      if(doExtras && is(M, "Matrix")) { ## M o <Matrix>
        d <- dim(M)
        ds <- sum(d * d.sig)         # signature .. match with all other sigs
        match. <- ds == mDims        # (matches at least itself)
        cat("\nM o M:")
        for(oM in Mat.objs[match.]) {
          M2 <- get(oM)
          ##   R4 :=  M  f  M2
          validObject(R4 <- do.call(f, list(M, M2)))
          cat(".")
          for(M. in list(as.mat(M), M)) { ## two cases ..
            r4 <- m2num(as.mat(do.call(f, list(M., as.mat(M2)))))
            cat(",")
            if(!identical(r4, as.mat(R4))) {
              cat(sprintf("\n %s %s %s not identical: r4 \\ R4:\n",
                          nm, f, oM))
              print(r4); print(R4)
              C1 <- (eq <- R4 == r4) | ((nr4 <- is.na(r4)) & !is.finite(R4))
              if(isTRUE(all(C1)) && (k1 <- M.knd(M)) != "d" && (k2 <- M.knd(M2)) != "d")
                cat(" --> ",k1,"",f,"", k2,
                    " (ok): only difference is NA (matrix) and NaN/Inf (Matrix)\n")
              else if(isTRUE(all(eq | (nr4 & Matrix:::is0(R4)))))
                cat(" --> 'ok': only difference is 'NA' (matrix) and 0 (Matrix)\n")
              else stop("differing \"too much\"")
            }
          }
          cat("i")
        }
      }
    }
    cat("\n")
  }
}
showProc.time()

###---- Now checking 0-length / 0-dim cases  <==> to R >= 3.4.0 !

## arithmetic, logic, and comparison (relop) for 0-extent arrays
(m <- Matrix(cbind(a=1[0], b=2[0])))
Lm <- as(m, "lMatrix")
## Im <- as(m, "iMatrix")
stopifnot(
    identical(m, m + 1), identical(m, m + 1[0]),
    identical(m, m + NULL),## now (2016-09-27) ok
    identical(m, Lm+ 1L) ,
    identical(m, m+2:3), ## gave error "length does not match dimension"
    identical(Lm, m & 1),
    identical(Lm, m | 2:3),## had Warning "In .... : data length exceeds size of matrix"
    identical(Lm, m & TRUE[0]),
    identical(Lm, m | FALSE[0]),
    identical(Lm, m > NULL),
    identical(Lm, m > 1),
    identical(Lm, m > .1[0]),## was losing dimnames
    identical(Lm, m > NULL), ## was not-yet-implemented
    identical(Lm, m <= 2:3)  ## had "wrong" warning
)
mm <- m[,c(1:2,2:1,2)]
assertV(m + mm) # ... non-conformable arrays
assertV(m | mm) # ... non-conformable arrays
## Matrix: ok ;  R : ok, in R >= 3.4.0
assertV(m == mm)
## in R <= 3.3.x, relop returned logical(0) and  m + 2:3  returned numeric(0)
##
## arithmetic, logic, and comparison (relop) -- inconsistency for 1x1 array o <vector >= 2>:
(m1 <- Matrix(1,1,1, dimnames=list("Ro","col")))
##    col
## Ro   1
## Before Sep.2016, here, Matrix was the *CONTRARY* to R:
assertV(m1  + 1:2)## M.: "correct" ERROR // R 3.4.0: "deprecated" warning (--> will be error)
assertV(m1  & 1:2)## gave 1 x 1 [TRUE]  -- now Error, as R
assertV(m1 <= 1:2)## gave 1 x 1 [TRUE]  -- now Error, as R
assertV(m1  & 1:2)## gave 1 x 1 [TRUE]  -- now Error, as R
assertV(m1 <= 1:2)## gave 1 x 1 [TRUE]  -- now Error, as R
##
##  arrays combined with NULL works
stopifnot(identical(Matrix(3,1,1) + NULL, 3[0]))# FIXME not-yet-implemented -- now ok
stopifnot(identical(Matrix(3,1,1) > NULL, T[0]))# FIXME not-yet-implemented -- now ok
stopifnot(identical(Matrix(3,1,1) & NULL, T[0])) ## FIXME ... -- now ok
## in R >= 3.4.0: logical(0) # with *no* warning and that's correct!

options(op)# reset 'warn'
mStop <- function(...) stop(..., call. = FALSE)
##
cat("Checking the Math (+ Math2) group generics for a set of arguments:\n",
    "------------ ==== ------------------------------------------------\n", sep='')
doStop <- function() mStop("**Math: ", f,"(<",class(M),">) of 'wrong' class ", dQuote(class(R)))
mM  <- getGroupMembers("Math")
mM2 <- getGroupMembers("Math2")
(mVec <- grep("^cum", mM, value=TRUE)) ## <<- are special: return *vector* for matrix input
for(f in c(mM, mM2)) {
  cat(sprintf("%-9s :\n %-7s\n", paste0('"',f,'"'), paste(rep("-", nchar(f)), collapse="")))
  givesVec <- f %in% mVec
  fn <- get(f)
  if(f %in% mM2) { fn0 <- fn ; fn <- function(x) fn0(x, digits=3) }
  for(nm in M.objs) {
    M <- get(nm, inherits=FALSE)
    is.m <- length(dim(M)) == 2
    cat("  '",nm,"':", if(is.m) "m" else "v", sep="")
    R <- fn(M)
    r <- fn(m <- if(is.m) as.mat(M) else as.vector(M))
    stopifnot(identical(dim(R), dim(r)))
    if(givesVec || !is.m) {
        assert.EQ(R, r)
    } else { ## (almost always:) matrix result
        assert.EQ.mat(R, r)
	## check preservation of properties, notably super class
	if(prod(dim(M)) > 1 && is(M, "diagonalMatrix"  ) && isDiagonal  (R) && !is(R, "diagonalMatrix"  )) doStop()
	if(prod(dim(M)) > 1 && is(M, "triangularMatrix") && (iT <- isTriangular(R)) && attr(iT, "kind") == M@uplo &&
           !is(R, "triangularMatrix")) doStop()
    }
  }
  cat("\n")
}
showProc.time()

##
cat("Checking the Summary group generics for a set of arguments:\n",
    "------------ ======= ------------------------------------------------\n", sep='')
doStop <- function()
    warning("**Summary: ", f,"(<",class(M),">) is not all.equal(..)", immediate.=TRUE)
for(f in getGroupMembers("Summary")) {
  cat(sprintf("%-9s :\n %-7s\n", paste0('"',f,'"'), paste(rep("-", nchar(f)), collapse="")))
  givesVec <- f %in% mVec
  fn <- get(f)
  if(f %in% mM2) { fn0 <- fn ; fn <- function(x) fn0(x, digits=3) }
  for(nm in M.objs) {
    M <- get(nm, inherits=FALSE)
    is.m <- length(dim(M)) == 2
    cat("  '",nm,"':", if(is.m) "m" else "v", sep="")
    R <- fn(M)
    r <- fn(m <- if(is.m) as.mat(M) else as.vector(M))
    stopifnot(identical(dim(R), dim(r)))
    assert.EQ(R, r)
  }
  cat("\n")
  ## if(length(warnings())) print(warnings())
}


cat('Time elapsed: ', proc.time(),'\n') # for ``statistical reasons''
