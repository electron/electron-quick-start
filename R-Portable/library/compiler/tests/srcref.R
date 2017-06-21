library(compiler)

# This tests tracking of source file references

options(keep.source=TRUE)
ln <- function() attr(sys.call(), "srcref")[1]

# NOTE: the block below is sensitive to formatting (newlines)

code <- quote({
    start <- ln()
    plus1 <- ln()                          # start + 1
    stopifnot(identical(plus1, start+1L))
    {
        plus4 <- ln()                         # start + 4
    }
    stopifnot(identical(plus4, start+4L))
    plus9 <- 0
    f <- function() {
        plus9 <<- ln()                       # start + 9
    }
    f()
    stopifnot(identical(plus9, start+9L))
    g <- function(x = ln()) x              # start + 13
    plus13 <- g()
    stopifnot(identical(plus13, start+13L))
    plus16 <- g(ln())                      # start + 16
    stopifnot(identical(plus16, start+13L) || identical(plus16, start+16L)) ### NOTE: see compatibility note below
    for(i in 1) plus18 <- ln()             # start + 18
    stopifnot(identical(plus18, start+18L))
    for(i in 1) { plus20 <- ln() }         # start + 20
    stopifnot(identical(plus20, start+20L))
    for(i in 1) {
        plus23 <- ln()                       # start + 23
    }
    stopifnot(identical(plus23, start+23L))
    ff <- function() for(i in 1) return(ln()) # start + 26
    plus26 <- ff()
    stopifnot(identical(plus26, start+26L))
    ff1 <- function() {
        for(i in 1) return(ln())             # start + 30
    }
    plus30 <- ff1()
    stopifnot(identical(plus30, start+30L))
})

## Compatibility note
##
## in the example above, "plus16" with the AST interpreter gets line number
## start+13, but with the compiler, it gets start+16.  The latter seems to
## be more correct, as line start+16 is where the spelling of "ln()" is.

oldoptimize <- getCompilerOption("optimize")
oldjit <- enableJIT(0)

l <- function() 1
body(l) <- code

for(jit in 0:2) {
    enableJIT(jit)
    for (opt in 0:3) {
        if (opt >=2 || jit <=2) {
            setCompilerOptions(optimize=opt)
            eval(code)
            eval(compile(code))
            body(l) <- code
            l()
            body(l) <- code
            cmpfun(l)()
            local(eval(code))
            do.call("local", list(code))
        }
    }
}

setCompilerOptions(optimize = oldoptimize)
enableJIT(oldjit)
