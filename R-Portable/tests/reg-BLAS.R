
## PR#4582 %*% with NAs
stopifnot(is.na(NA %*% 0), is.na(0 %*% NA))
## depended on the BLAS in use.


## found from fallback test in slam 0.1-15
## most likely indicates an inaedquate BLAS.
x <- matrix(c(1, 0, NA, 1), 2, 2)
y <- matrix(c(1, 0, 0, 2, 1, 0), 3, 2)
(z <- tcrossprod(x, y))
stopifnot(identical(z, x %*% t(y)))
stopifnot(is.nan(log(0) %*% 0))
## depended on the BLAS in use: some (including the reference BLAS)
## had z[1,3] == 0 and log(0) %*% 0 as as.matrix(0).

## matrix products
for(mopt in c("default","internal","default.simd")) {

  # matprod="blas" is excluded because some tests fail due to issues
  # in NaN/Inf propagation even in Rblas
  options(matprod=mopt)

  m <- matrix(c(1,2,3,4), ncol=2)
  v <- c(11,12)
  rv <- v; dim(rv) <- c(1,2)
  cv <- v; dim(cv) <- c(2,1)

  Cm <- m+0*1i;  # cast to complex keeping dimensions
  Cv <- v+0*1i;
  Ccv <- cv+0*1i;
  Crv <- rv+0*1i;

  cprod <- function(rres, cres, expected) {
    stopifnot(identical(rres, expected))
    stopifnot(identical(Re(cres), expected))
  }

  cprod(m %*% m, Cm %*% Cm, matrix(c(7,10,15,22), 2, 2) )
  cprod(m %*% cv, Cm %*% Ccv, matrix(c(47,70), 2, 1) )
  cprod(m %*% v, Cm %*% Cv, matrix(c(47,70), 2, 1) )
  cprod(rv %*% m, Crv %*% Cm, matrix(c(35,81), 1, 2) )
  cprod(v %*% m, Cv %*% Cm, matrix(c(35,81), 1, 2) )
  cprod(rv %*% cv, Crv %*% Ccv, matrix(265,1,1) )
  cprod(cv %*% rv, Ccv %*% Crv, matrix(c(121,132,132,144), 2, 2) )
  cprod(v %*% v, Cv %*% Cv, matrix(265,1,1) )

  cprod(crossprod(m, m), crossprod(Cm, Cm), matrix(c(5,11,11,25), 2, 2) )
  cprod(crossprod(m), crossprod(Cm), matrix(c(5,11,11,25), 2, 2) )
  cprod(crossprod(m, cv), crossprod(Cm, Ccv), matrix(c(35,81), 2, 1) )
  cprod(crossprod(m, v), crossprod(Cm, Cv), matrix(c(35,81), 2, 1) )
  cprod(crossprod(cv, m), crossprod(Ccv, Cm), matrix(c(35,81), 1, 2) )
  cprod(crossprod(v, m), crossprod(Cv, Cm), matrix(c(35,81), 1, 2) )
  cprod(crossprod(cv, cv), crossprod(Ccv, Ccv), matrix(265,1,1) )
  cprod(crossprod(v, v), crossprod(Cv, Cv), matrix(265,1,1) )
  cprod(crossprod(rv, rv), crossprod(Crv, Crv), matrix(c(121,132,132,144), 2, 2) )

  cprod(tcrossprod(m, m), tcrossprod(Cm, Cm), matrix(c(10,14,14,20), 2, 2) )
  cprod(tcrossprod(m), tcrossprod(Cm), matrix(c(10,14,14,20), 2, 2) )
  cprod(tcrossprod(m, rv), tcrossprod(Cm, Crv), matrix(c(47,70), 2, 1) )
  cprod(tcrossprod(rv, m), tcrossprod(Crv, Cm), matrix(c(47,70), 1, 2) )
  cprod(tcrossprod(v, m), tcrossprod(Cv, Cm), matrix(c(47,70), 1, 2) )
  cprod(tcrossprod(rv, rv), tcrossprod(Crv, Crv), matrix(265,1,1) )
  cprod(tcrossprod(cv, cv), tcrossprod(Ccv, Ccv), matrix(c(121,132,132,144), 2, 2) )
  cprod(tcrossprod(v, v), tcrossprod(Cv, Cv), matrix(c(121,132,132,144), 2, 2) )

  ## non-square matrix, with Inf

  m1 <- matrix(c(1,2,Inf,4,5,6), ncol=2)
  m2 <- matrix(c(1,2,3,4), ncol=2)

  v <- c(11,12)
  rv <- v; dim(rv) <- c(1,2)
  cv <- v; dim(cv) <- c(2,1)

  v1 <- c(11,12,13)
  rv1 <- v1; dim(rv1) <- c(1,3)
  cv1 <- v1; dim(cv1) <- c(3,1)

  Cm1 <- m1+0*1i
  Cm2 <- m2+0*1i
  Cv <- v+0*1i
  Crv <- rv+0*1i
  Ccv <- cv+0*1i
  Cv1 <- v1+0*1i
  Crv1 <- rv1+0*1i
  Ccv1 <- cv1+0*1i

  cprod(m1 %*% m2, Cm1 %*% Cm2, matrix(c(9,12,Inf,19,26,Inf), 3, 2) )
  cprod(m1 %*% cv, Cm1 %*% Ccv, matrix(c(59,82,Inf), 3, 1) )

    # the following 7 lines fail with Rblas and matprod = "blas"
  cprod(rv1 %*% m1, Crv1 %*% Cm1, matrix(c(Inf,182), 1, 2) )

  cprod(crossprod(m1, m1), crossprod(Cm1, Cm1), matrix(c(Inf,Inf,Inf,77), 2, 2) )
  cprod(crossprod(m1, cv1), crossprod(Cm1, Ccv1), matrix(c(Inf,182), 2, 1) )
  cprod(crossprod(cv1, m1), crossprod(Ccv1, Cm1), matrix(c(Inf,182), 1, 2) )

  cprod(tcrossprod(m1, m1), tcrossprod(Cm1, Cm1), matrix(c(17,22,Inf,22,29,Inf,Inf,Inf,Inf), 3,3) )
  cprod(tcrossprod(m2, m1), tcrossprod(Cm2, Cm1), matrix(c(13,18,17,24,Inf,Inf), 2, 3) )
  cprod(tcrossprod(rv, m1), tcrossprod(Crv, Cm1), matrix(c(59,82,Inf), 1, 3) )
    # the previous 7 lines fail with Rblas and matprod = "blas"

  cprod(tcrossprod(m1, rv), tcrossprod(Cm1, Crv), matrix(c(59,82,Inf), 3, 1) )

  ## complex

  m1 <- matrix(c(1+1i,2+2i,3+3i,4+4i,5+5i,6+6i), ncol=2)
  m2 <- matrix(c(1+1i,2+2i,3+3i,4+4i), ncol=2)

  stopifnot(identical(m1 %*% m2, matrix(c(18i,24i,30i,38i,52i,66i), 3, 2) ))
  stopifnot(identical(crossprod(m1, m1), t(m1) %*% m1))
  stopifnot(identical(tcrossprod(m1, m1), m1 %*% t(m1)))
}

## check that propagation of NaN/Inf values in multiplication of complex
## numbers is the same as in multiplication of complex matrices

for(mopt in c("default","internal","default.simd")) {
  # matprod="blas" is excluded because some tests fail due to issues
  # in NaN/Inf propagation even in Rblas
  options(matprod=mopt)

  vals <- c(0, 1, NaN, Inf)
  for(ar in vals)
  for(ai in vals)
  for(br in vals)
  for(bi in vals) {
    a = ar + 1i * ai
    b = br + 1i * bi
    stopifnot(identical(a * b, as.complex(a %*% b)))
    stopifnot(identical(a * b, as.complex(crossprod(a,b))))
    stopifnot(identical(a * b, as.complex(tcrossprod(a,b))))
  }
}
