
library(compiler)

##
## Tests for findHomeNS()
##

findHomeNS <- compiler:::findHomeNS

## return value for an undefinded variable should be NULL
stopifnot(is.null(findHomeNS("foo", getNamespace("stats"))))
stopifnot(is.null(findHomeNS("foo", parent.env(getNamespace("stats")))))
stopifnot(is.null(findHomeNS("foo", getNamespace("base"))))

## + is found in .BaseNamespaceEnv for stats or base
stopifnot(identical(findHomeNS("+", getNamespace("stats")),
                    .BaseNamespaceEnv))
stopifnot(identical(findHomeNS("+", parent.env(getNamespace("stats"))),
                    .BaseNamespaceEnv))
stopifnot(identical(findHomeNS("+", getNamespace("base")),
                    .BaseNamespaceEnv))

## dnorm is defined in stats
stopifnot(identical(findHomeNS("dnorm", getNamespace("stats")),
                    getNamespace("stats")))
stopifnot(identical(findHomeNS("dnorm", parent.env(getNamespace("stats"))),
                    getNamespace("stats")))
stopifnot(is.null(findHomeNS("dnorm", getNamespace("base"))))

## plot is available via the stats namespace since stats imports graphics
stopifnot(identical(findHomeNS("plot", getNamespace("stats")),
                    getNamespace("graphics")))
stopifnot(identical(findHomeNS("plot", parent.env(getNamespace("stats"))),
                    getNamespace("graphics")))
stopifnot(is.null(findHomeNS("plot", getNamespace("base"))))

## palette is one of a small set of selective imports from grDevices
stopifnot(identical(findHomeNS("palette", getNamespace("stats")),
                    getNamespace("grDevices")))
stopifnot(identical(findHomeNS("palette", parent.env(getNamespace("stats"))),
                    getNamespace("grDevices")))
stopifnot(is.null(findHomeNS("palette", getNamespace("base"))))


##
## Tests for getAssignedVar
##

getAssignedVar <- compiler:::getAssignedVar
stopifnot(identical(getAssignedVar(quote("v"<-x)), "v"))
stopifnot(identical(getAssignedVar(quote(v<-x)), "v"))
stopifnot(identical(getAssignedVar(quote(f(v)<-x)), "v"))
stopifnot(identical(getAssignedVar(quote(f(g(v,2),1)<-x)), "v"))


##
## Tests for findLocals
##

findLocals <- compiler:::findLocals
cenv <- compiler:::makeCenv(.GlobalEnv)
cntxt <- compiler:::make.toplevelContext(cenv, NULL)

stopifnot(identical(findLocals(quote(x<-1), cntxt), "x"))
stopifnot(identical(findLocals(quote(f(x)<-1), cntxt), "x"))
stopifnot(identical(findLocals(quote(f(g(x,2),1)<-1), cntxt), "x"))
stopifnot(identical(findLocals(quote(x<-y<-1), cntxt), c("x","y")))
stopifnot(identical(findLocals(quote(local(x<-1,e)), cntxt), "x"))
stopifnot(identical(findLocals(quote(local(x<-1)), cntxt), character(0)))
stopifnot(identical(findLocals(quote({local<-1;local(x<-1)}), cntxt),
                    c("local", "x")))

local({
    f <- function (f, x, y) {
        local <- f
        local(x <- y)
        x
    }
    stopifnot(identical(findLocals(body(f), cntxt), c("local","x")))
})

local({
    cenv <- compiler:::addCenvVars(cenv, "local")
    cntxt <- compiler:::make.toplevelContext(cenv, NULL)
    stopifnot(identical(findLocals(quote(local(x<-1,e)), cntxt), "x"))
})

stopifnot(identical(findLocals(quote(assign(x, 3)), cntxt), character(0)))
stopifnot(identical(findLocals(quote(assign("x", 3)), cntxt), "x"))
stopifnot(identical(findLocals(quote(assign("x", 3, 4)), cntxt), character(0)))
