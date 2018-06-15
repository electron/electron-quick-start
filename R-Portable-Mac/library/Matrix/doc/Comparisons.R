### R code from vignette source 'Comparisons.Rnw'
### Encoding: ASCII

###################################################
### code chunk number 1: preliminaries
###################################################
options(width=75)


###################################################
### code chunk number 2: modelMatrix
###################################################
data(Formaldehyde)
str(Formaldehyde)
(m <- cbind(1, Formaldehyde$carb))
(yo <- Formaldehyde$optden)


###################################################
### code chunk number 3: naiveCalc
###################################################
solve(t(m) %*% m) %*% t(m) %*% yo


###################################################
### code chunk number 4: timedNaive
###################################################
system.time(solve(t(m) %*% m) %*% t(m) %*% yo)


###################################################
### code chunk number 5: catNaive
###################################################
dput(c(solve(t(m) %*% m) %*% t(m) %*% yo))
dput(unname(lm.fit(m, yo)$coefficients))


###################################################
### code chunk number 6: KoenNg
###################################################
library(Matrix)
data(KNex, package = "Matrix")
 y <- KNex$y
mm <- as(KNex$mm, "matrix") # full traditional matrix
dim(mm)
system.time(naive.sol <- solve(t(mm) %*% mm) %*% t(mm) %*% y)


###################################################
### code chunk number 7: crossKoenNg
###################################################
system.time(cpod.sol <- solve(crossprod(mm), crossprod(mm,y)))
all.equal(naive.sol, cpod.sol)


###################################################
### code chunk number 8: xpxKoenNg
###################################################
system.time(t(mm) %*% mm)


###################################################
### code chunk number 9: fullMatrix_crossprod
###################################################
fm <- mm
set.seed(11)
fm[] <- rnorm(length(fm))
system.time(c1 <- t(fm) %*% fm)
system.time(c2 <- crossprod(fm))
stopifnot(all.equal(c1, c2, tol = 1e-12))


###################################################
### code chunk number 10: naiveChol
###################################################
system.time(ch <- chol(crossprod(mm)))
system.time(chol.sol <-
            backsolve(ch, forwardsolve(ch, crossprod(mm, y),
                                       upper = TRUE, trans = TRUE)))
stopifnot(all.equal(chol.sol, naive.sol))


###################################################
### code chunk number 11: MatrixKoenNg
###################################################
mm <- as(KNex$mm, "dgeMatrix")
class(crossprod(mm))
system.time(Mat.sol <- solve(crossprod(mm), crossprod(mm, y)))
stopifnot(all.equal(naive.sol, unname(as(Mat.sol,"matrix"))))


###################################################
### code chunk number 12: saveFactor
###################################################
xpx <- crossprod(mm)
xpy <- crossprod(mm, y)
system.time(solve(xpx, xpy))
system.time(solve(xpx, xpy)) # reusing factorization


###################################################
### code chunk number 13: SparseKoenNg
###################################################
mm <- KNex$mm
class(mm)
system.time(sparse.sol <- solve(crossprod(mm), crossprod(mm, y)))
stopifnot(all.equal(naive.sol, unname(as(sparse.sol, "matrix"))))


###################################################
### code chunk number 14: SparseSaveFactor
###################################################
xpx <- crossprod(mm)
xpy <- crossprod(mm, y)
system.time(solve(xpx, xpy))
system.time(solve(xpx, xpy))


###################################################
### code chunk number 15: sessionInfo
###################################################
toLatex(sessionInfo())


###################################################
### code chunk number 16: from_pkg_sfsmisc
###################################################

if(identical(1L, grep("linux", R.version[["os"]]))) { ##----- Linux - only ----

Sys.procinfo <- function(procfile)
{
  l2 <- strsplit(readLines(procfile),"[ \t]*:[ \t]*")
  r <- sapply(l2[sapply(l2, length) == 2],
              function(c2)structure(c2[2], names= c2[1]))
  attr(r,"Name") <- procfile
  class(r) <- "simple.list"
  r
}

Scpu <- Sys.procinfo("/proc/cpuinfo")
Smem <- Sys.procinfo("/proc/meminfo")
} # Linux only


###################################################
### code chunk number 17: Sys_proc_fake (eval = FALSE)
###################################################
## if(identical(1L, grep("linux", R.version[["os"]]))) { ## Linux - only ---
##  Scpu <- sfsmisc::Sys.procinfo("/proc/cpuinfo")
##  Smem <- sfsmisc::Sys.procinfo("/proc/meminfo")
##  print(Scpu[c("model name", "cpu MHz", "cache size", "bogomips")])
##  print(Smem[c("MemTotal", "SwapTotal")])
## }


###################################################
### code chunk number 18: Sys_proc_out
###################################################
if(identical(1L, grep("linux", R.version[["os"]]))) { ## Linux - only ---
 print(Scpu[c("model name", "cpu MHz", "cache size", "bogomips")])
 print(Smem[c("MemTotal", "SwapTotal")])
}


