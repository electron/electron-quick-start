## These two fail when length(x) == 0 {but are short and nice otherwise}
himed <- function(x) { n2 <- 1 + length(x) %/% 2; sort(x, partial = n2)[n2] }
lomed <- function(x) { n2 <- (1+ length(x))%/% 2; sort(x, partial = n2)[n2] }

## From package 'limma' : ~/R/BioCore/madman/Rpacks/limma/R/weightedmedian.R
weighted.median <- function (x, w, na.rm = FALSE, low = FALSE, high = FALSE)
{
    ##	Weighted median
    ##	Gordon Smyth
    ##	30 June 2005
    ##  improved by MMaechler: 'low' and 'high' as with 'mad()'; 21 Nov 2005

    if (missing(w))
        w <- rep.int(1, length(x))
    else {
        if(length(w) != length(x)) stop("'x' and 'w' must have the same length")
        if(any(is.na(w))) stop("NA weights not allowed")
        ## Note that sometimes the estimate would be well-defined even
        ## with some NA weights!
        if(any(w < 0)) stop("Negative weights not allowed")
        if(is.integer(w))
            w <- as.numeric(w)
    }
    if(any(nax <- is.na(x))) {
        if(na.rm) {
            w <- w[i <- !nax]
            x <- x[i]
        } else return(NA)
    }
    if(all(w == 0)) {
        warning("All weights are zero")
        return(NA)
    } ## otherwise,  have  sum(w) > 0
    if(is.unsorted(x)) {
        o <- order(x)
        x <- x[o]
        w <- w[o]
    }
    p <- cumsum(w)/sum(w)
    k <- sum(p < 0.5) + 1:1
    if(p[k] > 0.5 || low)
        x[k]
    else if(high) x[k+1] else (x[k] + x[k+1])/2
}

Qn0R  <- function(x) {
    ## `R only' naive version of Qn()  ==> slow and large memory for large n
    n <- length(x <- sort(x))
    if(n == 0) return(NA) else if(n == 1) return(0.)
    k <- choose(n %/% 2 + 1, 2)
    m <- outer(x,x,"-")# abs not needed because of sort()
    sort(m[lower.tri(m)], partial = k)[k]
}

Sn0R  <- function(x) {
    ## `R only' naive version of Sn()  ==> slow and large memory for large n
    if((n <- length(x)) == 0) return(NA) else if(n == 1) return(0.)
    lomed(apply(abs(outer(x,x,"-")), 2, himed))
}

## Tol = 2e-7 : higher than usual
is.all.equal <- function(x,y, tol = 2e-7, scale = 1) {
    ## scale = 1: ensures 'absolute error' in all cases
    ## scale = x: ensures `relative error' in all cases
    is.logical(r <- all.equal(x,y, tolerance = tol, scale = scale)) && r
}
