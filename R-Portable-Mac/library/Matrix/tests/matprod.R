library(Matrix)

### Matrix Products including  cross products

source(system.file("test-tools.R", package = "Matrix")) # is.EQ.mat(), dnIdentical() ..etc
doExtras
options(warn=1, # show as they happen
	Matrix.verbose = doExtras)

##' Check matrix multiplications with (unit) Diagonal matrices
chkDiagProd <- function(M) {
    stopifnot(is.matrix(M) || is(M,"Matrix"))
    I.l  <- Diagonal(nrow(M)) # I_n -- "unit" Diagonal
    I.r  <- Diagonal(ncol(M)) # I_d
    D2.l <- Diagonal(nrow(M), x = 2) # D_n
    D2.r <- Diagonal(ncol(M), x = 2) # I_d
    stopifnot(is.EQ.mat(M, M %*% I.r),
	      is.EQ.mat(M, I.l %*% M),
	      is.EQ.mat(2*M, M %*% D2.r),
	      is.EQ.mat(M*2, D2.l %*% M),
	      ## crossprod
	      is.EQ.mat(t(M), crossprod(M, I.l)),
	      is.EQ.mat(  M , crossprod(I.l, M)),
	      is.EQ.mat(t(2*M), crossprod(M, D2.l)),
	      is.EQ.mat(  M*2 , crossprod(D2.l, M)),
	      ## tcrossprod
	      is.EQ.mat(  M , tcrossprod(M, I.r)),
	      is.EQ.mat(t(M), tcrossprod(I.r, M)),
	      is.EQ.mat(  2*M , tcrossprod(M, D2.r)),
	      is.EQ.mat(t(M*2), tcrossprod(D2.r, M)))
}

### dimnames -- notably for matrix products ----------------
#
##' Checks that matrix products are the same, including dimnames
##'
##' @param m matrix = traditional-R-matrix version of M
##' @param M optional Matrix = "Matrix class version of m"
##' @param browse
chkDnProd <- function(m = as(M, "matrix"), M = Matrix(m), browse=FALSE, warn.ok=FALSE) {
    ## TODO:
    ## if(browse) stopifnot <- f.unction(...)  such that it enters browser() when it is not fulfilled
    if(!warn.ok) { # NO warnings allowd
        op <- options(warn = 2)
        on.exit(options(op))
    }
    stopifnot(is.matrix(m), is(M, "Matrix"), identical(dim(m), dim(M)), dnIdentical(m,M))
    ## m is  n x d  (say)
    is.square <- nrow(m) == ncol(m)

    p1 <- (tm <- t(m)) %*% m ## d x d
    p1. <- crossprod(m)
    stopifnot(is.EQ.mat3(p1, p1., crossprod(m,m)))

    t1 <- m %*% tm ## n x n
    t1. <- tcrossprod(m)
    stopifnot(is.EQ.mat3(t1, t1., tcrossprod(m,m)))

    if(is.square) {
	mm <- m %*% m
	stopifnot(is.EQ.mat3(mm, crossprod(tm,m), tcrossprod(m,tm)))
    }

    chkDiagProd(m)## was not ok in Matrix 1.2.0

    ## Now the	"Matrix" ones -- should match the "matrix" above
    M0 <- M
    cat("sparse: ")
    for(sparse in c(TRUE, FALSE)) {
	cat(sparse, "; ")
	M <- as(M0, if(sparse) "sparseMatrix" else "denseMatrix")
	P1 <- (tM <- t(M)) %*% M
	P1. <- crossprod(M)
	stopifnot(is.EQ.mat3(P1, P1., p1),
		  is.EQ.mat3(P1., crossprod(M,M), crossprod(M,m)),
		  is.EQ.mat (P1., crossprod(m,M)))

	## P1. is "symmetricMatrix" -- semantically "must have" symm.dimnames
	PP1 <- P1. %*% P1. ## still  d x d
	R <- triu(PP1); r <- as(R, "matrix") # upper - triangular
	L <- tril(PP1); l <- as(L, "matrix") # lower - triangular
	stopifnot(isSymmetric(P1.), isSymmetric(PP1),
		  isDiagonal(L) || is(L,"triangularMatrix"),
		  isDiagonal(R) || is(R,"triangularMatrix"),
		  isTriangular(L, upper=FALSE), isTriangular(R, upper=TRUE),
		  is.EQ.mat(PP1, (pp1 <- p1 %*% p1)),
		  dnIdentical(PP1, R),
		  dnIdentical(L, R))

	T1 <- M %*% tM
	T1. <- tcrossprod(M)
	stopifnot(is.EQ.mat3(T1, T1., t1),
		  is.EQ.mat3(T1., tcrossprod(M,M), tcrossprod(M,m)),
		  is.EQ.mat (T1., tcrossprod(m,M)),
		  is.EQ.mat(tcrossprod(T1., tM),
			    tcrossprod(t1., tm)),
		  is.EQ.mat(crossprod(T1., M),
			    crossprod(t1., m)))

	## Now, *mixing*  Matrix x matrix:
	stopifnot(is.EQ.mat3(tM %*% m, tm %*% M, tm %*% m))

	if(is.square)
	    stopifnot(is.EQ.mat (mm, M %*% M),
		      is.EQ.mat3(mm, crossprod(tM,M), tcrossprod(M,tM)),
		      ## "mixing":
		      is.EQ.mat3(mm, crossprod(tm,M), tcrossprod(m,tM)),
		      is.EQ.mat3(mm, crossprod(tM,m), tcrossprod(M,tm)))

	## Symmetric and Triangular
	stopifnot(is.EQ.mat(PP1 %*% tM, pp1 %*% tm),
		  is.EQ.mat(R %*% tM, r %*% tm),
		  is.EQ.mat(L %*% tM, L %*% tm))

	## Diagonal :
	chkDiagProd(M)
    }
    cat("\n")
    invisible(TRUE)
}

## All these are ok  {now, (2012-06-11) also for dense
(m <- matrix(c(0, 0, 2:0), 3, 5))
m00 <- m # *no* dimnames
dimnames(m) <- list(LETTERS[1:3], letters[1:5])
(m.. <- m) # has *both* dimnames
m0. <- m.0 <- m..
dimnames(m0.)[1] <- list(NULL); m0.
dimnames(m.0)[2] <- list(NULL); m.0
d <- diag(3); dimnames(d) <- list(c("u","v","w"), c("X","Y","Z")); d
dU <- diagN2U(Matrix(d)) # unitriangular sparse
(T <- new("dtrMatrix", diag = "U", x= c(0,0,5,0), Dim= c(2L,2L),
          Dimnames= list(paste0("r",1:2),paste0("C",1:2)))) # unitriangular dense
##                                                                   ^^^^^^^^^^^^
## currently many warnings about sub-optimal matrix products :
chkDnProd(m..)
chkDnProd(m0.)
chkDnProd(m.0)
chkDnProd(m00)
chkDnProd(M =   T)
chkDnProd(M = t(T))
chkDnProd(M =   dU)
chkDnProd(M = t(dU))
## all the above failed in 1.2-0 and 1.1-5, 1.1-4 some even earlier
chkDnProd(M = Diagonal(4))
chkDnProd(diag(x=3:1))
chkDnProd(d)
chkDnProd(M = as(d, "denseMatrix"))# M: dtrMatrix (diag = "N")


m5 <- 1 + as(diag(-1:4)[-5,], "dgeMatrix")
## named dimnames:
dimnames(m5) <- list(Rows= LETTERS[1:5], paste("C", 1:6, sep=""))
tr5 <- tril(m5[,-6])
m. <- as(m5, "matrix")
m5.2 <- local({t5 <- as.matrix(tr5); t5 %*% t5})
stopifnotValid(tr5, "dtrMatrix")
stopifnot(dim(m5) == 5:6,
	  class(cm5 <- crossprod(m5)) == "dpoMatrix")
assert.EQ.mat(t(m5) %*% m5, as(cm5, "matrix"))
assert.EQ.mat(tr5.2 <- tr5 %*% tr5, m5.2)
stopifnotValid(tr5.2, "dtrMatrix")
stopifnot(as.vector(rep(1,6) %*% cm5) == colSums(cm5),
	  as.vector(cm5 %*% rep(1,6)) == rowSums(cm5))
## uni-diagonal dtrMatrix with "wrong" entries in diagonal
## {the diagonal can be anything: because of diag = "U" it should never be used}:
tru <- Diagonal(3, x=3); tru[i.lt <- lower.tri(tru, diag=FALSE)] <- c(2,-3,4)
tru@diag <- "U" ; stopifnot(diag(trm <- as.matrix(tru)) == 1)
## TODO: Also add *upper-triangular*  *packed* case !!
stopifnot((tru %*% tru)[i.lt] ==
	  (trm %*% trm)[i.lt])

## crossprod() with numeric vector RHS and LHS
i5 <- rep.int(1, 5)
isValid(S5 <- tcrossprod(tr5), "dpoMatrix")# and inherits from "dsy"
G5 <- as(S5, "generalMatrix")# "dge"
assert.EQ.mat( crossprod(i5, m5), rbind( colSums(m5)))
assert.EQ.mat( crossprod(i5, m.), rbind( colSums(m5)))
assert.EQ.mat( crossprod(m5, i5), cbind( colSums(m5)))
assert.EQ.mat( crossprod(m., i5), cbind( colSums(m5)))
assert.EQ.mat( crossprod(i5, S5), rbind( colSums(S5))) # failed in Matrix 1.1.4
## tcrossprod() with numeric vector RHS and LHS :
stopifnot(identical(tcrossprod(i5, S5), # <- lost dimnames
		    tcrossprod(i5, G5) -> m51),
	  identical(dimnames(m51), list(NULL, LETTERS[1:5]))
	  )
m51 <- m5[, 1, drop=FALSE] # [6 x 1]
m.1 <- m.[, 1, drop=FALSE] ; assert.EQ.mat(m51, m.1)
## The only (M . v) case
assert.EQ.mat(tcrossprod(m51, 5:1), tcrossprod(m.1, 5:1))
## The two  (v . M) cases:
assert.EQ.mat(tcrossprod(rep(1,6), m.), rbind( rowSums(m5)))# |v| = ncol(m)
assert.EQ.mat(tcrossprod(rep(1,3), m51),
              tcrossprod(rep(1,3), m.1))# ncol(m) = 1

## classes differ
tc.m5 <- m5 %*% t(m5)	 # "dge*", no dimnames (FIXME)
(tcm5 <- tcrossprod(m5)) # "dpo*"  w/ dimnames
assert.EQ.mat(tc.m5, mm5 <- as(tcm5, "matrix"))
## tcrossprod(x,y) :
assert.EQ.mat(tcrossprod(m5, m5), mm5)
assert.EQ.mat(tcrossprod(m5, m.), mm5)
assert.EQ.mat(tcrossprod(m., m5), mm5)

M50 <- m5[,FALSE, drop=FALSE]
M05 <- t(M50)
s05 <- as(M05, "sparseMatrix")
s50 <- t(s05)
assert.EQ.mat(M05, matrix(1, 0,5))
assert.EQ.mat(M50, matrix(1, 5,0))
assert.EQ.mat(tcrossprod(M50), tcrossprod(as(M50, "matrix")))
assert.EQ.mat(tcrossprod(s50), tcrossprod(as(s50, "matrix")))
assert.EQ.mat( crossprod(s50),	crossprod(as(s50, "matrix")))
stopifnot(identical( crossprod(s50), tcrossprod(s05)),
	  identical( crossprod(s05), tcrossprod(s50)))
(M00 <- crossprod(M50))## used to fail -> .Call(dgeMatrix_crossprod, x, FALSE)
stopifnot(identical(M00, tcrossprod(M05)),
	  all(M00 == t(M50) %*% M50), dim(M00) == 0)

## simple cases with 'scalars' treated as 1x1 matrices:
d <- Matrix(1:5)
d %*% 2
10 %*% t(d)
assertError(3 %*% d)		 # must give an error , similar to
assertError(5 %*% as.matrix(d))	 # -> error

## right and left "numeric" and "matrix" multiplication:
(p1 <- m5 %*% c(10, 2:6))
(p2 <- c(10, 2:5) %*% m5)
(pd1 <- m5 %*% diag(1:6))
(pd. <- m5 %*% Diagonal(x = 1:6))
(pd2 <- diag (10:6)	   %*% m5)
(pd..<- Diagonal(x = 10:6) %*% m5)
stopifnot(dim(crossprod(t(m5))) == c(5,5),
	  c(class(p1),class(p2),class(pd1),class(pd2),
	    class(pd.),class(pd..)) == "dgeMatrix")
assert.EQ.mat(p1, cbind(c(20,30,33,38,54)))
assert.EQ.mat(pd1, m. %*% diag(1:6))
assert.EQ.mat(pd2, diag(10:6) %*% m.)
assert.EQ.mat(pd., as(pd1,"matrix"))
assert.EQ.mat(pd..,as(pd2,"matrix"))

## check that 'solve' and '%*%' are inverses
set.seed(1)
A <- Matrix(rnorm(25), nc = 5)
y <- rnorm(5)
all.equal((A %*% solve(A, y))@x, y)
Atr <- new("dtrMatrix", Dim = A@Dim, x = A@x, uplo = "U")
all.equal((Atr %*% solve(Atr, y))@x, y)

## R-forge bug 5933 by Sebastian Herbert,
## https://r-forge.r-project.org/tracker/index.php?func=detail&aid=5933&group_id=61&atid=294
mLeft  <- matrix(data = double(0), nrow = 3, ncol = 0)
mRight <- matrix(data = double(0), nrow = 0, ncol = 4)
MLeft   <- Matrix(data = double(0), nrow = 3, ncol = 0)
MRight  <- Matrix(data = double(0), nrow = 0, ncol = 4)
stopifnot(identical3(class(mLeft), class(mRight), "matrix"))
stopifnot(class(MLeft) ==  class(MRight),
          class(MLeft) ==  "dgeMatrix")

Qidentical3 <- function(a,b,c) Q.eq(a,b) && Q.eq(b,c)
Qidentical4 <- function(a,b,c,d) Q.eq(a,b) && Q.eq(b,c) && Q.eq(c,d)
chkP <- function(mLeft, mRight, MLeft, MRight, cl = class(MLeft)) {
    ident4 <- if(extends(cl, "generalMatrix"))
		  function(a,b,c,d) identical4(as(a, cl), b, c, d)
	      else function(a,b,c,d) {
		  assert.EQ.mat(M=b, m=a, tol=0)
		  Qidentical3(b,c,d)
	      }
    mm <- mLeft %*% mRight # ok
    m.m <- crossprod(mRight)
    mm. <- tcrossprod(mLeft, mLeft)
    stopifnot(mm == 0,
              ident4(mm,
                     mLeft %*% MRight,
                     MLeft %*% mRight,
                     MLeft %*% MRight),# now ok
	      m.m == 0, identical(m.m, crossprod(mRight, mRight)),
	      mm. == 0, identical(mm., tcrossprod(mLeft, mLeft)))
    stopifnot(ident4(m.m,
		     crossprod(MRight, MRight),
		     crossprod(MRight, mRight),
		     crossprod(mRight, MRight)))
    stopifnot(ident4(mm.,
		     tcrossprod(mLeft, MLeft),
		     tcrossprod(MLeft, MLeft),
		     tcrossprod(MLeft, mLeft)))
}

chkP(mLeft, mRight, MLeft, MRight, "dgeMatrix")
m0 <- mLeft[FALSE,] # 0 x 0
for(cls in c("triangularMatrix", "symmetricMatrix")) {
    cat(cls,": "); stopifnotValid(ML0 <- as(MLeft[FALSE,], cls), cls)
    chkP(m0, mRight, ML0, MRight, class(ML0))
    chkP(mLeft, m0 , MLeft, ML0 , class(ML0))
    chkP(m0,    m0 , ML0,   ML0 , class(ML0)); cat("\n")
}


## New in R 3.2.0 -- for traditional matrix m and vector v
for(spV in c(FALSE,TRUE)) {
    cat("sparseV:", spV, "\n")
    v <- if(spV) as(1:3, "sparseVector") else 1:3
    stopifnot(identical(class(v2 <- v[1:2]), class(v)))
    assertError(crossprod(v, v2)) ; assertError(v %*% v2)
    assertError(crossprod(v, 1:2)); assertError(v %*% 1:2)
    assertError(crossprod(v, 2))  ; assertError(v %*% 2)
    assertError(crossprod(1:2, v)); assertError(1:2 %*% v)
    if(spV || getRversion() >= "3.2.0") {
	cat("doing  vec x vec  ..\n")
	stopifnot(identical(crossprod(2, v), t(2) %*% v),
		  identical(5 %*% v, 5 %*% t(v)))
    }
    for(sp in c(FALSE, TRUE)) {
        m <- Matrix(1:2, 1,2, sparse=sp)
        cat(sprintf("class(m): '%s'\n", class(m)))
	stopifnot(identical( crossprod(m, v), t(m) %*% v), # m'v gave *outer* prod wrongly!
		  identical(tcrossprod(m, v2), m %*% v2))
	assert.EQ.Mat(m %*% v2, m %*% 1:2, tol=0)
    }
    ## gave error "non-conformable arguments"
}
##  crossprod(m, v)  t(1 x 2) * 3 ==> (2 x 1) *  (1 x 3) ==> 2 x 3
## tcrossprod(m,v2)    1 x 2  * 2 ==> (1 x 2) * t(1 x 2) ==> 1 x 1

### ------ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Sparse Matrix products
### ------
## solve() for dtC*
mc <- round(chol(crossprod(A)), 2)
B <- A[1:3,] # non-square on purpose
stopifnot(all.equal(sum(rowSums(B %*% mc)), 5.82424475145))
assert.EQ.mat(tcrossprod(B, mc), as.matrix(t(tcrossprod(mc, B))))

m <- kronecker(Diagonal(2), mc)
stopifnot(is(mc, "Cholesky"),
	  is(m, "sparseMatrix"))
im <- solve(m)
round(im, 3)
itm <- solve(t(m))
iim <- solve(im) # should be ~= 'm' of course
iitm <- solve(itm)
I <- Diagonal(nrow(m))
(del <- c(mean(abs(as.numeric(im %*% m - I))),
	  mean(abs(as.numeric(m %*% im - I))),
	  mean(abs(as.numeric(im  - t(itm)))),
	  mean(abs(as.numeric( m  - iim))),
	  mean(abs(as.numeric(t(m)- iitm)))))
stopifnot(is(m, "triangularMatrix"), is(m, "sparseMatrix"),
	  is(im, "dtCMatrix"), is(itm, "dtCMatrix"), is(iitm, "dtCMatrix"),
	  del < 1e-15)

## crossprod(.,.) & tcrossprod(),  mixing dense & sparse
v <- c(0,0,2:0)
mv <- as.matrix(v) ## == cbind(v)
(V <- Matrix(v, 5,1, sparse=TRUE))
sv <- as(v, "sparseVector")
a <- as.matrix(A)
cav <-	crossprod(a,v)
tva <- tcrossprod(v,a)
assert.EQ.mat(crossprod(A, V), cav) # gave infinite recursion
assert.EQ.mat(crossprod(A,sv), cav)
assert.EQ.mat(tcrossprod( sv, A), tva)
assert.EQ.mat(tcrossprod(t(V),A), tva)

## [t]crossprod()  for  <sparsevector> . <sparsevector>  incl. one arg.:
stopifnotValid(s.s <-  crossprod(sv,sv), "Matrix")
stopifnotValid(ss. <- tcrossprod(sv,sv), "sparseMatrix")
stopifnot(identical(s.s,  crossprod(sv)),
	  identical(ss., tcrossprod(sv)))
assert.EQ.mat(s.s,  crossprod(v,v))
assert.EQ.mat(ss., tcrossprod(v,v))

dm <- Matrix(v, sparse=FALSE)
sm <- Matrix(v, sparse=TRUE)

validObject(d.vvt <- as(as(vvt <- tcrossprod(v, v), "denseMatrix"), "dgeMatrix"))
validObject(s.vvt <- as(as(vvt, "sparseMatrix"), "dgCMatrix"))

stopifnot(
    identical4(tcrossprod(v, v), tcrossprod(mv, v),
	       tcrossprod(v,mv), tcrossprod(mv,mv))## (base R)
    ,
    identical4(d.vvt,		 tcrossprod(dm, v),
	       tcrossprod(v,dm), tcrossprod(dm,dm)) ## (v, dm) failed
    ,
    identical(s.vvt, tcrossprod(sm,sm))
    ,
    identical3(d.vvt, tcrossprod(sm, v),
               tcrossprod(v,sm)) ## both (sm,v) and (v,sm) failed
    )
assert.EQ.mat(d.vvt, vvt)
assert.EQ.mat(s.vvt, vvt)

M <- Matrix(0:5, 2,3) ; sM <- as(M, "sparseMatrix"); m <- as(M, "matrix")
v <- 1:3; v2 <- 2:1
sv  <- as( v, "sparseVector")
sv2 <- as(v2, "sparseVector")
tvm <- tcrossprod(v, m)
assert.EQ.mat(tcrossprod( v, M), tvm)
assert.EQ.mat(tcrossprod( v,sM), tvm)
assert.EQ.mat(tcrossprod(sv,sM), tvm)
assert.EQ.mat(tcrossprod(sv, M), tvm)
assert.EQ.mat(crossprod(M, sv2), crossprod(m, v2))
stopifnot(identical(tcrossprod(v, M), v %*% t(M)),
	  identical(tcrossprod(v,sM), v %*% t(sM)),
	  identical(tcrossprod(v, M), crossprod(v, t(M))),
	  identical(tcrossprod(sv,sM), sv %*% t(sM)),
	  identical(crossprod(sM, sv2), t(sM) %*% sv2),
	  identical(crossprod(M, v2), t(M) %*% v2))

## *unit* triangular :
t1 <- new("dtTMatrix", x= c(3,7), i= 0:1, j=3:2, Dim= as.integer(c(4,4)))
## from	 0-diagonal to unit-diagonal {low-level step}:
tu <- t1 ; tu@diag <- "U"
cu <- as(tu, "dtCMatrix")
cl <- t(cu) # unit lower-triangular
cl10 <- cl %*% Diagonal(4, x=10)
assert.EQ.mat(cl10, as(cl, "matrix") %*% diag(4, x=10))
stopifnot(is(cl,"dtCMatrix"), cl@diag == "U")
(cu2 <- cu %*% cu)
cl2 <- cl %*% cl
validObject(cl2)

cu3 <- tu[-1,-1]
assert.EQ.mat(crossprod(tru, cu3),## <- "FIXME" should return triangular ...
	      crossprod(trm, as.matrix(cu3)))

cl2
mcu <- as.matrix(cu)
cu2. <- Diagonal(4) + Matrix(c(rep(0,9),14,0,0,6,0,0,0), 4,4)
D4 <- Diagonal(4, x=10:7); d4 <- as(D4, "matrix")
D.D4 <- crossprod(D4); assert.EQ.mat(D.D4, crossprod(d4))
stopifnotValid(D.D4, "ddiMatrix")
stopifnotValid(su <- crossprod(cu), "dsCMatrix")
stopifnot(
    all(cu2 == cu2.)
   ,# was wrong for ver. <= 0.999375-4
          identical(D.D4, tcrossprod(D4))
,
          identical4(crossprod(d4, D4), crossprod(D4, d4), tcrossprod(d4, D4), D.D4)
,
	  is(cu2, "dtCMatrix"), is(cl2, "dtCMatrix"), # triangularity preserved
	  cu2@diag == "U", cl2@diag == "U",# UNIT-triangularity preserved
	  all.equal(D4 %*% cu, D4 %*% mcu)
,
	  all.equal(cu %*% D4, mcu %*% D4)
,
	  all(D4 %*% su == D4 %*% as.mat(su))
,
	  all(su %*% D4 == as.mat(su) %*% D4)
,
	  identical(t(cl2), cu2)
  , # !!
          identical ( crossprod(cu, D4),  crossprod(mcu, D4))
,
          identical4(tcrossprod(cu, D4), tcrossprod(mcu, D4), cu %*% D4, mcu %*% D4)
,
          identical4(tcrossprod(D4,cu), tcrossprod(D4,mcu), D4 %*% t(cu), D4 %*% t(mcu))
,
	  identical( crossprod(cu), Matrix( crossprod(mcu),sparse=TRUE))
,
	  identical(tcrossprod(cu), Matrix(tcrossprod(mcu),sparse=TRUE))
    )
assert.EQ.mat( crossprod(cu, D4),  crossprod(mcu, d4))
assert.EQ.mat(tcrossprod(cu, D4), tcrossprod(mcu, d4))
tr8 <- kronecker(rbind(c(2,0),c(1,4)), cl2)
T8 <- tr8 %*% (tr8/2) # triangularity preserved?
T8.2 <- (T8 %*% T8) / 4
stopifnot(is(T8, "triangularMatrix"), T8@uplo == "L", is(T8.2, "dtCMatrix"))
mr8 <- as(tr8,"matrix")
m8. <- (mr8 %*% mr8 %*% mr8 %*% mr8)/16
assert.EQ.mat(T8.2, m8.)

data(KNex); mm <- KNex$mm
M <- mm[1:500, 1:200]
MT <- as(M, "TsparseMatrix")
cpr   <- t(mm) %*% mm
cpr.  <- crossprod(mm)
cpr.. <- crossprod(mm, mm)
stopifnot(is(cpr., "symmetricMatrix"),
	  identical3(cpr, as(cpr., class(cpr)), cpr..))
## with dimnames:
m <- Matrix(c(0, 0, 2:0), 3, 5)
dimnames(m) <- list(LETTERS[1:3], letters[1:5])
m
p1 <- t(m) %*% m
(p1. <- crossprod(m))
t1 <- m %*% t(m)
(t1. <- tcrossprod(m))
stopifnot(isSymmetric(p1.),
	  isSymmetric(t1.),
	  identical(p1, as(p1., class(p1))),
	  identical(t1, as(t1., class(t1))),
	  identical(dimnames(p1), dimnames(p1.)),
	  identical(dimnames(p1), list(colnames(m), colnames(m))),
	  identical(dimnames(t1), dimnames(t1.))
	  )

showMethods("%*%", class=class(M))

v1 <- rep(1, ncol(M))
str(r <-  M %*% Matrix(v1))
str(rT <- MT %*% Matrix(v1))
stopifnot(identical(r, rT))
str(r. <- M %*% as.matrix(v1))
stopifnot(identical4(r, r., rT, M %*% as(v1, "matrix")))

v2 <- rep(1,nrow(M))
r2 <- t(Matrix(v2)) %*% M
r2T <- v2 %*% MT
str(r2. <- v2 %*% M)
stopifnot(identical3(r2, r2., t(as(v2, "matrix")) %*% M))


###------------------------------------------------------------------
### Close to singular matrix W
### (from  micEconAids/tests/aids.R ... priceIndex = "S" )
(load(system.file("external", "symW.rda", package="Matrix"))) # "symW"
stopifnot(is(symW, "symmetricMatrix"))
n <- nrow(symW)
I <- .sparseDiagonal(n, shape="g")
S <- as(symW, "matrix")
sis <- solve(S,    S)
## solve(<dsCMatrix>, <sparseMatrix>) when Cholmod fails was buggy for *long*:
SIS <- solve(symW, symW)
iw <- solve(symW)
iss <- iw %*% symW
##                                     nb-mm3   openBLAS (Avi A.)
assert.EQ.(I, drop0(sis), tol = 1e-8)# 2.6e-10;  7.96e-9
assert.EQ.(I, SIS,        tol = 1e-7)# 8.2e-9
assert.EQ.(I, iss,        tol = 4e-4)# 3.3e-5
## solve(<dsCMatrix>, <dense..>) :
I <- diag(nr=n)
SIS <- solve(symW, as(symW,"denseMatrix"))
iw  <- solve(symW, I)
iss <- iw %*% symW
assert.EQ.mat(SIS, I, tol = 1e-7, giveRE=TRUE)
assert.EQ.mat(iss, I, tol = 4e-4, giveRE=TRUE)
rm(SIS,iss)

WW <- as(symW, "generalMatrix") # the one that gave problems
IW <- solve(WW)
class(I1 <- IW %*% WW)# "dge" or "dgC" (!)
class(I2 <- WW %*% IW)
## these two were wrong for for M.._1.0-13:
assert.EQ.(as(I1,"matrix"), I, tol = 1e-4)
assert.EQ.(as(I2,"matrix"), I, tol = 7e-7)

## now slightly perturb WW (and hence break exact symmetry
set.seed(131); ii <- sample(length(WW), size= 100)
WW[ii] <- WW[ii] * (1 + 1e-7*runif(100))
SW. <- symmpart(WW)
SW2 <- Matrix:::forceSymmetric(WW)
stopifnot(all.equal(as(SW.,"matrix"),
                    as(SW2,"matrix"), tol = 1e-7))
(ch <- all.equal(WW, as(SW.,"dgCMatrix"), tolerance =0))
stopifnot(is.character(ch), length(ch) == 1)## had length(.)  2  previously
IW <- solve(WW)
class(I1 <- IW %*% WW)# "dge" or "dgC" (!)
class(I2 <- WW %*% IW)
I <- diag(nr=nrow(WW))
stopifnot(all.equal(as(I1,"matrix"), I, check.attributes=FALSE, tolerance = 1e-4),
          ## "Mean relative difference: 3.296549e-05"  (or "1.999949" for Matrix_1.0-13 !!!)
          all.equal(as(I2,"matrix"), I, check.attributes=FALSE)) #default tol gives "1" for M.._1.0-13

if(doExtras) {
    print(kappa(WW)) ## [1] 5.129463e+12
    print(rcond(WW)) ## [1] 6.216103e-14
    ## Warning message: rcond(.) via sparse -> dense coercion
}

class(Iw. <- solve(SW.))# FIXME? should be "symmetric" but is not
class(Iw2 <- solve(SW2))# FIXME? should be "symmetric" but is not
class(IW. <- as(Iw., "denseMatrix"))
class(IW2 <- as(Iw2, "denseMatrix"))

### The next two were wrong for very long, too
assert.EQ.(I, as.matrix(IW. %*% SW.), tol= 4e-4)
assert.EQ.(I, as.matrix(IW2 %*% SW2), tol= 4e-4)
dIW <- as(IW, "denseMatrix")
assert.EQ.(dIW, IW., tol= 4e-4)
assert.EQ.(dIW, IW2, tol= 8e-4)

##------------------------------------------------------------------



## Sparse Cov.matrices from  Harri Kiiveri @ CSIRO
a <- matrix(0,5,5)
a[1,2] <- a[2,3] <- a[3,4] <- a[4,5] <- 1
a <- a + t(a) + 2*diag(5)
b <- as(a, "dsCMatrix") ## ok, but we recommend to use Matrix() ``almost always'' :
(b. <- Matrix(a, sparse = TRUE))
stopifnot(identical(b, b.))

## calculate conditional variance matrix ( vars 3 4 5 given 1 2 )
(B2 <- b[1:2, 1:2])
bb <- b[1:2, 3:5]
stopifnot(is(B2, "dsCMatrix"), # symmetric indexing keeps symmetry
	  identical(as.mat(bb), rbind(0, c(1,0,0))),
	  ## TODO: use fully-sparse cholmod_spsolve() based solution :
	  is(z.s <- solve(B2, bb), "sparseMatrix"))
assert.EQ.mat(B2 %*% z.s, as(bb, "matrix"))
## -> dense RHS and dense result
z. <- solve(as(B2, "dgCMatrix"), bb)# now *sparse*
z  <- solve( B2, as(bb,"dgeMatrix"))
stopifnot(is(z., "sparseMatrix"),
          all.equal(z, as(z.,"denseMatrix")))
## finish calculating conditional variance matrix
v <- b[3:5,3:5] - crossprod(bb,z)
stopifnot(all.equal(as.mat(v),
		    matrix(c(4/3, 1:0, 1,2,1, 0:2), 3), tol = 1e-14))


###--- "logical" Matrices : ---------------------

##__ FIXME __ now works for lsparse* and nsparse* but not yet for  lge* and nge* !

## Robert's Example, a bit more readable
fromTo <- rbind(c(2,10),
		c(3, 9))
N <- 10
nrFT <- nrow(fromTo)
rowi <- rep.int(1:nrFT, fromTo[,2]-fromTo[,1] + 1) - 1:1
coli <- unlist(lapply(1:nrFT, function(x) fromTo[x,1]:fromTo[x,2])) - 1:1

# ## "n" --- nonzero pattern Matrices

chk.ngMatrix <- function(M, verbose = TRUE) {
    if(!(is(M, "nsparseMatrix") && length(d <- dim(M)) == 2 && d[1] == d[2]))
        stop("'M' must be a square sparse [patter]n Matrix")
    if(verbose)
        show(M)
    m  <- as(M, "matrix")

    ## Part I : matrix products of pattern Matrices
    ## ------   For now [by default]: *pattern* <==> boolean arithmetic
    ## ==> FIXME ??: warning that this will change?
    MM <- M %*% M # pattern (ngC)
    if(verbose) { cat("M %*% M:\n"); show(MM) }
    assert.EQ.mat(MM, m %*% m)
    assert.EQ.mat(t(M) %*% M, ## <- 'pattern', because of cholmod_ssmult()
                  (t(m) %*% m) > 0, tol=0)
    cM <-  crossprod(M) # pattern  {FIXME ?? warning ...}
    tM <- tcrossprod(M) # pattern  {FIXME ?? warning ...}
    if(verbose) {cat( "crossprod(M):\n"); show(cM) }
    if(verbose) {cat("tcrossprod(M):\n"); show(tM) }
    stopifnot(is(cM,"symmetricMatrix"), is(tM,"symmetricMatrix"),
	      identical(as( cM, "ngCMatrix"), t(M) %*%   M),
	      identical(as( tM, "ngCMatrix"),  M   %*% t(M)))
    assert.EQ.mat( cM,  crossprod(m) > 0)
    assert.EQ.mat( tM, as(tcrossprod(m),"matrix") > 0)

    ## Part II : matrix products pattern Matrices with numeric:
    ##
    ## "n" x "d" (and "d" x "n") --> "d", i.e. numeric in any case
    dM <- as(M, "dMatrix")
    stopifnot( ## dense ones:
        identical( M %*% m, m %*% M -> Mm)
       , ## sparse ones :
        identical3(
            M %*% dM, dM %*% M -> sMM,
            as(as(m %*% m, "sparseMatrix"), class(sMM)))
        )
    if(verbose) {cat( "M %*% m:\n"); show(Mm) }
    stopifnotValid(Mm,  "dMatrix") # not "n.."
    stopifnotValid(sMM, "dMatrix") # not "n.."
    stopifnotValid(cdM <-  crossprod(dM, M), "CsparseMatrix")
    stopifnotValid(tdM <- tcrossprod(dM, M), "CsparseMatrix")
    assert.EQ.mat (cdM,  crossprod(m))
    assert.EQ.mat (tdM, tcrossprod(m))
    stopifnot(identical( crossprod(dM), as(cdM, "symmetricMatrix")))
    stopifnot(identical(tcrossprod(dM), as(tdM, "symmetricMatrix")))
    invisible(TRUE)
}

sM <- new("ngTMatrix", i = rowi, j=coli, Dim=as.integer(c(N,N)))
chk.ngMatrix(sM) # "ngTMatrix"
chk.ngMatrix(tsM <- as(sM, "triangularMatrix")) #  ntT
chk.ngMatrix(as( sM, "CsparseMatrix"))  #  ngC
chk.ngMatrix(as(tsM, "CsparseMatrix"))  #  ntC

## "l" --- logical Matrices -- use usual 0/1 arithmetic
nsM <- sM
sM  <- as(sM, "lMatrix")
sm <- as(sM, "matrix")
stopifnot(identical(sm, as.matrix(nsM)))
stopifnotValid(sMM <- sM %*% sM, "dsparseMatrix")
assert.EQ.mat (sMM,   sm %*% sm)
assert.EQ.mat(t(sM) %*% sM,
	      t(sm) %*% sm, tol=0)
stopifnotValid(cM <- crossprod(sM),  "dsCMatrix")
stopifnotValid(tM <- tcrossprod(sM), "dsCMatrix")
stopifnot(identical(cM, as(t(sM) %*% sM, "symmetricMatrix")),
	  identical(tM, forceSymmetric(sM %*% t(sM))))
assert.EQ.mat( cM,     crossprod(sm))
assert.EQ.mat( tM, as(tcrossprod(sm),"matrix"))
dm <- as(sM, "denseMatrix")
## the following 6 products (dm o sM) all failed up to 2013-09-03
stopifnotValid(dm %*% sM,            "CsparseMatrix")## failed {missing coercion}
stopifnotValid(crossprod (dm ,   sM),"CsparseMatrix")
stopifnotValid(tcrossprod(dm ,   sM),"CsparseMatrix")
dm[2,1] <- TRUE # no longer triangular
stopifnotValid(           dm %*% sM, "CsparseMatrix")
stopifnotValid(crossprod (dm ,   sM),"CsparseMatrix")
stopifnotValid(tcrossprod(dm ,   sM),"CsparseMatrix")

## A sparse example - with *integer* matrix:
M <- Matrix(cbind(c(1,0,-2,0,0,0,0,0,2.2,0),
		  c(2,0,0,1,0), 0, 0, c(0,0,8,0,0),0))
t(M)
(-4:5) %*% M
stopifnot(as.vector(print(t(M %*% 1:6))) ==
	  c(as(M,"matrix") %*% 1:6))
(M.M <- crossprod(M))
MM. <- tcrossprod(M)
stopifnot(class(MM.) == "dsCMatrix",
	  class(M.M) == "dsCMatrix")

M3 <- Matrix(c(rep(c(2,0),4),3), 3,3, sparse=TRUE)
I3 <- as(Diagonal(3), "CsparseMatrix")
m3 <- as.matrix(M3)
iM3 <- solve(m3)
stopifnot(all.equal(unname(iM3), matrix(c(3/2,0,-1,0,1/2,0,-1,0,1), 3)))
assert.EQ.mat(solve(as(M3, "sparseMatrix")), iM3)
assert.EQ.mat(solve(I3,I3), diag(3))
assert.EQ.mat(solve(M3, I3), iM3)# was wrong because I3 is unit-diagonal
assert.EQ.mat(solve(m3, I3), iM3)# gave infinite recursion in (<=) 0.999375-10

stopifnot(identical(ttI3 <-  crossprod(tru, I3), t(tru) %*% I3),
	  identical(tI3t <-  crossprod(I3, tru), t(I3) %*% tru),
	  identical(I3tt <- tcrossprod(I3, tru), I3 %*% t(tru)))
I3@uplo # U pper triangular
tru@uplo# L ower triangular
## "FIXME": These are all FALSE now; the first one *is* ok (L o U); the others *not*
isValid(tru %*% I3, "triangularMatrix")
isValid(ttI3, "triangularMatrix")
isValid(tI3t, "triangularMatrix")
isValid(I3tt, "triangularMatrix")

## even simpler
m <- matrix(0, 4,7); m[c(1, 3, 6, 9, 11, 22, 27)] <- 1
(mm <- Matrix(m))
(cm <- Matrix(crossprod(m)))
stopifnot(identical(crossprod(mm), cm))
(tm1 <- Matrix(tcrossprod(m))) #-> had bug in 'Matrix()' !
(tm2 <- tcrossprod(mm))
Im2 <- solve(tm2[-4,-4])
P <- as(as.integer(c(4,1,3,2)),"pMatrix")
p <- as(P, "matrix")
P %*% mm
assertError(mm %*% P) # dimension mismatch
assertError(m  %*% P) # ditto
assertError(crossprod(t(mm), P)) # ditto
stopifnotValid(tm1, "dsCMatrix")
stopifnot(
	  all.equal(tm1, tm2, tolerance =1e-15),
	  identical(drop0(Im2 %*% tm2[1:3,]), Matrix(cbind(diag(3),0))),
	  identical(p, as.matrix(P)),
	  identical(P %*% m, as.matrix(P) %*% m),
	  all(P %*% mm	==  P %*% m),
	  all(P %*% mm	-   P %*% m == 0),
	  all(t(mm) %*% P ==  t(m) %*% P),
	  identical(crossprod(m, P),
		    crossprod(mm, P)),
	  TRUE)

d <- function(m) as(m,"dsparseMatrix")
IM1 <- as(c(3,1,2), "indMatrix")
IM2 <- as(c(1,2,1), "indMatrix")
assert.EQ.Mat(crossprod(  IM1,   IM2),
              crossprod(d(IM1),d(IM2)), tol=0)# failed at first
iM <- as(cbind2(IM2, 0), "indMatrix")
stopifnot(identical3(crossprod(iM), # <- wrong for Matrix <= 1.1-5
                     crossprod(iM, iM), Diagonal(x = 2:0)))

N3 <- Diagonal(x=1:3)
U3 <- Diagonal(3) # unit diagonal (@diag = "U")
C3 <- as(N3, "CsparseMatrix")
lM <- as(IM2, "lMatrix")
nM <- as(IM2, "nMatrix")
nCM <- as(nM, "CsparseMatrix")
NM <- N3 %*% IM2
NM. <- C3 %*% IM2
stopifnot(Q.C.identical(NM, ## <- failed
                        d(N3) %*% d(IM2), checkClass=FALSE),
          identical(NM, N3 %*% lM),
          identical(NM, N3 %*% nM)
          , ## all these "work" (but partly wrongly gave non-numeric Matrix:
          Q.C.identical(NM, NM., checkClass=FALSE)
          ,
          mQidentical(as.matrix(NM.), array(c(1, 0, 3, 0, 2, 0), dim=3:2))
          ,
          identical(NM., C3 %*% lM)
          ,
          identical(NM., C3 %*% nM) # wrongly gave n*Matrix
          ,
          isValid(U3 %*% IM2, "dsparseMatrix")# was l*
          ,
          isValid(U3 %*% lM,  "dsparseMatrix")# was l*
          ,
          isValid(U3 %*% nM,  "dsparseMatrix")# was n*
          ,
          identical(C3 %*% nM -> C3n,  # wrongly gave ngCMatrix
                    C3 %*% nCM)
          ,
          isValid(C3n, "dgCMatrix")
          ,
          identical3(U3 %*% IM2, # wrongly gave lgTMatrix
                     U3 %*% lM -> U3l, # ditto
                     U3 %*% nM)  # wrongly gave ngTMatrix
          ,
          isValid(U3l, "dgTMatrix")
          )

selectMethod("%*%", c("dtCMatrix", "ngTMatrix")) # x %*% .T.2.C(y) -->
selectMethod("%*%", c("dtCMatrix", "ngCMatrix")) # .Call(Csparse_Csparse_prod, x, y)
selectMethod("%*%", c("ddiMatrix", "indMatrix")) # x %*% as(y, "lMatrix") ->
selectMethod("%*%", c("ddiMatrix", "lgTMatrix")) # diagCspprod(as(x, "Csp.."), y)
selectMethod("%*%", c("ddiMatrix", "ngTMatrix")) #  (ditto)

stopifnot(
	isValid(show(crossprod(C3, nM)), "dgCMatrix"), # wrongly gave ngCMatrix
	identical3(## the next 4 should give the same (since C3 and U3 are symmetric):
   show(crossprod(U3, IM2)),# wrongly gave ngCMatrix
	crossprod(U3, nM),  # ditto
	crossprod(U3, lM))) # wrongly gave lgCMatrix


set.seed(123)
for(n in 1:250) {
    n1 <- 2 + rpois(1, 10)
    n2 <- 2 + rpois(1, 10)
    N <- rpois(1, 25)
    ii <- seq_len(N + min(n1,n2))
    IM1 <- as(c(sample(n1), sample(n1, N, replace=TRUE))[ii], "indMatrix")
    IM2 <- as(c(sample(n2), sample(n2, N, replace=TRUE))[ii], "indMatrix")
    ## stopifnot(identical(crossprod(  IM1,    IM2),
    ##                     crossprod(d(IM1), d(IM2))))
    if(!identical(C1 <- crossprod(  IM1,    IM2 ),
                  CC <- crossprod(d(IM1), d(IM2))) &&
       !all(C1 == CC)) {
        cat("The two crossprod()s differ: C1 - CC =\n")
        print(C1 - CC)
        stop("The two crossprod()s differ!")
    } else if(n %% 25 == 0) cat(n, " ")
}; cat("\n")

## two with an empty column --- these failed till 2014-06-14
X <- as(c(1,3,4,5,3), "indMatrix")
Y <- as(c(2,3,4,2,2), "indMatrix")

## kronecker:
stopifnot(identical(X %x% Y,
                    as(as.matrix(X) %x% as.matrix(Y), "indMatrix")))
## crossprod:
(XtY <- crossprod(X, Y))# gave warning in Matrix 1.1-3
XtY_ok <- as(crossprod(as.matrix(X), as.matrix(Y)), "dgCMatrix")
stopifnot(identical(XtY, XtY_ok)) # not true, previously

###------- %&% -------- Boolean Arithmetic Matrix products

x5 <- c(2,0,0,1,4)
D5 <- Diagonal(x=x5)
L5 <- D5 != 0 ## an "ldiMatrix"  NB: have *no*  ndiMatrix class
D. <- Diagonal(x=c(TRUE,FALSE,TRUE,TRUE,TRUE))
stopifnot(identical(D5 %&% D., L5))
stopifnot(identical(D5 %&% as(D.,"CsparseMatrix"),
                    as(as(L5, "nMatrix"),"CsparseMatrix")))

set.seed(7)
L <- Matrix(rnorm(20) > 1,    4,5)
(N <- as(L, "nMatrix"))
D <- Matrix(round(rnorm(30)), 5,6) # "dge", values in -1:1 (for this seed)
L %&% D
stopifnot(identical(L %&% D, N %&% D),
          all(L %&% D == as((L %*% abs(D)) > 0, "sparseMatrix")))
stopifnotValid(show(crossprod(N   ))      , "nsCMatrix") #  (TRUE/FALSE : boolean arithmetic)
stopifnotValid(show(crossprod(N +0)) -> cN0, "dsCMatrix") # -> numeric Matrix (with same "pattern")
stopifnot(all(crossprod(N) == t(N) %&% N),
          identical(crossprod(N, boolArith=TRUE) -> cN.,
                    as(cN0 != 0, "nMatrix")),
          identical (cN.,               crossprod(L, boolArith=TRUE)),
          identical3(cN0, crossprod(L), crossprod(L, boolArith=FALSE))
          )
stopifnotValid(cD <- crossprod(D, boolArith = TRUE), "nsCMatrix") # sparse: "for now"
## another slightly differing test "series"
L.L <- crossprod(L)
(NN <- as(L.L > 0,"nMatrix"))
nsy <- as(NN,"denseMatrix")
stopifnot(identical(NN, crossprod(NN)))# here
stopifnotValid(csy <- crossprod(nsy), "dpoMatrix")
## ?? or  FIXME ?  give 'nsy', as  {boolArith=NA -> TRUE if args are "nMatrix"}
stopifnotValid(csy. <- crossprod(nsy, boolArith=TRUE),"nsCMatrix")
stopifnot(all((csy > 0) == csy.),
          all(csy. == (nsy %&% nsy)))

## for "many" more seeds:
set.seed(7); for(nn in 1:256) {
    L <- Matrix(rnorm(20) > 1,    4,5)
    D <- Matrix(round(rnorm(30)), 5,6)
    stopifnot(all(L %&% D == as((L %*% abs(D)) > 0, "sparseMatrix")))
}

## [Diagonal]  o  [0-rows/colums] :
m20 <- matrix(nrow = 2, ncol = 0); m02 <- t(m20)
M20 <- Matrix(nrow = 2, ncol = 0); M02 <- t(M20)
stopifnot(identical(dim(Diagonal(x=c(1,2)) %*% m20), c(2L, 0L)),
          identical(dim(Diagonal(2)        %*% M20), c(2L, 0L)),
          identical(dim(Diagonal(x=2:1)    %*% M20), c(2L, 0L)))
stopifnot(identical(dim(m02 %*% Diagonal(x=c(1,2))), c(0L, 2L)),
          identical(dim(M02 %*% Diagonal(2)       ), c(0L, 2L)),
          identical(dim(M02 %*% Diagonal(x=2:1)   ), c(0L, 2L)))

cat('Time elapsed: ', proc.time(),'\n') # for ``statistical reasons''
