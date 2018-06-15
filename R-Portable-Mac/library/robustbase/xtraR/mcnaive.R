mcNaive <- function (x, method = c("h.use", "simple"),
                     low = FALSE, high = FALSE)
{
    ## Purpose:	 naive implementation of mc()
    ## ----------------------------------------------
    ##  (low, high) - as in mad() - for choosing the (lo/hi)-median with even n
    ##
    ## Author: Martin Maechler, Date: 21 Jul 2007

    n <- length(x)
    if(n <= 2) return(0)
    x <- sort(x)
    stopifnot(is.finite(m <- median(x)))# <==> no NAs in x[]
    x <- x - m
    n1 <- length(xL <- x[x <= 0]) # both contain all (if any) median values
    n2 <- length(xR <- x[x >= 0])
    n.n <- as.double(n1)*n2
    if(n.n > 1e8)# 1e8 < .Machine$integer.max
        stop("\"simple\" method not sensible here: would need too much memory: n.n=",
             n.n)
    Mmedian <- {
        if ((low || high) &&  n.n %% 2 == 0) {
            if (low && high)
                stop("'low' and 'high' cannot be both TRUE")
            N2 <- n.n %/% 2 + as.integer(high)
            function(x) sort(x, partial = N2)[N2]
        }
        else
            median
    }
    method <- match.arg(method)
    switch(method,
	   "simple" = {
	       r <- outer(xR, xL, "+") / outer(xR, xL, "-")
	       r[is.na(r)] <- 0		# simple --
	       ## ok only when the median-observations are "in the middle",
	       ## e.g. *not* ok for  c(-5, -1, 0, 0, 0, 1)
	       Mmedian(r)
	   },
	   "h.use" = {
	       k <- sum(x == 0) ## the number of obs coinciding with median()
	       irep <- rep.int(n1, n2)
	       if(k > 0) { ## have some obs. == median ( == 0)
		   h <- function(xl,xr, i,j) { ## must parallelize (!)
		       eq <- xl == xr
		       r <- xl
		       xr <- xr[!eq]
		       xl <- xl[!eq]
		       r [eq] <- sign(i[eq]+j[eq]-1-k)
		       r[!eq] <- (xr + xl)/(xr - xl)
		       r
		   }
		   i <- integer(n1)
		   j <- integer(n2)
		   i[(n1-k+1):n1] <- j[1:k] <- 1:k
		   i <- rep(i, times = n2)
		   j <- rep(j, irep)
	       }
	       else { ## k == 0:
		   h <- function(xl,xr, i,j) (xr + xl)/(xr - xl)
		   i <- j <- NULL
	       }

	       ## build	 outer(xL, xR, FUN= h)	manually, such that
	       ## we can pass (i,j) properly :
	       Mmedian(h(xl = rep(xL, times = n2),
                         xr = rep(xR, irep),
                         i, j))
	   })
}
