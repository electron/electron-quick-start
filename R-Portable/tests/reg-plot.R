#### Regression tests for GRAPHICS & PLOTS

pdf("reg-plot.pdf", paper="a4r", encoding ="ISOLatin1.enc", compress = FALSE)

## since we supply the font metrics, the results depend only on
## the encoding used: Windows is different from Unix by default.

options(warn = 1) # print as they occur

plot(0) # this should remain constant
str(par(c("usr","xaxp","yaxp")))
stopifnot(all.equal(
    par(c("usr","xaxp","yaxp"))
   ,
    list(usr = c(0.568, 1.432, -1.08, 1.08),
         xaxp = c(0.6, 1.4, 4), yaxp = c(-1, 1, 4))))


### Test for centring of chars.  All the chars which are plotted should
### be centred, and there should be no warnings about
### font metrics unknown for character `?'

par(pty="s")
plot(c(-1,16), c(-1,16), type="n", xlab="", ylab="", xaxs="i", yaxs="i")
title("Centred chars in default char set (ISO Latin1)")
grid(17, 17, lty=1)
known <- c(32:126, 160:255)

for(i in known) {
    x <- i %% 16
    y <- i %/% 16
    points(x, y, pch=-i)
}

par(pty="m")

## PR 816 (label sizes in dotchart)

### Prior to 1.2.2, the label sizes were unaffected by cex.

dotchart(VADeaths, main = "Death Rates in Virginia - 1940", cex = 0.5)
dotchart(VADeaths, main = "Death Rates in Virginia - 1940", cex = 1.5)

## killed by 0 prior to 1.4.0 and in 1.4.1:
t1 <- ts(0:100)
## only warnings about values <= 0
plot(t1, log = "y")
plot(cbind(t1, 10*t1, t1 - 4), log="y", plot.type = "single")
stopifnot(par("usr")[4] > 3) # log10: ylim[2] = 1000


## This one needs to be looked at.
## lty = "blank" killed the fill colour too.
plot(1:10, type="n")
polygon(c(1, 3, 3, 1), c(1, 1, 3, 3), col="yellow", border="red", lty="blank")
rect(6, 6, 10, 10,  col="blue", border="red", lty="blank")
## in 1.5.0 all omit the fill colours.
with(trees, symbols(Height, Volume, circles=Girth/24, inches=FALSE,
                    lty="blank", bg="blue"))
## in 1.5.0 ignored the lty.

## axis() and par(mgp < 0) {keep this example S+ compatible!}:
lt <- if(is.R()) "31" else 2
x <- seq(-2,3, len=1001)
op <- par(tck= +0.02, mgp = -c(3,2,0))
plot(x, x^2 - 1.2, xaxt = "n", xlab="", type ='l', col = 2,
     main = "mgp < 0: all ticks and labels inside `frame'")
x <- -2:3
lines(x, x^2 - 1.2, type ="h", col = 3, lwd=3)
axis(1, pos = 0, at=-1:1, lty = lt, col=4)## col & lty work only from R 1.6
par(op)
axis(1, pos = 0, at=c(-2,2,3), lty = lt, col=4)
mtext(side=1,"note the x-ticks on the other side of the bars")

## plot.table(): explicit xlab and ylab for non-1D
plot(UCBAdmissions)# default x- and y-lab
plot(UCBAdmissions, xlab = "x label", ylab = "YY")# wrong in 1.5.1
##   axis suppression
plot(tt <- table(c(rep(0,7), rep(1,4), rep(5, 3))), axes = FALSE)
plot(tt, xaxt = "n")
## wrong till (incl.) 1.6.x

## legend with call
lo <- legend(2,2, substitute(hat(theta) == that, list(that= pi)))
stopifnot(length(lo$text$x) == 1)
## length() was 3 till 1.7.x

plot(ecdf(c(1:4,8,12)), ylab = "ECDF", main=NULL)
## ylab didn't work till 1.8.0

plot(1:10, pch = NA) # gave error till 1.9.0
points(1:3, pch=c("o",NA,"x"))# used "N"
try(points(4, pch=c(NA,FALSE)))# still give an error

## 'lwd' should transfer to plot symbols
legend(1,10, c("A","bcd"), lwd = 2:3, pch= 21:22, pt.bg="skyblue",
       col = 2:3, bg = "thistle")
## (gave an error for 2 days in "2.0.0 unstable")

x <- 2^seq(1,1001, length=20)
plot(x, x^0.9, type="l", log="xy")
## gave error 'Infinite axis extents [GEPretty(1.87013e-12,inf,5)]' for R 2.0.1

plot(as.Date("2001/1/1") + 12*(1:9), 1:9)
## used bad 'xlab/ylab' in some versions of R 2.2.0(unstable)

## dotchart() restoring par()
Opar <- par(no.readonly=TRUE) ; dotchart(1:4, cex= 0.7)
Npar <- par(no.readonly=TRUE)
ii <- c(37, 50:51, 58:59, 63)
stopifnot(identical(names(Opar)[ii],
                    c("mai","pin","plt","usr","xaxp","yaxp")),
          identical(Opar[-ii], Npar[-ii]))
## did not correctly restore par("mar") up to (incl) R 2.4.0

## plot.function()     [n=11, ... : since we store and diff PS file !]
plot(cos,       xlim=c(-5,5), n=11, axes=FALSE); abline(v=0)
## did *not* plot for negative x up to R 2.5.1
plot(sin, -2,3, xlim=c(-5,5), n=11, axes=FALSE, xlab="")# plot from -2
axis(1, at=c(-2,3), tcl=-1); axis(1, at=c(-5,5))
## (from,to) & xlim  should work simultaneously

plot(cos, -7,7, n=11, axes=FALSE)
## gave wrong ylab in R 2.6.0
plot(cos, -7,7, ylab = "Cosine  cos(x)", n=11, axes=FALSE)
## partial matching of 'ylab'; mapping  [0,1] (not [-7.7]):
## margins chosen to avoid rouding error showing to 2dp.
op <- par(mar=c(5,4.123,4,2)+0.1)
plot(gamma, yla = expression(Gamma(x)), n=11, yaxt="n")
par(op)

## plot.ts(x, y) could get the labels wrong in R <= 2.6.0:
x <- ts(1:5);x1 <- lag(x, 2); plot(x1, x, axes=FALSE)

# adding a curve in log scale :
curve(5*exp(-x), 0.1, 100, n = 3, log="x", ylab="", axes=FALSE)
curve(5*exp(-x), add=TRUE, n = 3, col=2,lwd=3)
## should fully overplot; wrong default xlim in 2.6.1
## (and *slightly* wrong up to 2.6.0)

## Axis() calls via plot()  {[xy]axt to keep *.ps small}
x <- as.Date("2008-04-22 09:45") + (i <- c(0,4))
plot(x,    xaxt="n")# not ok in 2.6.2, nor 2.7.0
plot(x, i, yaxt="n")# ok in 2.6.2  and 2.7.0
plot(i, x, xaxt="n")# ok in 2.6.2 and not in 2.7.0

## table methods should be bypassed:
dotchart(table(infert$education))
## failed in 2.12.[12]

## cex as "..."  in "high level" function
hc <- hclust(dst <- dist(c(1:2, 5)), method="ave")
plot(hc, cex = 2, axes=FALSE, ann=FALSE)
## cex was not used in 3.0.[01]

## axis.Date() and axis.POSIXct() with reversed 'xlim'
toD <- as.Date("2016-08-19"); dates <- c(toD - 10, toD)
plot(dates, 1:2, xlim = rev(dates),
     ann=FALSE, yaxt="n", frame.plot=FALSE)
## failed to label the dates in R <= 3.3.1
