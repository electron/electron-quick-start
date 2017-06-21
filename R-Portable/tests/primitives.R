## check that the 'internal generics' are indeed generic.

x <- structure(pi, class="testit")
xx <- structure("OK", class="testOK")

for(f in ls(.GenericArgsEnv, all.names=TRUE))
{
    cat("testing S3 generic '", f, "'\n", sep="")
    method <- paste(f, "testit", sep=".")
    if(f %in% "seq.int") {
        ## note that this dispatches on 'seq'.
        assign("seq.testit", function(...) xx, .GlobalEnv)
        res <- seq.int(x, x)
    } else {
        if(length(grep("<-$", f)) > 0) {
            assign(method, function(x, value) xx, .GlobalEnv)
            y <- x
            res <- eval(substitute(ff(y, value=pi), list(ff=as.name(f))))
        } else {
            ff <- get(f, .GenericArgsEnv)
            body(ff) <- xx
            assign(method, ff, .GlobalEnv)
            res <- eval(substitute(ff(x), list(ff=as.name(f))))
        }
    }
    stopifnot(res == xx)
    rm(method)
}

## and that no others are generic
for(f in ls(.ArgsEnv, all.names=TRUE))
{
    if(f == "browser") next
    cat("testing non-generic '", f, "'\n", sep="")
    method <- paste(f, "testit", sep=".")
    fx <- get(f, envir=.ArgsEnv)
    body(fx) <- quote(return(42))
    assign(method, fx, .GlobalEnv)
    na <- length(formals(fx))
    res <- NULL
    if(na == 1)
        res <- try(eval(substitute(ff(x), list(ff=as.name(f)))), silent = TRUE)
    else if(na == 2)
        res <- try(eval(substitute(ff(x, x), list(ff=as.name(f)))), silent = TRUE)
    if(!inherits(res, "try-error") && identical(res, 42)) stop("is generic")
    rm(method)
}


## check that all primitives are accounted for in .[Generic]ArgsEnv,
## apart from the language elements:
ff <- as.list(baseenv(), all.names=TRUE)
ff <- names(ff)[vapply(ff, is.primitive, logical(1L))]

known <- c(names(.GenericArgsEnv), names(.ArgsEnv), tools::langElts)
stopifnot(ff %in% known, known %in% ff)


## check which are not considered as possibles for S4 generic
ff4 <- names(meth.FList <- methods:::.BasicFunsList)
# as.double is the same as as.numeric
S4generic <- ff %in% c(ff4, "as.double")
notS4 <- ff[!S4generic]
if(length(notS4))
    cat("primitives not covered in methods:::.BasicFunsList:",
        paste(sQuote(notS4), collapse=", "), "\n")
stopifnot(S4generic)

# functions which are listed but not primitive
extraS4 <- c('unlist', 'as.vector')
ff4[!ff4 %in% c(ff, extraS4)]
stopifnot(ff4 %in% c(ff, extraS4))


## primitives which are not internally generic cannot have S4 methods
## unless specifically arranged (e.g. %*%)
nongen_prims <- ff[!ff %in% ls(.GenericArgsEnv, all.names=TRUE)]
ff3 <- ff4[vapply(meth.FList, function(x) is.logical(x) && !x, NA, USE.NAMES=FALSE)]
ex <- nongen_prims[!nongen_prims %in% c("$", "$<-", "[", "[[" ,"[[<-", "[<-", "%*%", ff3)]
if(length(ex))
    cat("non-generic primitives not excluded in methods:::.BasicFunsList:",
        paste(sQuote(ex), collapse=", "), "\n")
stopifnot(length(ex) == 0)

## Now check that (most of) those which are listed really are generic.
require(methods)
setClass("foo", representation(x="numeric", y="numeric"))
xx <- new("foo",  x=1, y=2)
S4gen <- ff4[vapply(meth.FList, is.function, NA, USE.NAMES=FALSE)]
for(f in S4gen) {
    g <- get(f)
    if(!is(g, "genericFunction")) g <- getGeneric(f) # error on non-Generics.
    ff <- args(g)
    body(ff) <- "testit"
    nm <- names(formals(ff))
    ## the Summary group gives problems
    if(nm[1] == '...') {
        cat("skipping '", f, "'\n", sep="")
        next
    }
    cat("testing '", f, "'\n", sep="")
    setMethod(f, "foo", ff)
    ## might have created a generic, so redo 'get'
    stopifnot(identical(getGeneric(f)(xx), "testit"))
}

## check that they do argument matching, or at least check names
except <- c("call", "switch", ".C", ".Fortran", ".Call", ".External",
            ".External2", ".Call.graphics", ".External.graphics",
            ".subset", ".subset2", ".primTrace", ".primUntrace",
            "lazyLoadDBfetch", ".Internal", ".Primitive", "^", "|",
            "%*%", "rep", "seq.int", "forceAndCall",
            ## these may not be enabled
            "tracemem", "retracemem", "untracemem")

for(f in ls(.GenericArgsEnv, all.names=TRUE)[-(1:15)])
{
    if (f %in% except) next
    g <- get(f, envir = .GenericArgsEnv)
    an <- names(formals(args(g)))
    if(length(an) > 0 && an[1] == "...") next
    an <- an[an != "..."]
    a <- rep(list(NULL), length(an))
    names(a) <- c("zZ", an[-1])
    res <- try(do.call(f, a), silent = TRUE)
    m <- geterrmessage()
    if(!grepl('does not match|unused argument', m))
        stop("failure on ", f)
}

for(f in ls(.ArgsEnv, all.names=TRUE))
{
    if (f %in% except) next
    g <- get(f, envir = .ArgsEnv)
    an <- names(formals(args(g)))
    if(length(an) > 0 && an[1] == "...") next
    an <- an[an != "..."]
    if(length(an)) {
        a <- rep(list(NULL), length(an))
        names(a) <- c("zZ", an[-1])
    } else a <- list(zZ=NULL)
    res <- try(do.call(f, a), silent = TRUE)
    m <- geterrmessage()
    if(!grepl('does not match|unused argument|requires 0|native symbol', m))
        stop("failure on ", f)
}
