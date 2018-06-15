library(compiler)

# set to TRUE for debugging
only.print <- FALSE

testError <- function(expr, handler) {
    err <- tryCatch(expr, error = handler)
    stopifnot(identical(err, TRUE))
}

testWarning <- function(expr, handler) {
    warn <- tryCatch(expr, warning = handler)
    stopifnot(identical(warn, TRUE))
}

w <- function(expr, call = substitute(expr)) {
    if (only.print)
       testWarning(expr = expr, handler = function(e) {
           cat("WARNING-MESSAGE: \"", e$message, "\"\nWARNING-CALL: ", deparse(e$call), "\n", sep="")
           TRUE
       })
    else
       testWarning(expr = expr, handler = function(e) {
           stopifnot(identical(e$call, call))
           TRUE
       })
}

e <- function(expr, call = substitute(expr)) {
    if (only.print)
       testError(expr = expr, handler = function(e) {
           cat("ERROR-MESSAGE: \"", e$message, "\"\nERROR-CALL: ", deparse(e$call), "\n", sep="")
           TRUE
       })
    else
       testError(expr = expr, handler = function(e) {
           stopifnot(identical(e$call, call))
           TRUE
       })
}

f <- function(x = 1:2,
        y = -1,
        z = c(a=1, b=2, c=2, d=3),
        u = list(inner = c(a=1,b=2,c=3,d=4)),
        v = list(),
        ...) {


    w(x[1:3] <- 11:12)
        # quote(`[<-`(x, 1:3, value = 11:12))
    w(min(...))
    w(sqrt(y))

    e(names(z[1:2]) <- c("X", "Y", "Z"))
        # quote(`names<-`(z[1:2], value = c("X", "Y", "Z"))
    e(names(z[c(-1,1)]) <- c("X", "Y", "Z"),
        # quote(z[c(-1, 1)])) <=== this would be nice, but not possible at the moment
        quote(`*tmp*`[c(-1, 1)]))
    w(names(u$inner)[2:4] <- v[1:2] <- c("X", "Y", "Z", "U")[1:2])
        # quote(`[<-`(names(u$inner), 2:4, value = v[1:2] <- c("X", "Y", "Z", "U")[1:2]))

    ##_ Not anymore, as stopifnot() massages its error/warning message:
    ##_ e(stopifnot(is.numeric(dummy)))
}

old=options()

oldoptimize <- getCompilerOption("optimize")
oldjit <- enableJIT(3)

for (opt in 2:3) {
    setCompilerOptions(optimize=opt)
    f()
}

## test that AST and compiler errors/warnings agree

enableJIT(0)
testexpr <- function(fun) {
  resast <- tryCatch(fun(), error = function(e) e, warning = function(e) e)
  cfun <- cmpfun(fun)
  rescmp <- tryCatch(cfun(), error = function(e) e, warning = function(e) e)

  show(resast)
  show(rescmp)

  stopifnot(identical(resast, rescmp))
}

testexpr(function() { dummy()$e })
testexpr(function() { beta(-1, NULL) })
testexpr(function() { inherits(1, log) })

enableJIT(oldjit)
setCompilerOptions(optimize = oldoptimize)
