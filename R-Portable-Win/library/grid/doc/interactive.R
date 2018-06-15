### R code from vignette source 'interactive.Rnw'

###################################################
### code chunk number 1: interactive.Rnw:23-27
###################################################
library(grDevices)
library(grid)
ps.options(pointsize = 12)
options(width = 60)


###################################################
### code chunk number 2: fig1
###################################################
grid.xaxis(at = 1:4/5, vp = viewport(w = .5, h = 0.01), name = "gxa")


###################################################
### code chunk number 3: edit1 (eval = FALSE)
###################################################
## grid.edit("gxa", gp = gpar(col = "red"))


###################################################
### code chunk number 4: fig2
###################################################
gxa <- xaxisGrob(at = 1:4/5, vp = viewport(w = .5, h = .01))
gxa <- editGrob(gxa, gp = gpar(col = "red"))
grid.draw(gxa)


###################################################
### code chunk number 5: edit2 (eval = FALSE)
###################################################
## grid.edit(gPath("gxa", "labels"), gp = gpar(col = "green"))


###################################################
### code chunk number 6: fig3
###################################################
gxa <- xaxisGrob(at = 1:4/5, vp = viewport(w = .5, h = .01))
gxa <- editGrob(gxa, gp = gpar(col = "red"))
gxa <- editGrob(gxa, gPath = "labels", gp = gpar(col = "green"))
grid.draw(gxa)


###################################################
### code chunk number 7: edit3 (eval = FALSE)
###################################################
## grid.edit("gxa", at = c(0.0, 0.5, 1.0))


###################################################
### code chunk number 8: fig4
###################################################
gxa <- xaxisGrob(at = 1:4/5, vp = viewport(w = .5, h = .01))
gxa <- editGrob(gxa, gp = gpar(col = "red"))
gxa <- editGrob(gxa, gPath = "labels", gp = gpar(col = "green"))
gxa <- editGrob(gxa, at = c(0.0, 0.5, 1.0))
grid.draw(gxa)


###################################################
### code chunk number 9: edit4 (eval = FALSE)
###################################################
## grid.edit("gxa::labels", gp = gpar(col = "black"), rot = 30)


###################################################
### code chunk number 10: fig5
###################################################
gxa <- xaxisGrob(at = 1:4/5, vp = viewport(w = .5, h = .01))
gxa <- editGrob(gxa, gp = gpar(col = "red"))
gxa <- editGrob(gxa, gPath = "labels", gp = gpar(col = "green"))
gxa <- editGrob(gxa, at = c(0.0, 0.5, 1.0))
gxa <- editGrob(gxa, gPath = "labels", gp = gpar(col = "black"), rot = 30)
grid.draw(gxa)


###################################################
### code chunk number 11: interactive.Rnw:128-134
###################################################
gxa <- xaxisGrob(at = 1:4/5, vp = viewport(w = .5, h = .01))
gxa <- editGrob(gxa, gp = gpar(col = "red"))
gxa <- editGrob(gxa, gPath = "labels", gp = gpar(col = "green"))
gxa <- editGrob(gxa, at = c(0.0, 0.5, 1.0))
gxa <- editGrob(gxa, gPath = "labels", gp = gpar(col = "black"), rot = 30)
grid.draw(gxa)


