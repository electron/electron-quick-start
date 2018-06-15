xy = expand.grid(x = seq(5,355,by=10),y=seq(-85,85,by=10))
xyp = SpatialPoints(xy, CRS("+proj=longlat"))
gridded(xyp)=T
gridparameters(xyp)
xyf = spsample(xyp, 1000, type="Fibonacci")
plot(xyf, axes=TRUE)
if (require(rgdal)) {
	xy = expand.grid(x = seq(-85,85,by=10),y=seq(-85,85,by=10))
	xyp = SpatialPoints(xy, CRS("+proj=longlat"))
	gridded(xyp) = TRUE
	tocrs = CRS("+proj=ortho +lat_0=0 +lon_0=0 +x0=0 +y0=0")
	plot(spTransform(xyp, tocrs), pch=16,cex=.7)
	xyf = spsample(xyp, 1000, type="Fibonacci")
	plot(spTransform(xyf, tocrs), pch=16,cex=.7)
	dim(coordinates(xyf))
}
