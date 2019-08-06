#### Tools for Package Testing  --- in Matrix, sourced by ./test-tools.R
#### -------------------------
## to be used as, e.g.,
## source(system.file("test-tools-1.R", package="Matrix"), keep.source=FALSE)

### ------- Part I --  unrelated to "Matrix" classes ---------------

if(!exists("paste0", .BaseNamespaceEnv)) # have in R >= 2.15.0
    paste0 <- function(...) paste(..., sep = '')

identical3 <- function(x,y,z)	  identical(x,y) && identical (y,z)
identical4 <- function(a,b,c,d)   identical(a,b) && identical3(b,c,d)
identical5 <- function(a,b,c,d,e) identical(a,b) && identical4(b,c,d,e)
identical6 <- function(a,b,c,d,e,f)  identical(a,b) && identical5(b,c,d,e,f)
identical7 <- function(a,b,c,d,e,f,g)identical(a,b) && identical6(b,c,d,e,f,g)

if( exists("assertCondition", asNamespace("tools")) ) { ## R > 3.0.1

if(FALSE) {
assertError <- function(expr, verbose=getOption("verbose"))
    tools::assertCondition(expr, "error", verbose=verbose)
assertWarning <- function(expr, verbose=getOption("verbose"))
    tools::assertCondition(expr, "warning", verbose=verbose)
assertWarningAtLeast <- function(expr, verbose=getOption("verbose"))
    tools::assertCondition(expr, "error", "warning", verbose=verbose)
} else {
    require(tools)#-> assertError() and assertWarning()
    assertWarningAtLeast <- function(expr, verbose=getOption("verbose"))
        tools::assertCondition(expr, "error", "warning", verbose=verbose)
}

} else { ## in R <= 3.0.1 :

##' @title Ensure evaluating 'expr' signals an error
##' @param expr
##' @return the caught error, invisibly
##' @author Martin Maechler
assertError <- function(expr, verbose=getOption("verbose")) {
    d.expr <- deparse(substitute(expr))
    t.res <- tryCatch(expr, error = function(e) e)
    if(!inherits(t.res, "error"))
	stop(d.expr, "\n\t did not give an error", call. = FALSE)
    if(verbose) cat("Asserted Error:", conditionMessage(t.res),"\n")
    invisible(t.res)
}

## Note that our previous version of assertWarning() did *not* work correctly:
##     x <- 1:3; assertWarning({warning("bla:",x[1]); x[2] <- 99}); x
## had 'x' not changed!


## From ~/R/D/r-devel/R/src/library/tools/R/assertCondition.R :
assertCondition <- function(expr, ...,
                            .exprString = .deparseTrim(substitute(expr), cutoff = 30L),
                            verbose = FALSE) {
    fe <- function(e)e
    getConds <- function(expr) {
	conds <- list()
	tryCatch(withCallingHandlers(expr,
				     warning = function(w) {
					 conds <<- c(conds, list(w))
					 invokeRestart("muffleWarning")
				     },
				     condition = function(cond)
					 conds <<- c(conds, list(cond))),
		 error = function(e)
		     conds <<- c(conds, list(e)))
	conds
    }
    conds <- if(nargs() > 1) c(...) # else NULL
    .Wanted <- if(nargs() > 1) paste(c(...), collapse = " or ") else "any condition"
    res <- getConds(expr)
    if(length(res)) {
	if(is.null(conds)) {
            if(verbose)
                message("assertConditon: Successfully caught a condition\n")
	    invisible(res)
        }
	else {
	    ii <- sapply(res, function(cond) any(class(cond) %in% conds))
	    if(any(ii)) {
                if(verbose) {
                    found <-
                        unique(sapply(res, function(cond) class(cond)[class(cond) %in% conds]))
                    message(sprintf("assertCondition: caught %s",
                                    paste(dQuote(found), collapse =", ")))
                }
		invisible(res)
            }
	    else {
                .got <- paste(unique((sapply(res, function(obj)class(obj)[[1]]))),
                                     collapse = ", ")
		stop(gettextf("Got %s in evaluating %s; wanted %s",
			      .got, .exprString, .Wanted))
            }
	}
    }
    else
	stop(gettextf("Failed to get %s in evaluating %s",
		      .Wanted, .exprString))
}

assertWarning <- function(expr, verbose=getOption("verbose"))
    assertCondition(expr, "warning", verbose=verbose)
assertWarningAtLeast <- function(expr, verbose=getOption("verbose"))
    assertCondition(expr, "error", "warning", verbose=verbose)

}# [else: no assertCondition ]

##' [ from R's  demo(error.catching) ]
##' We want to catch *and* save both errors and warnings, and in the case of
##' a warning, also keep the computed result.
##'
##' @title tryCatch both warnings and errors
##' @param expr
##' @return a list with 'value' and 'warning', where
##'   'value' may be an error caught.
##' @author Martin Maechler
tryCatch.W.E <- function(expr)
{
    W <- NULL
    w.handler <- function(w){ # warning handler
	W <<- w
	invokeRestart("muffleWarning")
    }
    list(value = withCallingHandlers(tryCatch(expr, error = function(e) e),
				     warning = w.handler),
	 warning = W)
}


##' Is 'x' a valid object of class 'class' ?
isValid <- function(x, class) isTRUE(validObject(x, test=TRUE)) && is(x, class)

##' Signal an error (\code{\link{stop}}), if \code{x} is not a valid object
##' of class \code{class}.
##'
##' @title Stop if Not a Valid Object of Given Class
##' @param x any \R object
##' @param class character string specifying a class name
##' @return \emph{invisibly}, the value of \code{\link{validObject}(x)}, i.e.,
##'   \code{TRUE}; otherwise an error will have been signalled
##' @author Martin Maechler, March 2015
stopifnotValid <- function(x, class) {
    if(!is(x, class))
	stop(sprintf("%s is not of class \"%s\"",
		     deparse(substitute(x)), class), call. = FALSE)
    invisible(validObject(x))
}

## Some (sparse) Lin.Alg. algorithms return 0 instead of NA, e.g.
## qr.coef(<sparseQR>, y).
## For those cases, need to compare with a version where NA's are replaced by 0
mkNA.0 <- function(x) { x[is.na(x)] <- 0 ; x }

##' ... : further arguments passed to all.equal() such as 'check.attributes'
is.all.equal <- function(x,y, tol = .Machine$double.eps^0.5, ...)
    identical(TRUE, all.equal(x,y, tolerance=tol, ...))
is.all.equal3 <- function(x,y,z, tol = .Machine$double.eps^0.5, ...)
    is.all.equal(x,y, tol=tol, ...) && is.all.equal(y,z, tol=tol, ...)

is.all.equal4 <- function(x,y,z,u, tol = .Machine$double.eps^0.5, ...)
    is.all.equal3(x,y,z, tol=tol, ...) && isTRUE(all.equal(z,u, tolerance=tol, ...))

## A version of all.equal() for the slots
all.slot.equal <- function(x,y, ...) {
    slts <- slotNames(x)
    for(sl in slts) {
        aeq <- all.equal(slot(x,sl), slot(y,sl), ...)
        if(!identical(TRUE, aeq))
            return(paste("slot '",sl,"': ", aeq, sep=''))
    }
    TRUE
}

## all.equal() for list-coercible objects -- apart from *some* components
all.equal.X <- function(x,y, except, tol = .Machine$double.eps^0.5, ...)
{
    .trunc <- function(x) {
	ll <- as.list(x)
	ll[ - match(except, names(ll), nomatch = 0L)]
    }
    all.equal(.trunc(x), .trunc(y), tolerance = tol, ...)
}
## e.g. in lme4:
##  all.equal.X(env(m1), env(m2), except = c("call", "frame"))

## The relative error typically returned by all.equal:
relErr <- function(target, current) { ## make this work for 'Matrix'
    ## ==> no mean() ..
    n <- length(current)
    if(length(target) < n)
        target <- rep(target, length.out = n)
    sum(abs(target - current)) / sum(abs(target))
}

##' Compute the signed relative error between target and current vector -- vectorized
##' @title Relative Error (:= 0 when absolute error == 0)
##' @param target  numeric, possibly scalar
##' @param current numeric of length() a multiple of length(target)
##' @return *vector* of the same length as current
##' @author Martin Maechler
relErrV <- function(target, current) {
    n <- length(target <- as.vector(target))
    ## assert( <length current> is multiple of <length target>) :
    if(length(current) %% n)
	stop("length(current) must be a multiple of length(target)")
    RE <- current
    RE[] <- 0
    fr <- current/target
    neq <- is.na(current) | (current != target)
    RE[neq] <- 1 - fr[neq]
    RE
}

##' @title Number of correct digits: Based on relErrV(), recoding "Inf" to 'zeroDigs'
##' @param target  numeric vector of "true" values
##' @param current numeric vector of "approximate" values
##' @param zeroDigs how many correct digits should zero error give
##' @return basically   -log10 (| relErrV(target, current) | )
##' @author Martin Maechler, Summer 2011 (for 'copula')
nCorrDigits <- function(target, current, zeroDigs = 16) {
    stopifnot(zeroDigs >= -log10(.Machine$double.eps))# = 15.65
    RE <- relErrV(target, current)
    r <- -log10(abs(RE))
    r[RE == 0] <- zeroDigs
    r[is.na(RE) | r < 0] <- 0 # no correct digit, when relErr is NA
    r
}


## is.R22 <- (paste(R.version$major, R.version$minor, sep=".") >= "2.2")

pkgRversion <- function(pkgname)
    sub("^R ([0-9.]+).*", "\\1", packageDescription(pkgname)[["Built"]])

showSys.time <- function(expr, ...) {
    ## prepend 'Time' for R CMD Rdiff
    st <- system.time(expr, ...)
    writeLines(paste("Time", capture.output(print(st))))
    invisible(st)
}
showProc.time <- local({ ## function + 'pct' variable
    pct <- proc.time()
    function(final="\n") { ## CPU elapsed __since last called__
	ot <- pct ; pct <<- proc.time()
	## 'Time ..' *not* to be translated:  tools::Rdiff() skips its lines!
	cat('Time elapsed: ', (pct - ot)[1:3], final)
    }
})

##' A version of sfsmisc::Sys.memGB() which should never give an error
##'  ( ~/R/Pkgs/sfsmisc/R/unix/Sys.ps.R  )
##' TODO: A version that also works on Windows, using memory.size(max=TRUE)
##' Windows help on memory.limit(): size in Mb (1048576 bytes), rounded down.

Sys.memGB <- function(kind = "MemTotal") {## "MemFree" is typically more relevant
    if(!file.exists(pf <- "/proc/meminfo"))
	return(if(.Platform$OS.type == "windows")
		   memory.limit() / 1000
	       else NA)
    mm <- tryCatch(drop(read.dcf(pf, fields=kind)),
                   error = function(e) NULL)
    if(is.null(mm) || any(is.na(mm)) || !all(grepl(" kB$", mm)))
        return(NA)
    ## return memory in giga bytes
    as.numeric(sub(" kB$", "", mm)) / (1000 * 1024)
}



##' @title turn an S4 object (with slots) into a list with corresponding components
##' @param obj an R object with a formal class (aka "S4")
##' @return a list with named components where \code{obj} had slots
##' @author Martin Maechler
S4_2list <- function(obj) {
   sn <- slotNames(obj)
   structure(lapply(sn, slot, object = obj), .Names = sn)
}

assert.EQ <- function(target, current, tol = if(showOnly) 0 else 1e-15,
                      giveRE = FALSE, showOnly = FALSE, ...) {
    ## Purpose: check equality *and* show non-equality
    ## ----------------------------------------------------------------------
    ## showOnly: if TRUE, return (and hence typically print) all.equal(...)
    T <- isTRUE(ae <- all.equal(target, current, tolerance = tol, ...))
    if(showOnly) return(ae) else if(giveRE && T) { ## don't show if stop() later:
	ae0 <- if(tol == 0) ae else all.equal(target, current, tolerance = 0, ...)
	if(!isTRUE(ae0)) writeLines(ae0)
    }
    if(!T) stop("all.equal() |-> ", paste(ae, collapse=sprintf("%-19s","\n")))
    else if(giveRE) invisible(ae0)
}

##' a version with other "useful" defaults (tol, giveRE, check.attr..)
assert.EQ. <- function(target, current,
		       tol = if(showOnly) 0 else .Machine$double.eps^0.5,
		       giveRE = TRUE, showOnly = FALSE, ...) {
    assert.EQ(target, current, tol=tol, giveRE=giveRE, showOnly=showOnly,
	      check.attributes=FALSE, ...)
}

### ------- Part II  -- related to matrices, but *not* "Matrix" -----------

add.simpleDimnames <- function(m, named=FALSE) {
    stopifnot(length(d <- dim(m)) == 2)
    dimnames(m) <- setNames(list(if(d[1]) paste0("r", seq_len(d[1])),
				 if(d[2]) paste0("c", seq_len(d[2]))),
			    if(named) c("Row", "Col"))
    m
}

as.mat <- function(m) {
    ## as(., "matrix")	but with no extraneous empty dimnames
    d0 <- dim(m)
    m <- as(m, "matrix")
    if(!length(m) && is.null(d0)) dim(m) <- c(0L, 0L) # rather than (0, 1)
    if(identical(dimnames(m), list(NULL,NULL)))
	dimnames(m) <- NULL
    m
}

assert.EQ.mat <- function(M, m, tol = if(showOnly) 0 else 1e-15,
                          showOnly=FALSE, giveRE = FALSE, ...) {
    ## Purpose: check equality of  'Matrix' M with  'matrix' m
    ## ----------------------------------------------------------------------
    ## Arguments: M: is(., "Matrix") typically {but just needs working as(., "matrix")}
    ##            m: is(., "matrix")
    ##            showOnly: if TRUE, return (and hence typically print) all.equal(...)
    validObject(M)
    MM <- as.mat(M)                     # as(M, "matrix")
    if(is.logical(MM) && is.numeric(m))
	storage.mode(MM) <- "integer"
    attr(MM, "dimnames") <- attr(m, "dimnames") <- NULL
    assert.EQ(MM, m, tol=tol, showOnly=showOnly, giveRE=giveRE)
}
## a short cut
assert.EQ.Mat <- function(M, M2, tol = if(showOnly) 0 else 1e-15,
                          showOnly=FALSE, giveRE = FALSE, ...)
    assert.EQ.mat(M, as.mat(M2), tol=tol, showOnly=showOnly, giveRE=giveRE)


chk.matrix <- function(M) {
    ## check object; including coercion to "matrix" :
    cl <- class(M)
    cat("class ", dQuote(cl), " [",nrow(M)," x ",ncol(M),"]; slots (",
	paste(slotNames(M), collapse=","), ")\n", sep='')
    stopifnot(validObject(M),
	      dim(M) == c(nrow(M), ncol(M)),
	      identical(dim(m <- as(M, "matrix")), dim(M))
	      )
}

isOrthogonal <- function(x, tol = 1e-15) {
    all.equal(diag(as(zapsmall(crossprod(x)), "diagonalMatrix")),
              rep(1, ncol(x)), tolerance = tol)
}

.M.DN <- Matrix:::.M.DN ## from ../R/Auxiliaries.R :
dnIdentical  <- function(x,y) identical(.M.DN(x), .M.DN(y))
dnIdentical3 <- function(x,y,z) identical3(.M.DN(x), .M.DN(y), .M.DN(z))

##' @title Are two matrices practically equal - including dimnames
##' @param M1, M2: two matrices to be compared, maybe of _differing_ class
##' @param tol
##' @param dimnames logical indicating if dimnames must be equal
##' @param ... passed to all.equal(M1, M2)
##' @return TRUE or FALSE
is.EQ.mat <- function(M1, M2, tol = 1e-15, dimnames = TRUE, ...) {
    (if(dimnames) dnIdentical(M1,M2) else TRUE) &&
    is.all.equal(unname(as(M1, "matrix")),
		 unname(as(M2, "matrix")), tol=tol, ...)
}

##' see is.EQ.mat()
is.EQ.mat3 <- function(M1, M2, M3, tol = 1e-15, dimnames = TRUE, ...) {
    (if(dimnames) dnIdentical3(M1,M2,M3) else TRUE) &&
    is.all.equal3(unname(as(M1, "matrix")),
		  unname(as(M2, "matrix")),
		  unname(as(M3, "matrix")), tol=tol, ...)
}
