### R code from vignette source 'parallel.Rnw'

###################################################
### code chunk number 1: parallel.Rnw:473-474 (eval = FALSE)
###################################################
## library(parallel)


###################################################
### code chunk number 2: parallel.Rnw:499-506 (eval = FALSE)
###################################################
## library(boot)
## cd4.rg <- function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
## cd4.mle <- list(m = colMeans(cd4), v = var(cd4))
## cd4.boot <- boot(cd4, corr, R = 999, sim = "parametric",
##                  ran.gen = cd4.rg, mle = cd4.mle)
## boot.ci(cd4.boot,  type = c("norm", "basic", "perc"),
##         conf = 0.9, h = atanh, hinv = tanh)


###################################################
### code chunk number 3: parallel.Rnw:511-521 (eval = FALSE)
###################################################
## cd4.rg <- function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
## cd4.mle <- list(m = colMeans(cd4), v = var(cd4))
## run1 <- function(...) boot(cd4, corr, R = 500, sim = "parametric",
##                            ran.gen = cd4.rg, mle = cd4.mle)
## mc <- 2 # set as appropriate for your hardware
## ## To make this reproducible:
## set.seed(123, "L'Ecuyer")
## cd4.boot <- do.call(c, mclapply(seq_len(mc), run1) )
## boot.ci(cd4.boot,  type = c("norm", "basic", "perc"),
##         conf = 0.9, h = atanh, hinv = tanh)


###################################################
### code chunk number 4: parallel.Rnw:526-527 (eval = FALSE)
###################################################
## do.call(c, lapply(seq_len(mc), run1))


###################################################
### code chunk number 5: parallel.Rnw:531-546 (eval = FALSE)
###################################################
## run1 <- function(...) {
##    library(boot)
##    cd4.rg <- function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
##    cd4.mle <- list(m = colMeans(cd4), v = var(cd4))
##    boot(cd4, corr, R = 500, sim = "parametric",
##         ran.gen = cd4.rg, mle = cd4.mle)
## }
## cl <- makeCluster(mc)
## ## make this reproducible
## clusterSetRNGStream(cl, 123)
## library(boot) # needed for c() method on master
## cd4.boot <- do.call(c, parLapply(cl, seq_len(mc), run1) )
## boot.ci(cd4.boot,  type = c("norm", "basic", "perc"),
##         conf = 0.9, h = atanh, hinv = tanh)
## stopCluster(cl)


###################################################
### code chunk number 6: parallel.Rnw:556-569 (eval = FALSE)
###################################################
## cl <- makeCluster(mc)
## cd4.rg <- function(data, mle) MASS::mvrnorm(nrow(data), mle$m, mle$v)
## cd4.mle <- list(m = colMeans(cd4), v = var(cd4))
## clusterExport(cl, c("cd4.rg", "cd4.mle"))
## junk <- clusterEvalQ(cl, library(boot)) # discard result
## clusterSetRNGStream(cl, 123)
## res <- clusterEvalQ(cl, boot(cd4, corr, R = 500,
##                     sim = "parametric", ran.gen = cd4.rg, mle = cd4.mle))
## library(boot) # needed for c() method on master
## cd4.boot <- do.call(c, res)
## boot.ci(cd4.boot,  type = c("norm", "basic", "perc"),
##         conf = 0.9, h = atanh, hinv = tanh)
## stopCluster(cl)


###################################################
### code chunk number 7: parallel.Rnw:574-588 (eval = FALSE)
###################################################
## R <- 999; M <- 999 ## we would like at least 999 each
## cd4.nest <- boot(cd4, nested.corr, R=R, stype="w", t0=corr(cd4), M=M)
## ## nested.corr is a function in package boot
## op <- par(pty = "s", xaxs = "i", yaxs = "i")
## qqplot((1:R)/(R+1), cd4.nest$t[, 2], pch = ".", asp = 1,
##         xlab = "nominal", ylab = "estimated")
## abline(a = 0, b = 1, col = "grey")
## abline(h = 0.05, col = "grey")
## abline(h = 0.95, col = "grey")
## par(op)
## 
## nominal <- (1:R)/(R+1)
## actual <- cd4.nest$t[, 2]
## 100*nominal[c(sum(actual <= 0.05), sum(actual < 0.95))]


###################################################
### code chunk number 8: parallel.Rnw:593-601 (eval = FALSE)
###################################################
## mc <- 9
## R <- 999; M <- 999; RR <- floor(R/mc)
## run2 <- function(...)
##     cd4.nest <- boot(cd4, nested.corr, R=RR, stype="w", t0=corr(cd4), M=M)
## cd4.nest <- do.call(c, mclapply(seq_len(mc), run2, mc.cores = mc) )
## nominal <- (1:R)/(R+1)
## actual <- cd4.nest$t[, 2]
## 100*nominal[c(sum(actual <= 0.05), sum(actual < 0.95))]


###################################################
### code chunk number 9: parallel.Rnw:615-626 (eval = FALSE)
###################################################
## library(spatial)
## towns <- ppinit("towns.dat")
## tget <- function(x, r=3.5) sum(dist(cbind(x$x, x$y)) < r)
## t0 <- tget(towns)
## R <- 1000
## c <- seq(0, 1, 0.1)
## ## res[1] = 0
## res <- c(0, sapply(c[-1], function(c)
##     mean(replicate(R, tget(Strauss(69, c=c, r=3.5))))))
## plot(c, res, type="l", ylab="E t")
## abline(h=t0, col="grey")


###################################################
### code chunk number 10: parallel.Rnw:630-639 (eval = FALSE)
###################################################
## run3 <- function(c) {
##     library(spatial)
##     towns <- ppinit("towns.dat") # has side effects
##     mean(replicate(R, tget(Strauss(69, c=c, r=3.5))))
## }
## cl <- makeCluster(10, methods = FALSE)
## clusterExport(cl, c("R", "towns", "tget"))
## res <- c(0, parSapply(cl, c[-1], run3)) # 10 tasks
## stopCluster(cl)


###################################################
### code chunk number 11: parallel.Rnw:643-647 (eval = FALSE)
###################################################
## cl <- makeForkCluster(10)  # fork after the variables have been set up
## run4 <- function(c)  mean(replicate(R, tget(Strauss(69, c=c, r=3.5))))
## res <- c(0, parSapply(cl, c[-1], run4))
## stopCluster(cl)


###################################################
### code chunk number 12: parallel.Rnw:650-652 (eval = FALSE)
###################################################
## run4 <- function(c)  mean(replicate(R, tget(Strauss(69, c=c, r=3.5))))
## res <- c(0, unlist(mclapply(c[-1], run4, mc.cores = 10)))


###################################################
### code chunk number 13: parallel.Rnw:683-717 (eval = FALSE)
###################################################
## pkgs <- "<names of packages to be installed>"
## M <- 20 # number of parallel installs
## M <- min(M, length(pkgs))
## library(parallel)
## unlink("install_log")
## cl <- makeCluster(M, outfile = "install_log")
## clusterExport(cl, c("tars", "fakes", "gcc")) # variables needed by do_one
## 
## ## set up available via a call to available.packages() for
## ## repositories containing all the packages involved and all their
## ## dependencies.
## DL <- utils:::.make_dependency_list(pkgs, available, recursive = TRUE)
## DL <- lapply(DL, function(x) x[x %in% pkgs])
## lens <- sapply(DL, length)
## ready <- names(DL[lens == 0L])
## done <- character() # packages already installed
## n <- length(ready)
## submit <- function(node, pkg)
##     parallel:::sendCall(cl[[node]], do_one, list(pkg), tag = pkg)
## for (i in 1:min(n, M)) submit(i, ready[i])
## DL <- DL[!names(DL) %in% ready[1:min(n, M)]]
## av <- if(n < M) (n+1L):M else integer() # available workers
## while(length(done) < length(pkgs)) {
##     d <- parallel:::recvOneResult(cl)
##     av <- c(av, d$node)
##     done <- c(done, d$tag)
##     OK <- unlist(lapply(DL, function(x) all(x %in% done) ))
##     if (!any(OK)) next
##     p <- names(DL)[OK]
##     m <- min(length(p), length(av)) # >= 1
##     for (i in 1:m) submit(av[i], p[i])
##     av <- av[-(1:m)]
##     DL <- DL[!names(DL) %in% p[1:m]]
## }


###################################################
### code chunk number 14: parallel.Rnw:730-747 (eval = FALSE)
###################################################
##     fn <- function(r) statistic(data, i[r, ], ...)
##     RR <- sum(R)
##     res <- if (ncpus > 1L && (have_mc || have_snow)) {
##         if (have_mc) {
##             parallel::mclapply(seq_len(RR), fn, mc.cores = ncpus)
##         } else if (have_snow) {
##             list(...) # evaluate any promises
##             if (is.null(cl)) {
##                 cl <- parallel::makePSOCKcluster(rep("localhost", ncpus))
##                 if(RNGkind()[1L] == "L'Ecuyer-CMRG")
##                     parallel::clusterSetRNGStream(cl)
##                 res <- parallel::parLapply(cl, seq_len(RR), fn)
##                 parallel::stopCluster(cl)
##                 res
##             } else parallel::parLapply(cl, seq_len(RR), fn)
##         }
##     } else lapply(seq_len(RR), fn)


###################################################
### code chunk number 15: parallel.Rnw:750-751 (eval = FALSE)
###################################################
##             list(...) # evaluate any promises


