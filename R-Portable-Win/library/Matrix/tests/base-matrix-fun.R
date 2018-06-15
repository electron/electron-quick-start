#### Thanks to the manipulation in base namespace, see  ../R/zzz.R ,
#### all the functions (in 'base' or namespaces that import it)
#### starting with something like
####	" x <- as.matrix(x) "  or   " X <- as.array(X) "
#### will work for 'Matrix'-matrices

library(Matrix)

data(KNex); mm <- KNex$mm
str(m1 <- mm[1:500, 1:200])
m11 <- m1[1:100, 1:20]
## These now work thanks to using our as.matrix():
str(D1 <- dist(m11))
str(rs <- apply(m1, 1, sum))

stopifnot(identical(kappa(Matrix(2:5, 2)),
                    kappa(matrix(2:5, 2))))
## used to seg.fault, PR#7984,
## because qr() was calling the wrong as.matrix()

## also matplot() or pairs().

## a regression test for  as.matrix.dist(.) still working
stopifnot(c(43, 43) == dim(as.matrix(d <- dist(USJudgeRatings))))

m <- Matrix(0:5, 3, 2)
(m2 <- Matrix(diag(c(3,1))))
(m3 <- crossprod(t(m))) # <- that's an S4 method; nothing "base"

str( svd(m) )
str( lapply(eigen(m3), zapsmall))

### outer()  used to work thanks to  as.array() -- up to R 2.2.1
##  no longer, because the definition of outer has changed  -- FIXME?
## Whould work by providing an as.vector(.) method
##  *and*  is.array(.) \-> TRUE  which may be too strong
##--> For %o%: "need" to make  outer(.,.) an S3 generic
##    *and* provide Matrix S3 methods
## stopifnot(identical(outer(m, m2),
##                    outer(as(m,"matrix"), as(m2,"matrix"))),
##          identical(outer(m3, m2),
##                    outer(as(m3,"matrix"), as(m2,"matrix"))))


cat('Time elapsed: ', proc.time(),'\n') # for ``statistical reasons''
