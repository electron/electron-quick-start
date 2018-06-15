### R code from vignette source 'functions.Rnw'
### Encoding: ISO8859-1

###################################################
### code chunk number 1: code-1
###################################################
library(raster)
r <- raster(ncol=10, nrow=10)
r[] <- 1:100
r


###################################################
### code chunk number 2: code-2
###################################################
f1 <- function(x, a) {
	x@data@values <- x@data@values + a
	return(x) 
}
s <- f1(r, 5)
s


###################################################
### code chunk number 3: code-3
###################################################
f2 <- function(x, a) {
	v <- getValues(x)
	v <- v + a
	x <- setValues(x, v)
	return(x)
}
s <- f2(r, 5)
s


###################################################
### code chunk number 4: code-4
###################################################
f3 <- function(x, a, filename) {
	out <- raster(x)
	out <- writeStart(out, filename, overwrite=TRUE)
	for (r in 1:nrow(out)) {
		v <- getValues(x, r)
		v <- v + a
		out <- writeValues(out, v, r)
	}
	out <- writeStop(out)
	return(out)
}
s <- f3(r, 5, filename='test')
s


###################################################
### code chunk number 5: code-5
###################################################
f4 <- function(x, a, filename) {
	out <- raster(x)
	bs <- blockSize(out)
	out <- writeStart(out, filename, overwrite=TRUE)
	for (i in 1:bs$n) {
		v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i] )
		v <- v + a
		out <- writeValues(out, v, bs$row[i])
	}
	out <- writeStop(out)
	return(out)
}
s <- f4(r, 5, filename='test.grd')
blockSize(s)


###################################################
### code chunk number 6: code-6
###################################################
f5 <- function(x, a, filename='') {
	out <- raster(x)
	small <- canProcessInMemory(out, 3)
	filename <- trim(filename)
	
	if (!small & filename == '') {
		filename <- rasterTmpFile()
	}
	
	todisk <- FALSE
	if (filename != '') {
		out <- writeStart(out, filename, overwrite=TRUE)
		todisk <- TRUE
	} else {
		vv <- matrix(ncol=nrow(out), nrow=ncol(out))
	}
	
	for (r in 1:nrow(out)) {
		v <- getValues(x, r)
		v <- v + a
		if (todisk) {
			out <- writeValues(out, v, r)
		} else {
			vv[,r] <- v
		}
	}
	if (todisk) {
		out <- writeStop(out)
	} else {
		out <- setValues(out, as.vector(vv))
	}
	return(out)
}
s <- f5(r, 5)


###################################################
### code chunk number 7: code-7
###################################################
f6 <- function(x, a, filename='') {
	out <- raster(x)
	small <- canProcessInMemory(out, 3)
	filename <- trim(filename)
	
	if (! small & filename == '') {
		filename <- rasterTmpFile()
	}
	if (filename != '') {
		out <- writeStart(out, filename, overwrite=TRUE)
		todisk <- TRUE
	} else {
		vv <- matrix(ncol=nrow(out), nrow=ncol(out))
		todisk <- FALSE
	}
	
	bs <- blockSize(r)
	for (i in 1:bs$n) {
		v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i] )
		v <- v + a
		if (todisk) {
			out <- writeValues(out, v, bs$row[i])
		} else {
			cols <- bs$row[i]:(bs$row[i]+bs$nrows[i]-1)	
			vv[,cols] <- matrix(v, nrow=ncol(out))
		}
	}
	if (todisk) {
		out <- writeStop(out)
	} else {
		out <- setValues(out, as.vector(vv))
	}
	return(out)
}

s <- f6(r, 5)


###################################################
### code chunk number 8: code-8
###################################################
f7 <- function(x, a, filename='') {

	out <- raster(x)
	filename <- trim(filename)
	
	if (canProcessInMemory(out, 3)) {
		v <- getValues(x) + a
		out <- setValues(out, v)
		if (filename != '') {
			out <- writeRaster(out, filename, overwrite=TRUE)
		}
	} else {
		if (filename == '') {
			filename <- rasterTmpFile()
		}
		out <- writeStart(out, filename)
		
		bs <- blockSize(r)
		for (i in 1:bs$n) {
			v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i] )
			v <- v + a
			out <- writeValues(out, v, bs$row[i])
		}
		out <- writeStop(out)
	}
	return(out)
}

s <- f7(r, 5)


###################################################
### code chunk number 9: code-9
###################################################
f8 <- function(x, a, filename='', ...) {
	out <- raster(x)
	big <- ! canProcessInMemory(out, 3)
	filename <- trim(filename)
	if (big & filename == '') {
		filename <- rasterTmpFile()
	}
	if (filename != '') {
		out <- writeStart(out, filename, ...)
		todisk <- TRUE
	} else {
		vv <- matrix(ncol=nrow(out), nrow=ncol(out))
		todisk <- FALSE
	}
	
	bs <- blockSize(x)
	pb <- pbCreate(bs$n, ...)

	if (todisk) {
		for (i in 1:bs$n) {
			v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i] )
			v <- v + a
			out <- writeValues(out, v, bs$row[i])
			pbStep(pb, i) 
		}
		out <- writeStop(out)
	} else {
		for (i in 1:bs$n) {
			v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i] )
			v <- v + a
			cols <- bs$row[i]:(bs$row[i]+bs$nrows[i]-1)	
			vv[,cols] <- matrix(v, nrow=out@ncols)
			pbStep(pb, i) 
		}
		out <- setValues(out, as.vector(vv))
	}
	pbClose(pb)
	return(out)
}

s <- f8(r, 5, filename='test', overwrite=TRUE)

if(require(rgdal)) { # only if rgdal is installed
	s <- f8(r, 5, filename='test.tif', format='GTiff', overwrite=TRUE)
}
s


###################################################
### code chunk number 10: code-10
###################################################
if (!isGeneric("f9")) {
	setGeneric("f9", function(x, ...)
		standardGeneric("f9"))
}	


setMethod('f9', signature(x='RasterLayer'), 
	function(x, filename='', ...) {
		return(x)
	}
)

s <- f9(r)


###################################################
### code chunk number 11: code-clus1
###################################################
clusfun <- function(x, filename="", ...) {

	out <- raster(x)

	cl <- getCluster()
	on.exit( returnCluster() )
	
	nodes <- length(cl)
	
	bs <- blockSize(x, minblocks=nodes*4)
	pb <- pbCreate(bs$n)

	# the function to be used (simple example)
	clFun <- function(i) {
		v <- getValues(x, bs$row[i], bs$nrows[i])
		for (i in 1:length(v)) {
			v[i] <- v[i] / 100  
		}
		return(v)
	}

	# get all nodes going
	for (i in 1:nodes) {
		sendCall(cl[[i]], clFun, i, tag=i)
    }

	filename <- trim(filename)
	if (!canProcessInMemory(out) & filename == "") {
		filename <- rasterTmpFile()
	}
	
	if (filename != "") {
		out <- writeStart(out, filename=filename, ... )
	} else {
		vv <- matrix(ncol=nrow(out), nrow=ncol(out))
	}
	for (i in 1:bs$n) {
		# receive results from a node
		d <- recvOneData(cl)
		
		# error?
		if (! d$value$success) { 
			stop('cluster error')
		}
		
		# which block is this?
		b <- d$value$tag
		cat('received block: ',b,'\n'); flush.console();
		
		if (filename != "") {
			out <- writeValues(out, d$value$value, bs$row[b])
		} else {
			cols <- bs$row[b]:(bs$row[b] + bs$nrows[b]-1)	
			vv[,cols] <- matrix(d$value$value, nrow=out@ncols)
		}
		
		# need to send more data?
		ni <- nodes + i
		if (ni <= bs$n) {
			sendCall(cl[[d$node]], clFun, ni, tag=ni)
		}	
		pbStep(pb)
	}
	if (filename != "") {
		out <- writeStop(out)
	} else {
		out <- setValues(out, as.vector(vv))
	}
	pbClose(pb)
	
	return(out)
}	


###################################################
### code chunk number 12: code-clus2
###################################################
r <- raster()
# beginCluster()
r[] <- ncell(r):1
# x <- clusfun(r)
# endCluster()


