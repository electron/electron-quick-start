#### Demos for  sfsmisc::hatMat()

##' Matrix trace -- tr(M) = \sum_i  M_{i,i}
##'
##' .. content for \details{} ..
##' @title Matrix trace
##' @param m
##' @return sum(<diagonal elements of 'm'>)
##' @author Martin Maechler
TR <- function(m) { ## Matrix trace(.) == tr(.) :
    stopifnot(length(d <- dim(m)) == 2, d[1] == d[2])
    sum(diag(m))
}

## Take those from  ?hatMat  -- modified --
##--.--.--.--.--.--.--.--
## Example 'pred.sm' arguments for hatMat() :
pspl   <-  function(x,y,...) predict(smooth.spline(x,y, ...), x = x)$y
## needed! default surface="interpolate" is not good enough :
loess.C <- loess.control(surface = "direct")
ploess <- function(x,y,...) predict(loess(y ~ x, ..., control=loess.C))

pksm   <-  function(x,y,...) ksmooth(sort(x),y, kernel="normal", x.points=x, ...)$y
## maybe rather than ksmooth():
if(require("sm"))
  pksm2 <- function(x,y,...)
           sm.regression(x,y, display="none", eval.points=x, ...)$estimate
##--.--.--.--.--.--.--.--

set.seed(21)

x <- seq(0, 10, length= 201) ## sorted !! -- otherwise:
mf <- function(x) x^1.5 * sin(x)
y <-  mf(x) + 5*rnorm(x)

## Plot data + smooths -- smoothing parameters carefully chosen
##  such that  df ~= 8.8 for all:
plot(x,y, cex=.6)
lines(x, mf(x), col="gray", lwd=3)## true m(x)
lines(predict(s1 <- smooth.spline(x,y, spar=.8)), col="blue"); s1 #-> df = 8.8
lines(x, predict(s2 <- loess(y ~ x, span=.385, control=loess.C)),
      col="forest green"); s2 # df = 8.77
lines(x, s3y <- ksmooth(x,y, "normal", bandwidth= 1.3)$y, col="tomato")
s4 <- sm.regression(x,y, h = 0.54, display="none", eval.points=x)
lines(x, s4$estimate, col = "purple")
legend("topleft", c("true m(.)", "sm.spline", "loess", "ksmooth", "sm.regression"),
       col=c("gray","blue","forest green","tomato","purple"),
       lty=1, lwd=c(3, 1,1,1,1), inset=.01)

TR(H.sspl  <- hatMat(x, pred.sm = pspl,	 spar = .8))	 # 8.808432
TR(H.loess <- hatMat(x, pred.sm = ploess, span = .385))	 # 8.865958
TR(H.ksm   <- hatMat(x, pred.sm = pksm, bandwidth = 1.3))# 8.788017
TR(H.ksm2  <- hatMat(x, pred.sm = pksm2, h = 0.54))	 # 8.80269  -- sm.regression is S.L.O.W

## Check consistency:
stopifnot(
          ## Smoothing Spline:
          all.equal(c(H.sspl %*% y), fitted(s1))
          ,
          all.equal(sum(diag(H.sspl)), s1$df)
          ,
          ## Loess
          all.equal(c(H.loess %*% y), fitted(s2))
          ,
          ## ksmooth()
          all.equal(c(H.ksm %*% y), s3y)
          ,
          ## sm.regression()
          all.equal(c(H.ksm2 %*% y), s4$estimate)
          )


op <- mult.fig(mfrow=c(4,1), marP=-.5)$old.par
yl <- c(-.01, 0.10)
matplot(x, H.sspl,  type="l", ylim=yl)
matplot(x, H.loess, type="l", ylim=yl)
matplot(x, H.ksm,   type="l", ylim=yl)
matplot(x, H.ksm2,  type="l", ylim=yl)
par(op)

## or just a subset
i <- c(1, seq(10,200, by=20), length(x))
op <- mult.fig(mfrow=c(4,1), marP= -.5,
               main = paste("rows",paste(i,collapse=",")," of hat matrices"))$old.par
matplot(x, H.sspl [,i], type="l", ylim=yl)
matplot(x, H.loess[,i], type="l", ylim=yl)
matplot(x, H.ksm  [,i], type="l", ylim=yl)
matplot(x, H.ksm2 [,i], type="l", ylim=yl)
par(op)

##' Image plot of a symmetric matrix -- traditional graphics
##'
##' @title Image Plot of Symmetric Matrix
##' @param m symmetric numeric matrix
##' @param color
##' @param levels
##' @param ...  passed to filled.contour()
##' @return
##' @author Martin Maechler
pMatrix <- function(m, color=topo.colors, levels= pretty(range(m), 20), ...)
{
    stopifnot(length(d <- dim(m)) == 2, d[1] == d[2])
    n <- d[1]
    ii <- seq_len(n)
    i. <- rev(ii)
    il <- unique(c(1,pretty(ii)))
    op <- par(mgp = c(3, .6, 0)); on.exit(par(op))
    filled.contour(ii, ii, m[i.,], color=color, levels=levels,
                   plot.axes = { axis(3, il); axis(2, at = n+1-il, labels = il)}, ...)
}

levs <- pretty(c(-0.025, 0.15), 25)
pMatrix(H.sspl, levels=levs,
        main = "hat matrix S for smooth.spline()")

if(dev.interactive()) dev.new()
pMatrix(H.loess, levels=levs, main = "hat matrix S for  loess()")

if(dev.interactive()) dev.new()
pMatrix(H.ksm, levels=levs, main = "hat matrix S for  ksmooth()")
