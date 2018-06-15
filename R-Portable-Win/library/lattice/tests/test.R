postscript("test.ps")
library(lattice)

lattice.options(default.args =
                list(page = function(n) {
                    grid::grid.text(label = paste(deparse(trellis.last.object()$call, width.cutoff = 150L), collapse = "\n"),
                                    x = 0.01, y = 0.99, just = c("left", "top"))
                }))

densityplot(~ 5)
densityplot(~ 1:5 | letters[1:5])

x <- rnorm(200)
y <- rnorm(200)
z <- equal.count(rnorm(200))
a <- factor(rep(1:3, len = 200))

df.test <- list(xx = x+1-min(x), yy = y, zz = z, aa = a)

xyplot(y ~ x | z * a, strip = function(...) strip.default(..., style = 4),
       par.strip.text = list(cex = 2, col = "blue", font = 2),
       ##scales = list(x = list(draw = FALSE),  y = "sliced"))
       scales = list(x = list(rot = 0), y = list(rot = 0)))

xyplot(a ~ x | z,
       main = "xyplot call with modified options",
       lattice.options =
       list(panel.xyplot = "panel.bwplot",
            default.args = list(between = list(x = 1, y = 1))))




bwplot(zz ~ xx | aa, df.test)

bwplot(aa ~ xx | zz, df.test, 
       scales =
       list(x = list(log = "e", tck = 5, rot = 90,  cex = 2),
            y = list(col = "red", tck = 3, alternating = TRUE, cex = 5,  rot = 0),
            tick.number = 20),
       main = list("main", cex = 5),
       sub = list("sub", cex = 5),
       xlab = list("xlab", cex = 5),
       ylab = list("ylab", cex = 5))


bwplot(~zz , df.test)
bwplot(~xx , df.test)

dotplot(zz ~ xx | aa, df.test)
dotplot(aa ~ xx | zz, df.test)

dotplot(~zz , df.test)
dotplot(~xx , df.test)

stripplot(zz ~ xx | aa, df.test)
stripplot(aa ~ xx | zz, df.test)
stripplot(~zz , df.test)
stripplot(~xx , df.test)



xa <- 1:8
xb <- rep( c( NA, 10 ), 4 )

xc <- rep( c( 'C2', 'C1' ), 4 )
xyplot( xa ~ xb | xc)
xyplot( xa ~ xb | xc, scales = "free")

xc <- rep( c( 'C1', 'C2' ), 4 )
xyplot( xa ~ xb | xc)
xyplot( xa ~ xb | xc, scales = "free")

x = sample(1:3, 100, replace=TRUE)
histogram( ~ x, breaks=c(0,1.5,2.5,3.5), type='count')
histogram( ~ x, breaks=c(0,1.5,2.5,3.5), type='density')


## splom pscales

data(iris)
iris2 <- iris[,1:4]

splom(iris2, groups = iris$Species,
      pscales = 10)

splom(iris2, groups = iris$Species,
      pscales = list(list(at = 6, lab = "six"), list(at = 3), list(at = 4), list(at = 1)))

splom(iris2, groups = iris$Species,
      pscales = list(list(at = 6, lab = "six", limits = c(-10, 10)),
      list(at = 3), list(at = 4), list(limits = c(-5, 5))))


## factors in formula

data(barley)
levelplot(yield ~ year * variety | site, barley,
          panel = function(x, y, ...) {
              x <- as.numeric(x)
              y <- as.numeric(y)
              panel.levelplot(x, y, ...)
          })


data(volcano)
levelplot(volcano, key = list(x = .5, y = .5, points = list(col = 1:3)),
          legend = list(top = list(fun = grid::textGrob("This \nis \na \nstupid \nlegend"))))


## demo of seekViewport

library(grid)

splom(~iris[1:3]|Species, data = iris, 
      layout=c(2,2), pscales = 0,
      varnames = c("Sepal\nLength", "Sepal\nWidth", "Petal\nLength"),
      page = function(...) {
          ltext(x = seq(.6, .8, len = 4), 
                y = seq(.9, .6, len = 4), 
                lab = c("Three", "Varieties", "of", "Iris"),
                cex = 2)
      }, par.settings = list(clip = list(panel = FALSE)))

seekViewport(vpPath(trellis.vpname("panel", 1, 1), "pairs", "subpanel.2.3"))
grid.yaxis(main = TRUE)

seekViewport(vpPath(trellis.vpname("panel", 2, 1), "pairs", "subpanel.2.1"))
grid.yaxis(main = FALSE)

seekViewport(vpPath(trellis.vpname("panel", 1, 2), "pairs", "subpanel.2.2"))
grid.yaxis(main = FALSE)

demo("lattice")
dev.off()


