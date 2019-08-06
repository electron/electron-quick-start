### R code from vignette source 'survival.Rnw'

###################################################
### code chunk number 1: survival.Rnw:24-29
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=10) #text in graph about the same as regular text
options(contrasts=c("contr.treatment", "contr.poly")) #ensure default
require("survival")


