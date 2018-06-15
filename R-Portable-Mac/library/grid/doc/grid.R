### R code from vignette source 'grid.Rnw'

###################################################
### code chunk number 1: grid.Rnw:32-38
###################################################
library(grDevices)
library(graphics) # for par
library(stats) # for rnorm
library(grid)
ps.options(pointsize = 12)
options(width = 60)


###################################################
### code chunk number 2: grid.Rnw:80-81 (eval = FALSE)
###################################################
## viewport(x = 0.5, y = 0.5, width = 0.5, height = 0.25, angle=45)


###################################################
### code chunk number 3: viewport
###################################################
grid.show.viewport(viewport(x = 0.5, y = 0.5, width = 0.5, height = 0.25,
                            angle = 45))


###################################################
### code chunk number 4: pushviewports
###################################################
grid.rect(gp = gpar(lty = "dashed"))
vp1 <- viewport(x = 0, y = 0.5, w = 0.5, h = 0.5,
                just = c("left", "bottom"), name = "vp1")
vp2 <- viewport(x = 0.5, y = 0, w = 0.5, h = 0.5,
                just = c("left", "bottom"))
pushViewport(vp1)
grid.rect(gp = gpar(col = "grey"))
grid.text("Some drawing in graphics region 1", y = 0.8)
upViewport()
pushViewport(vp2)
grid.rect(gp = gpar(col = "grey"))
grid.text("Some drawing in graphics region 2", y = 0.8)
upViewport()
downViewport("vp1")
grid.text("MORE drawing in graphics region 1", y = 0.2)
popViewport()


###################################################
### code chunk number 5: vpstack
###################################################
grid.rect(gp = gpar(lty = "dashed"))
vp <- viewport(width = 0.5, height = 0.5)
pushViewport(vp)
grid.rect(gp = gpar(col = "grey"))
grid.text("quarter of the page", y = 0.85)
pushViewport(vp)
grid.rect()
grid.text("quarter of the\nprevious viewport")
popViewport(2)


###################################################
### code chunk number 6: units
###################################################
unit(1, "npc")
unit(1:3/4, "npc")
unit(1:3/4, "npc")[2]
unit(1:3/4, "npc") + unit(1, "inches")
min(unit(0.5, "npc"), unit(1, "inches"))
unit.c(unit(0.5, "npc"), unit(2, "inches") + unit(1:3/4, "npc"),
       unit(1, "strwidth", "hi there"))


###################################################
### code chunk number 7: vpcoords
###################################################
pushViewport(viewport(y = unit(3, "lines"), width = 0.9, height = 0.8,
                      just = "bottom", xscale = c(0, 100)))
grid.rect(gp = gpar(col = "grey"))
grid.xaxis()
pushViewport(viewport(x = unit(60, "native"), y = unit(0.5, "npc"),
                      width = unit(1, "strwidth", "coordinates for everyone"),
                      height = unit(3, "inches")))
grid.rect()
grid.text("coordinates for everyone")
popViewport(2)


###################################################
### code chunk number 8: vplayout
###################################################
pushViewport(viewport(layout = grid.layout(4, 5)))
grid.rect(gp = gpar(col = "grey"))
grid.segments(c(1:4/5, rep(0, 3)), c(rep(0, 4), 1:3/4),
              c(1:4/5, rep(1, 3)), c(rep(1, 4), 1:3/4),
              gp = gpar(col = "grey"))
pushViewport(viewport(layout.pos.col = 2:3, layout.pos.row = 3))
grid.rect(gp = gpar(lwd = 3))
popViewport(2)


###################################################
### code chunk number 9: layoutcomplex
###################################################
grid.show.layout(grid.layout(4, 4, widths = unit(c(3, 1, 1, 1),
                             c("lines", "null", "null", "cm")),
                             heights = c(1, 1, 2, 3),
                             c("cm", "null", "null", "lines")))


###################################################
### code chunk number 10: gpar
###################################################
pushViewport(viewport(gp = gpar(fill = "grey", fontface = "italic")))
grid.rect()
grid.rect(width = 0.8, height = 0.6, gp = gpar(fill = "white"))
grid.text(paste("This text and the inner rectangle",
                "have specified their own gpar settings", sep = "\n"),
          y = 0.75, gp = gpar(fontface = "plain"))
grid.text(paste("This text and the outer rectangle",
                "accept the gpar settings of the viewport", sep = "\n"),
          y = 0.25)
popViewport()


###################################################
### code chunk number 11: simpleplot
###################################################
grid.rect(gp = gpar(lty = "dashed"))
x <- y <- 1:10
pushViewport(plotViewport(c(5.1, 4.1, 4.1, 2.1)))
pushViewport(dataViewport(x, y))
grid.rect()
grid.xaxis()
grid.yaxis()
grid.points(x, y)
grid.text("1:10", x = unit(-3, "lines"), rot = 90)
popViewport(2)


###################################################
### code chunk number 12: bpdata
###################################################
barData <- matrix(sample(1:4, 16, replace = TRUE), ncol = 4)


###################################################
### code chunk number 13: barconstraint
###################################################
boxColours <- 1:4


###################################################
### code chunk number 14: bpfun
###################################################
bp <- function(barData) {
    nbars <- dim(barData)[2]
    nmeasures <- dim(barData)[1]
    barTotals <- rbind(rep(0, nbars), apply(barData, 2, cumsum))
    barYscale <- c(0, max(barTotals)*1.05)
    pushViewport(plotViewport(c(5, 4, 4, 1),
                              yscale = barYscale,
                              layout = grid.layout(1, nbars)))
    grid.rect()
    grid.yaxis()
    for (i in 1:nbars) {
        pushViewport(viewport(layout.pos.col = i, yscale = barYscale))
        grid.rect(x = rep(0.5, nmeasures),
                  y = unit(barTotals[1:nmeasures, i], "native"),
                  height = unit(diff(barTotals[,i]), "native"),
                  width = 0.8, just = "bottom", gp = gpar(fill = boxColours))
        popViewport()
    }
    popViewport()
}


###################################################
### code chunk number 15: legendlabels
###################################################
legLabels <- c("Group A", "Group B", "Group C", "Something Longer")
boxSize <- unit(0.5, "inches")


###################################################
### code chunk number 16: legfun
###################################################
leg <- function(legLabels) {
    nlabels <- length(legLabels)
    pushViewport(viewport(layout = grid.layout(nlabels, 1)))
    for (i in 1:nlabels) {
        pushViewport(viewport(layout.pos.row = i))
        grid.rect(width = boxSize, height = boxSize, just = "bottom",
                  gp = gpar(fill = boxColours[i]))
        grid.text(legLabels[i], y = unit(0.5, "npc") - unit(1, "lines"))
        popViewport()
    }
    popViewport()
}


###################################################
### code chunk number 17: barplot
###################################################
grid.rect(gp = gpar(lty = "dashed"))
legend.width <- max(unit(rep(1, length(legLabels)),
                         "strwidth", as.list(legLabels)) +
                    unit(2, "lines"),
                    unit(0.5, "inches") + unit(2, "lines"))
pushViewport(viewport(layout = grid.layout(1, 2,
                      widths = unit.c(unit(1,"null"), legend.width))))
pushViewport(viewport(layout.pos.col = 1))
bp(barData)
popViewport()
pushViewport(viewport(layout.pos.col = 2))
pushViewport(plotViewport(c(5, 0, 4, 0)))
leg(legLabels)
popViewport(3)


###################################################
### code chunk number 18: grid.Rnw:654-655
###################################################
library(lattice)


###################################################
### code chunk number 19: trellisdata (eval = FALSE)
###################################################
## x <- rnorm(100)
## y <- rnorm(100)
## g <- sample(1:8, 100, replace = TRUE)


###################################################
### code chunk number 20: trellispanelplot (eval = FALSE)
###################################################
## xyplot(y ~ x | g, panel = function(x, y) {
##     panel.xyplot(x, y);
##     grid.lines(unit(c(0, 1), "npc"), unit(0, "native"),
##                gp = gpar(col = "grey"))
## })


###################################################
### code chunk number 21: trellispanel
###################################################
x <- rnorm(100)
y <- rnorm(100)
g <- sample(1:8, 100, replace = TRUE)
xyplot(y ~ x | g, panel = function(x, y) {
    panel.xyplot(x, y);
    grid.lines(unit(c(0, 1), "npc"), unit(0, "native"),
               gp = gpar(col = "grey"))
})


###################################################
### code chunk number 22: trellisstripplot (eval = FALSE)
###################################################
## xyplot(y ~ x | g, strip = function(which.given, which.panel, ...) {
##     grid.text(paste("Variable ", which.given, ": Level ",
##                     which.panel[which.given], sep = ""),
##               unit(1, "mm"), .5, just = "left")
## })


###################################################
### code chunk number 23: trellisstrip
###################################################
x <- rnorm(100)
y <- rnorm(100)
g <- sample(1:8, 100, replace = TRUE)
xyplot(y ~ x | g, strip = function(which.given, which.panel, ...) {
    grid.text(paste("Variable ", which.given, ": Level ",
                    which.panel[which.given], sep = ""),
              unit(1, "mm"), .5, just = "left")
})


###################################################
### code chunk number 24: trellisgridplot (eval = FALSE)
###################################################
## someText <- paste("A panel of text", "produced using", "raw grid code",
##                   "that could be used", "to describe",
##                   "the plot", "to the right.", sep = "\n")
## latticePlot <- xyplot(y ~ x | g, layout = c(2, 4))
## grid.rect(gp = gpar(lty = "dashed"))
## pushViewport(viewport(layout = grid.layout(1, 2,
##                       widths = unit.c(unit(1, "strwidth", someText) +
##                       unit(2, "cm"),
##                       unit(1, "null")))))
## pushViewport(viewport(layout.pos.col = 1))
## grid.rect(gp = gpar(fill = "light grey"))
## grid.text(someText,
##           x = unit(1, "cm"), y = unit(1, "npc") - unit(1, "inches"),
##           just = c("left", "top"))
## popViewport()
## pushViewport(viewport(layout.pos.col = 2))
## print(latticePlot, newpage = FALSE)
## popViewport(2)


###################################################
### code chunk number 25: trellisgrid
###################################################
x <- rnorm(100)
y <- rnorm(100)
g <- sample(1:8, 100, replace = TRUE)
someText <- paste("A panel of text", "produced using", "raw grid code",
                  "that could be used", "to describe",
                  "the plot", "to the right.", sep = "\n")
latticePlot <- xyplot(y ~ x | g, layout = c(2, 4))
grid.rect(gp = gpar(lty = "dashed"))
pushViewport(viewport(layout = grid.layout(1, 2,
                      widths = unit.c(unit(1, "strwidth", someText) +
                      unit(2, "cm"),
                      unit(1, "null")))))
pushViewport(viewport(layout.pos.col = 1))
grid.rect(gp = gpar(fill = "light grey"))
grid.text(someText,
          x = unit(1, "cm"), y = unit(1, "npc") - unit(1, "inches"),
          just = c("left", "top"))
popViewport()
pushViewport(viewport(layout.pos.col = 2))
print(latticePlot, newpage = FALSE)
popViewport(2)


