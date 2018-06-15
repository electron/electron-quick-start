## This came from a bug report on R-help by ge yreyt <tothri2000@yahoo.ca>
## Date: Mon, 9 Jun 2003 16:06:53 -0400 (EDT)
library(cluster)
if(FALSE) # manual testing
library(cluster, lib="~/R/Pkgs/cluster.Rcheck")

data(iris)

.proctime00 <- proc.time()

mdist <- as.dist(1 - cor(t(iris[,1:4])))#dissimlarity
## this is always the same:
hc <- diana(mdist, diss = TRUE, stand = FALSE)

maxk <- 15                # at most 15 clusters
silh.wid <- numeric(maxk)  # myind[k] := the silh.value for k clusters
silh.wid[1] <- NA # 1-cluster: silhouette not defined

op <- par(mfrow = c(4,4), mar = .1+ c(2,1,2,1), mgp=c(1.5, .6,0))
for(k in 2:maxk) {
    cat("\n", k,":\n==\n")
    k.gr <- cutree(as.hclust(hc), k = k)
    cat("grouping table: "); print(table(k.gr))
    si <- silhouette(k.gr, mdist)
    cat("silhouette:\n"); print(summary(si))
    plot(si, main = paste("k =",k),
         col = 2:(k+1), do.n.k=FALSE, do.clus.stat=FALSE)
    silh.wid[k] <- summary(si)$avg.width
    ##      ===
}
par(op)

summary(si.p <- silhouette(50 - k.gr, mdist))
stopifnot(identical(si.p[,3],         si[,3]),
	  identical(si.p[, 1:2], 50 - si[, 1:2]))

# the widths:
silh.wid
#select the number of k clusters with the largest si value :
(myk <- which.min(silh.wid)) # -> 8 (here)

postscript(file="silhouette-ex.ps")
## MM:  plot to see how the decision is made
plot(silh.wid, type = 'b', col= "blue", xlab = "k")
axis(1, at=myk, col.axis= "red", font.axis= 2)

##--- PAM()'s silhouette should give same as silh*.default()!
Eq <- function(x,y, tol = 1e-12) x == y | abs(x - y) < tol * abs((x+y)/2)

for(k in 2:40) {
    cat("\n", k,":\n==\n")
    p.k <- pam(mdist, k = k)
    k.gr <- p.k$clustering
    si.p <- silhouette(p.k)
    si.g <- silhouette(k.gr, mdist)
    ## since the obs.order may differ (within cluster):
    si.g <- si.g[ as.integer(rownames(si.p)), ]
    cat("grouping table: "); print(table(k.gr))
    if(!isTRUE(all.equal(c(si.g), c(si.p)))) {
	cat("silhouettes differ:")
	if(any(neq <- !Eq(si.g[,3], si.p[,3]))) {
	    cat("\n")
	    print( cbind(si.p[], si.g[,2:3])[ neq, ] )
	} else cat(" -- but not in col.3 !\n")
    }
}


## "pathological" case where a_i == b_i == 0 :
D6 <- structure(c(0, 0, 0, 0.4, 1, 0.05, 1, 1, 0, 1, 1, 0, 0.25, 1, 1),
                Labels = LETTERS[1:6], Size = 6, call = as.name("manually"),
                class = "dist", Diag = FALSE, Upper = FALSE)
D6
kl6 <- c(1,1, 2,2, 3,3)
silhouette(kl6, D6)# had one NaN
summary(silhouette(kl6, D6))
plot(silhouette(kl6, D6))# gives error in earlier cluster versions

dev.off()

## Last Line:
cat('Time elapsed: ', proc.time() - .proctime00,'\n')

