## array subsetting tests
##
## Tests should be written to raise an error on test failure
##

## Test for subsetting of an array using a matrix with ncol == length(dim(x))

## first matrix case
m <- matrix(1:25, ncol=5, dimnames = list(letters[1:5], LETTERS[1:5]))

si <- matrix(c(1, 1, 2, 3, 3, 4), ncol = 2, byrow = TRUE)
ss <- matrix(c("a", "A", "b", "C", "c", "D"), ncol = 2, byrow = TRUE)

stopifnot(identical(m[si], m[ss]))
stopifnot(identical(c(1L, 12L, 18L), m[ss]))

## test behavior of NA entries in subset matrix.
## NA in character matrix should propagate and should not
## match an NA in a dimname.

## An NA in either column propagates to result
ssna <- ss; ssna[2, 2] <- NA
stopifnot(identical(c(1L, NA, 18L), m[ssna]))
ssna <- ss; ssna[2, 1] <- NA
stopifnot(identical(c(1L, NA, 18L), m[ssna]))

## An NA in row/column names is not matched
mnadim <- m
tmp <- rownames(mnadim)
tmp[5] <- NA
rownames(mnadim) <- tmp
stopifnot(identical(c(1L, NA, 18L), m[ssna]))

## Unmatched subscripts raise an error
ssnm <- ss
ssnm[2, 2] <- "NOMATCH"
stopifnot(inherits(try(m[ssnm], silent=TRUE), "try-error"))

## "" does not match and so raises an error
mnadim <- m
tmp <- rownames(mnadim)
tmp[5] <- ""
rownames(mnadim) <- tmp
ssnm <- ss
ssnm[2, 2] <- ""
stopifnot(inherits(try(mnadim[ssnm], silent=TRUE), "try-error"))


## test assignment
m3 <- m2 <- m
m2[si] <- c(100L, 200L, 300L)
m3[ss] <- c(100L, 200L, 300L)
stopifnot(identical(m2, m3))

## now an array case
a <- array(1:75, dim = c(5, 5, 3),
           dimnames = list(letters[1:5], LETTERS[1:5], letters[24:26]))

si <- matrix(c(1, 1, 1,
               2, 3, 1,
               3, 4, 1,
               5, 1, 3),
             ncol = 3, byrow = TRUE)

ss <- matrix(c("a", "A", "x",
               "b", "C", "x",
               "c", "D", "x",
               "e", "A", "z"),
             ncol = 3, byrow = TRUE)

stopifnot(identical(a[si], a[ss]))
stopifnot(identical(c(1L, 12L, 18L, 55L), a[ss]))

a2 <- a1 <- a
a1[si] <- c(100L, 1200L, 1800L, 5500L)
a2[ss] <- c(100L, 1200L, 1800L, 5500L)
stopifnot(identical(a1, a2))

## it is an error to subset if some dimnames are missing NOTE: this
## gives a subscript out of bounds error, might want something more
## informative?
a3 <- a
dn <- dimnames(a3)
dn[2] <- list(NULL)
dimnames(a3) <- dn
stopifnot(inherits(try(a3[ss], silent=TRUE), "try-error"))
