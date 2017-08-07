### R code from vignette source 'csdacm.Rnw'

###################################################
### code chunk number 1: csdacm.Rnw:53-56
###################################################
owidth <- getOption("width")
options("width"=90)
.PngNo <- 0


###################################################
### code chunk number 2: figreset (eval = FALSE)
###################################################
## .iwidth <- 5
## .iheight <- 6
## .ipointsize <- 12


###################################################
### code chunk number 3: csdacm.Rnw:65-66
###################################################
.iwidth <- 5
.iheight <- 6
.ipointsize <- 12


###################################################
### code chunk number 4: afig (eval = FALSE)
###################################################
## .PngNo <- .PngNo + 1; file <- paste("Fig-bitmap-", .PngNo, ".pdf", sep="")
## pdf(file=file, width = .iwidth, height = .iheight, pointsize = .ipointsize)
## opar <- par(mar=c(3,3,1,1)+0.1)


###################################################
### code chunk number 5: zfig (eval = FALSE)
###################################################
## dev.null <- dev.off()
## cat("\\includegraphics[width=0.95\\textwidth]{", file, "}\n\n", sep="")


###################################################
### code chunk number 6: csdacm.Rnw:109-112
###################################################
myfun <- function(x) {
	x + 2
}


###################################################
### code chunk number 7: csdacm.Rnw:117-118
###################################################
myfun(1:3)


###################################################
### code chunk number 8: csdacm.Rnw:123-124
###################################################
myfun(x=1:3)


###################################################
### code chunk number 9: csdacm.Rnw:130-133
###################################################
plotXplus2Yminus3 <- function(x, y, ...) {
	plot(x = x + 2, y = y - 3, ...)
}


###################################################
### code chunk number 10: csdacm.Rnw:146-147
###################################################
methods("plot")


###################################################
### code chunk number 11: csdacm.Rnw:152-154
###################################################
library(sp)
showMethods("plot")


###################################################
### code chunk number 12: csdacm.Rnw:165-168
###################################################
x <- rnorm(10)
class(x) <- "foo"
x


###################################################
### code chunk number 13: csdacm.Rnw:177-180
###################################################
plot.foo <- function(x, y, ...) {
	plot.default(x, type = 'l', ...)
}


###################################################
### code chunk number 14: csdacm.Rnw:189-190
###################################################
class(x) <- c("foo", "bar")


###################################################
### code chunk number 15: csdacm.Rnw:192-193 (eval = FALSE)
###################################################
## plot(x)


###################################################
### code chunk number 16: csdacm.Rnw:204-207
###################################################
data(meuse)
class(meuse)
class(lm(log(zinc)~sqrt(dist), meuse))


###################################################
### code chunk number 17: csdacm.Rnw:226-227
###################################################
options("width"=60)


###################################################
### code chunk number 18: csdacm.Rnw:229-249 (eval = FALSE)
###################################################
## setClass("CRS", representation(projargs = "character"))
## setClass("Spatial",
##     representation(bbox = "matrix", proj4string = "CRS"),
## # NOT TOO WIDE
##     validity <- function(object) {
##         bb <- bbox(object)
##         if (!is.matrix(bb))
##             return("bbox should be a matrix")
##         n <- dimensions(object)
##         if (n < 2)
##             return("spatial.dimension should be 2 or more")
##         if (any(is.na(bb)))
##             return("bbox should never contain NA values")
##         if (any(!is.finite(bb)))
##             return("bbox should never contain infinite values")
##         if (any(bb[,"max"] < bb[,"min"]))
##             return("invalid bbox: max < min")
## 		TRUE
## 	}
## )


###################################################
### code chunk number 19: csdacm.Rnw:251-252
###################################################
options("width"=70)


###################################################
### code chunk number 20: csdacm.Rnw:264-265
###################################################
isGeneric("show")


###################################################
### code chunk number 21: csdacm.Rnw:271-273 (eval = FALSE)
###################################################
## setGeneric("bbox", function(obj) standardGeneric("bbox"))
## setMethod("bbox", signature = "Spatial", function(obj) obj@bbox)


###################################################
### code chunk number 22: csdacm.Rnw:304-315
###################################################
library(sp)
setClass("trip", representation("SpatialPointsDataFrame", TOR.columns = "character"),
    validity <- function(object) {
        if (length(object@TOR.columns) != 2)
            stop("Time/id column names must be of length 2")
		if (!all(object@TOR.columns %in% names(object@data)))
			stop("Time/id columns must be present in attribute table")
        TRUE
    }
)
showClass("trip")


###################################################
### code chunk number 23: csdacm.Rnw:328-341
###################################################
trip.default <- function(obj, TORnames) {
    if (!is(obj, "SpatialPointsDataFrame"))
        stop("trip only supports SpatialPointsDataFrame") 
	if (is.numeric(TORnames))
		TORnames <- names(obj)[TORnames]
    new("trip", obj, TOR.columns = TORnames)
}

if (!isGeneric("trip"))
    setGeneric("trip", function(obj, TORnames)
        standardGeneric("trip"))

setMethod("trip", signature(obj = "SpatialPointsDataFrame", TORnames = "ANY"), trip.default)


###################################################
### code chunk number 24: csdacm.Rnw:348-349
###################################################
turtle <- read.csv(system.file("external/seamap105_mod.csv", package="sp"))


###################################################
### code chunk number 25: csdacm.Rnw:351-360
###################################################
timestamp <- as.POSIXlt(strptime(as.character(turtle$obs_date), "%m/%d/%Y %H:%M:%S"), "GMT")
turtle <- data.frame(turtle, timestamp = timestamp)
turtle$lon <- ifelse(turtle$lon < 0, turtle$lon+360, turtle$lon)
turtle <- turtle[order(turtle$timestamp),]
coordinates(turtle) <- c("lon", "lat")
proj4string(turtle) <- CRS("+proj=longlat +ellps=WGS84")
turtle$id <- c(rep(1, 200), rep(2, nrow(coordinates(turtle)) - 200))
turtle_trip <- trip(turtle, c("timestamp", "id"))
summary(turtle_trip)


###################################################
### code chunk number 26: csdacm.Rnw:372-382
###################################################
summary.trip <- function(object, ...) {
	cat("Object of class \"trip\"\nTime column: ")
	print(object@TOR.columns[1])
	cat("Identifier column: ")
	print(object@TOR.columns[2])
	print(summary(as(object, "Spatial")))
	print(summary(object@data))
}
setMethod("summary", "trip", summary.trip)
summary(turtle_trip)


###################################################
### code chunk number 27: csdacm.Rnw:400-415
###################################################
setGeneric("lines", function(x, ...) standardGeneric("lines"))
setMethod("lines", signature(x = "trip"),
    function(x, ..., col = NULL) {
# NOT TOO WIDE
	tor <- x@TOR.columns
	if (is.null(col)) {
	  l <- length(unique(x[[tor[2]]]))
          col <- hsv(seq(0, 0.5, length = l))
	}
        coords <- coordinates(x)
        lx <- split(1:nrow(coords), x[[tor[2]]])
        for (i in 1:length(lx))
        	lines(coords[lx[[i]], ], col = col[i], ...)
    }
)


###################################################
### code chunk number 28: csdacm.Rnw:436-437
###################################################
options("width"=50)


###################################################
### code chunk number 29: csdacm.Rnw:439-448
###################################################
setClass("SpatialMultiPoints", representation("SpatialLines"), 
	validity <- function(object) {
		if (any(unlist(lapply(object@lines, function(x) length(x@Lines))) != 1))
# NOT TOO WIDE
			stop("Only Lines objects with one Line element")
		TRUE
	}
)
SpatialMultiPoints <- function(object) new("SpatialMultiPoints", object)


###################################################
### code chunk number 30: csdacm.Rnw:450-451
###################################################
options("width"=70)


###################################################
### code chunk number 31: csdacm.Rnw:458-468
###################################################
n <- 5
set.seed(1)
x1 <- cbind(rnorm(n),rnorm(n, 0, 0.25))
x2 <- cbind(rnorm(n),rnorm(n, 0, 0.25))
x3 <- cbind(rnorm(n),rnorm(n, 0, 0.25))
L1 <- Lines(list(Line(x1)), ID="mp1")
L2 <- Lines(list(Line(x2)), ID="mp2")
L3 <- Lines(list(Line(x3)), ID="mp3")
s <- SpatialLines(list(L1,L2,L3))
smp <- SpatialMultiPoints(s)


###################################################
### code chunk number 32: csdacm.Rnw:477-491
###################################################
plot.SpatialMultiPoints <- function(x, ..., pch = 1:length(x@lines), col = 1, cex = 1) {
	n <- length(x@lines)
	if (length(pch) < n)
		pch <- rep(pch, length.out = n)
	if (length(col) < n)
		col <- rep(col, length.out = n)
	if (length(cex) < n)
		cex <- rep(cex, length.out = n)
	plot(as(x, "Spatial"),  ...)
	for (i in 1:n)
		points(x@lines[[i]]@Lines[[1]]@coords, pch = pch[i], col = col[i], cex = cex[i])
}
setMethod("plot", signature(x = "SpatialMultiPoints", y = "missing"),
    function(x, y, ...) plot.SpatialMultiPoints(x, ...))


###################################################
### code chunk number 33: csdacm.Rnw:513-525
###################################################
cName <- "SpatialMultiPointsDataFrame"
setClass(cName, representation("SpatialLinesDataFrame"), 
	validity <- function(object) {
                lst <- lapply(object@lines, function(x) length(x@Lines))
		if (any(unlist(lst) != 1))
			stop("Only Lines objects with single Line")
		TRUE
	}
)
SpatialMultiPointsDataFrame <- function(object) {
   new("SpatialMultiPointsDataFrame", object)
}


###################################################
### code chunk number 34: csdacm.Rnw:531-536
###################################################
df <- data.frame(x1 = 1:3, x2 = c(1,4,2), row.names = c("mp1", "mp2", "mp3"))
smp_df <- SpatialMultiPointsDataFrame(SpatialLinesDataFrame(smp, df))
setMethod("plot", signature(x = "SpatialMultiPointsDataFrame", y = "missing"),
    function(x, y, ...) plot.SpatialMultiPoints(x, ...))
grys <- c("grey10", "grey40", "grey80")


###################################################
### code chunk number 35: csdacm.Rnw:538-539 (eval = FALSE)
###################################################
## plot(smp_df, col = grys[smp_df[["x1"]]], pch = smp_df[["x2"]], cex = 2, axes = TRUE) 


###################################################
### code chunk number 36: csdacm.Rnw:546-553
###################################################
.iwidth <- 6
.iheight <- 2.5
.ipointsize <- 10
.PngNo <- .PngNo + 1; file <- paste("Fig-bitmap-", .PngNo, ".pdf", sep="")
pdf(file=file, width = .iwidth, height = .iheight, pointsize = .ipointsize)
opar <- par(mar=c(3,3,1,1)+0.1)
plot(smp_df, col = grys[smp_df[["x1"]]], pch = smp_df[["x2"]], cex = 2, axes = TRUE) 
dev.null <- dev.off()
cat("\\includegraphics[width=0.95\\textwidth]{", file, "}\n\n", sep="")
.iwidth <- 5
.iheight <- 6
.ipointsize <- 12


###################################################
### code chunk number 37: csdacm.Rnw:569-573
###################################################
data(meuse.grid)
gridded(meuse.grid)=~x+y
xx <- spsample(meuse.grid,  type="hexagonal", cellsize=200)
class(xx)


###################################################
### code chunk number 38: csdacm.Rnw:581-582
###################################################
HexPts <- spsample(meuse.grid,  type="hexagonal", cellsize=200)


###################################################
### code chunk number 39: csdacm.Rnw:584-585 (eval = FALSE)
###################################################
## spplot(meuse.grid["dist"], sp.layout = list("sp.points", HexPts, col = 1))


###################################################
### code chunk number 40: csdacm.Rnw:587-590
###################################################
HexPols <- HexPoints2SpatialPolygons(HexPts)
df <- over(HexPols, meuse.grid)
HexPolsDf <- SpatialPolygonsDataFrame(HexPols, df, match.ID = FALSE)


###################################################
### code chunk number 41: csdacm.Rnw:592-593 (eval = FALSE)
###################################################
## spplot(HexPolsDf["dist"])


###################################################
### code chunk number 42: csdacm.Rnw:599-611
###################################################
.iwidth <- 6
.iheight <- 4
.PngNo <- .PngNo + 1; file <- paste("Fig-bitmap-", .PngNo, ".pdf", sep="")
pdf(file=file, width = .iwidth, height = .iheight, pointsize = .ipointsize)
opar <- par(mar=c(3,3,1,1)+0.1)
library(lattice)
# RSB quietening greys
grys <- grey.colors(11, 0.95, 0.55, 2.2)
print(spplot(meuse.grid["dist"], cuts=10, col.regions=grys, sp.layout = list("sp.points", HexPts, col = 1)),
	split = c(1, 1, 2, 1), more = TRUE)
print(spplot(HexPolsDf["dist"], cuts=10, col.regions=grys),
	split = c(2, 1, 2, 1), more = FALSE)
dev.null <- dev.off()
cat("\\includegraphics[width=0.95\\textwidth]{", file, "}\n\n", sep="")
.iwidth <- 5
.iheight <- 6
.ipointsize <- 12


###################################################
### code chunk number 43: csdacm.Rnw:624-631
###################################################
setClass("SpatialHexGrid", representation("SpatialPoints", dx = "numeric"),
	validity <- function(object) {
		if (object@dx <= 0)
			stop("dx should be positive")
		TRUE
	}
)


###################################################
### code chunk number 44: csdacm.Rnw:633-634
###################################################
options("width"=40)


###################################################
### code chunk number 45: csdacm.Rnw:636-644
###################################################
setClass("SpatialHexGridDataFrame", representation("SpatialPointsDataFrame", dx = "numeric"),
# NOT TOO WIDE
	validity <- function(object) {
		if (object@dx <= 0)
			stop("dx should be positive")
		TRUE
	}
)


###################################################
### code chunk number 46: csdacm.Rnw:646-647
###################################################
options("width"=70)


###################################################
### code chunk number 47: csdacm.Rnw:664-669
###################################################
HexPts <- spsample(meuse.grid,  type="hexagonal", cellsize=200)
Hex <- new("SpatialHexGrid", HexPts, dx = 200)
df <- over(Hex, meuse.grid)
spdf <- SpatialPointsDataFrame(HexPts, df)
HexDf <- new("SpatialHexGridDataFrame", spdf, dx = 200)


###################################################
### code chunk number 48: csdacm.Rnw:676-679
###################################################
is(HexDf, "SpatialHexGrid")
setIs("SpatialHexGridDataFrame", "SpatialHexGrid")
is(HexDf, "SpatialHexGrid")


###################################################
### code chunk number 49: csdacm.Rnw:689-690
###################################################
options("width"=50)


###################################################
### code chunk number 50: csdacm.Rnw:692-701
###################################################
# NOT TOO WIDE
setAs("SpatialHexGrid", "SpatialPolygons", 
	function(from) 
		HexPoints2SpatialPolygons(from, from@dx)
)
setAs("SpatialHexGridDataFrame", "SpatialPolygonsDataFrame", 
	function(from)
		SpatialPolygonsDataFrame(as(obj, "SpatialPolygons"), obj@data, match.ID = FALSE)
)


###################################################
### code chunk number 51: csdacm.Rnw:703-704
###################################################
options("width"=70)


###################################################
### code chunk number 52: csdacm.Rnw:711-724
###################################################
setMethod("plot", signature(x = "SpatialHexGrid", y = "missing"),
    function(x, y, ...) plot(as(x, "SpatialPolygons"), ...)
)
setMethod("spplot", signature(obj = "SpatialHexGridDataFrame"),
    function(obj, ...)
		spplot(SpatialPolygonsDataFrame( as(obj, "SpatialPolygons"), obj@data, match.ID = FALSE), ...)
)
setMethod("spsample", "SpatialHexGrid", function(x, n, type, ...) 
	spsample(as(x, "SpatialPolygons"), n = n, type = type, ...)
)
setMethod("over", c("SpatialHexGrid", "SpatialPoints"), function(x, y, ...) 
	over(as(x, "SpatialPolygons"), y)
)


###################################################
### code chunk number 53: csdacm.Rnw:730-732 (eval = FALSE)
###################################################
## spplot(meuse.grid["dist"], sp.layout = list("sp.points", Hex, col = 1))
## spplot(HexDf["dist"])


###################################################
### code chunk number 54: csdacm.Rnw:739-740 (eval = FALSE)
###################################################
## as(HexDf, "data.frame")


###################################################
### code chunk number 55: csdacm.Rnw:747-749
###################################################
bbox(Hex)
bbox(as(Hex, "SpatialPolygons"))


###################################################
### code chunk number 56: csdacm.Rnw:770-776
###################################################
n <- 10
x <- data.frame(expand.grid(x1 = 1:n, x2 = 1:n, x3 = 1:n), z = rnorm(n^3))
coordinates(x) <- ~x1+x2+x3
gridded(x) <- TRUE
fullgrid(x) <- TRUE
summary(x)


###################################################
### code chunk number 57: csdacm.Rnw:791-792
###################################################
options("width"=50)


###################################################
### code chunk number 58: csdacm.Rnw:794-801
###################################################
# NOT TOO WIDE
setClass("SpatialTimeGrid", "SpatialGrid",
	validity <- function(object) {
		stopifnot(dimensions(object) == 3)
		TRUE
	}
)


###################################################
### code chunk number 59: csdacm.Rnw:803-804
###################################################
options("width"=70)


###################################################
### code chunk number 60: csdacm.Rnw:811-819
###################################################
setClass("SpatialTimeGridDataFrame", "SpatialGridDataFrame",
	validity <- function(object) {
		stopifnot(dimensions(object) == 3)
		TRUE
	}
)
setIs("SpatialTimeGridDataFrame", "SpatialTimeGrid")
x <- new("SpatialTimeGridDataFrame", x)


###################################################
### code chunk number 61: csdacm.Rnw:824-835
###################################################
summary.SpatialTimeGridDataFrame <- function(object, ...) {
	cat("Object of class SpatialTimeGridDataFrame\n")
	x <- gridparameters(object)
	t0 <- ISOdate(1970,1,1,0,0,0)
	t1 <- t0 + x[3,1]
	cat(paste("first time step:", t1, "\n"))
	t2 <- t0 + x[3,1] + (x[3,3] - 1) * x[3,2]
	cat(paste("last time step: ", t2, "\n"))
	cat(paste("time step:      ", x[3,2], "\n"))
	summary(as(object, "SpatialGridDataFrame"))
}


###################################################
### code chunk number 62: csdacm.Rnw:837-838
###################################################
options("width"=50)


###################################################
### code chunk number 63: csdacm.Rnw:840-843
###################################################
# NOT TOO WIDE
setMethod("summary", "SpatialTimeGridDataFrame", summary.SpatialTimeGridDataFrame)
summary(x)


###################################################
### code chunk number 64: csdacm.Rnw:845-846
###################################################
options("width"=70)


###################################################
### code chunk number 65: csdacm.Rnw:853-880
###################################################
subs.SpatialTimeGridDataFrame <- function(x, i, j, ..., drop=FALSE) {
	t <- coordinates(x)[,3] + ISOdate(1970,1,1,0,0,0)
	if (missing(j))
		j <- TRUE
	sel <- t %in% i
	if (! any(sel))
		stop("selection results in empty set")
	fullgrid(x) <- FALSE
	if (length(i) > 1) {
		x <- x[i = sel, j = j,...]
		fullgrid(x) <- TRUE
		as(x, "SpatialTimeGridDataFrame")
	} else {
		gridded(x) <- FALSE
		x <- x[i = sel, j = j,...]
		cc <- coordinates(x)[,1:2]
		p4s <- CRS(proj4string(x))
# NOT TOO WIDE
		SpatialPixelsDataFrame(cc, x@data, proj4string = p4s)
	}
}
setMethod("[", c("SpatialTimeGridDataFrame", "POSIXct", "ANY"), 
	subs.SpatialTimeGridDataFrame)
t1 <- as.POSIXct("1970-01-01 0:00:03", tz = "GMT")
t2 <- as.POSIXct("1970-01-01 0:00:05", tz = "GMT")
summary(x[c(t1,t2)])
summary(x[t1])


###################################################
### code chunk number 66: csdacm.Rnw:893-906
###################################################
spplot.stgdf <- function(obj, zcol = 1, ..., format = NULL) {
# NOT TOO WIDE
	if (length(zcol) != 1)
		stop("can only plot a single attribute")
	if (is.null(format)) format <- "%Y-%m-%d %H:%M:%S"
	cc <- coordinates(obj)
	df <- unstack(data.frame(obj[[zcol]], cc[,3]))
	ns <- as.character(coordinatevalues(getGridTopology(obj))[[3]] + ISOdate(1970,1,1,0,0,0), format = format)
	cc2d <- cc[cc[,3] == min(cc[,3]), 1:2]
	obj <- SpatialPixelsDataFrame(cc2d, df)
	spplot(obj, names.attr = ns,...)
}
setMethod("spplot", "SpatialTimeGridDataFrame", spplot.stgdf)


###################################################
### code chunk number 67: csdacm.Rnw:912-918
###################################################
.iwidth <- 6
.iheight <- 4
.PngNo <- .PngNo + 1; file <- paste("Fig-bitmap-", .PngNo, ".pdf", sep="")
pdf(file=file, width = .iwidth, height = .iheight, pointsize = .ipointsize)
opar <- par(mar=c(3,3,1,1)+0.1)
print(spplot(x, format = "%H:%M:%S", as.table=TRUE))
dev.null <- dev.off()
cat("\\includegraphics[width=0.95\\textwidth]{", file, "}\n\n", sep="")
.iwidth <- 5
.iheight <- 6
.ipointsize <- 12


###################################################
### code chunk number 68: csdacm.Rnw:927-932 (eval = FALSE)
###################################################
## library(lattice)
## trellis.par.set(canonical.theme(color = FALSE))
## spplot(x, format = "%H:%M:%S", as.table=TRUE, cuts=6,
##  col.regions=grey.colors(7, 0.55, 0.95, 2.2)) 
## # RSB quietening greys


###################################################
### code chunk number 69: csdacm.Rnw:938-939 (eval = FALSE)
###################################################
## ?as.character.POSIXt


###################################################
### code chunk number 70: csdacm.Rnw:963-969
###################################################
library(gstat)
data(meuse)
coordinates(meuse) <- ~x+y
v <- vgm(.5, "Sph", 800, .05)
sim <- krige(log(zinc)~1, meuse, meuse.grid, v, nsim=100, nmax=30)
sim@data <- exp(sim@data)


###################################################
### code chunk number 71: csdacm.Rnw:977-981
###################################################
quantile.Spatial <- function(x, ..., byLayer = FALSE) {
	stopifnot("data" %in% slotNames(x))
	apply(x@data, ifelse(byLayer, 2, 1), quantile, ...)
}


###################################################
### code chunk number 72: csdacm.Rnw:987-989
###################################################
sim$lower <- quantile.Spatial(sim[1:100], probs = 0.025)
sim$upper <- quantile.Spatial(sim[1:100], probs = 0.975)


###################################################
### code chunk number 73: csdacm.Rnw:996-997
###################################################
medians <- quantile.Spatial(sim[1:100], probs = 0.5, byLayer = TRUE)


###################################################
### code chunk number 74: csdacm.Rnw:999-1000 (eval = FALSE)
###################################################
## hist(medians)


###################################################
### code chunk number 75: csdacm.Rnw:1014-1015
###################################################
options("width"=50)


###################################################
### code chunk number 76: csdacm.Rnw:1017-1022
###################################################
fractionBelow <- function(x, q, byLayer = FALSE) {
	stopifnot(is(x, "Spatial") || !("data" %in% slotNames(x)))
	apply(x@data < q, ifelse(byLayer, 2, 1), function(r) sum(r)/length(r))
# NOT TOO WIDE
}


###################################################
### code chunk number 77: csdacm.Rnw:1024-1025
###################################################
options("width"=70)


###################################################
### code chunk number 78: csdacm.Rnw:1027-1030
###################################################
over500 <- 1 - fractionBelow(sim[1:100], 200, byLayer = TRUE)
summary(over500)
quantile(over500, c(0.025, 0.975))


###################################################
### code chunk number 79: csdacm.Rnw:1047-1048
###################################################
fn <- system.file("pictures/erdas_spnad83.tif", package = "rgdal")[1]


###################################################
### code chunk number 80: csdacm.Rnw:1050-1053 (eval = FALSE)
###################################################
## x <- readGDAL(fn, output.dim = c(120, 132))
## x$band1[x$band1 <= 0] <- NA
## spplot(x, col.regions=bpy.colors())


###################################################
### code chunk number 81: csdacm.Rnw:1064-1070
###################################################
library(rgdal)
x <- GDAL.open(fn)
class(x)
x.subs <- x[1:100, 1:100, 1]
class(x.subs)
gridparameters(x.subs)


###################################################
### code chunk number 82: csdacm.Rnw:1088-1089
###################################################
options("width"=50)


###################################################
### code chunk number 83: csdacm.Rnw:1091-1096
###################################################
setClass("SpatialGDAL",
    representation("Spatial", grid = "GridTopology", grod = "GDALReadOnlyDataset", 
# NOT TOO WIDE
		name = "character"))
setClass("SpatialGDALWrite", "SpatialGDAL")


###################################################
### code chunk number 84: csdacm.Rnw:1098-1099
###################################################
options("width"=70)


###################################################
### code chunk number 85: csdacm.Rnw:1110-1126 (eval = FALSE)
###################################################
## x <- open.SpatialGDAL(fn)
## nrows <- GDALinfo(fn)["rows"]
## ncols <- GDALinfo(fn)["columns"]
## xout <- copy.SpatialGDAL(x, "erdas_spnad83_out.tif")
## bls <- 20
## for (i in 1:(nrows/bls - 1)) {
## 	r <- 1+(i-1)*bls
## 	for (j in 1:(ncols/bls - 1)) {
## 		c <- 1+(j-1)*bls
## 		x.in <- x[r:(r+bls),c:(c+bls)]
## 		xout[r:(r+bls),c:(c+bls)] <- x.in$band1 + 10 #$
## 	}
## 	cat(paste("row-block", i, "\n"))
## }
## close(x)
## close(xout)


###################################################
### code chunk number 86: csdacm.Rnw:1133-1140 (eval = FALSE)
###################################################
## setMethod("[", "SpatialGDAL",
##     function(x, i, j, ... , drop = FALSE)
##         x@grod[i = i, j = j, ...]
## )
## setReplaceMethod("[", "SpatialGDALWrite", function(x, i, j, ..., value) {
## 	...
## })


###################################################
### code chunk number 87: csdacm.Rnw:1166-1167
###################################################
options("width"=owidth)


