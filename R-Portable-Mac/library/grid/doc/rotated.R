### R code from vignette source 'rotated.Rnw'

###################################################
### code chunk number 1: rotated.Rnw:23-29
###################################################
library(grDevices)
library(graphics) # for boxplot
library(stats) # for rnorm
library(grid)
ps.options(pointsize = 12)
options(width = 60)


###################################################
### code chunk number 2: rotated.Rnw:35-38
###################################################
pushViewport(viewport(h = .8, w = .8, angle = 15))
grid.multipanel(newpage = FALSE)
popViewport()


###################################################
### code chunk number 3: complex1
###################################################
x <- rnorm(50)
y <- x + rnorm(50, 1, 2)


###################################################
### code chunk number 4: complex2
###################################################
# We will extend the axes over the entire region so
# extrapolate scale from main data region
scale <- extendrange(r = range(x,y))
extscale <- c(min(scale), max(scale)+diff(scale)*1/3)


###################################################
### code chunk number 5: complex3
###################################################
lay <- grid.layout(2, 2,
                   widths = unit(c(3, 1), "inches"),
                   heights = unit(c(1, 3), "inches"))
vp1 <- viewport(width = unit(4, "inches"), height = unit(4, "inches"),
                layout = lay, xscale = extscale, yscale = extscale)


###################################################
### code chunk number 6: complex4
###################################################
grid.newpage()
pushViewport(vp1)
grid.rect()
grid.xaxis()
grid.text("Test", y = unit(-3, "lines"))
grid.yaxis()
grid.text("Retest", x = unit(-3, "lines"), rot = 90)


###################################################
### code chunk number 7: complex5
###################################################
vp2 <- viewport(layout.pos.row = 2, layout.pos.col = 1,
                xscale = scale, yscale = scale)
pushViewport(vp2)
grid.lines()
grid.points(x, y, gp = gpar(col = "blue"))
popViewport()


###################################################
### code chunk number 8: complex6
###################################################
diffs <- (y - x)
rdiffs <- range(diffs)
ddiffs <- diff(rdiffs)
bxp <- boxplot(diffs, plot = FALSE)
vp3 <- viewport(x = unit(3, "inches"),
                y = unit(3, "inches"),
                width = unit(.5, "inches"),
                # NOTE that the axis on the boxplot represents
                # actual (y - x) values BUT to make
                # the bits of the boxplot line
                # up with the data points we have to plot
                # (y - x)/sqrt(2)
                # Hence the sin(pi/4) below
                height = unit(ddiffs*sin(pi/4)/diff(scale)*3, "inches"),
                just = c("centre", "center"),
                angle = 45,
	        gp = gpar(col = "red"),
                yscale = c(-ddiffs/2, ddiffs/2))
pushViewport(vp3)
left <- -.3
width <- .8
middle <- left + width/2
grid.rect(x = left, y = unit(bxp$conf[1,1], "native"),
          width = width, height = unit(diff(bxp$conf[,1]), "native"),
          just = c("left", "bottom"),
	  gp = gpar(col = NULL, fill = "orange"))
grid.rect(x = left, y = unit(bxp$stats[4,1], "native"),
          width = width, height = unit(diff(bxp$stats[4:3,1]), "native"),
          just = c("left", "bottom"))
grid.rect(x = left, y = unit(bxp$stats[3,1], "native"),
          width = width, height = unit(diff(bxp$stats[3:2,1]), "native"),
          just = c("left", "bottom"))
grid.lines(x = c(middle, middle), y = unit(bxp$stats[1:2,1], "native"))
grid.lines(x = c(middle, middle), y = unit(bxp$stats[4:5,1], "native"))
grid.lines(x = c(middle-.1, middle+.1), y = unit(bxp$stats[1,1], "native"))
grid.lines(x = c(middle-.1, middle+.1), y = unit(bxp$stats[5,1], "native"))
np <- length(bxp$out)
if (np > 0)
  grid.points(x = rep(middle, np), y = unit(bxp$out, "native"))
grid.yaxis(main = FALSE)
popViewport(2)



###################################################
### code chunk number 9: rotated.Rnw:144-150
###################################################
x <- rnorm(50)
y <- x + rnorm(50, 1, 2)
# We will extend the axes over the entire region so
# extrapolate scale from main data region
scale <- extendrange(r = range(x,y))
extscale <- c(min(scale), max(scale)+diff(scale)*1/3)
lay <- grid.layout(2, 2,
                   widths = unit(c(3, 1), "inches"),
                   heights = unit(c(1, 3), "inches"))
vp1 <- viewport(width = unit(4, "inches"), height = unit(4, "inches"),
                layout = lay, xscale = extscale, yscale = extscale)
grid.newpage()
pushViewport(vp1)
grid.rect()
grid.xaxis()
grid.text("Test", y = unit(-3, "lines"))
grid.yaxis()
grid.text("Retest", x = unit(-3, "lines"), rot = 90)
vp2 <- viewport(layout.pos.row = 2, layout.pos.col = 1,
                xscale = scale, yscale = scale)
pushViewport(vp2)
grid.lines()
grid.points(x, y, gp = gpar(col = "blue"))
popViewport()
diffs <- (y - x)
rdiffs <- range(diffs)
ddiffs <- diff(rdiffs)
bxp <- boxplot(diffs, plot = FALSE)
vp3 <- viewport(x = unit(3, "inches"),
                y = unit(3, "inches"),
                width = unit(.5, "inches"),
                # NOTE that the axis on the boxplot represents
                # actual (y - x) values BUT to make
                # the bits of the boxplot line
                # up with the data points we have to plot
                # (y - x)/sqrt(2)
                # Hence the sin(pi/4) below
                height = unit(ddiffs*sin(pi/4)/diff(scale)*3, "inches"),
                just = c("centre", "center"),
                angle = 45,
	        gp = gpar(col = "red"),
                yscale = c(-ddiffs/2, ddiffs/2))
pushViewport(vp3)
left <- -.3
width <- .8
middle <- left + width/2
grid.rect(x = left, y = unit(bxp$conf[1,1], "native"),
          width = width, height = unit(diff(bxp$conf[,1]), "native"),
          just = c("left", "bottom"),
	  gp = gpar(col = NULL, fill = "orange"))
grid.rect(x = left, y = unit(bxp$stats[4,1], "native"),
          width = width, height = unit(diff(bxp$stats[4:3,1]), "native"),
          just = c("left", "bottom"))
grid.rect(x = left, y = unit(bxp$stats[3,1], "native"),
          width = width, height = unit(diff(bxp$stats[3:2,1]), "native"),
          just = c("left", "bottom"))
grid.lines(x = c(middle, middle), y = unit(bxp$stats[1:2,1], "native"))
grid.lines(x = c(middle, middle), y = unit(bxp$stats[4:5,1], "native"))
grid.lines(x = c(middle-.1, middle+.1), y = unit(bxp$stats[1,1], "native"))
grid.lines(x = c(middle-.1, middle+.1), y = unit(bxp$stats[5,1], "native"))
np <- length(bxp$out)
if (np > 0)
  grid.points(x = rep(middle, np), y = unit(bxp$out, "native"))
grid.yaxis(main = FALSE)
popViewport(2)



