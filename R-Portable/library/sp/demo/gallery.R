library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

data(meuse)
coordinates(meuse)=~x+y

## coloured points plot with legend in plotting area and scales:
spplot(meuse, "zinc", do.log = TRUE,
	key.space=list(x=0.2,y=0.9,corner=c(0,1)),
	scales=list(draw=T))
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

data(meuse)
coordinates(meuse)=~x+y

## coloured points plot with legend in plotting area and scales;
## non-default number of cuts with user-supplied legend entries:
spplot(meuse, "zinc", do.log = TRUE,
	key.space=list(x=0.2,y=0.9,corner=c(0,1)),
	scales=list(draw=T), cuts = 3,
	legendEntries = c("low", "intermediate", "high"))
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

data(meuse)
coordinates(meuse)=~x+y

scale = list("SpatialPolygonsRescale", layout.scale.bar(), 
	offset = c(178600,332990), scale = 500, fill=c("transparent","black"))
text1 = list("sp.text", c(178600,333090), "0")
text2 = list("sp.text", c(179100,333090), "500 m")
arrow = list("SpatialPolygonsRescale", layout.north.arrow(), 
	offset = c(178750,332500), scale = 400)
## points plot with scale bar, scale bar text, north arrow and title:
spplot(meuse, "zinc", do.log=T,
	key.space=list(x=0.1,y=0.93,corner=c(0,1)),
	sp.layout=list(scale,text1,text2,arrow),
	main = "Zinc (top soil)")
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

data(meuse)
coordinates(meuse)=~x+y
data(meuse.riv)
meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))
rv = list("sp.polygons", meuse.sr, fill = "lightblue")

scale = list("SpatialPolygonsRescale", layout.scale.bar(), 
	offset = c(180500,329800), scale = 500, fill=c("transparent","black"), which = 1)
text1 = list("sp.text", c(180500,329900), "0", which = 1)
text2 = list("sp.text", c(181000,329900), "500 m", which = 1)
arrow = list("SpatialPolygonsRescale", layout.north.arrow(), 
	offset = c(178750,332500), scale = 400)
## plot with north arrow and text outside panels
## (scale can, as of yet, not be plotted outside panels)
spplot(meuse["zinc"], do.log = TRUE,
	key.space = "bottom", 
	sp.layout = list(rv, scale, text1, text2),
	main = "Zinc (top soil)",
	legend = list(right = list(fun = mapLegendGrob(layout.north.arrow()))))
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

data(meuse)
coordinates(meuse)=~x+y
data(meuse.riv)
meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))

## same plot; north arrow now inside panel, custom panel function instead of sp.layout
spplot(meuse, "zinc", panel = function(x, y, ...) {
		sp.polygons(meuse.sr, fill = "lightblue")
		SpatialPolygonsRescale(layout.scale.bar(), offset = c(179900,329600), 
			scale = 500, fill=c("transparent","black"))
		sp.text(c(179900,329700), "0")
		sp.text(c(180400,329700), "500 m")
		SpatialPolygonsRescale(layout.north.arrow(), 
			offset = c(178750,332500), scale = 400)
		panel.pointsplot(x, y, ...)
	},
	do.log = TRUE, cuts = 7,
	key.space = list(x = 0.1, y = 0.93, corner = c(0,1)),
	main = "Top soil zinc concentration (ppm)")
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

data(meuse)
coordinates(meuse)=~x+y
data(meuse.riv)
meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))
rv = list("sp.polygons", meuse.sr, fill = "lightblue")

## multi-panel plot, scales + north arrow only in last plot:
## using the "which" argument in a layout component
## (if which=4 was set as list component of sp.layout, the river
## would as well be drawn only in that (last) panel)
scale = list("SpatialPolygonsRescale", layout.scale.bar(), 
	offset = c(180500,329800), scale = 500, fill=c("transparent","black"), which = 4)
text1 = list("sp.text", c(180500,329900), "0", cex = .5, which = 4)
text2 = list("sp.text", c(181000,329900), "500 m", cex = .5, which = 4)
arrow = list("SpatialPolygonsRescale", layout.north.arrow(), 
	offset = c(181300,329800), 
	scale = 400, which = 4)
cuts = c(.2,.5,1,2,5,10,20,50,100,200,500,1000,2000)
spplot(meuse, c("cadmium", "copper", "lead", "zinc"), do.log = TRUE,
	key.space = "right", as.table = TRUE,
	sp.layout=list(rv, scale, text1, text2, arrow), # note that rv is up front!
	main = "Heavy metals (top soil), ppm", cex = .7, cuts = cuts)
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

alphaChannelSupported = function() { 
	!is.na(match(names(dev.cur()), c("pdf")))
}

data(meuse)
coordinates(meuse)=~x+y
data(meuse.riv)
meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))

rv = list("sp.polygons", meuse.sr, 
	fill = ifelse(alphaChannelSupported(), "blue", "transparent"),
	alpha = ifelse(alphaChannelSupported(), 0.1, 1))
pts = list("sp.points", meuse, pch = 3, col = "grey", 
	alpha = ifelse(alphaChannelSupported(), .5, 1))
text1 = list("sp.text", c(180500,329900), "0", cex = .5, which = 4)
text2 = list("sp.text", c(181000,329900), "500 m", cex = .5, which = 4)
scale = list("SpatialPolygonsRescale", layout.scale.bar(), 
	offset = c(180500,329800), scale = 500, fill=c("transparent","black"), which = 4)

library(gstat, pos = match(paste("package", "sp", sep=":"), search()) + 1)
data(meuse.grid)
coordinates(meuse.grid) = ~x+y
gridded(meuse.grid) = TRUE
v.ok = variogram(log(zinc)~1, meuse)
ok.model = fit.variogram(v.ok, vgm(1, "Exp", 500, 1))
# plot(v.ok, ok.model, main = "ordinary kriging")
v.uk = variogram(log(zinc)~sqrt(dist), meuse)
uk.model = fit.variogram(v.uk, vgm(1, "Exp", 300, 1))
# plot(v.uk, uk.model, main = "universal kriging")
meuse[["ff"]] = factor(meuse[["ffreq"]])
meuse.grid[["ff"]] = factor(meuse.grid[["ffreq"]])
v.sk = variogram(log(zinc)~ff, meuse)
sk.model = fit.variogram(v.sk, vgm(1, "Exp", 300, 1))
# plot(v.sk, sk.model, main = "stratified kriging")
zn.ok = krige(log(zinc)~1,          meuse, meuse.grid, model = ok.model)
zn.uk = krige(log(zinc)~sqrt(dist), meuse, meuse.grid, model = uk.model)
zn.sk = krige(log(zinc)~ff,         meuse, meuse.grid, model = sk.model)
zn.id = krige(log(zinc)~1,          meuse, meuse.grid)

zn = zn.ok
zn[["a"]] = zn.ok[["var1.pred"]]
zn[["b"]] = zn.uk[["var1.pred"]]
zn[["c"]] = zn.sk[["var1.pred"]]
zn[["d"]] = zn.id[["var1.pred"]]
spplot(zn, c("a", "b", "c", "d"), 
	names.attr = c("ordinary kriging", "universal kriging with dist to river", 
		"stratified kriging with flood freq", "inverse distance"), 
	as.table = TRUE, main = "log-zinc interpolation",
	sp.layout = list(rv, scale, text1, text2)
)
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

alphaChannelSupported = function() { 
	!is.na(match(names(dev.cur()), c("pdf")))
}

data(meuse)
coordinates(meuse)=~x+y
data(meuse.riv)
meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))
rv = list("sp.polygons", meuse.sr, fill = "lightblue")

scale = list("SpatialPolygonsRescale", layout.scale.bar(), 
	offset = c(180500,329800), scale = 500, fill=c("transparent","black"), which = 4)
text1 = list("sp.text", c(180500,329900), "0", cex = .5, which = 4)
text2 = list("sp.text", c(181000,329900), "500 m", cex = .5, which = 4)
arrow = list("SpatialPolygonsRescale", layout.north.arrow(), 
	offset = c(181300,329800), 
	scale = 400, which = 4)

library(gstat, pos = match(paste("package", "sp", sep=":"), search()) + 1)
data(meuse.grid)
coordinates(meuse.grid) = ~x+y
gridded(meuse.grid) = TRUE
v.ok = variogram(log(zinc)~1, meuse)
ok.model = fit.variogram(v.ok, vgm(1, "Exp", 500, 1))
# plot(v.ok, ok.model, main = "ordinary kriging")
v.uk = variogram(log(zinc)~sqrt(dist), meuse)
uk.model = fit.variogram(v.uk, vgm(1, "Exp", 300, 1))
# plot(v.uk, uk.model, main = "universal kriging")
meuse[["ff"]] = factor(meuse[["ffreq"]])
meuse.grid[["ff"]] = factor(meuse.grid[["ffreq"]])
v.sk = variogram(log(zinc)~ff, meuse)
sk.model = fit.variogram(v.sk, vgm(1, "Exp", 300, 1))
# plot(v.sk, sk.model, main = "stratified kriging")
zn.ok = krige(log(zinc)~1,          meuse, meuse.grid, model = ok.model)
zn.uk = krige(log(zinc)~sqrt(dist), meuse, meuse.grid, model = uk.model)
zn.sk = krige(log(zinc)~ff,         meuse, meuse.grid, model = sk.model)
zn.id = krige(log(zinc)~1,          meuse, meuse.grid)

rv = list("sp.polygons", meuse.sr, 
	fill = ifelse(alphaChannelSupported(), "blue", "transparent"),
	alpha = ifelse(alphaChannelSupported(), 0.1, 1))
pts = list("sp.points", meuse, pch = 3, col = "grey", 
	alpha = ifelse(alphaChannelSupported(), .7, 1))
spplot(zn.uk, "var1.pred",
	sp.layout = list(rv, scale, text1, text2, pts),
	main = "log(zinc); universal kriging using sqrt(dist to Meuse)")
zn.uk[["se"]] = sqrt(zn.uk[["var1.var"]])

## Universal kriging standard errors; grid plot with point locations
## and polygon (river), pdf has transparency on points and river
spplot(zn.uk, "se",
	sp.layout = list(rv, scale, text1, text2, pts),
	main = "log(zinc); universal kriging standard errors")

library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

# prepare nc sids data set:
library(maptools)
nc <- readShapePoly(system.file("shapes/sids.shp", package="maptools")[1], proj4string=CRS("+proj=longlat +datum=NAD27"))
arrow = list("SpatialPolygonsRescale", layout.north.arrow(),
    offset = c(-76,34), scale = 0.5, which = 2)
#scale = list("SpatialPolygonsRescale", layout.scale.bar(),
#    offset = c(-77.5,34), scale = 1, fill=c("transparent","black"), which = 2)
#text1 = list("sp.text", c(-77.5,34.15), "0", which = 2)
#text2 = list("sp.text", c(-76.5,34.15), "1 degree", which = 2)
## multi-panel plot with filled polygons: North Carolina SIDS
spplot(nc, c("SID74", "SID79"), names.attr = c("1974","1979"),
    colorkey=list(space="bottom"), scales = list(draw = TRUE),
    main = "SIDS (sudden infant death syndrome) in North Carolina",
    sp.layout = list(arrow), as.table = TRUE)

#    sp.layout = list(arrow, scale, text1, text2), as.table = TRUE)
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

arrow = list("SpatialPolygonsRescale", layout.north.arrow(), 
	offset = c(-76,34), scale = 0.5, which = 2)
#scale = list("SpatialPolygonsRescale", layout.scale.bar(), 
#	offset = c(-77.5,34), scale = 1, fill=c("transparent","black"), which = 2)
#text1 = list("sp.text", c(-77.5,34.15), "0", which = 2)
#text2 = list("sp.text", c(-76.5,34.15), "1 degree", which = 2)
# create a fake lines data set:
library(maptools)
ncl <- readShapeLines(system.file("shapes/sids.shp", package="maptools")[1], proj4string=CRS("+proj=longlat +datum=NAD27"))
## multi-panel plot with coloured lines: North Carolina SIDS
spplot(ncl, c("SID74","SID79"), names.attr = c("1974","1979"),
    colorkey=list(space="bottom"),
    main = "SIDS (sudden infant death syndrome) in North Carolina",
    sp.layout = arrow, as.table = TRUE)
library(sp)

data(meuse.grid)
coordinates(meuse.grid) = ~x+y
gridded(meuse.grid) = TRUE
data(meuse)
coordinates(meuse) = ~x+y
data(meuse.riv)
meuse.sl = SpatialLines(list(Lines(list(Line(meuse.riv)), "ID")))
#meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))

## image plot with points and lines
image(meuse.grid["dist"], 
	main = "meuse river data set; colour indicates distance to river")
points(meuse, pch = 3)
lines(meuse.sl)
library(sp)
library(lattice)

data(meuse)
coordinates(meuse) = ~x+y

## bubble plots for cadmium and zinc
data(meuse)
coordinates(meuse) <- c("x", "y") # promote to SpatialPointsDataFrame
b1 = bubble(meuse, "cadmium", maxsize = 1.5, main = "cadmium concentrations (ppm)",
	key.entries = 2^(-1:4))
b2 = bubble(meuse, "zinc", maxsize = 1.5, main = "zinc concentrations (ppm)",
	key.entries =  100 * 2^(0:4))
print(b1, split = c(1,1,2,1), more = TRUE)
print(b2, split = c(2,1,2,1), more = FALSE)
library(sp)

## plot for SpatialPolygons, with county name at label point
library(maptools)
nc2 <- readShapePoly(system.file("shapes/sids.shp", package="maptools")[1], proj4string=CRS("+proj=longlat +datum=NAD27"))
plot(nc2)
invisible(text(coordinates(nc2), labels=as.character(nc2$NAME), cex=0.4))
library(sp)

## plot of SpatialPolygonsDataFrame, using grey shades
library(maptools)
nc1 <- readShapePoly(system.file("shapes/sids.shp", package="maptools")[1], proj4string=CRS("+proj=longlat +datum=NAD27"))
names(nc1)
rrt <- nc1$SID74/nc1$BIR74
brks <- quantile(rrt, seq(0,1,1/7))
cols <- grey((length(brks):2)/length(brks))
dens <- (2:length(brks))*3
plot(nc1, col=cols[findInterval(rrt, brks, all.inside=TRUE)])
library(sp)

## plot of SpatialPolygonsDataFrame, using line densities
library(maptools)
nc <- readShapePoly(system.file("shapes/sids.shp", package="maptools")[1], proj4string=CRS("+proj=longlat +datum=NAD27"))
names(nc)
rrt <- nc$SID74/nc$BIR74
brks <- quantile(rrt, seq(0,1,1/7))
cols <- grey((length(brks):2)/length(brks))
dens <- (2:length(brks))*3
plot(nc, density=dens[findInterval(rrt, brks, all.inside=TRUE)])
library(sp)
data(meuse.riv)

meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)), "x")))
plot(meuse.sr)
## stratified sampling within a polygon
points(spsample(meuse.sr@polygons[[1]], n = 200, "stratified"), pch = 3, cex=.3)
## random sampling over a grid
library(sp)
data(meuse.grid)
gridded(meuse.grid) = ~x+y
image(meuse.grid)
points(spsample(meuse.grid,n=1000,type="random"), pch=3, cex=.4)
## regular sampling over a grid
library(sp)
data(meuse.grid)
gridded(meuse.grid) = ~x+y
image(meuse.grid["dist"])
points(spsample(meuse.grid,n=1000,type="regular"), pch=3, cex=.4)
## nonaligned systematic sampling over a grid
library(sp)
data(meuse.grid)
gridded(meuse.grid) = ~x+y
image(meuse.grid["dist"])
points(spsample(meuse.grid,n=1000,type="nonaligned"), pch=3, cex=.4)
library(sp)
library(lattice) # required for trellis.par.set():
trellis.par.set(sp.theme()) # sets color ramp to bpy.colors()

alphaChannelSupported = function() { 
	!is.na(match(names(dev.cur()), c("pdf")))
}

data(meuse)
coordinates(meuse)=~x+y
data(meuse.riv)
meuse.sr = SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)),"meuse.riv")))
rv = list("sp.polygons", meuse.sr, fill = "lightblue")

scale = list("SpatialPolygonsRescale", layout.scale.bar(), 
	offset = c(180500,329800), scale = 500, fill=c("transparent","black"), which = 4)
text1 = list("sp.text", c(180500,329900), "0", cex = .5, which = 4)
text2 = list("sp.text", c(181000,329900), "500 m", cex = .5, which = 4)
arrow = list("SpatialPolygonsRescale", layout.north.arrow(), 
	offset = c(181300,329800), 
	scale = 400, which = 4)

library(gstat, pos = match(paste("package", "sp", sep=":"), search()) + 1)
data(meuse.grid)
coordinates(meuse.grid) = ~x+y
gridded(meuse.grid) = TRUE
v.ok = variogram(log(zinc)~1, meuse)
ok.model = fit.variogram(v.ok, vgm(1, "Exp", 500, 1))
# plot(v.ok, ok.model, main = "ordinary kriging")
v.uk = variogram(log(zinc)~sqrt(dist), meuse)
uk.model = fit.variogram(v.uk, vgm(1, "Exp", 300, 1))
# plot(v.uk, uk.model, main = "universal kriging")
meuse[["ff"]] = factor(meuse[["ffreq"]])
meuse.grid[["ff"]] = factor(meuse.grid[["ffreq"]])
v.sk = variogram(log(zinc)~ff, meuse)
sk.model = fit.variogram(v.sk, vgm(1, "Exp", 300, 1))
# plot(v.sk, sk.model, main = "stratified kriging")
zn.ok = krige(log(zinc)~1,          meuse, meuse.grid, model = ok.model)
zn.uk = krige(log(zinc)~sqrt(dist), meuse, meuse.grid, model = uk.model)
zn.sk = krige(log(zinc)~ff,         meuse, meuse.grid, model = sk.model)
zn.id = krige(log(zinc)~1,          meuse, meuse.grid)

rv = list("sp.polygons", meuse.sr, 
	fill = ifelse(alphaChannelSupported(), "blue", "transparent"),
	alpha = ifelse(alphaChannelSupported(), 0.1, 1))
pts = list("sp.points", meuse, pch = 3, col = "grey", 
	alpha = ifelse(alphaChannelSupported(), .5, 1))
spplot(zn.uk, "var1.pred",
	sp.layout = list(rv, scale, text1, text2, pts),
	main = "log(zinc); universal kriging using sqrt(dist to Meuse)")
zn.uk[["se"]] = sqrt(zn.uk[["var1.var"]])

## Universal kriging standard errors; grid plot with point locations
## and polygon (river), pdf has transparency on points and river
spplot(zn.uk, "se",
	sp.layout = list(rv, scale, text1, text2, pts),
	main = "log(zinc); universal kriging standard errors")

library(sp)
library(maptools)

nc <- readShapePoly(system.file("shapes/sids.shp", package="maptools")[1], proj4string=CRS("+proj=longlat +datum=NAD27"))
names(nc)
# create two dummy factor variables, with equal labels:
set.seed(31)
nc$f = factor(sample(1:5,100,replace=T),labels=letters[1:5])
nc$g = factor(sample(1:5,100,replace=T),labels=letters[1:5])
library(RColorBrewer)
## Two (dummy) factor variables shown with qualitative colour ramp; degrees in axes
spplot(nc, c("f","g"), col.regions=brewer.pal(5, "Set3"), scales=list(draw = TRUE))
