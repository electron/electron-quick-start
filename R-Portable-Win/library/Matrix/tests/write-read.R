library(Matrix)

####  Read / Write  (sparse) Matrix objects ----------------------

### Rebuild the 'mm' example matrix, now in KNex data

### This is no longer really important, as we now use
### ../data/KNex.R  which creates the S4 object *every time*
data(KNex)

## recreate 'mm' from list :
sNms <- c("Dim", "i","p","x")
L <- lapply(sNms, function(SN) slot(KNex$mm, SN)); names(L) <- sNms
mm2 <- new(class(KNex$mm))
for (n in sNms) slot(mm2, n) <- L[[n]]

stopifnot(validObject(mm2),
          identical(mm2, KNex$mm))
L$y <- KNex$y
## save(L, file = "/u/maechler/R/Pkgs/Matrix/inst/external/KNex_slots.rda")


## recreate 'mm' from ASCI file :
mmT <- as(KNex$mm, "dgTMatrix")
str(mmT)
mm3 <- cbind(i = mmT@i, j = mmT@j, x = mmT@x)
write.table(mm3, file = "mm-Matrix.tab", row.names=FALSE)# -> ASCII version

str(mmr <- read.table("mm-Matrix.tab", header = TRUE))
mmr$i <- as.integer(mmr$i)
mmr$j <- as.integer(mmr$j)

mmN <- with(mmr, new("dgTMatrix", Dim = c(max(i)+1:1,max(j)+1:1),
                     i = i, j = j, x = x))

stopifnot(identical(mmT, mmN)) # !!
## weaker (and hence TRUE too):
stopifnot(all.equal(as(mmN, "matrix"),
                    as(mmT, "matrix"), tol=0))

mm <- as(mmN, "dgCMatrix")
stopifnot(all.equal(mm, KNex$mm))
## save(mm, file = "....../Matrix/data/mm.rda", compress = TRUE)


A <- Matrix(c(1,0,3,0,0,5), 10, 10, sparse = TRUE) # warning about [6] vs [10]
(fname <- file.path(tempdir(), "kk.mm"))
writeMM(A, fname)
(B  <- readMM(fname))
validObject(B)
Bc <- as(B, "CsparseMatrix")
stopifnot(identical(A, Bc))

fname <- system.file("external", "wrong.mtx", package = "Matrix")
r <- try(readMM(fname))
stopifnot(inherits(r, "try-error"), length(grep("readMM.*row.*1:nr", r)) == 1)
## gave a much less intelligible error message
