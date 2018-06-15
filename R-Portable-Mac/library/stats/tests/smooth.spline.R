## partly moved from ../man/smooth.spline.Rd , quite system-specific.
if(!dev.interactive(TRUE)) pdf("smooth.spline-test.pdf")

##-- artificial example
y18 <- c(1:3, 5, 4, 7:3, 2*(2:5), rep(10, 4))
## "truly 64 bit platform" {have seen "x86-64" instead of "x86_64")
(b.64 <- grepl("^x86.64", Sys.info()[["machine"]]) &&
     .Machine$sizeof.pointer > 4)## "truly 64 bit platform"
(Lb.64 <- b.64 && Sys.info()[["sysname"]] == "Linux" && .Machine$sizeof.pointer == 8)
## i386-Linux: Df ~= (even! > ) 18 : interpolating -- much smaller PRESS
## It is the too low 'low = -3' which "kills" the algo; low= -2.6 still ok
## On other platforms, e.g., x64, ends quite differently (and fine)
## typically with Df = 8.636
(s2. <- smooth.spline(y18, cv = TRUE,
                      control = list(trace=TRUE, tol = 1e-6,
                                     low = if(b.64) -3 else -2)))
plot(y18)
xx <- seq(1,length(y18), len=201)
lines(predict(s2., xx), col = 4)
mtext(deparse(s2.$call,200), side= 1, line= -1, cex= 0.8, col= 4)

(sdf8 <- smooth.spline(y18, df = 8, control=list(trace=TRUE)))# 11 iter.
sdf8$df - 8 # -0.0009159978
(sdf8. <- smooth.spline(y18, df = 8, control=list(tol = 1e-8)))# 14 iter.

## This gave error: "... spar 'way too large'" -- now sees in dpbfa() that it can't factorize
## --> and gives *warning* about too large spar only
## e <- try(smooth.spline(y18, spar = 50)) #>> error
## stopifnot(inherits(e, "try-error"))
ss50 <- try(smooth.spline(y18, spar = 50)) #>> warning only (in R >= 3.4.0) -- FIXME ??
   e <- try(smooth.spline(y18, spar = -9)) #>> error : .. too small', not on 32-bit
## if(Lb.64) stopifnot(inherits(e, "try-error"))
if(Lb.64) inherits(e, "try-error") else "not Linux 64-bit"
## I see (in 32 bit Windows),
b.64 || inherits(ss50, "try-error")  # TRUE .. always?

## "extreme" range of spar, i.e., 'lambda' directly  (" spar = c(lambda = *) "):
##  ---------------------  --> problem/bug for too large lambda
e10 <- c(-20, -10, -7, -4:4, 7, 10)
(lams <- setNames(10^e10, paste0("lambda = 10^", e10)))
lamExp <- as.expression(lapply(e10, function(E)
				substitute(lambda == 10^e, list(e = E))))
sspl <- lapply(lams, function(LAM) try(smooth.spline(y18, lambda = LAM)))
sspl
ok <- vapply(sspl, class, "") == "smooth.spline"
stopifnot(ok[e10 <= 7])
ssok <- sspl[ok]
ssGet  <- function(ch) t(sapply(ssok, `[` , ch))
ssGet1 <- function(ch)   sapply(ssok, `[[`, ch)
stopifnot(all.equal(ssGet1("crit"), ssGet1("cv.crit"), tol = 1e-10))# seeing rel.diff = 6.57e-12
## Interesting:  for really large lambda, solution "diverges" from the straight line
ssGet(c("lambda", "df", "crit", "pen.crit"))

plot(y18); lines(predict(s2., xx), lwd = 5, col = adjustcolor(4, 1/4))
invisible(lapply(seq_along(ssok), function(i) lines(predict(ssok[[i]], xx), col=i)))
i18 <- 1:18
abline(lm(y18 ~ i18), col = adjustcolor('tomato',1/2), lwd = 5, lty = 3)
## --> lambda = 10^10 is clearly wrong: a *line* but not the L.S. one
legend("topleft", lamExp[ok], ncol = 2, bty = "n", col = seq_along(ssok), lty=1)

##--- Explore 'all.knots' and 'keep.stuff'

s2   <- smooth.spline(y18, cv = TRUE, keep.stuff=TRUE)

s2.7  <- smooth.spline(y18, cv = TRUE, keep.stuff=TRUE, nknots = 7)
s2.11 <- smooth.spline(y18, cv = TRUE, keep.stuff=TRUE, nknots = 11)
plot(y18)
lines(predict(s2, xx), lwd = 5, col = adjustcolor(4, 1/4))
lines(predict(s2.7,  xx), lwd = 3, col = adjustcolor("red", 1/4))
lines(predict(s2.11, xx), lwd = 2, col = adjustcolor("forestgreen", 1/4))
## s2.11 is very close to 's2'

if(!requireNamespace("Matrix") && !interactive())
    q("no")

if(Lb.64 && interactive()) ## extra checks (from above), but _not_ part of R checks
    stopifnot(inherits(e, "try-error"))
## in any case:
rbind("s-9_err" = inherits(e, "try-error"),
      "s+50_err"= inherits(ss50, "try-error"))


aux2Mat <- function(auxM) {
    stopifnot(is.list(auxM),
              identical(vapply(auxM, class, ""),
                        setNames(rep("numeric", 4), c("XWy", "XWX", "Sigma", "R"))))
    ## requireNamespace("Matrix")# want sparse matrices
    nk <- length(XWy <- auxM[["XWy"]])
    list(XWy = XWy,
         XWX =  Matrix::bandSparse(nk, k= 0:3, diagonals= matrix(auxM[[ "XWX" ]], nk,4), symmetric=TRUE),
         Sigma= Matrix::bandSparse(nk, k= 0:3, diagonals= matrix(auxM[["Sigma"]], nk,4), symmetric=TRUE))
}

## "Prove" basic property :
##
##     \hat{\beta} =  (X'W X + \lambda \Sigma)^{-1} X'W y
##     ---------------------------------------------------
##
chkB <- function(smspl, tol = 1e-10) {
    stopifnot(inherits(smspl, "smooth.spline"))
    if(!is.list(smspl$auxM))
        stop("need result of  smooth.spline(., keep.stuff = TRUE)")
    lM <- aux2Mat(smspl$auxM)
    beta.hat <- solve(lM$XWX + smspl$lambda * lM$Sigma, lM$XWy)
    all.equal(as.vector(beta.hat),
              smspl$fit$coef, tolerance = tol)
}

stopifnot(chkB(s2))
stopifnot(chkB(s2.7))
stopifnot(chkB(s2.11))

lM <- aux2Mat(s2$auxM)
A <- lM$XWX + s2$lambda * lM$Sigma
R <- Matrix::chol(A)
c. <- s2$fit$coef
stopifnot(all.equal(c., as.vector( solve(A, lM$XWy))) )

## c' Sigma c =
pen <- as.vector(c. %*% lM$Sigma %*% c.)
c(unscaled.penalty = pen,
  scaled.penalty   = s2$lambda * pen)

Sigma.tit <- quote(list(Sigma == Omega, "where"~~ Omega[list(j,k)] ==
                                      integral({B[j]*second}(t)~{B[k]*second}(t)~dt)))
Matrix::image(lM$XWX, main = quote({X*minute}*W*X))
Matrix::image(lM$Sigma, main = Sigma.tit)
Matrix::image(A, main = quote({X*minute}*W*X + lambda*Sigma))
Matrix::image(R, main = quote(R == chol({X*minute}*W*X + lambda*Sigma)))


## Specifying  'all.knots' ourselves

## 1) compatibly :
s2.7.k  <- smooth.spline(y18, cv = TRUE, keep.stuff=TRUE,
                         all.knots = s2.7$fit$knot[3+ 1:7])
ii <- names(s2.7) != "call"
stopifnot( all.equal(s2.7  [ii],
                     s2.7.k[ii]))

## 2) "free" but approximately in [0,1]
s2.9f  <- smooth.spline(y18, cv = TRUE, keep.stuff=TRUE,
                        all.knots = seq(0, 1, length.out = 9))
lines(predict(s2.9f, xx), lwd = 2, lty=3, col = adjustcolor("tomato", 1/2))
## knots partly outside [0,1]  --- is that correct ? (see below)
s2.7f  <- smooth.spline(y18, cv = TRUE, keep.stuff=TRUE,
                        all.knots = c(-1,1,3,5,7,9,12)/10)

if(FALSE) { ## not allowed (currently)
    ## knots partly *inside* [0,1] i.e. data outside knots
    s2.5f  <- smooth.spline(y18, cv = TRUE, keep.stuff=TRUE, control=list(trace=TRUE),
                            all.knots = c(1,3,5,7,9)/10)
    ## ------ OOOPS!  Segmentation fault ... "in attrib.c" {when returning from .Fortran()}
    lines(predict(s2.5f, xx), lwd = 2, lty=3, col = adjustcolor("brown", 1/2))
}
##' back-transform knots to "data-scale":
dScaledKnots <- function(smsp, drop.ends=TRUE) {
    stopifnot(inherits(smsp, "smooth.spline"))
    sf <- smsp$fit
    nk <- length(kk <- sf$knot)
    stopifnot((nk <- length(kk <- sf$knot)) >= 7)
    if(drop.ends) kk <- kk[4:(nk-3)]
    sf$min + sf$range * kk
}
pLines <- function(ss) {
    abline(v = dScaledKnots(ss), lty=3, col=adjustcolor("black", 1/2))
    abline(h = 0, v = range(ss$x), lty=4, lwd = 1.5, col="skyblue4")
}

## The following shows the data boundaries are used even when the knots are outside:
xe <- seq(-5, 25, length=256)
##
plot(y18, xlim=range(xe), ylim = c(-4,10)+.5, xlab="x")
lines(predict(s2.7f, xe), col=2, lwd = 2)
pLines(s2.7f)

str(m2 <- predict(s2.7f, x=xe, deriv=2)) # \hat{m''}(x)
plot(m2, type="l", col=2, lwd = 2,
     main = "m''(x) -- for  m(.) := smooth.spl(*, all.knots=c(..))",
     sub = "(knots shown as vertical dotted lines)")
pLines(s2.7f)

## same phenomenon (data boundaries, ...):
m1 <- predict(s2.7f, x=xe, deriv = 1) # \hat{m'}(x)
plot(m1, type="l", col=2, lwd = 2,
     main = "m'(x) -- for m(.) := smooth.spl(*, all.knots=c(..))",
     sub = "(knots shown as vertical dotted lines)")
pLines(s2.7f)
