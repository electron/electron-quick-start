library(cluster)
## Compare on these:
nms <- c("clustering", "objective", "isolation", "clusinfo", "silinfo")
nm2 <- c("medoids", "id.med", nms)
nm3 <- nm2[- pmatch("obj", nm2)]

(x <- x0 <- cbind(V1 = (-3:4)^2, V2 = c(0:6,NA), V3 = c(1,2,NA,7,NA,8:9,8)))
(px <- pam(x,2, metric="manhattan"))
stopifnot(identical(x,x0))# DUP=FALSE ..
pd <-  pam(dist(x,"manhattan"), 2)
px2 <- pam(x,2, metric="manhattan", keep.diss=FALSE, keep.data=FALSE)
pdC <- pam(x,2, metric="manhattan", cluster.only = TRUE)
p1  <- pam(x,1, metric="manhattan")

stopifnot(identical(px[nms], pd[nms]),
	  identical(px[nms], px2[nms]),
	  identical(pdC, px2$clustering),
	  ## and for default dist "euclidean":
	  identical(pam(x,	2)[nms],
		    pam(dist(x),2)[nms]),
	  identical(p1[c("id.med", "objective", "clusinfo")],
		    list(id.med = 6L, objective = c(build=9.25, swap=9.25),
			 clusinfo = array(c(8, 18, 9.25, 45, 0), dim = c(1, 5),
			 dimnames=list(NULL, c("size", "max_diss", "av_diss",
			 "diameter", "separation"))))),
	  p1$clustering == 1, is.null(p1$silinfo)
	  )

set.seed(253)
## generate 250 objects, divided into 2 clusters.
x <- rbind(cbind(rnorm(120, 0,8), rnorm(120, 0,8)),
	   cbind(rnorm(130,50,8), rnorm(130,10,8)))

.proctime00 <- proc.time()

summary(px2 <- pam(x, 2))
pdx <- pam(dist(x), 2)
all.equal(px2[nms], pdx[nms], tol = 1e-12) ## TRUE
pdxK <- pam(dist(x), 2, keep.diss = TRUE)
stopifnot(identical(pdx[nm2], pdxK[nm2]))

spdx <- silhouette(pdx)
summary(spdx)
spdx
postscript("pam-tst.ps")
if(FALSE)
    plot(spdx)# the silhouette
## is now identical :
plot(pdx)# failed in 1.7.0 -- now only does silhouette

par(mfrow = 2:1)
## new 'dist' argument for clusplot():
plot(pdx, dist=dist(x))
## but this should work automagically (via eval()) as well:
plot(pdx)
## or this
clusplot(pdx)

data(ruspini)
summary(pr4 <- pam(ruspini, 4))
(pr3 <- pam(ruspini, 3))
(pr5 <- pam(ruspini, 5))

data(votes.repub)
summary(pv3 <- pam(votes.repub, 3))
(pv4 <- pam(votes.repub, 4))
(pv6 <- pam(votes.repub, 6, trace = 3))

cat('Time elapsed: ', proc.time() - .proctime00,'\n')

## re-starting with medoids from pv6  shouldn't change:
pv6. <- pam(votes.repub, 6, medoids = pv6$id.med, trace = 3)
identical(pv6[nm3], pv6.[nm3])

## This example seg.faulted at some point:
d.st <- data.frame(V1= c(9, 12, 12, 15, 9, 9, 13, 11, 15, 10, 13, 13,
		       13, 15,  8, 13, 13, 10, 7, 9, 6, 11, 3),
		   V2= c(5, 9, 3, 5, 1, 1, 2, NA, 10, 1, 4, 7,
		       4, NA, NA, 5, 2, 4, 3, 3, 6, 1, 1),
		   V3 = c(63, 41, 59, 50, 290, 226, 60, 36, 32, 121, 70, 51,
		       79, 32, 42, 39, 76, 60, 56, 88, 57, 309, 254),
		   V4 = c(146, 43, 78, 88, 314, 149, 78, NA, 238, 153, 159, 222,
		       203, NA, NA, 74, 100, 111, 9, 180, 50, 256, 107))
dd <- daisy(d.st, stand = TRUE)
(r0 <- pam(dd, 5))# cluster 5 = { 23 } -- on single observation
## pam doing the "daisy" computation internally:
r0s <- pam(d.st, 5, stand=TRUE, keep.diss=FALSE, keep.data=FALSE)
(ii <- which(names(r0) %in% c("call","medoids")))
stopifnot(all.equal(r0[-ii], r0s[-ii], tol=1e-14),
          identical(r0s$medoids, data.matrix(d.st)[r0$medoids, ]))

## This gave only 3 different medoids -> and seg.fault:
(r5 <- pam(dd, 5, medoids = c(1,3,20,2,5), trace = 2)) # now "fine"

dev.off()

##------------------------ Testing pam() with new "pamonce" argument:

## This is from "next version of Matrix" test-tools-1.R:
showSys.time <- function(expr) {
    ## prepend 'Time' for R CMD Rdiff
    st <- system.time(expr)
    writeLines(paste("Time", capture.output(print(st))))
    invisible(st)
}
show2Ratios <- function(...) {
    stopifnot(length(rgs <- list(...)) == 2,
              nchar(ns <- names(rgs)) > 0)
    r <- round(cbind(..1, ..2)[c(1,3),], 3)
    dimnames(r) <- list(paste("Time ", rownames(r)), ns)
    r
}


n <- 1000
## If not enough cases, all CPU times equals 0.
n <- 500 # for now, and automatic testing

sd <- 0.5
set.seed(13)
n2 <- as.integer(round(n * 1.5))
x <- rbind(cbind(rnorm( n,0,sd), rnorm( n,0,sd)),
           cbind(rnorm(n2,5,sd), rnorm(n2,5,sd)),
           cbind(rnorm(n2,7,sd), rnorm(n2,7,sd)),
           cbind(rnorm(n2,9,sd), rnorm(n2,9,sd)))


## original algorithm
st0 <- showSys.time(pamx      <- pam(x, 4,               trace.lev=2))# 8.157   0.024   8.233
 ## bswapPamOnce  algorithm
st1 <- showSys.time(pamxonce  <- pam(x, 4, pamonce=TRUE, trace.lev=2))# 6.122   0.024   6.181
## bswapPamOnceDistIndice
st2 <- showSys.time(pamxonce2 <- pam(x, 4, pamonce = 2,  trace.lev=2))# 4.101   0.024   4.151
show2Ratios('2:orig' = st2/st0, '1:orig' = st1/st0)

## only call element is not equal
(icall <- which(names(pamx) == "call"))
pamx[[icall]]
stopifnot(all.equal(pamx    [-icall],  pamxonce [-icall]),
	  all.equal(pamxonce[-icall],  pamxonce2[-icall]))

## Same using specified medoids
(med0 <- 1 + round(n* c(0,1, 2.5, 4)))#                                      lynne (~ 2010, AMD Phenom II X4 925)
st0 <- showSys.time(pamxst      <- pam(x, 4, medoids = med0,               trace.lev=2))#  13.071   0.024  13.177
st1 <- showSys.time(pamxoncest  <- pam(x, 4, medoids = med0, pamonce=TRUE, trace.lev=2))#   8.503   0.024   8.578
st2 <- showSys.time(pamxonce2st <- pam(x, 4, medoids = med0, pamonce=2,    trace.lev=2))#   5.587   0.025   5.647
show2Ratios('2:orig' = st2/st0, '1:orig' = st1/st0)

## only call element is not equal
stopifnot(all.equal(pamxst    [-icall], pamxoncest [-icall]),
          all.equal(pamxoncest[-icall], pamxonce2st[-icall]))

## Different starting values
med0 <- 1:4 #                                                               lynne (~ 2010, AMD Phenom II X4 925)
st0 <- showSys.time(pamxst      <- pam(x, 4, medoids = med0,               trace.lev=2))# 13.416   0.023  13.529
st1 <- showSys.time(pamxoncest  <- pam(x, 4, medoids = med0, pamonce=TRUE, trace.lev=2))#  8.384   0.024   8.459
st2 <- showSys.time(pamxonce2st <- pam(x, 4, medoids = med0, pamonce=2,    trace.lev=2))#  5.455   0.030   5.520
show2Ratios('2:orig' = st2/st0, '1:orig' = st1/st0)

## only call element is not equal
stopifnot(all.equal(pamxst    [-icall], pamxoncest [-icall]),
          all.equal(pamxoncest[-icall], pamxonce2st[-icall]))


## Medoid bug  --- MM: Fixed, well "0L+ hack", in my pam.q, on 2012-01-31
## ----------
med0 <- (1:6)
st0 <- showSys.time(pamxst   <- pam(x, 6, medoids = med0 ,            trace.lev=2))
stopifnot(identical(med0, 1:6))
med0 <- (1:6)
st1 <- showSys.time(pamxst.1 <- pam(x, 6, medoids = med0 , pamonce=1, trace.lev=2))
stopifnot(identical(med0, 1:6))
stopifnot(all.equal(pamxst[-icall], pamxst.1 [-icall]))


## Last Line:
cat('Time elapsed: ', proc.time() - .proctime00,'\n')

