
postscript("levelplot.ps")
library(lattice)

data(volcano)

foo <-
    data.frame(z = as.vector(volcano),
               x = rep(1:87, 61),
               y = rep(1:61, each = 87))

levelplot(z ~ x * y, subset(foo, z > 150), contour = T)
levelplot(z ~ x * y, foo, subset = z > 150, contour = T)
contourplot(z ~ x * y, foo, subset = z > 150, cuts = 10)

## subset group interaction has problems (does it any longer):

cloud(Sepal.Length ~ Petal.Length * Petal.Width, 
      data = iris, cex = 0.8, groups = Species, subpanel = panel.superpose, 
      main = "Stereo", screen = list(z = 20, x = -70, y = 0), subset = 30:60)

cloud(Sepal.Length ~ Petal.Length * Petal.Width, 
      data = iris[30:60, ], cex = 0.8, groups = Species, subpanel = panel.superpose, 
      main = "Stereo", screen = list(z = 20, x = -70, y = 0))


levelplot(Sepal.Length ~ Petal.Length * Petal.Width, 
          data = iris, groups = Species, 
          subset = 30:60)




cloud(z ~ x * y, foo)
cloud(z ~ x * y, foo, subset = z > 150)



## long format: NA's clipped at the beginning (??)

splom(~iris[,1:4], iris, groups = Species)
splom(~iris[,1:4], iris, groups = Species, subset = 70:130, auto.key = T)

parallel(~iris[,1:4] | Species, iris, subset = 30:130)

## NA-s in matrix

volna <- volcano
volna[20:40, 20:40] <- NA
levelplot(volna)
cloud(volna)
wireframe(volna)



dev.off()




# grid.newpage()
# pushViewport(viewport())
# grid.lines(x = c(1:5, NA, 7:10) / 10,
#            y = c(1:5, NA, 7:10) / 10)

# grid.points(x = c(1:5, NA, 7:10) / 10,
#             y = c(1:5, 6, 7:10) / 10)




# grid.points(x = .5, y = .1, pch = 16, gp = gpar(cex  = 1))
# grid.points(x = .5, y = .2, pch = 16, gp = gpar(cex  = 3))

# grid.points(x = .5, y = .3, pch = '+', gp = gpar(cex  = 1))
# grid.points(x = .5, y = .4, pch = '+', gp = gpar(cex  = 3))




# viewport[ROOT] ->

#     (viewport[GRIDVP1182]->

#      (viewport[GRIDVP1185],
#       viewport[GRIDVP1187],
#       viewport[GRIDVP1189],
#       viewport[GRIDVP1190],

#       viewport[panel.1]->

#       (viewport[GRIDVP1184]->
       
#        (viewport[subpanel.1.1],
#         viewport[subpanel.1.2], viewport[subpanel.1.3],
#         viewport[subpanel.2.1], viewport[subpanel.2.2],
#         viewport[subpanel.2.3], viewport[subpanel.3.1],
#         viewport[subpanel.3.2], viewport[subpanel.3.3])),

#       viewport[panel.2]->
#       (viewport[GRIDVP1186]->
#        (viewport[subpanel.1.1],
#         viewport[subpanel.1.2], viewport[subpanel.1.3],
#         viewport[subpanel.2.1], viewport[subpanel.2.2],
#         viewport[subpanel.2.3], viewport[subpanel.3.1],
#         viewport[subpanel.3.2], viewport[subpanel.3.3])),

#       viewport[panel.3]->
#       (viewport[GRIDVP1188]->
#        (viewport[subpanel.1.1],
#         viewport[subpanel.1.2], viewport[subpanel.1.3],
#         viewport[subpanel.2.1], viewport[subpanel.2.2],
#         viewport[subpanel.2.3], viewport[subpanel.3.1],
#         viewport[subpanel.3.2], viewport[subpanel.3.3]))))

