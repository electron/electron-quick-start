### R code from vignette source 'saveload.Rnw'

###################################################
### code chunk number 1: saveload.Rnw:23-27
###################################################
library(grDevices)
library(grid)
ps.options(pointsize = 12)
options(width = 60)


###################################################
### code chunk number 2: saveload.Rnw:54-56
###################################################
gt <- textGrob("hi")
save(gt, file = "mygridplot")


###################################################
### code chunk number 3: saveload.Rnw:60-62
###################################################
load("mygridplot")
grid.draw(gt)


###################################################
### code chunk number 4: saveload.Rnw:95-98
###################################################
grid.grill()
temp <- recordPlot()
save(temp, file = "mygridplot")


###################################################
### code chunk number 5: saveload.Rnw:105-107
###################################################
load("mygridplot")
temp


