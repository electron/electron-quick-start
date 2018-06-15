pdf("fontsize.pdf", pointsize = 5)
library(lattice)

splom(iris, sub = "fontsize : 5")

trellis.par.set(grid.pars = list(fontsize = 10))
splom(iris, sub = "fontsize : 10")

trellis.par.set(fontsize = list(text = 15))
splom(iris, sub = "fontsize : 15")




