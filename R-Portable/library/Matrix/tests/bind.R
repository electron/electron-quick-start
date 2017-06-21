#### Testing  cBind() & rBind()

if(getRversion() >= "3.2.0") {
    cBind <- base::cbind
    rBind <- base::rbind
}


library(Matrix)

source(system.file("test-tools.R", package = "Matrix"))# identical3() etc

### --- Dense Matrices ---

m1 <- m2 <- m <- matrix(1:12, 3,4)
dimnames(m2) <- list(LETTERS[1:3],
                     letters[1:4])
dimnames(m1) <- list(NULL,letters[1:4])
M  <- Matrix(m)
M1 <- Matrix(m1)
M2 <- Matrix(m2)

stopifnot(
    identical3(cBind ( M, 10*M),
		show(cbind2( M, 10*M)),
	      Matrix(cbind ( m, 10*m)))
   ,
    identical3(cBind (M1, 100+M1),
               show(cbind2(M1, 100+M1)),
               Matrix(cbind (m1, 100+m1)))
   ,
    identical3(cBind (M1, 10*M2),
               show(cbind2(M1, 10*M2)),
               Matrix(cbind (m1, 10*m2)))
   ,
    identical3(cBind (M2, M1+M2),
               show(cbind2(M2, M1+M2)),
               Matrix(cbind (m2, m1+m2)))
   ,
    identical(colnames(show(cBind(M1, MM = -1))),
	      c(colnames(M1), "MM"))
   ,
    identical3(rBind ( M, 10*M),
		show(rbind2( M, 10*M)),
	      Matrix(rbind ( m, 10*m)))
    ,
    identical3(rBind (M2, M1+M2),
	       show(rbind2(M2, M1+M2)),
	       Matrix(rbind (m2, m1+m2)))
   ,
    Qidentical(show  (rBind(R1 = 10:11, M1)),
	       Matrix(rbind(R1 = 10:11, m1)), strict=FALSE)
  , TRUE)

identical.or.eq <- function(x,y, tol=0, ...) {
    if(identical(x,y, ...))
        TRUE
    else if(isTRUE(aeq <- all.equal(x,y, tolerance = tol)))
        structure(TRUE, comment = "not identical")
    else aeq
}
identicalShow <- function(x,y, ...)
    if(!isTRUE(id <- identical.or.eq(x, y, ...))) cat(id,"\n")

## Checking  deparse.level { <==> example at end of ?cbind }:
checkRN <- function(dd, B = rbind) {
    FN <- function(deparse.level)
        rownames(B(1:4, c=2,"a+"=10, dd, deparse.level=deparse.level))
    rn <- c("1:4", "c", "a+", "dd",  "")
    isMatr <- (length(dim(dd)) == 2)
    id <- if(isMatr) 5 else 4
    if(!identical(B, methods:::rbind)) ## <= BUG in methods:::rbind !!
    identicalShow(rn[c(5,2:3, 5)], FN(deparse.level= 0)) # middle two names
    identicalShow(rn[c(5,2:3,id)], FN(deparse.level= 1)) # last shown if vector
    identicalShow(rn[c(1,2:3,id)], FN(deparse.level= 2)) # first shown; (last if vec.)
}
checkRN(10) # <==> ?cbind's ex
checkRN(1:4)
checkRN(       rbind(c(0:1,0,0)))
if(FALSE)# not yet
checkRN(Matrix(rbind(c(0:1,0,0))))
## rBind(): -- works with the above workaround methods:::rbind bug
checkRN(10 ,				rBind)
checkRN(1:4,				rBind)
checkRN(       rbind(c(0:1,0,0)),  	rBind)
checkRN(Matrix(rbind(c(0:1,0,0))), 	rBind)


cBind(0, Matrix(0+0:1, 1,2), 3:2)# FIXME? should warn - as with matrix()
as(rBind(0, Matrix(0+0:1, 1,2), 3:2),
   "sparseMatrix")
cBind(M2, 10*M2[nrow(M2):1 ,])# keeps the rownames from the first

(im <- cBind(I = 100, M))
str(im)
(mi <- cBind(M2, I = 1000))
str(mi)
(m1m <- cBind(M,I=100,M2))
showProc.time()

### --- Diagonal / Sparse - had bugs

D4 <- Diagonal(4)
(D4T <- as(D4, "TsparseMatrix"))
D4C <- as(D4T, "CsparseMatrix")
c1 <- Matrix(0+0:3, 4, sparse=TRUE) ; r1 <- t(c1); r1

d4 <- rBind(Diagonal(4), 0:3)
m4 <- cBind(Diagonal(x=-1:2), 0:3)
c4. <- cBind(Diagonal(4), c1)
c.4 <- cBind(c1, Diagonal(4))
r4. <- rBind(Diagonal(4), r1)
r.4 <- rBind(r1, Diagonal(4))
assert.EQ.mat(d4, rBind(diag(4),    0:3))
assert.EQ.mat(m4, cBind(diag(-1:2), 0:3))
stopifnot(identical(Matrix(cbind(diag(3),0)), cbind2(Diagonal(3),0)),
	  is(d4, "sparseMatrix"), is(m4, "sparseMatrix"),
	  identical(t(d4), cBind(Diagonal(4),     0:3)),
	  identical(t(m4), rBind(Diagonal(x=-1:2), 0:3)))
showProc.time()

### --- Sparse Matrices ---

identical4(cBind(diag(4), diag(4)),
           cBind(D4C, D4C),
           cBind(D4T, D4C),
           cBind(D4C, D4T))
nr <- 4
m. <- matrix(c(0, 2:-1),  nr ,6)
M <- Matrix(m.)
(mC <- as(M, "dgCMatrix"))
(mT <- as(M, "dgTMatrix"))
stopifnot(identical(mT, as(mC, "dgTMatrix")),
          identical(mC, as(mT, "dgCMatrix")))

for(v in list(0, 2, 1:0))
    for(fnam in c("cBind", "rBind")) {
        cat(fnam,"(m, v=", deparse(v),"), class(m) :")
        FUN <- get(fnam)
        for(m in list(M, mC, mT)) {
            cat("", class(m),"")
            assert.EQ.mat(FUN(v, m), FUN(v, m.)) ; cat(",")
            assert.EQ.mat(FUN(m, v), FUN(m., v)) ; cat(".")
        }
        cat("\n")
    }
showProc.time()

cBind(0, mC); cBind(mC, 0)
cBind(0, mT); cBind(mT, 2)
cBind(diag(nr), mT)
stopifnot(identical(t(cBind(diag(nr),   mT)),
                      rBind(diag(nr), t(mT))))
(cc <- cBind(mC, 0,7,0, diag(nr), 0))
stopifnot(identical3(cc, cBind(mT, 0,7,0, diag(nr), 0),
                     as( cBind( M, 0,7,0, diag(nr), 0), "dgCMatrix")))

cBind(mC, 1, 100*mC, 0, 0:2)
cBind(mT, 1, 0, mT+10*mT, 0, 0:2)
one <- 1
zero <- 0
dimnames(mC) <- dimnames(mT) <- list(LETTERS[1:4], letters[1:6])
op <- options(sparse.colnames = TRUE)# show colnames in print :
cBind(mC, one, 100*mC, zero, 0:2)
cBind(mC, one, 100*mC, zero, 0:2, deparse.level=0)# no "zero", "one"
cBind(mC, one, 100*mC, zero, 0:2, deparse.level=2)# even "0:2"
cBind(mT, one, zero, mT+10*mT, zero, 0:2)


## logical (sparse) - should remain logical :
L5 <- Diagonal(n = 5, x = TRUE); v5 <- rep(x = c(FALSE,TRUE), length = ncol(L5))
stopifnot(is(show(rBind(L5,v5)), "lsparseMatrix"),
	  is(show(cBind(v5,L5)), "lsparseMatrix"),
	  is(rBind(L5, 2* v5), "dsparseMatrix"),
	  is(cBind(2* v5, L5), "dsparseMatrix"))

## print() / show() of  non-structural zeros:
(m <- Matrix(c(0, 0, 2:0), 3, 5))
(m2 <- cBind(m,m))
(m4 <- rBind(m2,m2))
diag(m4)
for(i in 1:6) {
    m4[i, i ] <- i
    m4[i,i+1] <- 0
}
m4 ## now show some non-structural zeros:

## Mixture of dense and sparse/diagonal -- used to fail, even in 1.0-0
D5 <- Diagonal(x = 10*(1:5))
(D5.1 <- cbind2(D5, 1))
## "FIXME" in newer versions of R, do not need Matrix() here:
s42 <- Matrix(z42 <- cbind2(rep(0:1,4), rep(1:0,4)),
              sparse=TRUE)
(C86 <- rBind(1, 0, D5.1, 0))
stopifnotValid(D5.1, "dgCMatrix")
stopifnotValid(print(rbind2(Matrix(1:10, 2,5), D5)),   "dgCMatrix")
stopifnotValid(print(cbind2(Matrix(10:1, 5,2), D5.1)), "dgeMatrix")
stopifnotValid(zz <- cbind2(z42, C86), "dgCMatrix")
stopifnot(identical(zz, cbind2(s42, C86)))

## Using "nMatrix"
(m1 <- sparseMatrix(1:3, 1:3)) # ngCMatrix
m2 <- sparseMatrix(1:3, 1:3, x = 1:3)
stopifnotValid(c12 <- cBind(m1,m2), "dgCMatrix") # was "ngC.." because of cholmod_horzcat !
stopifnotValid(c21 <- cBind(m2,m1), "dgCMatrix") #  ditto
stopifnotValid(r12 <- rBind(m1,m2), "dgCMatrix") # was "ngC.." because of cholmod_vertcat !
stopifnotValid(r21 <- rBind(m2,m1), "dgCMatrix") #  ditto
d1 <- as(m1, "denseMatrix")
d2 <- as(m2, "denseMatrix")
stopifnotValid(cbind2(d2,d1), "dgeMatrix")
stopifnotValid(cbind2(d1,d2), "dgeMatrix")## gave an error in Matrix 1.1-5
stopifnotValid(rbind2(d2,d1), "dgeMatrix")
stopifnotValid(rbind2(d1,d2), "dgeMatrix")## gave an error in Matrix 1.1-5

## rbind2() / cbind2() mixing sparse/dense: used to "fail",
## ------------------- then (in 'devel', ~ 2015-03): completely wrong
S <- .sparseDiagonal(2)
s <- diag(2)
S9 <- rBind(S,0,0,S,0,NaN,0,0,0,2)## r/cbind2() failed to determine 'sparse' in Matrix <= 1.2-2
s9 <- rbind(s,0,0,s,0,NaN,0,0,0,2)
assert.EQ.mat(S9, s9)
D <- Matrix(1:6, 3,2); d <- as.matrix(D)
T9 <- t(S9); t9 <- t(s9); T <- t(D); t <- t(d)
stopifnot(identical(rbind (s9,d), rbind2(s9,d)),
	  identical(rbind2(D,S9), t(cbind2(T,T9))),
	  identical(rbind2(S9,D), t(cbind2(T9,T))))
assert.EQ.mat(rbind2(S9,D), rbind2(s9,d))
assert.EQ.mat(rbind2(D,S9), rbind2(d,s9))
## now with cbind2() -- no problem!
stopifnot(identical(cbind (t9,t), cbind2(t9,t)))
assert.EQ.mat(cbind2(T9,T), cbind2(t9,t))
assert.EQ.mat(cbind2(T,T9), cbind2(t,t9))



options(op)
showProc.time()
