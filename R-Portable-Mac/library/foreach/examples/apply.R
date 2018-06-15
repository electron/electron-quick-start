#  File src/library/base/R/apply.R
#  Part of the R package, http://www.R-project.org
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/

applyPar <- function(X, MARGIN, FUN, ...)
{
    FUN <- match.fun(FUN)

    ## Ensure that X is an array object
    d <- dim(X)
    dl <- length(d)
    if(dl == 0)
	stop("dim(X) must have a positive length")
    ds <- 1:dl
    if(length(oldClass(X)) > 0)
	X <- if(dl == 2) as.matrix(X) else as.array(X)
    ## now recompute things as coercion can change dims
    ## (e.g. when a data frame contains a matrix).
    d <- dim(X)
    dn <- dimnames(X)

    ## Extract the margins and associated dimnames

    s.call <- ds[-MARGIN]
    s.ans  <- ds[MARGIN]
    d.call <- d[-MARGIN]
    d.ans  <- d[MARGIN]
    dn.call<- dn[-MARGIN]
    dn.ans <- dn[MARGIN]
    ## dimnames(X) <- NULL

    ## do the calls

    d2 <- prod(d.ans)
    if(d2 == 0) {
        ## arrays with some 0 extents: return ``empty result'' trying
        ## to use proper mode and dimension:
        ## The following is still a bit `hackish': use non-empty X
        newX <- array(vector(typeof(X), 1), dim = c(prod(d.call), 1))
        ans <- FUN(if(length(d.call) < 2) newX[,1] else
                   array(newX[,1], d.call, dn.call), ...)
        return(if(is.null(ans)) ans else if(length(d.ans) < 2) ans[1][-1]
               else array(ans, d.ans, dn.ans))
    }
    ## else
    newX <- aperm(X, c(s.call, s.ans))
    dim(newX) <- c(prod(d.call), d2)
    #### ans <- vector("list", d2)
    nw <- getDoParWorkers()
    if(length(d.call) < 2) {# vector
        if (length(dn.call)) dimnames(newX) <- c(dn.call, list(NULL))
        #### for(i in 1:d2) {
        ####     tmp <- FUN(newX[,i], ...)
        ####     if(!is.null(tmp)) ans[[i]] <- tmp
        #### }
        ans <- foreach(x=iblkcol(newX, nw), .combine='c', .packages='foreach') %dopar% {
          foreach(i=1:ncol(x)) %do% FUN(x[,i], ...)
        }
    } else {
        #### for(i in 1:d2) {
        ####     tmp <- FUN(array(newX[,i], d.call, dn.call), ...)
        ####     if(!is.null(tmp)) ans[[i]] <- tmp
        #### }
        ans <- foreach(x=iblkcol(newX, nw), .combine='c', .packages='foreach') %dopar% {
          foreach(y=1:ncol(x)) %do% FUN(array(x[,i], d.call, dn.call), ...)
        }
    }

    ## answer dims and dimnames

    ans.list <- is.recursive(ans[[1]])
    l.ans <- length(ans[[1]])

    ans.names <- names(ans[[1]])
    if(!ans.list)
	ans.list <- any(unlist(lapply(ans, length)) != l.ans)
    if(!ans.list && length(ans.names)) {
        all.same <- sapply(ans, function(x) identical(names(x), ans.names))
        if (!all(all.same)) ans.names <- NULL
    }
    len.a <- if(ans.list) d2 else length(ans <- unlist(ans, recursive = FALSE))
    if(length(MARGIN) == 1 && len.a == d2) {
	names(ans) <- if(length(dn.ans[[1]])) dn.ans[[1]] # else NULL
	return(ans)
    }
    if(len.a == d2)
	return(array(ans, d.ans, dn.ans))
    if(len.a > 0 && len.a %% d2 == 0) {
        if(is.null(dn.ans)) dn.ans <- vector(mode="list", length(d.ans))
        dn.ans <- c(list(ans.names), dn.ans)
	return(array(ans, c(len.a %/% d2, d.ans),
                     if(!all(sapply(dn.ans, is.null))) dn.ans))
    }
    return(ans)
}

##############################################################################
#
# Something like this will be added to the iterators package.
# This creates an iterator over block columns of a matrix.
iblkcol <- function(a, chunks) {
  n <- ncol(a)
  i <- 1

  nextEl <- function() {
    if (chunks <= 0 || n <= 0) stop('StopIteration')
    m <- ceiling(n / chunks)
    r <- seq(i, length=m)
    i <<- i + m
    n <<- n - m
    chunks <<- chunks - 1
    a[,r, drop=FALSE]
  }

  obj <- list(nextElem=nextEl)
  class(obj) <- c('abstractiter', 'iter')
  obj
}

# Simple test program for applyPar
library(foreach)
x <- matrix(rnorm(16000000), 4000)
actual <- applyPar(x, 2, mean)
expected <- apply(x, 2, mean)

cat(sprintf('Result correct: %s\n', identical(actual, expected)))
