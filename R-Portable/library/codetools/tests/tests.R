library(codetools)
assert <- function(e)
    if (! e) stop(paste("assertion failed:", deparse(substitute(e))))
local({
    st <- function(e) {
        v <- NULL
        write <- function(x)
            v <<- paste(v, as.character(x), sep = "")
        showTree(e, write = write)
        v
    }
    assert(identical(st(quote(f(x))), "(f x)\n"))
    assert(identical(st(quote((x+y)*z)), "(* (\"(\" (+ x y)) z)\n"))
    assert(identical(st(quote(-3)), "(- 3)\n"))
})
assert(identical(constantFold(quote(3)), 3))
assert(identical(constantFold(quote(1+2)), 3))
assert(identical(constantFold(quote(1+2+x)), NULL))
assert(identical(constantFold(quote(pi)), pi))
assert(identical(constantFold(quote(pi), "pi"), NULL))
assert(identical(constantFold(quote(pi), "pi", FALSE), FALSE))
assert(identical(getAssignedVar(quote("v"<-x)), "v"))
assert(identical(getAssignedVar(quote(v<-x)), "v"))
assert(identical(getAssignedVar(quote(f(v)<-x)), "v"))
assert(identical(getAssignedVar(quote(f(g(v,2),1)<-x)), "v"))
assert(identical(findLocals(quote(x<-1)), "x"))
assert(identical(findLocals(quote(f(x)<-1)), "x"))
assert(identical(findLocals(quote(f(g(x,2),1)<-1)), "x"))
assert(identical(findLocals(quote(x<-y<-1)), c("x","y")))
assert(identical(findLocals(quote(local(x<-1,e))), "x"))
assert(identical(findLocals(quote(local(x<-1))), character(0)))
assert(identical(findLocals(quote({local<-1;local(x<-1)})), c("local", "x")))
assert(identical(findLocals(quote(local(x<-1,e)), "local"), "x"))
local({
    f <- function (f, x, y) {
        local <- f
        local(x <- y)
        x
    }
    assert(identical(findLocals(body(f)), c("local","x")))
})
local({
    env <- new.env()
    assign("local", 1, env)
    assert(identical(findLocals(quote(local(x<-1,e)), env), "x"))
})
assert(identical(findLocals(quote(assign(x, 3))), character(0)))
assert(identical(findLocals(quote(assign("x", 3))), "x"))
assert(identical(findLocals(quote(assign("x", 3, 4))), character(0)))
local({
    f<-function() { x <- 1; y <- 2}
    assert(identical(sort(findFuncLocals(formals(f),body(f))), c("x","y")))
    f<-function(u = x <- 1) y <- 2
    assert(identical(sort(findFuncLocals(formals(f),body(f))), c("x","y")))
})
assert(identical(flattenAssignment(quote(x)), list(NULL, NULL)))
assert(identical(flattenAssignment(quote(f(x, 1))),
                 list(list(quote(x)),
                      list(quote("f<-"(x, 1, value = `*tmpv*`))))))
assert(identical(flattenAssignment(quote(f(g(x, 2), 1))),
                 list(list(quote(x), quote(g(`*tmp*`, 2))),
                     list(quote("f<-"(`*tmp*`, 1, value = `*tmpv*`)),
                          quote("g<-"(x, 2, value = `*tmpv*`))))))
assert(identical(flattenAssignment(quote(f(g(h(x, 3), 2), 1))),
                 list(list(quote(x),
                           quote(h(`*tmp*`, 3)),
                           quote(g(`*tmp*`, 2))),
                     list(quote("f<-"(`*tmp*`, 1, value = `*tmpv*`)),
                          quote("g<-"(`*tmp*`, 2, value = `*tmpv*`)),
                          quote("h<-"(x, 3, value = `*tmpv*`))))))
assert(identical(flattenAssignment(quote(f(g(h(k(x, 4), 3), 2), 1))),
                 list(list(quote(x),
                           quote(k(`*tmp*`, 4)),
                           quote(h(`*tmp*`, 3)),
                           quote(g(`*tmp*`, 2))),
                     list(quote("f<-"(`*tmp*`, 1, value = `*tmpv*`)),
                          quote("g<-"(`*tmp*`, 2, value = `*tmpv*`)),
                          quote("h<-"(`*tmp*`, 3, value = `*tmpv*`)),
                          quote("k<-"(x, 4, value = `*tmpv*`))))))
if (getRversion() >= "2.13.0")
    assert(identical(flattenAssignment(quote(base::diag(x))),
                     list(list(quote(x)),
                          list(quote(base::`diag<-`(x, value = `*tmpv*`))))))
assert(! "y" %in% findGlobals(function() if (is.R()) x else y))
assert(identical(findGlobals(function() if (FALSE) x), "if"))
# **** need more test cases here
assert(identical(sort(findGlobals(function(x) { z <- 1; x + y + z})),
                 sort(c("<-", "{",  "+",  "y"))))

assert(identical(findGlobals(function() Quote(x)), "Quote"))
