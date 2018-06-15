#### NOT part of the cluster package!

#### Find out what exactly sweep() in ../src/spannel.f is doing
#### in order to eventually replace it with BLAS calls !

### subroutine sweep (cov,nord,ixlo,nel,deter)
###            ===============================
### is called only once as
###	call sweep(cov,ndep,0,i,deter)
### where  i in 0:ndep

sweep1 <- function(cov, i, det = 1)
{
  ## Purpose:
  ## -------------------------------------------------------------------------
  ## Arguments:
  ## -------------------------------------------------------------------------
  ## Author: Martin Maechler, Date: 22 Jan 2002, 08:58
    if(!is.matrix(cov) || 0 != diff(D <- dim(cov)))
        stop("'cov' must be a square matrix")
    if((nord <- as.integer(D[1] - 1)) < 1)## cov[0:nord, 0:nord]
        stop("'cov' must be at least 2 x 2")
    if(0 > (i <- as.integer(i)) || i > nord)
        stop("'i' must be in 0:nord, where nord = nrow(cov)-1")
    storage.mode(cov) <- "double"
    .C(cluster:::cl_sweep,
       cov,
       nord,
       ixlo = 0:0,
       i = i,
       deter=det)
}

sweepAll <- function(cov, det = 1)
{
  ## Purpose:
  ## -------------------------------------------------------------------------
  ## Arguments:
  ## -------------------------------------------------------------------------
  ## Author: Martin Maechler, Date: 22 Jan 2002, 08:58
    if(!is.matrix(cov) || 0 != diff(D <- dim(cov)))
        stop("'cov' must be a square matrix")
    if((nord <- as.integer(D[1] - 1)) < 1)## cov[0:nord, 0:nord]
        stop("'cov' must be at least 2 x 2")
    storage.mode(cov) <- "double"
    for(i in 0:nord) {
	.C(cluster:::cl_sweep,
	   cov,
	   nord,
	   ixlo = 0:0,
	   i = i,
	   deter = det,
	   DUP = FALSE) # i.e. work on 'cov' and 'det' directly
        if(det <= 0)
            cat("** i = ", i, "; deter = ", format(det)," <= 0\n",sep="")
    }
    list(cov = cov, deter = det)
}

require(cluster)

## Examples with errors
m1 <- cov(cbind(1, 1:5))
try(sweepAll(m1))# deter = 0; cov[2,2] = Inf

## ok
(m2 <- cov(cbind(1:5, c(2:5,1), c(4:2,2,6))))
qr(m2, tol = .001)$rank
sweepAll(m2) ## deter = 0
