#  Copyright (C) 1997-2013 The R Core Team

## being a 'builtin' function is not the same as being in base
ls.base <- ls("package:base", all=TRUE)
base.is.f <- sapply(ls.base, function(x) is.function(get(x)))
cat("\nNumber of base objects:\t\t", length(ls.base),
    "\nNumber of functions in base:\t", sum(base.is.f),
    "\n\t starting with 'is.' :\t  ",
    sum(grepl("^is\\.", ls.base[base.is.f])), "\n", sep = "")
## 0.14  : 31
## 0.50  : 33
## 0.60  : 34
## 0.63  : 37
## 1.0.0 : 38
## 1.3.0 : 41
## 1.6.0 : 45
## 2.0.0 : 45

## Do we have a method (probably)?
is.method <- function(fname) {
    isFun <- function(name) (exists(name, mode="function") &&
                             is.na(match(name, c("is", "as"))))
    np <- length(sp <- strsplit(fname, split = "\\.")[[1]])
    if(np <= 1 )
        FALSE
    else
        (isFun(paste(sp[1:(np-1)], collapse = '.')) ||
         (np >= 3 &&
          isFun(paste(sp[1:(np-2)], collapse = '.'))))
}

is.ALL <- function(obj, func.names = ls(pos=length(search())),
		   not.using = c("is.single", "is.real", "is.loaded",
                     "is.empty.model", "is.R", "is.element", "is.unsorted"),
		   true.only = FALSE, debug = FALSE)
{
    ## Purpose: show many 'attributes' of  R object __obj__
    ## -------------------------------------------------------------------------
    ## Arguments: obj: any R object
    ## -------------------------------------------------------------------------
    ## Author: Martin Maechler, Date: 6 Dec 1996

    is.fn <- func.names[substring(func.names,1,3) == "is."]
    is.fn <- is.fn[substring(is.fn,1,7) != "is.na<-"]
    use.fn <- is.fn[ is.na(match(is.fn, not.using))
                    & ! sapply(is.fn, is.method) ]

    r <- if(true.only) character(0)
    else structure(vector("list", length= length(use.fn)), names= use.fn)
    for(f in use.fn) {
	if(any(f == c("is.na", "is.finite"))) {
	    if(!is.list(obj) && !is.vector(obj) && !is.array(obj)) {
		if(!true.only) r[[f]] <- NA
		next
	    }
	}
	if(any(f == c("is.nan", "is.finite", "is.infinite"))) {
	    if(!is.atomic(obj)) {
	    	if(!true.only) r[[f]] <- NA
	    	next
	    }
	}
	if(debug) cat(f,"")
	fn <- get(f)
	rr <- if(is.primitive(fn) || length(formals(fn))>0)  fn(obj) else fn()
	if(!is.logical(rr)) cat("f=",f," --- rr	 is NOT logical	 = ",rr,"\n")
	##if(1!=length(rr))   cat("f=",f," --- rr NOT of length 1; = ",rr,"\n")
	if(true.only && length(rr)==1 && !is.na(rr) && rr) r <- c(r, f)
	else if(!true.only) r[[f]] <- rr
    }
    if(debug)cat("\n")
    if(is.list(r)) structure(r, class = "isList") else r
}

print.isList <- function(x, ..., verbose = getOption("verbose"))
{
    ## Purpose:	 print METHOD  for `isList' objects
    ## ------------------------------------------------
    ## Author: Martin Maechler, Date: 12 Mar 1997
    if(is.list(x)) {
        if(verbose) cat("print.isList(): list case (length=",length(x),")\n")
	nm <- format(names(x))
	rr <- lapply(x, stats::symnum, na = "NA")
	for(i in seq_along(x)) cat(nm[i],":",rr[[i]],"\n", ...)
    } else NextMethod("print", ...)
}


is.ALL(NULL)
##fails: is.ALL(NULL, not.using = c("is.single", "is.loaded"))
is.ALL(NULL,   true.only = TRUE)
all.equal(NULL, pairlist())
## list() != NULL == pairlist() :
is.ALL(list(), true.only = TRUE)

(pl <- is.ALL(pairlist(1,    list(3,"A")), true.only = TRUE))
(ll <- is.ALL(    list(1,pairlist(3,"A")), true.only = TRUE))
all.equal(pl[pl != "is.pairlist"],
          ll[ll != "is.vector"])## TRUE

is.ALL(1:5)
is.ALL(array(1:24, 2:4))
is.ALL(1 + 3)
e13 <- expression(1 + 3)
is.ALL(e13)
is.ALL(substitute(expression(a + 3), list(a=1)), true.only = TRUE)
is.ALL(y ~ x) #--> NA	 for is.na & is.finite

is0 <- is.ALL(numeric(0))
is0.ok <- 1 == (lis0 <- sapply(is0, length))
is0[!is0.ok]
is0 <- unlist(is0)
is0
ispi <- unlist(is.ALL(pi))
all(ispi[is0.ok] == is0)

is.ALL(numeric(0), true=TRUE)
is.ALL(array(1,1:3), true=TRUE)
is.ALL(cbind(1:3), true=TRUE)

is.ALL(structure(1:7, names = paste("a",1:7,sep="")))
is.ALL(structure(1:7, names = paste("a",1:7,sep="")), true.only = TRUE)

x <- 1:20 ; y <- 5 + 6*x + rnorm(20)
lm.xy <- lm(y ~ x)
is.ALL(lm.xy)
is.ALL(structure(1:7, names = paste("a",1:7,sep="")))
is.ALL(structure(1:7, names = paste("a",1:7,sep="")), true.only = TRUE)
