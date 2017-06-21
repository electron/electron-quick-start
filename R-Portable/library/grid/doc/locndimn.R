### R code from vignette source 'locndimn.Rnw'

###################################################
### code chunk number 1: locndimn.Rnw:25-29
###################################################
library(grDevices)
library(grid)
ps.options(pointsize = 12)
options(width = 60)


###################################################
### code chunk number 2: locndimn.Rnw:57-96
###################################################
diagram.locn <- function(i, n, locn) {
  x <- i/(n+1)
  grid.lines(x = unit(rep(x, 2), "npc"),
             y = unit.c(unit(0, "npc"), locn))
  grid.lines(x = unit(x, "npc") + unit(c(-2, 0, 2), "mm"),
             y = locn + unit(c(-2, 0, -2), "mm"))
  grid.text(paste(as.character(locn), "as a location"),
            x = unit(x, "npc") - unit(1, "mm"),
            y = locn - unit(3, "mm"),
            just = c("right", "bottom"),
            rot = 90)
}
diagram.dimn <- function(i, n, dimn) {
  x <- i/(n+1)
  pushViewport(viewport(x = unit(x, "npc"), y = unit(0, "native"),
            h = dimn, w = unit(1, "lines"), just = c("centre", "bottom")))
  grid.rect()
  grid.text(paste(as.character(dimn), "as a dimension"),
            rot = 90)
  popViewport()
}
pushViewport(viewport(w = 0.8, y=unit(1.7, "inches"),
                      h = unit(4, "inches"),
                      just = c("centre", "bottom"),
                      yscale = c(-0.6, 1.3)))
grid.grill(v = c(0, 1), h = seq(-0.5, 1, 0.5), default.units = "native")
grid.rect()
grid.yaxis()
n <- 10
diagram.locn(1, n, unit(1, "native"))
diagram.locn(2, n, unit(-0.4, "native"))
diagram.locn(3, n, unit(0.4, "native"))
diagram.locn(4, n, unit(1, "native") + unit(-0.4, "native"))
diagram.locn(5, n, unit(1, "native") - unit(0.4, "native"))
diagram.dimn(6, n, unit(1, "native"))
diagram.dimn(7, n, unit(-0.4, "native"))
diagram.dimn(8, n, unit(0.4, "native"))
diagram.dimn(9, n, unit(1, "native") + unit(-0.4, "native"))
diagram.dimn(10, n, unit(1, "native") - unit(0.4, "native"))


###################################################
### code chunk number 3: locndimn.Rnw:107-119
###################################################
pushViewport(viewport(yscale = c(-0.6, 1.3)))
# Unexpected results?
convertY(unit(1,'native'), "native")
convertY(unit(-.4,'native'), "native")
convertY(unit(1,'native')+unit(-.4,'native'), "native")
convertY(unit(1,'native')-unit(.4,'native'), "native")
# Expected results
convertHeight(unit(1,'native'), "native")
convertHeight(unit(-.4,'native'), "native")
convertHeight(unit(1,'native')+unit(-.4,'native'), "native")
convertHeight(unit(1,'native')-unit(.4,'native'), "native")
popViewport()


