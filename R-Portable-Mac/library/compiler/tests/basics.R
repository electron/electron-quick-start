library(compiler)

options(keep.source=TRUE)

## very minimal
x <- 2
stopifnot(eval(compile(quote(x + 1))) == 3)

## simple code generation
checkCode <- function(expr, code, optimize = 2) {
    v <- compile(expr, options = list(optimize = optimize))
    d <- .Internal(disassemble(v))[[2]][-1]
    dd <- as.integer(eval(substitute(code), getNamespace("compiler")))
    identical(d, dd)
}
x <- 2
stopifnot(checkCode(quote(x + 1),
                    c(GETVAR.OP, 1L,
                      LDCONST.OP, 2L,
                      ADD.OP, 0L,
                      RETURN.OP)))
f <- function(x) x
checkCode(quote({f(1); f(2)}),
          c(GETFUN.OP, 1L,
            PUSHCONSTARG.OP, 3L,
            CALL.OP, 4L,
            POP.OP,
            GETFUN.OP, 1L,
            PUSHCONSTARG.OP, 6L,
            CALL.OP, 7L,
            RETURN.OP))


## names and ... args
f <- function(...) list(...)
stopifnot(identical(f(1, 2), cmpfun(f)(1, 2)))

f <- function(...) list(x = ...)
stopifnot(identical(f(1, 2), cmpfun(f)(1, 2)))


## substitute and argument constant folding
f <- function(x) substitute(x)
g <- function() f(1 + 2)
v1 <- g()
f <- cmpfun(f)
g <- cmpfun(g)
v2 <- g()
stopifnot(identical(v1, v2))


## simple loops
sr <- function(x) {
    n <- length(x)
    i <- 1
    s <- 0
    repeat {
        if (i > n) break
        s <- s + x[i]
        i <- i + 1
    }
    s
}
sw <- function(x) {
    n <- length(x)
    i <- 1
    s <- 0
    while (i <= n) {
        s <- s + x[i]
        i <- i + 1
    }
    s
}
sf <- function(x) {
    s <- 0
    for (y in x)
        s <- s + y
    s
}
src <- cmpfun(sr)
swc <- cmpfun(sw)
sfc <- cmpfun(sf)
x <- 1 : 5
stopifnot(src(x) == sr(x))
stopifnot(swc(x) == sw(x))
stopifnot(sfc(x) == sf(x))


## Check that the handlers have been associated with the correct package
h <- ls(compiler:::inlineHandlers, all = TRUE)
p <- sub("package:", "", sapply(h, find))
pp <- sapply(h, function(n) get(n, compiler:::inlineHandlers)$package)
stopifnot(identical(p, pp))


## Check assumption about simple .Internals
## These are .External calls now.
## stopifnot(all(sapply(compiler:::safeStatsInternals,
##                      function(f)
##                      compiler:::is.simpleInternal(get(f, "package:stats")))))

stopifnot(all(sapply(compiler:::safeBaseInternals,
                     function(f)
                     compiler:::is.simpleInternal(get(f, "package:base")))))
