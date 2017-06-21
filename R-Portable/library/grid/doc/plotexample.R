### R code from vignette source 'plotexample.Rnw'

###################################################
### code chunk number 1: plotexample.Rnw:33-38
###################################################
library(grDevices)
library(stats) # for runif()
library(grid)
ps.options(pointsize=12)
options(width=60)


###################################################
### code chunk number 2: plotexample.Rnw:93-95
###################################################
x <- runif(10)
y <- runif(10)


###################################################
### code chunk number 3: datavp
###################################################
data.vp <- viewport(x = unit(5, "lines"),
                    y = unit(4, "lines"),
                    width = unit(1, "npc") - unit(7, "lines"),
                    height = unit(1, "npc") - unit(7, "lines"),
                    just = c("left", "bottom"),
                    xscale = range(x) + c(-0.05, 0.05)*diff(range(x)),
                    yscale = range(y) + c(-0.05, 0.05)*diff(range(y)))


###################################################
### code chunk number 4: procplot
###################################################
pushViewport(data.vp)
grid.points(x, y)
grid.rect()
grid.xaxis()
grid.yaxis()
grid.text("x axis", y = unit(-3, "lines"),
          gp = gpar(fontsize = 14))
grid.text("y axis", x = unit(-4, "lines"),
          gp = gpar(fontsize = 14), rot = 90)
grid.text("A Simple Plot",
          y = unit(1, "npc") + unit(1.5, "lines"),
          gp = gpar(fontsize = 16))
popViewport()


###################################################
### code chunk number 5: plotexample.Rnw:130-131
###################################################
pushViewport(data.vp)
grid.points(x, y)
grid.rect()
grid.xaxis()
grid.yaxis()
grid.text("x axis", y = unit(-3, "lines"),
          gp = gpar(fontsize = 14))
grid.text("y axis", x = unit(-4, "lines"),
          gp = gpar(fontsize = 14), rot = 90)
grid.text("A Simple Plot",
          y = unit(1, "npc") + unit(1.5, "lines"),
          gp = gpar(fontsize = 16))
popViewport()


###################################################
### code chunk number 6: ann1
###################################################
pushViewport(data.vp)
grid.text(date(), x = unit(1, "npc"), y = 0,
          just = c("right", "bottom"), gp = gpar(col="grey"))
popViewport()


###################################################
### code chunk number 7: plotexample.Rnw:147-149
###################################################
pushViewport(data.vp)
grid.points(x, y)
grid.rect()
grid.xaxis()
grid.yaxis()
grid.text("x axis", y = unit(-3, "lines"),
          gp = gpar(fontsize = 14))
grid.text("y axis", x = unit(-4, "lines"),
          gp = gpar(fontsize = 14), rot = 90)
grid.text("A Simple Plot",
          y = unit(1, "npc") + unit(1.5, "lines"),
          gp = gpar(fontsize = 16))
popViewport()
pushViewport(data.vp)
grid.text(date(), x = unit(1, "npc"), y = 0,
          just = c("right", "bottom"), gp = gpar(col="grey"))
popViewport()


###################################################
### code chunk number 8: plotexample.Rnw:164-185
###################################################
data.vp <- viewport(name = "dataregion",
                    x = unit(5, "lines"),
                    y = unit(4, "lines"),
                    width = unit(1, "npc") - unit(7, "lines"),
                    height = unit(1, "npc") - unit(7, "lines"),
                    just = c("left", "bottom"),
                    xscale = range(x) + c(-0.05, 0.05)*diff(range(x)),
                    yscale = range(y) + c(-0.05, 0.05)*diff(range(y)))
pushViewport(data.vp)
grid.points(x, y)
grid.rect()
grid.xaxis()
grid.yaxis()
grid.text("x axis", y = unit(-3, "lines"),
          gp = gpar(fontsize = 14))
grid.text("y axis", x = unit(-4, "lines"),
          gp = gpar(fontsize = 14), rot = 90)
grid.text("A Simple Plot",
          y = unit(1, "npc") + unit(1.5, "lines"),
          gp = gpar(fontsize = 16))
upViewport()


###################################################
### code chunk number 9: plotexample.Rnw:191-195
###################################################
downViewport("dataregion")
grid.text(date(), x = unit(1, "npc"), y  =  0,
          just = c("right", "bottom"), gp = gpar(col = "grey"))
upViewport()


###################################################
### code chunk number 10: funcplot
###################################################
splot <- function(x = runif(10), y = runif(10), title = "A Simple Plot") {
    data.vp <- viewport(name = "dataregion",
                        x = unit(5, "lines"),
                        y = unit(4, "lines"),
                        width = unit(1, "npc") - unit(7, "lines"),
                        height = unit(1, "npc") - unit(7, "lines"),
                        just = c("left", "bottom"),
                        xscale = range(x) + c(-.05, .05)*diff(range(x)),
                        yscale = range(y) + c(-.05, .05)*diff(range(y)))
    pushViewport(data.vp)
    grid.points(x, y)
    grid.rect()
    grid.xaxis()
    grid.yaxis()
    grid.text("y axis", x = unit(-4, "lines"),
              gp = gpar(fontsize = 14), rot = 90)
    grid.text(title, y = unit(1, "npc") + unit(1.5, "lines"),
              gp = gpar(fontsize = 16))
    upViewport()
}


###################################################
### code chunk number 11: embed
###################################################
grid.rect(gp = gpar(fill = "grey"))
message <-
    paste("I could draw all sorts",
          "of stuff over here",
          "then create a viewport",
          "over there and stick",
          "a scatterplot in it.", sep = "\n")
grid.text(message, x = 0.25)
grid.lines(x = unit.c(unit(0.25, "npc") + 0.5*stringWidth(message) +
           unit(2, "mm"),
           unit(0.5, "npc") - unit(2, "mm")),
           y = 0.5,
           arrow = arrow(angle = 15, type = "closed"),
           gp = gpar(lwd = 3, fill = "black"))
pushViewport(viewport(x = 0.5, height = 0.5, width = 0.45, just = "left",
                      gp = gpar(cex = 0.5)))
grid.rect(gp = gpar(fill = "white"))
splot(1:10, 1:10, title = "An Embedded Plot")
upViewport()


###################################################
### code chunk number 12: ann2 (eval = FALSE)
###################################################
## downViewport("dataregion")
## grid.text(date(), x = unit(1, "npc"), y  =  0,
##           just = c("right", "bottom"), gp = gpar(col = "grey"))
## upViewport(0)


###################################################
### code chunk number 13: plotexample.Rnw:271-273
###################################################
grid.rect(gp = gpar(fill = "grey"))
message <-
    paste("I could draw all sorts",
          "of stuff over here",
          "then create a viewport",
          "over there and stick",
          "a scatterplot in it.", sep = "\n")
grid.text(message, x = 0.25)
grid.lines(x = unit.c(unit(0.25, "npc") + 0.5*stringWidth(message) +
           unit(2, "mm"),
           unit(0.5, "npc") - unit(2, "mm")),
           y = 0.5,
           arrow = arrow(angle = 15, type = "closed"),
           gp = gpar(lwd = 3, fill = "black"))
pushViewport(viewport(x = 0.5, height = 0.5, width = 0.45, just = "left",
                      gp = gpar(cex = 0.5)))
grid.rect(gp = gpar(fill = "white"))
splot(1:10, 1:10, title = "An Embedded Plot")
upViewport()
downViewport("dataregion")
grid.text(date(), x = unit(1, "npc"), y  =  0,
          just = c("right", "bottom"), gp = gpar(col = "grey"))
upViewport(0)


###################################################
### code chunk number 14: plotexample.Rnw:300-336
###################################################
splot.data.vp <- function(x, y) {
  viewport(name = "dataregion",
           x = unit(5, "lines"),
           y = unit(4, "lines"),
           width = unit(1, "npc") - unit(7, "lines"),
           height = unit(1, "npc") - unit(7, "lines"),
           just = c("left", "bottom"),
           xscale = range(x) + c(-.05, .05)*diff(range(x)),
           yscale = range(y) + c(-.05, .05)*diff(range(y)))
}

splot.title <- function(title) {
      textGrob(title, name = "title",
               y = unit(1, "npc") + unit(1.5, "lines"),
               gp = gpar(fontsize = 16), vp = "dataregion")
}

splot <- function(x, y, title, name=NULL, draw=TRUE, gp=gpar(), vp=NULL) {
    spg <- gTree(x = x, y = y, title = title, name = name,
                 childrenvp  =  splot.data.vp(x, y),
                 children = gList(rectGrob(name = "border",
                                           vp = "dataregion"),
                 xaxisGrob(name = "xaxis", vp = "dataregion"),
                 yaxisGrob(name = "yaxis", vp = "dataregion"),
                 pointsGrob(x, y, name = "points", vp = "dataregion"),
                 textGrob("x axis", y = unit(-3, "lines"), name = "xlab",
                          gp = gpar(fontsize = 14), vp = "dataregion"),
                 textGrob("y axis", x = unit(-4, "lines"), name = "ylab",
                          gp = gpar(fontsize = 14), rot = 90,
                          vp = "dataregion"),
                 splot.title(title)),
                 gp = gp, vp = vp,
                 cl = "splot")
    if (draw) grid.draw(spg)
    spg
}


###################################################
### code chunk number 15: splotgrob (eval = FALSE)
###################################################
## sg <- splot(1:10, 1:10, "Same as Before", name = "splot", draw = FALSE)


###################################################
### code chunk number 16: plotexample.Rnw:353-358
###################################################
splot(1:10, 1:10, "Same as Before", name = "splot")
downViewport("dataregion")
grid.text(date(), x = unit(1, "npc"), y = 0,
          just = c("right", "bottom"), gp = gpar(col = "grey"))
upViewport(0)


###################################################
### code chunk number 17: plotexample.Rnw:406-408
###################################################
splot(1:10, 1:10, "Same as Before", name = "splot")
grid.edit("splot", gp = gpar(cex=0.5))


###################################################
### code chunk number 18: plotexample.Rnw:409-412
###################################################
sg <- splot(1:10, 1:10, "Same as Before", name = "splot", draw = FALSE)
sg <- editGrob(sg, gp = gpar(cex = 0.5))
grid.draw(sg)


###################################################
### code chunk number 19: plotexample.Rnw:418-420
###################################################
splot(1:10, 1:10, "Same as Before", name = "splot")
grid.edit(gPath("splot", "points"), gp = gpar(col = 1:10))


###################################################
### code chunk number 20: plotexample.Rnw:421-425
###################################################
sg <- splot(1:10, 1:10, "Same as Before", name = "splot", draw = FALSE)
sg <- editGrob(sg, gPath = "points", gp = gpar(col = 1:10))
grid.draw(sg)



###################################################
### code chunk number 21: plotexample.Rnw:433-445
###################################################
editDetails.splot <- function(x, specs) {
    if (any(c("x", "y") %in% names(specs))) {
        if (is.null(specs$x)) xx <- x$x else xx <- specs$x
        if (is.null(specs$y)) yy <- x$y else yy <- specs$y
        x$childrenvp <- splot.data.vp(xx, yy)
        x <- addGrob(x, pointsGrob(xx, yy, name = "points",
                                   vp = "dataregion"))
    }
  x
}
splot(1:10, 1:10, "Same as Before", name = "splot")
grid.edit("splot", x = 1:100, y = (1:100)^2)


###################################################
### code chunk number 22: plotexample.Rnw:446-449
###################################################
sg <- splot(1:10, 1:10, "Same as Before", name = "splot", draw = FALSE)
sg <- editGrob(sg, x = 1:100, y = (1:100)^2)
grid.draw(sg)


###################################################
### code chunk number 23: plotexample.Rnw:460-501
###################################################
cellname <- function(i, j) paste("cell", i, j, sep = "")

splom.vpTree <- function(n) {
    vplist <- vector("list", n^2)
    for (i in 1:n)
        for (j in 1:n)
            vplist[[(i - 1)*n + j]] <-
              viewport(layout.pos.row = i, layout.pos.col = j,
                       name = cellname(i, j))
    vpTree(viewport(layout = grid.layout(n, n), name = "cellgrid"),
    do.call("vpList", vplist))
}

cellpath <- function(i, j) vpPath("cellgrid", cellname(i, j))

splom <- function(df, name = NULL, draw = TRUE) {
    n <- dim(df)[2]
    glist <- vector("list", n*n)
    for (i in 1:n)
        for (j in 1:n) {
            glist[[(i - 1)*n + j]] <-if (i == j)
                textGrob(paste("diag", i, sep = ""),
                         gp = gpar(col = "grey"), vp = cellpath(i, j))
            else if (j > i)
                textGrob(cellname(i, j),
                         name = cellname(i, j),
                         gp = gpar(col = "grey"), vp = cellpath(i, j))
            else
                splot(df[,j], df[,i], "",
                      name = paste("plot", i, j, sep = ""),
                      vp = cellpath(i, j),
                      gp = gpar(cex = 0.5), draw = FALSE)
        }
    smg <- gTree(name = name, childrenvp = splom.vpTree(n),
                 children = do.call("gList", glist))
    if (draw) grid.draw(smg)
    smg
}

df <- data.frame(x = rnorm(10), y = rnorm(10), z = rnorm(10))
splom(df)


###################################################
### code chunk number 24: plotexample.Rnw:506-511
###################################################
splom(df)
grid.edit("plot21::xlab", label = "", redraw = FALSE)
grid.edit("plot32::ylab", label = "", redraw = FALSE)
grid.edit("plot21::xaxis", label = FALSE, redraw = FALSE)
grid.edit("plot32::yaxis", label = FALSE)


###################################################
### code chunk number 25: splomgrob (eval = FALSE)
###################################################
## smg <- splom(df, draw = FALSE)


###################################################
### code chunk number 26: plotexample.Rnw:514-520
###################################################
smg <- splom(df, draw = FALSE)
smg <- editGrob(smg, gPath = "plot21::xaxis", label = FALSE)
smg <- editGrob(smg, gPath = "plot21::xlab", label = "")
smg <- editGrob(smg, gPath = "plot32::yaxis", label = FALSE)
smg <- editGrob(smg, gPath = "plot32::ylab", label = "")
grid.draw(smg)


###################################################
### code chunk number 27: plotexample.Rnw:530-535
###################################################
splom(df, name = "splom")
grid.remove("cell12")
grid.add("splom", textGrob(date(), name = "date",
                           gp = gpar(fontface = "italic"),
                           vp = "cellgrid::cell12"))


###################################################
### code chunk number 28: plotexample.Rnw:536-542
###################################################
smg <- splom(df, draw = FALSE)
smg <- removeGrob(smg, "cell12")
smg <- addGrob(smg, textGrob(date(), name = "date",
                             gp = gpar(fontface = "italic"),
                             vp = "cellgrid::cell12"))
grid.draw(smg)


###################################################
### code chunk number 29: plotexample.Rnw:550-566
###################################################
splom(df, name = "splom")
grid.remove("cell12")
grid.add("splom", textGrob(date(), name = "date",
                           gp = gpar(fontface = "italic"),
                           vp = "cellgrid::cell12"))
smg <- grid.get("splom")
save(smg, file = "splom.RData")
load("splom.RData")
plot <- getGrob(smg, "plot31")
date <- getGrob(smg, "date")
plot <- editGrob(plot, vp = NULL, gp = gpar(cex = 1))
date <- editGrob(date, y = unit(1, "npc") - unit(1, "lines"), vp = NULL)
grid.newpage()
grid.draw(plot)
grid.draw(date)



###################################################
### code chunk number 30: plotexample.Rnw:567-580
###################################################
smg <- splom(df, draw = FALSE)
smg <- removeGrob(smg, "cell12")
smg <- addGrob(smg, textGrob(date(), name = "date",
                             gp = gpar(fontface = "italic"),
                             vp = "cellgrid::cell12"))
save(smg, file = "splom.RData")
load("splom.RData")
plot <- getGrob(smg, "plot31")
date <- getGrob(smg, "date")
plot <- editGrob(plot, vp = NULL, gp = gpar(cex = 1))
date <- editGrob(date, y = unit(1, "npc") - unit(1, "lines"), vp = NULL)
grid.draw(plot)
grid.draw(date)


