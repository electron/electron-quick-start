### R code from vignette source 'Raster.Rnw'
### Encoding: ISO8859-1

###################################################
### code chunk number 1: foo
###################################################
options(width = 60)
foo <- packageDescription("raster")


###################################################
### code chunk number 2: raster-1a
###################################################
library(raster)
# RasterLayer with the default parameters
x <- raster()
x

# With other parameters
x <- raster(ncol=36, nrow=18, xmn=-1000, xmx=1000, ymn=-100, ymx=900)
# that can be changed
res(x)

# change resolution
res(x) <- 100
res(x)
ncol(x)
# change the numer of columns (affects resolution)
ncol(x) <- 18
ncol(x)
res(x)

# set the coordinate reference system (CRS) (define the projection)
projection(x) <- "+proj=utm +zone=48 +datum=WGS84"
x


###################################################
### code chunk number 3: raster-1b
###################################################
r <- raster(ncol=10, nrow=10)
ncell(r)
hasValues(r)

# use the 'values' function
# e.g., 
values(r) <- 1:ncell(r)
# or
set.seed(0)
values(r) <- runif(ncell(r))

hasValues(r)
inMemory(r)
values(r)[1:10]

plot(r, main='Raster with 100 cells')


###################################################
### code chunk number 4: raster-1c
###################################################
hasValues(r)
res(r)
dim(r)
xmax(r)

# change the maximum x coordinate of the extent (bounding box) of the RasterLayer
xmax(r) <- 0

hasValues(r)
res(r)
dim(r)

ncol(r) <- 6
hasValues(r)
res(r)
dim(r)
xmax(r)


###################################################
### code chunk number 5: raster-2a
###################################################
# get the name of an example file installed with the package
# do not use this construction of your own files
filename <- system.file("external/test.grd", package="raster")

filename
r <- raster(filename)
filename(r)
hasValues(r)
inMemory(r)
plot(r, main='RasterLayer from file')


###################################################
### code chunk number 6: raster-2b
###################################################
# create three identical RasterLayer objects
r1 <- r2 <- r3 <- raster(nrow=10, ncol=10)
# Assign random cell values 
values(r1) <- runif(ncell(r1))
values(r2) <- runif(ncell(r2))
values(r3) <- runif(ncell(r3))

# combine three RasterLayer objects into a RasterStack
s <- stack(r1, r2, r3)
s
nlayers(s)

# combine three RasterLayer objects into a RasterBrick 
b1 <- brick(r1, r2, r3)
# equivalent to:
b2 <- brick(s)

# create a RasterBrick  from file
filename <- system.file("external/rlogo.grd", package="raster")
filename
b <- brick(filename)
b
nlayers(b)

# extract a single RasterLayer
r <- raster(b, layer=2)
# equivalent to creating it from disk
r <- raster(filename, band=2)


###################################################
### code chunk number 7: raster-3a
###################################################
# create an empty RasterLayer
r <- raster(ncol=10, nrow=10)
# assign values to cells
values(r) <- 1:ncell(r)
s <- r + 10
s <- sqrt(s)
s <- s * r + 5
r[] <- runif(ncell(r))
r <- round(r)
r <- r == 1


###################################################
### code chunk number 8: raster-3b
###################################################
s[r] <- -0.5
s[!r] <- 5
s[s == 5] <- 15


###################################################
### code chunk number 9: raster-3c
###################################################
r <- raster(ncol=5, nrow=5)
r[] <- 1
s <- stack(r, r+1)
q <- stack(r, r+2, r+4, r+6)
x <- r + s + q
x


###################################################
### code chunk number 10: raster-3d
###################################################
a <- mean(r,s,10)
b <- sum(r,s)
st <- stack(r, s, a, b)
sst <- sum(st)
sst


###################################################
### code chunk number 11: raster-3e
###################################################
cellStats(st, 'sum')
cellStats(sst, 'sum')


###################################################
### code chunk number 12: raster-5
###################################################
r <- raster()
r[] <- 1:ncell(r)
ra <- aggregate(r, 10)
r1 <- crop(r, extent(-180,0,0,30))
r2 <- crop(r, extent(-10,180,-20,10))
m <- merge(r1, r2, filename='test.grd', overwrite=TRUE)
plot(m)


###################################################
### code chunk number 13: raster-6
###################################################
r <- raster(ncol=3, nrow=2)
r[] <- 1:ncell(r)
getValues(r)
s <- calc(r, fun=function(x){ x[x < 4] <- NA; return(x)} )
as.matrix(s)
t <- overlay(r, s, fun=function(x, y){ x / (2 * sqrt(y)) + 5 } )
as.matrix(t)
u <- mask(r, t)
as.matrix(u)
v = u==s
as.matrix(v)
w <- cover(t, r)
as.matrix(w)
x <- reclassify(w, c(0,2,1,  2,5,2, 4,10,3))
as.matrix(x)
y <- subs(x, data.frame(id=c(2,3), v=c(40,50)))
as.matrix(y)


###################################################
### code chunk number 14: raster-7
###################################################
r <- raster(nrow=45, ncol=90)
r[] <- round(runif(ncell(r))*3)
a <- area(r)
zonal(a, r, 'sum')


###################################################
### code chunk number 15: raster-10
###################################################
r <- raster(ncol=36, nrow=18)
r[] <- runif(ncell(r))
cellStats(r, mean)
s = r
s[] <- round(runif(ncell(r)) * 5)
zonal(r, s, 'mean')
freq(s)
freq(s, value=3)
crosstab(r*3, s)


###################################################
### code chunk number 16: raster-20a
###################################################
b <- brick(system.file("external/rlogo.grd", package="raster"))
plot(b)


###################################################
### code chunk number 17: raster-20b
###################################################
plotRGB(b, r=1, g=2, b=3)


###################################################
### code chunk number 18: raster-15
###################################################
library(raster)
r <- raster(ncol=36, nrow=18)
ncol(r)
nrow(r)
ncell(r)
rowFromCell(r, 100)
colFromCell(r, 100)
cellFromRowCol(r,5,5)
xyFromCell(r, 100)
cellFromXY(r, c(0,0))
colFromX(r, 0)
rowFromY(r, 0)


###################################################
### code chunk number 19: raster-20
###################################################
r <- raster(system.file("external/test.grd", package="raster"))
v <- getValues(r, 50)
v[35:39]
getValuesBlock(r, 50, 1, 35, 5)


###################################################
### code chunk number 20: raster-21
###################################################
cells <- cellFromRowCol(r, 50, 35:39)
cells
extract(r, cells)
xy = xyFromCell(r, cells)
xy
extract(r, xy)


###################################################
### code chunk number 21: raster-32
###################################################
r[cells] 
r[1:4]
filename(r)
r[2:3] <- 10
r[1:4]
filename(r)


###################################################
### code chunk number 22: raster-33
###################################################
r[1]
r[2,2]
r[1,]
r[,2]
r[1:3,1:3]

# keep the matrix structure
r[1:3,1:3, drop=FALSE]


###################################################
### code chunk number 23: raster-119
###################################################
rasterOptions()


###################################################
### code chunk number 24: raster-120
###################################################
r1 <- raster(ncol=36, nrow=18)
r2 <- r1
r1[] <- runif(ncell(r1))
r2[] <- runif(ncell(r1))
s <- stack(r1, r2)
sgdf <- as(s, 'SpatialGridDataFrame')
newr2 <- raster(sgdf, 2)
news <- stack(sgdf)


###################################################
### code chunk number 25: raster-132
###################################################
setClass ('myRaster',
	contains = 'RasterLayer',
	representation (
		important = 'data.frame',
		essential = 'character'
	) ,
	prototype (
		important = data.frame(),
		essential = ''
	)
)
	
r = raster(nrow=10, ncol=10)

m <- as(r, 'myRaster')
m@important <- data.frame(id=1:10, value=runif(10))
m@essential <- 'my own slot'
m[] <- 1:ncell(m)


###################################################
### code chunk number 26: raster-133
###################################################
setMethod ('show' , 'myRaster', 
	function(object) {
		callNextMethod(object) # call show(RasterLayer)
		cat('essential:', object@essential, '\n')
		cat('important information:\n')
		print( object@important)
	})	
	
m


