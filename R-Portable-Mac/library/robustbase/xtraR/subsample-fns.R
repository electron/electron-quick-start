### Mainly used for source package checking in ../../tests/subsample.R
### however, available (for reproducible research, confirmation) as
### part of the robustbase package.

## R version of LU decomposition in subsample() in lmrob.c
## Modified from Golub G. H., Van Loan, C. F., Matrix Computations, 3rd edition
LU.gaxpy <- function(A, pivot=TRUE, tol = 1e-7, verbose = FALSE)
{
    A <- as.matrix(A) ##  m x n  matrix,  n >= m >= 1
    stopifnot((n <- ncol(A)) >= (m <- nrow(A)), m >= 1)
    ## precondition:
    cf0 <- max(abs(A))
    A <- A / cf0
    v <- double(m) ## work matrix
    ## these matrices will contain the results
    L <- diag(m)
    U <- matrix(0, m, m)
    p <- integer(m-1) ## pivots
    idc <- 1L:n ## which columns of A are used
    idr <- 1L:m ## how rows of A are permuted
    for(j in 1L:m) {
	sing <- TRUE
	while(sing) {
            if (length(idc) < j)
                break
	    if (j == 1L) {
		v[j:m] <- A[idr[j:m], idc[j]]
	    } else {
		rows <- 1L:(j-1L)
		z <- forwardsolve(L[rows, rows, drop=FALSE], A[idr[rows], idc[j]])
		U[rows, j] <- z
		v[j:m] <- A[idr[j:m], idc[j]] - L[j:m, rows, drop=FALSE] %*% z
		if(verbose)
		    cat("Step", j, "z=", sapply(z, function(x) sprintf("%.15f", x)),
			"\n v=", v, "\n")
	    }
	    if (j < m) {
		mu <- j
		mu <- if (pivot) which.max(abs(v[j:m])) + j - 1L else j
		if(verbose) ## debug possumDiv example
		    cat(sprintf("R-Step: %i: ", j), round(abs(v[j:m]), 6),
			"\n", mu, v[mu], "\n")
		if (abs(v[mu]) >= tol) { ## singular: can stop here already
		    p[j] <- mu
		    if (pivot) {
			tmp <-   v[j];   v[j] <-   v[mu];   v[mu] <- tmp
			tmp <- idr[j]; idr[j] <- idr[mu]; idr[mu] <- tmp
		    }
		    L[(j+1L):m, j] <- v[(j+1L):m]/v[j]
		    if (pivot && j > 1) { ## swap rows   L[j,]  <->  L[mu,]
			tmp <- L[j, rows]; L[j, rows] <- L[mu, rows]; L[mu, rows] <- tmp
		    }
		}
	    }
	    U[j, j] <- v[j]
	    if (abs(v[j]) < tol) {
		if(verbose) cat("* singularity detected in step ", j,
				"; candidate ", idc[j],"\n")
		idc <- idc[-j]
	    } else sing <- FALSE
	}## {while}
    }## {for}
    list(L = L, U = U * cf0, p = p, idc = idc[1L:m], singular = sing)
}

Rsubsample <- function(x, y, mts=0, tolInverse = 1e-7) {
    if(!is.matrix(x)) x <- as.matrix(x)
    stopifnot((n <- length(y)) == nrow(x))
    p <- ncol(x)
    storage.mode(x) <- "double"
    .C(robustbase:::R_subsample,
       x=x,
       y=as.double(y),
       n=as.integer(n),
       m=as.integer(p),
       beta=double(p),
       ind_space=integer(n),
       idc = integer(n), ## elements 1:p: chosen subsample
       idr = integer(n),
       lu = matrix(double(1), p,p),
       v=double(p),
       pivot = integer(p-1),
       Dr=double(n),
       Dc=double(p),
       rowequ=integer(1),
       colequ=integer(1),
       status=integer(1),
       sample = FALSE, ## set this to TRUE for sampling
       mts = as.integer(mts),
       ss = as.integer(mts == 0),
       tolinv = as.double(tolInverse),
       solve = TRUE)
}

##' Simple version, just checking  (non)singularity conformance
tstSubsampleSing <- function(X, y) {
    lX <- X[sample(nrow(X)), ]
    ## C version
    zc <- Rsubsample(lX, y)
    ## R version
    zR <- LU.gaxpy(t(lX))
    if (as.logical(zc$status)) {
        ## singularity in C detected
        if (!zR$singular)
            stop("singularity in C but not in R")
    } else {
        ## no singularity detected
        if (zR$singular)
            stop("singularity in R but not in C")
    }
    zR$singular
}

##' Sophisticated version
tstSubsample <- function(x, y=rnorm(n), compareMatrix = TRUE,
                         lu.tol = 1e-7, lu.verbose=FALSE, tolInverse = lu.tol,
                         eq.tol = .Machine$double.eps^0.5)
{
    x0 <- x <- as.matrix(x)
    n <- nrow(x)
    p <- ncol(x)
    if(p <= 1) stop("wrong 'x': need at least two columns for these tests")
    stopifnot(length(y) == n)

    z <- Rsubsample(x, y, tolInverse=tolInverse)
    ##	 ----------
    ## convert idc, idr and p to 1-based indexing:
    idr <- z$idr      + 1L
    idc <- z$idc[1:p] + 1L
    pivot <- z$pivot  + 1L
    ## get L and U
    L <- U <- LU <- matrix(z$lu, p, p)
    L[upper.tri(L, diag=TRUE)] <- 0
    diag(L) <- 1
    U[lower.tri(U, diag=FALSE)] <- 0

    ## test solved parameter
    if (z$status == 0) {
	stopifnot(all.equal(z$beta, unname(solve(x[idc, ], y[idc])), tol=eq.tol))
    }

    if (z$rowequ) x <- diag(z$Dr) %*% x
    if (z$colequ) x <- x %*% diag(z$Dc)

    if (z$rowequ || z$colequ)
	cat(sprintf("kappa before equilibration = %g, after = %g\n",
		    kappa(x0), kappa(x)))


    LU. <- LU.gaxpy(t(x), tol=lu.tol, verbose=lu.verbose)
    ##	   --------
    if (!isTRUE(all.equal(LU.$p, pivot, tolerance=0))) {
	cat("LU.gaxpy() and Rsubsample() have different pivots:\n")
	print(LU.$p)
	print(pivot)
	cat("  ... are different at indices:\n ")
	print(which(LU.$p != pivot))
    } else {
        stopifnot(all.equal(LU.$L, L, tol=eq.tol),
                  all.equal(LU.$U, U, tol=eq.tol),
		  LU.$p == pivot,
                  ## only compare the indices selected before stopping
		  LU.$idc[seq_along(LU.$p)] == idc[seq_along(pivot)])
    }

    ## compare with Matrix result
    if (compareMatrix && z$status == 0) {
        xsub <- x[idc, ]
	stopifnot(require("Matrix"))
	tmp <- lu(t(xsub))
	## idx <- upper.tri(xsub, diag=TRUE)
	stopifnot(all.equal(tmp@x, as.vector(z$lu), tol=eq.tol))
    }

    invisible(z)
}
