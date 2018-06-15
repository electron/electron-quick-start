### triangular packed
library(Matrix)
source(system.file("test-tools.R", package = "Matrix"))# identical3() etc

cp6 <- chol(H6 <- Hilbert(6))
tp6 <- as(cp6,"dtpMatrix")
round(tp6, 3)## round() is "Math2" group method
1/tp6        ## "Arith" group : gives 'dgeMatrix'
str(tp6)
## arithmetic with a mix of dimnames / no dimnames
tp <- tp6; dimnames(tp) <- list(LETTERS[1:6], letters[11:16])
## as.matrix() --> "logical" matrix
stopifnot(as.matrix(tp - tp6 == tp6 - tp),
	  as.matrix(0 == tp - tp6),
	  identical(as(tp6,"CsparseMatrix"),
		    as(cp6,"CsparseMatrix")))

stopifnot(validObject(tp6),
          all.equal(tp6 %*% diag(6), as(tp6, "dgeMatrix")),
          validObject(tp6. <- diag(6) %*% tp6),
          class((tt6 <- t(tp6))) == "dtpMatrix",
          identical(t(tt6), tp6),
          tp6@uplo == "U" && tt6@uplo == "L")

all.equal(as(tp6.,"matrix"),
          as(tp6, "matrix"), tolerance= 1e-15)
(tr6 <- as(tp6, "dtrMatrix"))
dH6 <- determinant(H6)
D. <- determinant(tp6)
rc <- rcond(tp6)
stopifnot(all.equal(dH6$modulus, determinant(as.matrix(H6))$modulus),
          is.all.equal3(c(D.$modulus), c(dH6$modulus) / 2, -19.883103353),
          all.equal(rc, 1.791511257e-4),
          all.equal(norm(tp6, "I") , 2.45),
          all.equal(norm(tp6, "1") , 1),
          all.equal(norm(tp6, "F") , 1.37047826623)
          )
object.size(tp6)
object.size(as(tp6, "dtrMatrix"))
object.size(as(tp6, "matrix"))
D6 <- as(diag(6), "dgeMatrix")
ge6 <- as(tp6, "dgeMatrix")
stopifnot(all.equal(D6 %*% tp6, ge6),
          all.equal(tp6 %*% D6, ge6))

## larger case
set.seed(123)
rl <- new("dtpMatrix", uplo="L", diag="N", Dim = rep.int(1000:1000,2),
          x = rnorm(500*1001))
validObject(rl)
str(rl)
sapply(c("I", "1", "F"), function(type) norm(rl, type=type))
rcond(rl)# 0 !
stopifnot(all.equal(as(rl %*% diag(1000),"matrix"),
                    as(rl, "matrix")))
object.size(rl) ## 4 MB
object.size(as(rl, "dtrMatrix"))# 8 MB
object.size(as(rl, "matrix"))# ditto
print(drl <- determinant(rl), digits = 12)
stopifnot(all.equal(c(drl$modulus), -638.257312422))


cat('Time elapsed: ', proc.time(),'\n') # for ``statistical reasons''
