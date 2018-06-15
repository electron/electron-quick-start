# polar projection with map:
library(maps)
m = map(xlim = c(-180,180), ylim = c(-90,-70), plot = FALSE, fill = TRUE)
IDs <- sapply(strsplit(m$names, ":"), function(x) x[1])
library(maptools)
m <- map2SpatialPolygons(m, IDs=IDs, proj4string = CRS("+init=epsg:4326"))
polar = CRS("+init=epsg:3031")
gl = spTransform(gridlines(m, easts = seq(-180,180,20)), polar)
plot(gl)
plot(spTransform(m, polar), add = TRUE, col = grey(0.8, 0.8))
l = labels(gl, CRS("+init=epsg:4326"), side = 3)
# pos is too simple here, use adj:
l$pos = NULL 
text(l, adj = c(0.5, -0.3), cex = .85)
l = labels(gl, CRS("+init=epsg:4326"), side = 2)
l$srt = 0 # otherwise they are upside-down
text(l, cex = .85)
title("grid line labels on polar projection, epsg 3031")
