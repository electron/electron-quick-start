library(robustbase)

source(system.file("xtraR/test_MCD.R", package = "robustbase"))#-> doMCDdata()

##' This version of domcd() runs *both* "Fast" and "deterministic" MCD
##' @title covMcd() "workhorse" function -- *passed* to and from  doMCDdata()
##' @param x data set: n x p numeric matrix
##' @param xname "promise" which will be substituted() and printed
##' @param nrep number of repetition: only sensible for *timing*
##' @param time
##' @param short
##' @param full
##' @param lname optional:
##' @param seed  optional:
##' @param trace optional:
domcd.2 <- function(x, xname, nrep=1,
                    do.exact = NULL, # <- smart default, globally customizable
                    time   = get("time",   parent.frame()), # compromise
                    short  = get("short",  parent.frame()), # compromise
                    full   = get("full",   parent.frame()), # compromise
                    lname=20, seed=123, trace=FALSE)
{
    if(short && full)
	stop("you should not set both 'full' and 'short' to TRUE")
    force(xname)# => evaluate when it is a data(<>, ..) call
    n <- dim(x)[1]
    p <- dim(x)[2]
    metha <- "FastMCD"
    methb <- "detMCD"
    if(is.null(do.exact)) {
        nLarge <- if(exists("nLarge", mode="numeric"))
                      get("nLarge", mode="numeric") else 5000
        do.exact <- choose(n, p+1L) < nLarge
    }
    set.seed(seed); mcda <- covMcd(x, trace=trace)
    set.seed(seed); mcdb <- covMcd(x, nsamp="deterministic", trace=trace)
    if(do.exact) {
	methX <- "exactMCD"
        set.seed(seed); mcdX <- covMcd(x, nsamp="exact", trace=trace)
    }
    mkRes <- function(mcd)
	sprintf("%3d %3d %3d %12.6f\n", n,p, mcd$quan, mcd$crit)
    xresa <- mkRes(mcda)
    xresb <- mkRes(mcdb)
    if(do.exact) xresX <- mkRes(mcdX)
    if(time) {
        tim1 <- function(meth)
            sprintf("%10.3f\n", system.time(repMCD(x, nrep, meth))[1]/nrep)
        xresa <- paste(xresa, tim1(metha))
        xresb <- paste(xresb, tim1(methb))
        if(do.exact) xresX <- paste(xresX, tim1(methX))
    }
    if(full) {
	header <- get("header", parent.frame())
	header(time)
    }
    ## lname: must fit to header():
    x.meth <- paste(xname, format(c(metha, methb, if(do.exact) methX)))
    cat(sprintf("%*s", lname, x.meth[1]), xresa)
    cat(sprintf("%*s", lname, x.meth[2]), xresb)
    if(do.exact) cat(sprintf("%*s", lname, x.meth[3]), xresX)
    cat("Best subsamples: \n")
    cat(sprintf(" %10s: ", metha)); print(mcda$best)
    if(identical(mcdb$best, mcda$best))
	cat(sprintf(" %s is the same as %s\n", methb, metha))
    else {
	cat(sprintf(" %10s: ", methb)); print(mcdb$best)
	cat(sprintf(" Difference  %s - %s:", methb, metha))
	print(setdiff(mcdb$best, mcda$best))
    }
    if(do.exact) {
	if(identical(mcda$best, mcdX$best))
	    cat(sprintf(" %s is the same as %s\n", methX, metha))
	else if(identical(mcdb$best, mcdX$best))
	    cat(sprintf(" %s is the same as %s\n", methX, methb))
	else {
	    cat(sprintf(" %10s: ", methX)); print(mcdX$best)
        }
    }
    if(!short) {
        cat("Details about", metha,": ")
        ibad <- which(mcda$wt==0)
        names(ibad) <- NULL
        nbad <- length(ibad)
        cat("Outliers: ",nbad,"\n")
        if(nbad > 0)
            print(ibad)
        if(full){
            cat("-------------\n")
            print(mcda)
        }
        cat("--------------------------------------------------------\n")
    }
}

doMCDdata(domcd = domcd.2)
warnings() ## in one example  n < 2 * p ..

###' Test the exact fit property of CovMcd --------------------------------

##' generate "exact fit" data
d.exact <- function(seed=seed, p=2) {
    stopifnot(p >= 1)
    set.seed(seed)
    n1 <- 45
    x1 <- matrix(rnorm(p*n1), nrow=n1, ncol=p)
    x1[,p] <- x1[,p] + 3
    n2 <- 55
    m2 <- 3
    x <- rbind(x1, cbind(matrix(rnorm((p-1)*n2), n2, p-1), rep(m2,n2)))
    colnames(x) <- paste0("X", 1:p)
    x
}

plot(d.exact(18, p=2))
pairs(d.exact(1234, p=3), gap=0.1)

for(p in c(2,4))
for(sid in c(2, 4, 18, 1234)) {
    cat("\nseed = ",sid,"; p = ",p,":\n")
    d.x <- d.exact(sid, p=p)
    d2 <- covMcd(d.x)
    ## Gave error {for p=2, seeds 2, 4, 18 also on 64-bit}:
    ## At line 729 of file rffastmcd.f
    ## Fortran runtime error: Index '6' of dimension 1 of array 'z' above upper bound of 4
    print(d2)
    if(FALSE) ## FIXME fails when calling eigen() in "r6pack()"
        d2. <- covMcd(d.x, nsamp = "deterministic", scalefn = Qn)
    stopifnot(d2$singularity$kind == "on.hyperplane")
}


## TODO: also get examples of other singularity$kind's

