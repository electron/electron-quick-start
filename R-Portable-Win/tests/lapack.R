## tests of R functions based on the lapack module

## NB: the signs of singular and eigenvectors are arbitrary,
## so there may be differences from the reference ouptut,
## especially when alternative BLAS are used.

options(digits = 4L)

##    -------  examples from ?svd ---------

hilbert <- function(n) { i <- 1:n; 1 / outer(i - 1, i, "+") }
Eps <- 100 * .Machine$double.eps

## The signs of the vectors are not determined here, so don't print
X <- hilbert(9L)[, 1:6]
s <- svd(X); D <- diag(s$d)
stopifnot(abs(X - s$u %*% D %*% t(s$v)) < Eps)#  X = U D V'
stopifnot(abs(D - t(s$u) %*% X %*% s$v) < Eps)#  D = U' X V

## ditto
X <- cbind(1, 1:7)
s <- svd(X); D <- diag(s$d)
stopifnot(abs(X - s$u %*% D %*% t(s$v)) < Eps)#  X = U D V'
stopifnot(abs(D - t(s$u) %*% X %*% s$v) < Eps)#  D = U' X V

# test nu and nv
s <- svd(X, nu = 0L)
s <- svd(X, nu = 7L) # the last 5 columns are not determined here
stopifnot(dim(s$u) == c(7L,7L))
s <- svd(X, nv = 0L)

# test of complex case

X <- cbind(1, 1:7+(-3:3)*1i)
s <- svd(X); D <- diag(s$d)
stopifnot(abs(X - s$u %*% D %*% Conj(t(s$v))) < Eps)
stopifnot(abs(D - Conj(t(s$u)) %*% X %*% s$v) < Eps)



##  -------  tests of random real and complex matrices ------
fixsign <- function(A) {
    A[] <- apply(A, 2L, function(x) x*sign(Re(x[1L])))
    A
}
##			       100  may cause failures here.
eigenok <- function(A, E, Eps=1000*.Machine$double.eps)
{
    print(fixsign(E$vectors))
    print(zapsmall(E$values))
    V <- E$vectors; lam <- E$values
    stopifnot(abs(A %*% V - V %*% diag(lam)) < Eps,
              abs(lam[length(lam)]/lam[1]) < Eps | # this one not for singular A :
              abs(A - V %*% diag(lam) %*% t(V)) < Eps)
}

Ceigenok <- function(A, E, Eps=1000*.Machine$double.eps)
{
    print(fixsign(E$vectors))
    print(signif(E$values, 5))
    V <- E$vectors; lam <- E$values
    stopifnot(Mod(A %*% V - V %*% diag(lam)) < Eps,
              Mod(A - V %*% diag(lam) %*% Conj(t(V))) < Eps)
}

## failed for some 64bit-Lapack-gcc combinations:
sm <- cbind(1, 3:1, 1:3)
eigenok(sm, eigen(sm))
eigenok(sm, eigen(sm, sym=FALSE))

set.seed(123)
sm <- matrix(rnorm(25), 5, 5)
sm <- 0.5 * (sm + t(sm))
eigenok(sm, eigen(sm))
eigenok(sm, eigen(sm, sym=FALSE))

sm[] <- as.complex(sm)
Ceigenok(sm, eigen(sm))
Ceigenok(sm, eigen(sm, sym=FALSE))

sm[] <- sm + rnorm(25) * 1i
sm <- 0.5 * (sm + Conj(t(sm)))
Ceigenok(sm, eigen(sm))
Ceigenok(sm, eigen(sm, sym=FALSE))


##  -------  tests of integer matrices -----------------

set.seed(123)
A <- matrix(rpois(25, 5), 5, 5)

A %*% A
crossprod(A)
tcrossprod(A)

solve(A)
qr(A)
determinant(A, log = FALSE)

rcond(A)
rcond(A, "I")
rcond(A, "1")

eigen(A)
svd(A)
La.svd(A)

As <- crossprod(A)
E <- eigen(As)
E$values
abs(E$vectors) # signs vary
chol(As)
backsolve(As, 1:5)

##  -------  tests of logical matrices -----------------

set.seed(123)
A <- matrix(runif(25) > 0.5, 5, 5)

A %*% A
crossprod(A)
tcrossprod(A)

Q <- qr(A)
zapsmall(Q$qr)
zapsmall(Q$qraux)
determinant(A, log = FALSE) # 0

rcond(A)
rcond(A, "I")
rcond(A, "1")

E <- eigen(A)
zapsmall(E$values)
zapsmall(Mod(E$vectors))
S <- svd(A)
zapsmall(S$d)
S <- La.svd(A)
zapsmall(S$d)

As <- A
As[upper.tri(A)] <- t(A)[upper.tri(A)]
det(As)
E <- eigen(As)
E$values
zapsmall(E$vectors)
solve(As)

## quite hard to come up with an example where this might make sense.
Ac <- A; Ac[] <- as.logical(diag(5))
chol(Ac)


