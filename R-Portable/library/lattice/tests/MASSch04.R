#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 4   Graphical Output

library(MASS)
library(lattice)
trellis.device(postscript, file="ch04.ps", width=8, height=6,
               pointsize=9)
options(echo=T, width=65, digits=5)


# 4.2  Basic plotting functions

topo.loess <- loess(z ~ x * y, topo, degree = 2, span = 0.25)
topo.mar <- list(x = seq(0, 6.5, 0.2), y=seq(0, 6.5, 0.2))
topo.lo <- predict(topo.loess, expand.grid(topo.mar))
topo.lo1 <- cbind(expand.grid(x=topo.mar$x, y=topo.mar$y),
                  z=as.vector(topo.lo))
contourplot(z ~ x * y, topo.lo1, aspect = 1,
  at = seq(700, 1000, 25), xlab = "", ylab = "",
  panel = function(x, y, subscripts, ...) {
     panel.levelplot(x, y, subscripts, ...)
     panel.xyplot(topo$x, topo$y, cex = 0.5)
  }
)







# 4.5  Trellis graphics


xyplot(time ~ dist, data = hills,
  panel = function(x, y, ...) {
     panel.xyplot(x, y, ...)
     panel.lmline(x, y, type = "l")
     panel.abline(lqs(y ~ x), lty = 3)
#     identify(x, y, row.names(hills))
  }
)

bwplot(Expt ~ Speed, data = michelson, ylab = "Experiment No.",
       main = "Speed of Light Data")


data(swiss)
splom(~ swiss, aspect = "fill",
  panel = function(x, y, ...) {
     panel.xyplot(x, y, ...); panel.loess(x, y, ...)
  }
)

sps <- trellis.par.get("superpose.symbol")
sps$pch <- 1:7
trellis.par.set("superpose.symbol", sps)
xyplot(Time ~ Viscosity, data = stormer, groups = Wt,
   panel = panel.superpose, type = "b",
   key = list(columns = 3,
       text = list(paste(c("Weight:   ", "", ""),
                         unique(stormer$Wt), "gms")),
       points = Rows(sps, 1:3)
       )
)
rm(sps)

topo.plt <- expand.grid(topo.mar)
topo.plt$pred <- as.vector(predict(topo.loess, topo.plt))
levelplot(pred ~ x * y, topo.plt, aspect = 1,
  at = seq(690, 960, 10), xlab = "", ylab = "",
  panel = function(x, y, subscripts, ...) {
     panel.levelplot(x, y, subscripts, ...)
     panel.xyplot(topo$x,topo$y, cex = 0.5, col = 1)
  }
)

## if (F) {
wireframe(pred ~ x * y, topo.plt, aspect = c(1, 0.5),
  drape = T, screen = list(z = -150, x = -60),
  colorkey = list(space="right", height=0.6))
## }

lcrabs.pc <- predict(princomp(log(crabs[,4:8])))
crabs.grp <- c("B", "b", "O", "o")[rep(1:4, each = 50)]
splom(~ lcrabs.pc[, 1:3], groups = crabs.grp,
   panel = panel.superpose,
   key = list(text = list(c("Blue male", "Blue female",
                            "Orange Male", "Orange female")),
       points = Rows(trellis.par.get("superpose.symbol"), 1:4),
       columns = 4)
  )

sex <- crabs$sex
levels(sex) <- c("Female", "Male")
sp <- crabs$sp
levels(sp) <- c("Blue", "Orange")
splom(~ lcrabs.pc[, 1:3] | sp*sex, cex = 0.5, pscales = 0)

Quine <- quine
levels(Quine$Eth) <- c("Aboriginal", "Non-aboriginal")
levels(Quine$Sex) <- c("Female", "Male")
levels(Quine$Age) <- c("primary", "first form",
                      "second form", "third form")
levels(Quine$Lrn) <- c("Average learner", "Slow learner")
bwplot(Age ~ Days | Sex*Lrn*Eth, data = Quine)

bwplot(Age ~ Days | Sex*Lrn*Eth, data = Quine, layout = c(4, 2),
      strip = function(...) strip.default(..., style = 1))

stripplot(Age ~ Days | Sex*Lrn*Eth, data = Quine,
         jitter = TRUE, layout = c(4, 2))

stripplot(Age ~ Days | Eth*Sex, data = Quine,
   groups = Lrn, jitter = TRUE,
   panel = function(x, y, subscripts, jitter.data = F, ...) {
       if(jitter.data)  y <- jitter(as.numeric(y))
       panel.superpose(x, y, subscripts, ...)
   },
   xlab = "Days of absence",
   between = list(y = 1), par.strip.text = list(cex = 0.7),
   key = list(columns = 2, text = list(levels(Quine$Lrn)),
       points = Rows(trellis.par.get("superpose.symbol"), 1:2)
       ),
   strip = function(...)
        strip.default(..., strip.names = c(TRUE, TRUE), style = 1)
)

fgl0 <- fgl[ ,-10] # omit type.
fgl.df <- data.frame(type = rep(fgl$type, 9),
  y = as.vector(as.matrix(fgl0)),
  meas = factor(rep(1:9, each = 214), labels = names(fgl0)))
stripplot(type ~ y | meas, data = fgl.df,
  scales = list(x = "free"), xlab = "", cex = 0.5,
  strip = function(...) strip.default(style = 1, ...))

if(F) { # no data supplied
xyplot(ratio ~ scant | subject, data = A5,
      xlab = "scan interval (years)",
      ylab = "ventricle/brain volume normalized to 1 at start",
      subscripts = TRUE, ID = A5$ID,
      strip = function(factor, ...)
         strip.default(..., factor.levels = labs, style = 1),
      layout = c(8, 5, 1),
      skip = c(rep(FALSE, 37), rep(TRUE, 1), rep(FALSE, 1)),
      panel = function(x, y, subscripts, ID) {
          panel.xyplot(x, y, type = "b", cex = 0.5)
          which <- unique(ID[subscripts])
          panel.xyplot(c(0, 1.5), pr3[names(pr3) == which],
                       type = "l", lty = 3)
          if(which == 303 || which == 341) points(1.4, 1.3)
      })
}

Cath <- equal.count(swiss$Catholic, number = 6, overlap = 0.25)
xyplot(Fertility ~ Education | Cath, data = swiss,
  span = 1, layout = c(6, 1), aspect = 1,
  panel = function(x, y, span) {
     panel.xyplot(x, y); panel.loess(x, y, span)
  }
)

Cath2 <- equal.count(swiss$Catholic, number = 2, overlap = 0)
Agr <- equal.count(swiss$Agric, number = 3, overlap = 0.25)
xyplot(Fertility ~ Education | Agr * Cath2, data = swiss,
  span = 1, aspect = "xy",
  panel = function(x, y, span) {
     panel.xyplot(x, y); panel.loess(x, y, span)
  }
)

Cath
levels(Cath)
plot(Cath, aspect = 0.3)

# End of ch04
