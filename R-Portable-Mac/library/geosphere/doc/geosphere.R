### R code from vignette source 'geosphere.Rnw'
### Encoding: ISO8859-1

###################################################
### code chunk number 1: foo
###################################################
options(keep.source = TRUE, width = 60)
foo <- packageDescription("geosphere")


###################################################
### code chunk number 2: geosphere.Rnw:58-71
###################################################
library(geosphere)
Lon <- c(1:9/1000, 1:9/100, 1:9/10, 1:90*2) 
Lat <- c(1:9/1000, 1:9/100, 1:9/10, 1:90) 
dcos <- distCosine(c(0,0), cbind(Lon, Lat))
dhav <- distHaversine(c(0,0), cbind(Lon, Lat))
dvsp <- distVincentySphere(c(0,0), cbind(Lon, Lat))
par(mfrow=(c(1,2)))
plot(log(dcos), dcos-dhav, col='red', ylim=c(-1e-05, 1e-05), 
            xlab="Log 'Law of Cosines' distance (m)", 
            ylab="Law of Cosines minus Haversine distance")
plot(log(dhav), dhav-dvsp, col='blue',
            xlab="Log 'Haversine' distance (m)", 
            ylab="Vincenty Sphere minus Haversine distance")


###################################################
### code chunk number 3: geosphere.Rnw:76-79
###################################################
dvse <- distVincentyEllipsoid(c(0,0), cbind(Lon, Lat))
plot(dvsp/1000, (dvsp-dvse)/1000, col='blue', xlab='Vincenty Sphere Distance (km)', 
        ylab="Difference between 'Vincenty Sphere' and 'Vincenty Ellipsoid' methods (km)")


###################################################
### code chunk number 4: geosphere.Rnw:89-102
###################################################
LA <- c(-118.40, 33.95)
NY <- c(-73.78,  40.63)
data(wrld)
plot(wrld, type='l')
gc <- greatCircle(LA, NY)
lines(gc, lwd=2, col='blue')
gci <- gcIntermediate(LA, NY)
lines(gci, lwd=4, col='green')
points(rbind(LA, NY), col='red', pch=20, cex=2)
mp <- midPoint(LA, NY)
onGreatCircle(LA,NY, rbind(mp,c(0,0)))
points(mp, pch='*', cex=3, col='orange')
greatCircleBearing(LA, brng=270, n=10)


###################################################
### code chunk number 5: geosphere.Rnw:109-117
###################################################
destPoint(LA, b=65, d=100000)
circle=destPoint(c(0,80), b=1:365, d=1000000)
circle2=destPoint(c(0,80), b=1:365, d=500000)
circle3=destPoint(c(0,80), b=1:365, d=100000)
plot(circle, type='l')
polygon(circle, col='blue', border='black', lwd=4)
polygon(circle2, col='red', lwd=4, border='orange')
polygon(circle3, col='white', lwd=4, border='black')


###################################################
### code chunk number 6: geosphere.Rnw:125-139
###################################################
ml <- gcMaxLat(LA, NY)
lat0 <- gcLat(LA, NY, lon=0)
lon0 <- gcLon(LA, NY, lat=0)
plot(wrld, type='l')
lines(gc, lwd=2, col='blue')
points(ml, col='red', pch=20, cex=2)
points(cbind(0, lat0), pch=20, cex=2, col='yellow') 
points(t(rbind(lon0, 0)), pch=20, cex=2, col='green' )

f <- function(lon){gcLat(LA, NY, lon)}
opt <- optimize(f, interval=c(-180, 180), maximum=TRUE)
points(opt$maximum, opt$objective, pch=20, cex=2, col='dark green' )
anti <- antipode(c(opt$maximum, opt$objective)) 
points(anti, pch=20, cex=2, col='dark blue' )


###################################################
### code chunk number 7: geosphere.Rnw:146-161
###################################################
SF <- c(-122.44, 37.74)
AM <- c(4.75, 52.31)
gc2 <- greatCircle(AM, SF)
plot(wrld, type='l')
lines(gc, lwd=2, col='blue')
lines(gc2, lwd=2, col='green')
int <- gcIntersect(LA, NY, SF, AM)
int
antipodal(int[,1:2], int[,3:4])
points(rbind(int[,1:2], int[,3:4]), col='red', pch=20, cex=2)
bearing1 <- bearing(LA, NY)
bearing2 <- bearing(SF, AM)
bearing1
bearing2
gcIntersectBearing(LA, bearing1, SF, bearing2)


###################################################
### code chunk number 8: geosphere.Rnw:169-189
###################################################
MS <- c(-93.26, 44.98)
gc1 <- greatCircleBearing(NY, 281)
gc2 <- greatCircleBearing(MS, 195)
gc3 <- greatCircleBearing(LA, 55)
plot(wrld, type='l', xlim=c(-125, -70), ylim=c(20, 60))
lines(gc1, col='green')
lines(gc2, col='blue')
lines(gc3, col='red')

int <- gcIntersectBearing(rbind(NY, NY, MS), 
            c(281, 281, 195), rbind(MS, LA, LA), c(195, 55, 55))
int
distm(rbind(int[,1:2], int[,3:4]))
int <- int[,1:2]
points(int)
poly <- rbind(int, int[1,])
centr <- centroid(poly)
poly2 <- makePoly(int)
polygon(poly2, col='yellow')
points(centr, pch='*', col='dark red', cex=2)


###################################################
### code chunk number 9: geo5
###################################################
d <- distCosine(LA, NY)
d
b <- bearing(LA, NY)
b
destPoint(LA, b, d)
NY
finalBearing(LA, NY)


###################################################
### code chunk number 10: geosphere.Rnw:213-224
###################################################
atd <- alongTrackDistance(LA, NY, MS)
p <- destPoint(LA, b, atd)
plot(wrld, type='l', xlim=c(-130,-60), ylim=c(22,52))
lines(gci, col='blue', lwd=2)
points(rbind(LA, NY), col='red', pch=20, cex=2)
points(MS[1], MS[2], pch=20, col='blue', cex=2)
lines(gcIntermediate(LA, p), col='green', lwd=3)
lines(gcIntermediate(MS, p), col='dark green', lwd=3)
points(p, pch=20, col='red', cex=2)
dist2gc(LA, NY, MS)
distCosine(p, MS)


###################################################
### code chunk number 11: geosphere.Rnw:232-241
###################################################
line <- rbind(c(-180,-20), c(-150,-10), c(-140,55), c(10, 0), c(-140,-60))
pnts <- rbind(c(-170,0), c(-75,0), c(-70,-10), c(-80,20), c(-100,-50),
           c(-100,-60), c(-100,-40), c(-100,-20), c(-100,-10), c(-100,0))
d = dist2Line(pnts, line)
plot( makeLine(line), type='l')
points(line)
points(pnts, col='blue', pch=20)
points(d[,2], d[,3], col='red', pch='x', cex=2)
for (i in 1:nrow(d)) lines(gcIntermediate(pnts[i,], d[i,2:3], 10), lwd=2, col='green')


###################################################
### code chunk number 12: geosphere.Rnw:249-269
###################################################
NP <- c(0, 85)
bearing(SF, NP)
b <- bearingRhumb(SF, NP)
b
dc <- distCosine(SF, NP)
dr <- distRhumb(SF, NP)
dc / dr

pr <- destPointRhumb(SF, b, d=round(dr/100) * 1:100)
pc <- rbind(SF, gcIntermediate(SF, NP), NP)
par(mfrow=c(1,2))
data(wrld)
plot(wrld, type='l', xlim=c(-140,10), ylim=c(15,90), main='Equirectangular')
lines(pr, col='blue')
lines(pc, col='red')
data(merc)
plot(merc, type='l', xlim=c(-15584729, 1113195), 
                     ylim=c(2500000, 22500000), main='Mercator')
lines(mercator(pr), col='blue')
lines(mercator(pc), col='red')


###################################################
### code chunk number 13: geosphere.Rnw:277-291
###################################################
pol <- rbind(c(-120,-20), c(-80,5), c(0, -20), c(-40,-60), c(-120,-20))
areaPolygon(pol)
perimeter(pol)
centroid(pol)
span(pol, fun=max)
nicepoly = makePoly(pol)
plot(pol, xlab='longitude', ylab='latitude', cex=2, lwd=3, xlim=c(-140, 0))
lines(wrld, col='grey')
lines(pol, col='red', lwd=2)
lines(nicepoly, col='blue', lwd=2)
points(centroid(pol), pch='*', cex=3, col='dark green')
text(centroid(pol)-c(0,2.5), 'centroid')
legend(-140, -48, c('planar','spherical'), lty=1, lwd=2, 
                 col=c('red', 'blue'), title='polygon type')


###################################################
### code chunk number 14: geosphere.Rnw:299-304
###################################################
plot(wrld, type='l', col='grey')
a = randomCoordinates(500)
points(a, col='blue', pch=20, cex=0.5)
b = regularCoordinates(3)
points(b, col='red', pch='x')


###################################################
### code chunk number 15: geosphere.Rnw:313-321
###################################################
as.Date(80, origin='2009-12-31')
as.Date(172, origin='2009-12-31')
plot(0:90, daylength(lat=0:90, doy=1), ylim=c(0,24), type='l', xlab='Latitude', 
        ylab='Daylength', main='Daylength by latitude and day of year', lwd=2)
lines(0:90, daylength(lat=0:90, doy=80), col='green', lwd=2)
lines(0:90, daylength(lat=0:90, doy=172), col='blue', lwd=2)
legend(0,24, c('1','80','172'), lty=1, lwd=2, col=c('black', 'green', 'blue'), 
        title='Day of year')


