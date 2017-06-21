### R code from vignette source 'sharing.Rnw'

###################################################
### code chunk number 1: sharing.Rnw:20-26
###################################################
library(grDevices)
library(graphics)
library(stats) # for rnorm
library(grid)
ps.options(pointsize = 12)
options(width = 60)


###################################################
### code chunk number 2: axes1 (eval = FALSE)
###################################################
## pushViewport(viewport(layout = grid.layout(1, 2, respect = TRUE)))


###################################################
### code chunk number 3: axes2 (eval = FALSE)
###################################################
## x <- 1:10
## y1 <- rnorm(10)
## vp1a <- viewport(layout.pos.col = 1)
## vp1b <- viewport(width = 0.6, height = 0.6,
##                  xscale = c(0, 11), yscale = c(-4, 4))
## pushViewport(vp1a, vp1b)
## grid.xaxis(name = "xaxis")
## grid.yaxis(name = "yaxis")
## grid.points(x, y1)
## popViewport(2)


###################################################
### code chunk number 4: axes3 (eval = FALSE)
###################################################
## y2 <- rnorm(10)
## vp2a <- viewport(layout.pos.col = 2)
## vp2b <- viewport(width = 0.6, height = 0.6,
##                  xscale = c(0, 11), yscale = c(-4, 4))
## pushViewport(vp2a, vp2b)
## grid.xaxis
## grid.xaxis(name = "xaxis")
## grid.yaxis(name = "yaxis")
## grid.points(x, y2)
## popViewport(2)


###################################################
### code chunk number 5: shared
###################################################
pushViewport(viewport(layout = grid.layout(1, 2, respect = TRUE)))
x <- 1:10
y1 <- rnorm(10)
vp1a <- viewport(layout.pos.col = 1)
vp1b <- viewport(width = 0.6, height = 0.6,
                 xscale = c(0, 11), yscale = c(-4, 4))
pushViewport(vp1a, vp1b)
grid.xaxis(name = "xaxis")
grid.yaxis(name = "yaxis")
grid.points(x, y1)
popViewport(2)
y2 <- rnorm(10)
vp2a <- viewport(layout.pos.col = 2)
vp2b <- viewport(width = 0.6, height = 0.6,
                 xscale = c(0, 11), yscale = c(-4, 4))
pushViewport(vp2a, vp2b)
grid.xaxis
grid.xaxis(name = "xaxis")
grid.yaxis(name = "yaxis")
grid.points(x, y2)
popViewport(2)



###################################################
### code chunk number 6: axesedit (eval = FALSE)
###################################################
## grid.edit("xaxis", at = c(1, 5, 9), global = TRUE)
## 


###################################################
### code chunk number 7: shared2
###################################################
postscript("shared2-%02d.eps", onefile = FALSE, paper = "special",
           width = 4, height = 2)
pushViewport(viewport(layout = grid.layout(1, 2, respect = TRUE)))
x <- 1:10
y1 <- rnorm(10)
vp1a <- viewport(layout.pos.col = 1)
vp1b <- viewport(width = 0.6, height = 0.6,
                 xscale = c(0, 11), yscale = c(-4, 4))
pushViewport(vp1a, vp1b)
grid.xaxis(name = "xaxis")
grid.yaxis(name = "yaxis")
grid.points(x, y1)
popViewport(2)
y2 <- rnorm(10)
vp2a <- viewport(layout.pos.col = 2)
vp2b <- viewport(width = 0.6, height = 0.6,
                 xscale = c(0, 11), yscale = c(-4, 4))
pushViewport(vp2a, vp2b)
grid.xaxis
grid.xaxis(name = "xaxis")
grid.yaxis(name = "yaxis")
grid.points(x, y2)
popViewport(2)
grid.edit("xaxis", at = c(1, 5, 9), global = TRUE)

dev.off()

pdf("shared2-%02d.pdf", onefile = FALSE, width = 4, height = 2)
pushViewport(viewport(layout = grid.layout(1, 2, respect = TRUE)))
x <- 1:10
y1 <- rnorm(10)
vp1a <- viewport(layout.pos.col = 1)
vp1b <- viewport(width = 0.6, height = 0.6,
                 xscale = c(0, 11), yscale = c(-4, 4))
pushViewport(vp1a, vp1b)
grid.xaxis(name = "xaxis")
grid.yaxis(name = "yaxis")
grid.points(x, y1)
popViewport(2)
y2 <- rnorm(10)
vp2a <- viewport(layout.pos.col = 2)
vp2b <- viewport(width = 0.6, height = 0.6,
                 xscale = c(0, 11), yscale = c(-4, 4))
pushViewport(vp2a, vp2b)
grid.xaxis
grid.xaxis(name = "xaxis")
grid.yaxis(name = "yaxis")
grid.points(x, y2)
popViewport(2)
grid.edit("xaxis", at = c(1, 5, 9), global = TRUE)

dev.off()


