### R code from vignette source 'sparseModels.Rnw'
### Encoding: ASCII

###################################################
### code chunk number 1: preliminaries
###################################################
options(width=75)


###################################################
### code chunk number 2: ex1
###################################################
 (ff <- factor(strsplit("statistics_is_a_task", "")[[1]], levels=c("_",letters)))
 factor(ff)      # drops the levels that do not occur
 f1 <- ff[, drop=TRUE] # the same, more transparently


###################################################
### code chunk number 3: ex1.2
###################################################
 levels(f1)[match(c("c","k"), levels(f1))] <- "ck"
 library(Matrix)

 Matrix(contrasts(f1)) # "treatment" contrasts by default -- level "_" = baseline

 Matrix(contrasts(C(f1, sum)))
 Matrix(contrasts(C(f1, helmert)), sparse=TRUE) # S-plus default; much less sparse


###################################################
### code chunk number 4: as_factor_sparse
###################################################
as(f1, "sparseMatrix")


###################################################
### code chunk number 5: contrasts_sub
###################################################
printSpMatrix( t( Matrix(contrasts(f1))[as.character(f1) ,] ),
              col.names=TRUE)


###################################################
### code chunk number 6: ex1-model.matrix
###################################################
t( Matrix(model.matrix(~ 0+ f1))) # model with*OUT* intercept


###################################################
### code chunk number 7: chickwts-ex
###################################################
str(chickwts)# a standard R data set,  71 x 2
x.feed <- as(chickwts$feed, "sparseMatrix")
x.feed[ , (1:72)[c(TRUE,FALSE,FALSE)]] ## every  3rd  column:



###################################################
### code chunk number 8: warpbreaks-data
###################################################
data(warpbreaks)# a standard R data set
str(warpbreaks) # 2 x 3 (x 9) balanced two-way with 9 replicates:
xtabs(~ wool + tension, data = warpbreaks)


###################################################
### code chunk number 9: modMat-warpbreaks
###################################################
tmm <- with(warpbreaks,
            rBind(as(tension, "sparseMatrix"),
                  as(wool,    "sparseMatrix")[-1,,drop=FALSE]))
print(  image(tmm)  ) # print(.) the lattice object


###################################################
### code chunk number 10: morley-data
###################################################
data(morley) # a standard R data set
morley$Expt <- factor(morley$Expt)
morley$Run <- factor(morley$Run)
str(morley)
t.mm <- with(morley,
             rBind(as(Expt, "sparseMatrix"),
                   as(Run,  "sparseMatrix")[-1,]))
print(  image(t.mm)  ) # print(.) the lattice object


###################################################
### code chunk number 11: npk_ex
###################################################
data(npk, package="MASS")
npk.mf <- model.frame(yield ~ block + N*P*K, data = npk)
## str(npk.mf) # the data frame + "terms" attribute

m.npk <- model.matrix(attr(npk.mf, "terms"), data = npk)
class(M.npk <- Matrix(m.npk))
dim(M.npk)# 24 x 13  sparse Matrix
t(M.npk) # easier to display, column names readably displayed as row.names(t(.))


###################################################
### code chunk number 12: aov-large-ex
###################################################
id <- factor(1:20)
a <- factor(1:2)
b <- factor(1:2)
d <- factor(1:1500)
aDat <- expand.grid(id=id, a=a, b=b, d=d)
aDat$y <- rnorm(length(aDat[, 1])) # generate some random DV data
dim(aDat) # 120'000 x 5  (120'000 = 2*2*1500 * 20 = 6000 * 20)


###################################################
### code chunk number 13: aov-ex-X-sparse
###################################################
d2 <- factor(1:150) # 10 times smaller
tmp2 <- expand.grid(id=id, a=a, b=b, d=d2)
dim(tmp2)
dim(mm <- model.matrix( ~ a*b*d, data=tmp2))
## is 100 times smaller than original example

class(smm <- Matrix(mm)) # automatically coerced to sparse
round(object.size(mm) / object.size(smm), 1)


###################################################
### code chunk number 14: X-sparse-image (eval = FALSE)
###################################################
## image(t(smm), aspect = 1/3, lwd=0, col.regions = "red")


###################################################
### code chunk number 15: X-sparse-image-fake
###################################################
png("sparseModels-X-sparse-image.png", width=6, height=3,
    units='in', res=150)
print(
image(t(smm), aspect = 1/3, lwd=0, col.regions = "red")
      )
dev.off()


###################################################
### code chunk number 16: X-sparse-mult
###################################################
x <- 1:600
system.time(y <- smm %*% x) ## sparse is much faster
system.time(y. <- mm %*% x) ## than dense
identical(as.matrix(y), y.) ## TRUE


###################################################
### code chunk number 17: sessionInfo
###################################################
toLatex(sessionInfo())


