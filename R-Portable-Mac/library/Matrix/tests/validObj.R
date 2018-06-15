library(Matrix)
### Do all kinds of object creation and coercion

source(system.file("test-tools.R", package = "Matrix"))

## the empty ones:
checkMatrix(new("dgeMatrix"))
checkMatrix(Matrix(,0,0))

## "dge"
assertError( new("dgeMatrix", Dim = c(2,2), x= 1:4) )# double 'Dim'
assertError( new("dgeMatrix", Dim = as.integer(c(2,2)), x= 1:4) )# int 'x'
assertError( new("dgeMatrix", Dim = 2:2, x=as.double(1:4)) )# length(Dim) !=2
assertError( new("dgeMatrix", Dim = as.integer(c(2,2)), x= as.double(1:5)))

checkMatrix(m1 <- Matrix(1:6, ncol=2))
checkMatrix(m2 <- Matrix(1:7 +0, ncol=3)) # a (desired) warning
c("dgeMatrix", "ddenseMatrix", "generalMatrix", "geMatrix", "dMatrix",
  "denseMatrix", "compMatrix", "Matrix", "xMatrix", "mMatrix") -> m1.cl
stopifnot(!anyNA(match(m1.cl, is(m1))),
	  dim(t(m1)) == 2:3, identical(m1, t(t(m1))))
c.nam <- paste("C",1:2, sep='')
dimnames(m1) <- list(NULL, c.nam)
checkMatrix(m1) # failed in 0.999375-10
checkMatrix(tm1 <- t(m1))
stopifnot(colnames(m1) == c.nam,
	  identical(dimnames(tm1), list(c.nam, NULL)),
	  identical(m1, t(tm1)))

## an example of *named* dimnames
(t34N <- as(unclass(table(x = gl(3,4), y=gl(4,3))), "dgeMatrix"))
stopifnot(identical(dimnames(t34N),
		    dimnames(as(t34N, "matrix"))),
          identical(t34N, t(t(t34N))))

## "dpo"
checkMatrix(cm <- crossprod(m1))
checkMatrix(cp <- as(cm, "dppMatrix"))# 'dpp' + factors
checkMatrix(cs <- as(cm, "dsyMatrix"))# 'dsy' + factors
checkMatrix(dcm <- as(cm, "dgeMatrix"))#'dge'
checkMatrix(mcm <- as(cm, "dMatrix")) # 'dsy' + factors -- buglet? rather == cm?
checkMatrix(mc. <- as(cm, "Matrix"))  # dpo --> dsy -- (as above)  FIXME? ??
stopifnot(identical(mc., mcm),
	  identical(cm, (2*cm)/2),# remains dpo
	  identical(cm + cp, cp + cs),# dge
	  identical(mc., mcm),
	  all(2*cm == mcm * 2))

checkMatrix(eq <- cm == cs)
stopifnot(all(eq@x),
	  identical3(pack(eq), cs == cp, cm == cp),
	  as.logical(!(cs < cp)),
	  identical4(!(cs < cp), !(cp > cs), cp <= cs, cs >= cp))

## Coercion to 'dpo' should give an error if result would be invalid
M <- Matrix(diag(4) - 1)
assertError(as(M, "dpoMatrix"))
M. <- as(M, "dgeMatrix")
M.[1,2] <- 10 # -> not even symmetric anymore
assertError(as(M., "dpoMatrix"))


## Cholesky
checkMatrix(ch <- chol(cm))
checkMatrix(ch2 <- chol(as(cm, "dsyMatrix")))
checkMatrix(ch3 <- chol(as(cm, "dgeMatrix")))
stopifnot(is.all.equal3(as(ch, "matrix"), as(ch2, "matrix"), as(ch3, "matrix")))
### Very basic	triangular matrix stuff

assertError( new("dtrMatrix", Dim = c(2,2), x= 1:4) )# double 'Dim'
assertError( new("dtrMatrix", Dim = as.integer(c(2,2)), x= 1:4) )# int 'x'
## This caused a segfault (before revision r1172 in ../src/dtrMatrix.c):
assertError( new("dtrMatrix", Dim = 2:2, x=as.double(1:4)) )# length(Dim) !=2
assertError( new("dtrMatrix", Dim = as.integer(c(2,2)), x= as.double(1:5)))

tr22 <- new("dtrMatrix", Dim = as.integer(c(2,2)), x=as.double(1:4))
tt22 <- t(tr22)
(tPt <- tr22 + tt22)
stopifnot(identical(10 * tPt, tPt * 10),
	  as.vector(t.22 <- (tr22 / .5)* .5) == c(1,0,3,4),
	  TRUE) ## not yet: class(t.22) == "dtrMatrix")

## non-square triagonal Matrices --- are forbidden ---
assertError(new("dtrMatrix", Dim = 2:3,
		x=as.double(1:6), uplo="L", diag="U"))

n <- 3:3
assertError(new("dtCMatrix", Dim = c(n,n), diag = "U"))
validObject(T <- new("dtTMatrix", Dim = c(n,n), diag = "U"))
validObject(M <- new("dtCMatrix", Dim = c(n,n), diag = "U",
		     p = rep.int(0:0, n+1)))
stopifnot(identical(as.mat(T), diag(n)))

set.seed(3) ; (p9 <- as(sample(9), "pMatrix"))
## Check that the correct error message is triggered:
ind.try <- try(p9[1,1] <- 1, silent = TRUE)
np9 <- as(p9, "ngTMatrix")
stopifnot(grepl("replacing.*sensible", ind.try[1]),
	  is.logical(p9[1,]),
	  is(p9[2,, drop=FALSE], "indMatrix"),
	  is(p9[9:1,], "indMatrix"),
	  isTRUE(p9[-c(1:6, 8:9), 1]),
	  identical(t(p9), solve(p9)),
	  identical(p9[TRUE, ], p9),
          all.equal(p9[, TRUE], np9), # currently...
	  identical(as(diag(9), "pMatrix"), as(1:9, "pMatrix"))
	  )
assert.EQ.mat(p9[TRUE,], as.matrix(np9))

## validObject --> Cparse_validate(.)
mm <- new("dgCMatrix", Dim = c(3L, 5L),
          i = c(2L, 0L, 1L, 2L, 0L, 1L),
          x = c( 2,  1,  1,  2,  1,  2),
          p = c(0:2, 4L, 4L, 6L))

## Previously unsorted columns were sorted - now are flagged as invalid
m. <- mm
ip <- c(1:2, 4:3, 6:5) # permute the 'i' and 'x' slot just "inside column":
m.@i <- m.i <- mm@i[ip]
m.@x <- m.x <- mm@x[ip]
stopifnot(grep("row indices are not", validObject(m., test=TRUE)) == 1)
Matrix:::.sortCsparse(m.) # don't use this at home, boys!
m. # now is fixed

## Make sure that validObject() objects...
## 1) to wrong 'p'
m. <- mm; m.@p[1] <- 1L
stopifnot(grep("first element of slot p", validObject(m., test=TRUE)) == 1)
m.@p <- mm@p[c(1,3:2,4:6)]
stopifnot(grep("^slot p.* non-decreasing", validObject(m., test=TRUE)) == 1)
## 2) to non-strictly increasing i's:
m. <- mm ; ix <- c(1:3,3,5:6)
m.@i <- mm@i[ix]
m.@x <- mm@x[ix]
stopifnot(identical(grep("slot i is not.* increasing .*column$",
                         validObject(m., test=TRUE)), 1L))
## ix <- c(1:3, 3:6) # now the the (i,x) slots are too large (and decreasing at end)
## m.@i <- mm@i[ix]
## m.@x <- mm@x[ix]
## stopifnot(identical(grep("^slot i is not.* increasing .*sort",
##                          (msg <- validObject(m., test=TRUE))),# seg.fault in the past
##                     1L))

## over-allocation of the i- and x- slot should be allowed:
## (though it does not really help in M[.,.] <- *  yet)
m. <- mm
m.@i <- c(mm@i, NA, NA, NA)
m.@x <- c(mm@x, 10:12)
validObject(m.)
m. # show() now works
stopifnot(all(m. == mm), # in spite of
	  length(m.@i) > length(mm@i),
          identical(t(t(m.)), mm),
	  identical3(m. * m., m. * mm, mm * mm))
m.[1,4] <- 99 ## FIXME: warning and cuts (!) the over-allocated slots

## Low-level construction of invalid object:
##  Ensure that it does *NOT* segfault
foo <- new("ngCMatrix",
           i = as.integer(c(12204, 16799, 16799, 33517, 1128, 11930, 1128, 11930, 32183)),
           p = rep(0:9, c(2,4,1,11,10,0,1,0,9,12)),
           Dim = c(36952L, 49L))
validObject(foo)# TRUE
foo@i[5] <- foo@i[5] + 50000L
msg <- validObject(foo, test=TRUE)# is -- correctly -- *not* valid anymore
stopifnot(is.character(msg))
## Error in validObject(foo) :
##   invalid class "ngCMatrix" object: all row indices must be between 0 and nrow-1
getLastMsg <- function(tryRes) {
    ## Extract "final" message from erronous try result
    sub("\n$", "",
        sub(".*: ", "", as.character(tryRes)))
}
t <- try(show(foo)) ## error
t2 <- try(head(foo))
stopifnot(identical(msg, getLastMsg(t)),
	  identical(1L, grep("as_cholmod_sparse", getLastMsg(t2))))


cat('Time elapsed: ', proc.time(),'\n') # "stats"

if(!interactive()) warnings()
