library(Matrix)

source(system.file("test-tools.R", package = "Matrix"))

data(KNex) ; mm <- KNex$mm
stopifnot(##is(mm) == c("dgCMatrix", "dMatrix", "Matrix"),
          dim(mm) == (dm <- c(1850, 712)),
          identical(dimnames(mm), list(NULL,NULL)))
str(mm)
tmm <- t(mm)
str(tmm)

str(mTm <- crossprod(mm))
mmT  <- crossprod(tmm)
mmT. <- tcrossprod(mm)
stopifnot(all.equal(mmT, mmT.))
## Previously these were not the same
## Should be the same but not quite: even length( * @ x ) differs!
##str(mmT, max=2)# much larger than mTm (i.e less sparse)
##str(mmT., max=2)# x slot is currently slightly larger --> improve tcrossprod()?
##system.time(ae <- all.equal(as(mmT.,"matrix"), as(mmT,"matrix"), tolerance = 1e-14))
## 4-5 seconds on a 850 MHz, P III
##stopifnot(ae)

stopifnot(validObject(tmm), dim(tmm) == dm[2:1],
          validObject(mTm), dim(mTm) == dm[c(2,2)],
          validObject(mmT), dim(mmT) == dm[c(1,1)],
          identical(as(tmm, "matrix"), t(as(mm, "matrix"))))

## from a bug report by Guissepe Ragusa <gragusa@ucsd.edu>
set.seed(101)
for(i in 1:10) {
    A <- matrix(rnorm(400), nrow = 100, ncol = 4)
    A[A < +1] <- 0 ; Am <- A
    Acsc <- as(Am, "dgCMatrix")
    A    <- as(Am, "dgeMatrix")
    b <- matrix(rnorm(400), nrow = 4, ncol = 100)
    B <- as(b, "dgeMatrix")
    assert.EQ.mat(A %*% B, Am %*%  b)
    assert.EQ.mat(B %*% A,  b %*% Am)
    stopifnot(identical(A, as(Acsc, "dgeMatrix")),
              identical(Acsc, as(A, "dgCMatrix")),
              is.all.equal4(A %*% B, Acsc %*% B,
                            A %*% b, Acsc %*% b),
              is.all.equal4(b %*% A, b %*% Acsc,
                            B %*% A, B %*% Acsc))
}

###--- dgTMatrix {was ./dgTMatrix.R } -------

### Use ``non-unique'' versions of dgTMatrix objects

N <- 200
set.seed(1)
i <- as.integer(round(runif (N, 0, 100)))
j <- as.integer(3* rpois (N, lam=15))
x <- round(rnorm(N), 2)
which(duplicated(cbind(i,j))) # 8 index pairs are duplicated

m1 <- new("dgTMatrix", Dim = c(max(i)+1:1, max(j)+1:1), i = i, j = j, x = x)
mc <- as(m1, "dgCMatrix")
m2 <- as(mc, "dgTMatrix")## the same as 'm1' but without duplicates

stopifnot(!isTRUE(all.equal.default(m1, m2)),
          all.equal(as(m1,"matrix"), as(m2,"matrix"), tolerance =1e-15),
          all.equal(crossprod(m1), crossprod(m2), tolerance =1e-15),
          identical(mc, as(m2, "dgCMatrix")))

### -> uniq* functions now in ../R/Auxiliaries.R
(t2 <- system.time(um2 <- Matrix:::uniq(m1)))
stopifnot(identical(m2,um2))

### -> error/warning condition for solve() of a singular matrix (Barry Rowlingson)
(M <- Matrix(0+ 1:16, nc = 4))
assertError(solve(M), verbose=TRUE)## ".. computationally singular" + warning + caches LU
assertError(solve(t(M)))
options(warn=2) # no more warnings allowed from here
lum <- lu(M, warnSing=FALSE)
stopifnot(is(fLU <- M@factors $ LU, "MatrixFactorization"),
          identical(lum, fLU))
(e.lu <- expand(fLU))
M2 <- with(e.lu, P %*% L %*% U)
assert.EQ.mat(M2, as(M, "matrix"))
## now the sparse LU :
M. <- as(M,"sparseMatrix")
tt <- try(solve(M.)) # less nice: factor is *not* cached
## use a non-singular one:
M1 <- M. + 0.5*Diagonal(nrow(M.))
luM1 <- lu(M1)
d1 <- determinant(as(M1,"denseMatrix"))
stopifnot(identical(luM1, M1@factors$LU),
	  diag(luM1@L) == 1,# L is *unit*-triangular
	  all.equal(log(-prod(diag(luM1@U))), c(d1$modulus)))

cat('Time elapsed: ', proc.time(),'\n') # for ``statistical reasons''
