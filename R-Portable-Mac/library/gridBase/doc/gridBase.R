### R code from vignette source 'gridBase.Rnw'

###################################################
### code chunk number 1: gridBase.Rnw:81-84
###################################################
library(grid)
library(gridBase)



###################################################
### code chunk number 2: basesetup (eval = FALSE)
###################################################
## midpts <- barplot(1:10, axes=FALSE)
## axis(2)
## axis(1, at=midpts, labels=FALSE)
## 


###################################################
### code chunk number 3: baseviewport (eval = FALSE)
###################################################
## vps <- baseViewports()
## pushViewport(vps$inner, vps$figure, vps$plot)
## 


###################################################
### code chunk number 4: gridtext (eval = FALSE)
###################################################
## grid.text(c("one", "two", "three", "four", "five",
##             "six", "seven", "eight", "nine", "ten"), 
##           x=unit(midpts, "native"), y=unit(-1, "lines"),
## 	  just="right", rot=60)
## popViewport(3)
## 


###################################################
### code chunk number 5: gridBase.Rnw:110-114
###################################################
midpts <- barplot(1:10, axes=FALSE)
axis(2)
axis(1, at=midpts, labels=FALSE)

vps <- baseViewports()
pushViewport(vps$inner, vps$figure, vps$plot)

grid.text(c("one", "two", "three", "four", "five",
            "six", "seven", "eight", "nine", "ten"), 
          x=unit(midpts, "native"), y=unit(-1, "lines"),
	  just="right", rot=60)
popViewport(3)




###################################################
### code chunk number 6: plotsymbol (eval = FALSE)
###################################################
## novelsym <- function(speed, temp, 
##                      width=unit(3, "mm"),
##                      length=unit(0.5, "inches")) {
##   grid.rect(height=length, y=0.5,
##             just="top", width=width,
##             gp=gpar(fill="white"))
##   grid.rect(height=temp*length,
##             y=unit(0.5, "npc") - length,
##             width=width,
##             just="bottom", gp=gpar(fill="grey"))
##   grid.lines(x=0.5, 
##              y=unit.c(unit(0.5, "npc"), unit(0.5, "npc") + speed*length),
## 	     arrow=arrow(length=unit(3, "mm"), type="closed"), 
##              gp=gpar(fill="black"))
##   grid.points(unit(0.5, "npc"), unit(0.5, "npc"), size=unit(2, "mm"), 
##               pch=16)
## }
## 


###################################################
### code chunk number 7: baseplot (eval = FALSE)
###################################################
## chinasea <- read.table(system.file("doc", "chinasea.txt", 
##                                    package="gridBase"),
##                        header=TRUE)
## plot(chinasea$lat, chinasea$long, type="n",
##   xlab="latitude", ylab="longitude", 
##   main="China Sea Wind Speed/Direction and Temperature")
## 


###################################################
### code chunk number 8: gridsym (eval = FALSE)
###################################################
## speed <- 0.8*chinasea$speed/14 + 0.2 
## temp <- chinasea$temp/40
## vps <- baseViewports()
## pushViewport(vps$inner, vps$figure, vps$plot)
## for (i in 1:25) {
##   pushViewport(viewport(x=unit(chinasea$lat[i], "native"),
##                          y=unit(chinasea$long[i], "native"),
##                          angle=chinasea$dir[i]))
##   novelsym(speed[i], temp[i])
##   popViewport() 
## }
## popViewport(3)
## 


###################################################
### code chunk number 9: gridBase.Rnw:184-188
###################################################
novelsym <- function(speed, temp, 
                     width=unit(3, "mm"),
                     length=unit(0.5, "inches")) {
  grid.rect(height=length, y=0.5,
            just="top", width=width,
            gp=gpar(fill="white"))
  grid.rect(height=temp*length,
            y=unit(0.5, "npc") - length,
            width=width,
            just="bottom", gp=gpar(fill="grey"))
  grid.lines(x=0.5, 
             y=unit.c(unit(0.5, "npc"), unit(0.5, "npc") + speed*length),
	     arrow=arrow(length=unit(3, "mm"), type="closed"), 
             gp=gpar(fill="black"))
  grid.points(unit(0.5, "npc"), unit(0.5, "npc"), size=unit(2, "mm"), 
              pch=16)
}

chinasea <- read.table(system.file("doc", "chinasea.txt", 
                                   package="gridBase"),
                       header=TRUE)
plot(chinasea$lat, chinasea$long, type="n",
  xlab="latitude", ylab="longitude", 
  main="China Sea Wind Speed/Direction and Temperature")

speed <- 0.8*chinasea$speed/14 + 0.2 
temp <- chinasea$temp/40
vps <- baseViewports()
pushViewport(vps$inner, vps$figure, vps$plot)
for (i in 1:25) {
  pushViewport(viewport(x=unit(chinasea$lat[i], "native"),
                         y=unit(chinasea$long[i], "native"),
                         angle=chinasea$dir[i]))
  novelsym(speed[i], temp[i])
  popViewport() 
}
popViewport(3)




###################################################
### code chunk number 10: gridBase.Rnw:220-225
###################################################
     data(USArrests)
     hc <- hclust(dist(USArrests), "ave")
     dend1 <- as.dendrogram(hc)
     dend2 <- cut(dend1, h=70)



###################################################
### code chunk number 11: gridBase.Rnw:229-233
###################################################
x <- 1:4
y <- 1:4
height <- factor(round(unlist(lapply(dend2$lower, attr, "height"))))



###################################################
### code chunk number 12: gridBase.Rnw:248-260
###################################################
space <- max(unit(rep(1, 50), "strwidth",
             as.list(rownames(USArrests))))
dendpanel <- function(x, y, subscripts, ...) {
  pushViewport(viewport(y=space, width=0.9,
                         height=unit(0.9, "npc") - space,
                         just="bottom"))
  grid.rect(gp=gpar(col="grey", lwd=5))
  par(plt=gridPLT(), new=TRUE, ps=10)
  plot(dend2$lower[[subscripts]], axes=FALSE)
  popViewport()
}



###################################################
### code chunk number 13: gridBase.Rnw:266-273
###################################################
library(lattice)
plot.new()
print(xyplot(y ~ x | height, subscripts=TRUE, xlab="", ylab="",
             strip=function(...) { strip.default(style=4, ...) },
             scales=list(draw=FALSE), panel=dendpanel),
      newpage=FALSE)



###################################################
### code chunk number 14: gridBase.Rnw:290-294
###################################################
     counts <- c(18,17,15,20,10,20,25,13,12)
     outcome <- gl(3,1,9)
     treatment <- gl(3,3)



###################################################
### code chunk number 15: gridBase.Rnw:302-304
###################################################
oldpar <- par(no.readonly=TRUE)



###################################################
### code chunk number 16: regions (eval = FALSE)
###################################################
## pushViewport(viewport(layout=grid.layout(1, 3,
##   widths=unit(rep(1, 3), c("null", "cm", "null")))))
## 


###################################################
### code chunk number 17: lattice (eval = FALSE)
###################################################
## pushViewport(viewport(layout.pos.col=1))
## library(lattice)
## bwplot <- bwplot(counts ~ outcome | treatment)
## print(bwplot, newpage=FALSE)
## popViewport()
## 


###################################################
### code chunk number 18: diagnostic (eval = FALSE)
###################################################
## pushViewport(viewport(layout.pos.col=3))
##      glm.D93 <- glm(counts ~ outcome + treatment, family=poisson())
##      par(omi=gridOMI(), mfrow=c(2, 2), new=TRUE)
##      par(cex=0.5, mar=c(5, 4, 1, 2))
##      par(mfg=c(1, 1))
##      plot(glm.D93, caption="", ask=FALSE) 
## popViewport(2)
## 


###################################################
### code chunk number 19: multiplot
###################################################
pushViewport(viewport(layout=grid.layout(1, 3,
  widths=unit(rep(1, 3), c("null", "cm", "null")))))

pushViewport(viewport(layout.pos.col=1))
library(lattice)
bwplot <- bwplot(counts ~ outcome | treatment)
print(bwplot, newpage=FALSE)
popViewport()

pushViewport(viewport(layout.pos.col=3))
     glm.D93 <- glm(counts ~ outcome + treatment, family=poisson())
     par(omi=gridOMI(), mfrow=c(2, 2), new=TRUE)
     par(cex=0.5, mar=c(5, 4, 1, 2))
     par(mfg=c(1, 1))
     plot(glm.D93, caption="", ask=FALSE) 
popViewport(2)




###################################################
### code chunk number 20: gridBase.Rnw:346-348
###################################################
par(oldpar)



###################################################
### code chunk number 21: gridBase.Rnw:375-379
###################################################
x <- c(0.88, 1.00, 0.67, 0.34)
y <- c(0.87, 0.43, 0.04, 0.94)
z <- matrix(runif(4*2), ncol=2)



###################################################
### code chunk number 22: gridBase.Rnw:386-388
###################################################
oldpar <- par(no.readonly=TRUE)



###################################################
### code chunk number 23: plot1 (eval = FALSE)
###################################################
## plot(x, y, xlim=c(-0.2, 1.2), ylim=c(-0.2, 1.2), type="n")
## 


###################################################
### code chunk number 24: plot2 (eval = FALSE)
###################################################
## vps <- baseViewports()
## pushViewport(vps$inner, vps$figure, vps$plot)
## grid.segments(x0=unit(c(rep(0, 4), x),
##                       rep(c("npc", "native"), each=4)),
##               x1=unit(c(x, x), rep("native", 8)),
##               y0=unit(c(y, rep(0, 4)),
##                       rep(c("native", "npc"), each=4)),
##               y1=unit(c(y, y), rep("native", 8)),
##               gp=gpar(lty="dashed", col="grey"))
##  


###################################################
### code chunk number 25: gridBase.Rnw:427-431
###################################################
maxpiesize <- unit(1, "inches")
totals <- apply(z, 1, sum)
sizemult <- totals/max(totals)



###################################################
### code chunk number 26: plot3 (eval = FALSE)
###################################################
## for (i in 1:4) {
##   pushViewport(viewport(x=unit(x[i], "native"),
##                          y=unit(y[i], "native"),
##                          width=sizemult[i]*maxpiesize,
##                          height=sizemult[i]*maxpiesize))
##   grid.rect(gp=gpar(col="grey", fill="white", lty="dashed"))
##   par(plt=gridPLT(), new=TRUE)
##   pie(z[i,], radius=1, labels=rep("", 2))
##   popViewport()
## }
## 


###################################################
### code chunk number 27: plot4 (eval = FALSE)
###################################################
## popViewport(3)
## par(oldpar)
## 


###################################################
### code chunk number 28: complex
###################################################
plot(x, y, xlim=c(-0.2, 1.2), ylim=c(-0.2, 1.2), type="n")

vps <- baseViewports()
pushViewport(vps$inner, vps$figure, vps$plot)
grid.segments(x0=unit(c(rep(0, 4), x),
                      rep(c("npc", "native"), each=4)),
              x1=unit(c(x, x), rep("native", 8)),
              y0=unit(c(y, rep(0, 4)),
                      rep(c("native", "npc"), each=4)),
              y1=unit(c(y, y), rep("native", 8)),
              gp=gpar(lty="dashed", col="grey"))
 
for (i in 1:4) {
  pushViewport(viewport(x=unit(x[i], "native"),
                         y=unit(y[i], "native"),
                         width=sizemult[i]*maxpiesize,
                         height=sizemult[i]*maxpiesize))
  grid.rect(gp=gpar(col="grey", fill="white", lty="dashed"))
  par(plt=gridPLT(), new=TRUE)
  pie(z[i,], radius=1, labels=rep("", 2))
  popViewport()
}

popViewport(3)
par(oldpar)




###################################################
### code chunk number 29: gridBase.Rnw:544-549
###################################################
     ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
     trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
     group <- gl(2,10,20, labels=c("Ctl","Trt"))
     weight <- c(ctl, trt)



###################################################
### code chunk number 30: gridBase.Rnw:557-559
###################################################
oldpar <- par(no.readonly=TRUE)



###################################################
### code chunk number 31: regions (eval = FALSE)
###################################################
## pushViewport(viewport(layout=grid.layout(1, 3,
##   widths=unit(rep(1, 3), c("null", "cm", "null")))))
## 


###################################################
### code chunk number 32: lattice (eval = FALSE)
###################################################
## pushViewport(viewport(layout.pos.col=1))
## library(lattice)
## bwplot <- bwplot(weight ~ group)
## print(bwplot, newpage=FALSE)
## popViewport()
## 


###################################################
### code chunk number 33: diagnostic (eval = FALSE)
###################################################
## pushViewport(viewport(layout.pos.col=3))
##      lm.D9 <- lm(weight ~ group)
##      par(omi=gridOMI(), mfrow=c(2, 2), new=TRUE)
##      par(cex=0.5)
##      par(mfg=c(1, 1))
##      plot(lm.D9, caption="", ask=FALSE) 
## popViewport(2)
## 


