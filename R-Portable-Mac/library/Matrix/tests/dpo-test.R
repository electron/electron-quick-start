### Testing positive definite matrices
library(Matrix)
source(system.file("test-tools.R", package = "Matrix"))# identical3() etc
cat("doExtras:",doExtras,"\n")

h9 <- Hilbert(9)
stopifnot(c(0,0) == dim(Hilbert(0)),
          c(9,9) == dim(h9),
	  identical(h9@factors, list()))
str(h9)# no 'factors'		32b:	-96.73694669	2.08e-8
assert.EQ.(c(determinant(h9)$modulus),	-96.7369487, tol = 8e-8)
##				64b:	-96.73695078	2.15e-8 then 6.469e-8

## determinant() now working via chol(): ==> h9 now has factorization
stopifnot(names(h9@factors) == "Cholesky",
          identical(ch9 <- chol(h9), h9@factors$Cholesky))
round(ch9, 3) ## round() preserves 'triangular' !
str(f9 <- as(ch9, "dtrMatrix"))
stopifnot(all.equal(rcond(h9), 9.0938e-13),
          all.equal(rcond(f9), 9.1272e-7, tolerance = 1e-6))# more precision fails
options(digits=4)
(cf9 <- crossprod(f9))# looks the same as  h9 :
assert.EQ.mat(h9, as(cf9,"matrix"), tol=1e-15)

h9. <- round(h9, 2)# actually loses pos.def. "slightly"
                   # ==> the above may be invalid in the future
h9p  <- as(h9,  "dppMatrix")
h9.p <- as(h9., "dppMatrix")
ch9p <- chol(h9p)
stopifnot(identical(ch9p, h9p@factors$pCholesky),
	  identical(names(h9p@factors), c("Cholesky", "pCholesky")))
h4  <- h9.[1:4, 1:4] # this and the next
h9.[1,1] <- 10       # had failed in 0.995-14
h9p[1,1] <- 10
stopifnotValid(h9., "symmetricMatrix")
stopifnotValid(h9p, "symmetricMatrix")
stopifnotValid(h4,  "symmetricMatrix")

h9p[1,2] <- 99
stopifnot(class(h9p) == "dgeMatrix", h9p[1,1:2] == c(10,99))

str(h9p <- as(h9, "dppMatrix"))# {again}
h6 <- h9[1:6,1:6]
stopifnot(all(h6 == Hilbert(6)), length(h6@factors) == 0)
stopifnotValid(th9p <- t(h9p), "dppMatrix")
stopifnotValid(h9p@factors$Cholesky,"Cholesky")
H6  <- as(h6, "dspMatrix")
pp6 <- as(H6, "dppMatrix")
po6 <- as(pp6,"dpoMatrix")
hs <- as(h9p, "dspMatrix")
stopifnot(names(H6@factors)  == "pCholesky",
	  names(pp6@factors) == "pCholesky",
	  names(hs@factors)  == "Cholesky") # for now
chol(hs) # and that is cached in 'hs' too :
stopifnot(names(hs@factors) %in% c("Cholesky","pCholesky"),
	  all.equal(h9, crossprod(hs@factors$pCholesky), tolerance =1e-13),
	  all.equal(h9, crossprod(hs@factors$ Cholesky), tolerance =1e-13))

hs@x <- 1/h9p@x # is not pos.def. anymore
validObject(hs) # "but" this does not check
stopifnot(diag(hs) == seq(1, by = 2, length = 9))

s9 <- solve(h9p, seq(nrow(h9p)))
signif(t(s9)/10000, 4)# only rounded numbers are platform-independent
(I9 <- h9p %*% s9)
m9 <- matrix(1:9, dimnames = list(NULL,NULL))
stopifnot(all.equal(m9, .asmatrix(I9), tolerance = 2e-9))

### Testing nearPD() --- this is partly in  ../man/nearPD.Rd :
pr <- Matrix(c(1,     0.477, 0.644, 0.478, 0.651, 0.826,
               0.477, 1,     0.516, 0.233, 0.682, 0.75,
               0.644, 0.516, 1,     0.599, 0.581, 0.742,
               0.478, 0.233, 0.599, 1,     0.741, 0.8,
               0.651, 0.682, 0.581, 0.741, 1,     0.798,
               0.826, 0.75,  0.742, 0.8,   0.798, 1),
             nrow = 6, ncol = 6)

nL <-
    list(r   = nearPD(pr, conv.tol = 1e-7), # default
	 r.1 = nearPD(pr, conv.tol = 1e-7,		corr = TRUE),
	 rs  = nearPD(pr, conv.tol = 1e-7, doDyk=FALSE),
	 rs1 = nearPD(pr, conv.tol = 1e-7, doDyk=FALSE, corr = TRUE),
	 rH  = nearPD(pr, conv.tol = 1e-15),
         rH.1= nearPD(pr, conv.tol = 1e-15, corr = TRUE))

sapply(nL, `[`, c("iterations", "normF"))

allnorms <- function(d) vapply(c("1","I","F","M","2"),
                               norm, x = d, double(1))

## "F" and "M" distances are larger for the (corr=TRUE) constrained:
100 * sapply(nL, function(rr) allnorms((pr - rr  $ mat)))

## But indeed, the 'corr = TRUE' constraint yield a better solution,
## if you need the constraint :  cov2cor() does not just fix it up :
100 * (nn <- sapply(nL, function(rr) allnorms((pr - cov2cor(rr  $ mat)))))

stopifnot(
all.equal(nn["1",],
          c(r =0.0999444286984696, r.1= 0.0880468666522317,
            rs=0.0999444286984702, rs1= 0.0874614179943388,
            rH=0.0999444286984696, rH.1=0.0880468927726625),
          tolerance=1e-9))

nr <- nL $rH.1 $mat
stopifnot(
    all.equal(nr[lower.tri(nr)],
	      c(0.4877861230299, 0.6429309061748, 0.4904554299278, 0.6447150779852,
		0.8082100656035, 0.514511537243, 0.2503412693503, 0.673249718642,
		0.7252316891977, 0.5972811755863, 0.5818673040157, 0.7444549621769,
		0.7308954865819, 0.7713984381710, 0.8124321235679),
	      tolerance = 1e-9))
showProc.time()


set.seed(27)
m9 <- h9 + rnorm(9^2)/1000 ; m9 <- (m9 + t(m9))/2
nm9 <- nearPD(m9)
showProc.time()

nRep <- if(doExtras) 50 else 4
CPU <- 0
for(M in c(5, 12))
    for(i in 1:nRep) {
	m <- matrix(round(rnorm(M^2),2), M, M)
	m <- m + t(m)
	diag(m) <- pmax(0, diag(m)) + 1
	m <- cov2cor(m)
	CPU <- CPU + system.time(n.m <- nearPD(m))[1]
	X <- as(n.m$mat, "matrix")
	stopifnot(all.equal(X, (X + t(X))/2, tolerance = 8*.Machine$double.eps),
		  all.equal(eigen(n.m$mat, only.values=TRUE)$values,
			    n.m$eigenvalues, tolerance = 4e-8))
    }
cat('Time elapsed for ',nRep, 'nearPD(): ', CPU,'\n')
showProc.time()

## cov2cor()
m <- diag(6:1) %*% as(pr,"matrix") %*% diag(6:1) # so we can "vector-index"
m[upper.tri(m)] <- 0
ltm <- which(lower.tri(m))
ne <- length(ltm)
set.seed(17)
m[ltm[sample(ne, 3/4*ne)]] <- 0
m <- (m + t(m))/2 # now is a covariance matrix with many 0 entries
(spr <- Matrix(m))
cspr <- cov2cor(spr)
ev <- eigen(cspr, only.v = TRUE)$values
stopifnot(is(spr, "dsCMatrix"),
          is(cspr,"dsCMatrix"),
          all.equal(ev, c(1.5901626099,  1.1902658504, 1, 1,
                          0.80973414959, 0.40983739006), tolerance=1e-10))

x <- c(2,1,1,2)
mM <- Matrix(x, 2,2, dimnames=rep( list(c("A","B")), 2))# dsy
mM
stopifnot(length(mM@factors)== 0)
(po <- as(mM, "dpoMatrix")) # still has dimnames
mm <- as(mM, "matrix")
msy <- as(mm, "dsyMatrix")
stopifnot(Qidentical(mM, msy),
	  length(mM @factors)== 1,
	  length(msy@factors)== 0)

c1 <- as(mm, "corMatrix")
c2 <- as(mM, "corMatrix")
c3 <- as(po, "corMatrix")
(co.x <- matrix(x/2, 2,2))
checkMatrix(c1)
assert.EQ.mat(c1, co.x)
assert.EQ.mat(c2, co.x) # failed in Matrix 0.999375-9, because of
## the wrong automatic "dsyMatrix" -> "corMatrix" coerce method
stopifnot(identical(dimnames(c1), dimnames(mM)),
	  all.equal(c1, c3, tolerance =1e-15))

showProc.time()

