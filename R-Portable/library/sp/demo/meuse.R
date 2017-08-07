require(sp)
crs = CRS("+init=epsg:28992")
data("meuse")
coordinates(meuse) <- ~x+y
proj4string(meuse) <- crs
data("meuse.grid")
coordinates(meuse.grid) <- ~x+y
gridded(meuse.grid) <- TRUE
proj4string(meuse.grid) <- crs
data("meuse.riv")
meuse.riv <- SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))
proj4string(meuse.riv) <- crs
data("meuse.area")
meuse.area = SpatialPolygons(list(Polygons(list(Polygon(meuse.area)), "area")))
proj4string(meuse.area) <- crs
