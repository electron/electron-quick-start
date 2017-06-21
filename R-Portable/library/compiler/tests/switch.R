library(compiler)

ev <- function(expr)
    tryCatch(withVisible(eval(expr, parent.frame(), baseenv())),
             error = function(e) conditionMessage(e))

f <- function(x) switch(x, x = 1, y = , z = 3, , w =, 6, v = )
fc <- cmpfun(f)

stopifnot(identical(ev(quote(fc("x"))), ev(quote(f("x")))))
stopifnot(identical(ev(quote(fc("A"))), ev(quote(f("A")))))

stopifnot(identical(ev(quote(fc(0))), ev(quote(f(0)))))
stopifnot(identical(ev(quote(fc(1))), ev(quote(f(1)))))
stopifnot(identical(ev(quote(fc(2))), ev(quote(f(2)))))
stopifnot(identical(ev(quote(fc(3))), ev(quote(f(3)))))
stopifnot(identical(ev(quote(fc(4))), ev(quote(f(4)))))
stopifnot(identical(ev(quote(fc(5))), ev(quote(f(5)))))
stopifnot(identical(ev(quote(fc(6))), ev(quote(f(6)))))
stopifnot(identical(ev(quote(fc(7))), ev(quote(f(7)))))
stopifnot(identical(ev(quote(fc(8))), ev(quote(f(8)))))


g <- function(x) switch(x, x = 1, y = , z = 3, w =, 5, v = )
gc <- cmpfun(g)

stopifnot(identical(ev(quote(gc("x"))), ev(quote(g("x")))))
stopifnot(identical(ev(quote(gc("y"))), ev(quote(g("y")))))
stopifnot(identical(ev(quote(gc("z"))), ev(quote(g("z")))))
stopifnot(identical(ev(quote(gc("w"))), ev(quote(g("w")))))
stopifnot(identical(ev(quote(gc("v"))), ev(quote(g("v")))))
stopifnot(identical(ev(quote(gc("A"))), ev(quote(g("A")))))

stopifnot(identical(ev(quote(gc(0))), ev(quote(g(0)))))
stopifnot(identical(ev(quote(gc(1))), ev(quote(g(1)))))
stopifnot(identical(ev(quote(gc(2))), ev(quote(g(2)))))
stopifnot(identical(ev(quote(gc(3))), ev(quote(g(3)))))
stopifnot(identical(ev(quote(gc(4))), ev(quote(g(4)))))
stopifnot(identical(ev(quote(gc(5))), ev(quote(g(5)))))
stopifnot(identical(ev(quote(gc(6))), ev(quote(g(6)))))
stopifnot(identical(ev(quote(gc(7))), ev(quote(g(7)))))


h <- function(x) switch(x, x = 1, y = , z = 3)
hc <- cmpfun(h)

stopifnot(identical(ev(quote(hc("x"))), ev(quote(h("x")))))
stopifnot(identical(ev(quote(hc("y"))), ev(quote(h("y")))))
stopifnot(identical(ev(quote(hc("z"))), ev(quote(h("z")))))
stopifnot(identical(ev(quote(hc("A"))), ev(quote(h("A")))))

stopifnot(identical(ev(quote(hc(0))), ev(quote(h(0)))))
stopifnot(identical(ev(quote(hc(1))), ev(quote(h(1)))))
stopifnot(identical(ev(quote(hc(2))), ev(quote(h(2)))))
stopifnot(identical(ev(quote(hc(3))), ev(quote(h(3)))))
stopifnot(identical(ev(quote(hc(4))), ev(quote(h(4)))))


k <- function(x) switch(x, x = 1, y = 2, z = 3)
kc <- cmpfun(k)

stopifnot(identical(ev(quote(kc("x"))), ev(quote(k("x")))))
stopifnot(identical(ev(quote(kc("y"))), ev(quote(k("y")))))
stopifnot(identical(ev(quote(kc("z"))), ev(quote(k("z")))))
stopifnot(identical(ev(quote(kc("A"))), ev(quote(k("A")))))

stopifnot(identical(ev(quote(kc(0))), ev(quote(k(0)))))
stopifnot(identical(ev(quote(kc(1))), ev(quote(k(1)))))
stopifnot(identical(ev(quote(kc(2))), ev(quote(k(2)))))
stopifnot(identical(ev(quote(kc(3))), ev(quote(k(3)))))
stopifnot(identical(ev(quote(kc(4))), ev(quote(k(4)))))


l <- function(x) switch(x, "a", "b", "c")
lc <- cmpfun(l)

ce <- function(expr) tryCatch(expr, error = function(e) "Error")

## both of these should raise errors but the messages will differ
stopifnot(identical(ce(lc("A")), ce(l("A"))))

stopifnot(identical(ev(quote(lc(0))), ev(quote(l(0)))))
stopifnot(identical(ev(quote(lc(1))), ev(quote(l(1)))))
stopifnot(identical(ev(quote(lc(2))), ev(quote(l(2)))))
stopifnot(identical(ev(quote(lc(3))), ev(quote(l(3)))))
stopifnot(identical(ev(quote(lc(4))), ev(quote(l(4)))))

l <- function(x) switch(x)
lc <- cmpfun(l)

cw <- function(expr) tryCatch(expr, warning = function(w) w)

stopifnot(identical(cw(l(1)), cw(lc(1))))
stopifnot(identical(cw(l("A")), cw(lc("A"))))
suppressWarnings(stopifnot(identical(withVisible(l(1)),
                                     withVisible(lc(1)))))
suppressWarnings(stopifnot(identical(withVisible(l("A")),
                                     withVisible(lc("A")))))
