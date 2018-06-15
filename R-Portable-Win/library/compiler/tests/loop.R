library(compiler)

f <- function(x) x

g <- function(x) repeat if (x) f(return(1)) else return(2)
gc <- cmpfun(g)
stopifnot(identical(g(TRUE), gc(TRUE)))
stopifnot(identical(g(FALSE), gc(FALSE)))

h <- function(x) { repeat if (x) f(return(1)) else break; 2 }
hc <- cmpfun(h)
stopifnot(identical(h(TRUE), hc(TRUE)))
stopifnot(identical(h(FALSE), hc(FALSE)))

k <- function(x) { repeat if (x) return(1) else f(break); 2 }
kc <- cmpfun(k)
stopifnot(identical(k(TRUE), kc(TRUE)))
stopifnot(identical(k(FALSE), kc(FALSE)))

## **** need more variations on this.

## this would give an error prior to fixing a binding cache bug
f <- function(x) { for (y in x) { z <- y; g(break) } ; z }
g <- function(x) x
cmpfun(f)(c(1,2,3))

