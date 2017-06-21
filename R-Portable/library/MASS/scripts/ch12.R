#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 12   Classification

library(MASS)
pdf(file="ch12.pdf", width=8, height=6, pointsize=9)
options(width=65, digits=5)
library(class)
library(nnet)


# 12.1  Discriminant Analysis

ir <- rbind(iris3[,,1], iris3[,,2], iris3[,,3])
ir.species <- factor(c(rep("s", 50), rep("c", 50), rep("v", 50)))

(ir.lda <- lda(log(ir), ir.species))
ir.ld <- predict(ir.lda, dimen = 2)$x
eqscplot(ir.ld, type = "n", xlab = "first linear discriminant",
          ylab = "second linear discriminant")
text(ir.ld, labels = as.character(ir.species[-143]),
      col = 3 + unclass(ir.species), cex = 0.8)

plot(ir.lda, dimen = 1)
plot(ir.lda, type = "density", dimen = 1)

lcrabs <- log(crabs[, 4:8])
crabs.grp <- factor(c("B", "b", "O", "o")[rep(1:4, each = 50)])

(dcrabs.lda <- lda(crabs$sex ~ FL + RW + CL + CW, lcrabs))
table(crabs$sex, predict(dcrabs.lda)$class)

(dcrabs.lda4 <- lda(crabs.grp ~ FL + RW + CL + CW, lcrabs))
dcrabs.pr4 <- predict(dcrabs.lda4, dimen = 2)
dcrabs.pr2 <- dcrabs.pr4$post[, c("B", "O")] %*% c(1, 1)
table(crabs$sex, dcrabs.pr2 > 0.5)

cr.t <- dcrabs.pr4$x[, 1:2]
eqscplot(cr.t, type = "n", xlab = "First LD", ylab = "Second LD")
text(cr.t, labels = as.character(crabs.grp))
perp <- function(x, y) {
   m <- (x+y)/2
   s <- - (x[1] - y[1])/(x[2] - y[2])
   abline(c(m[2] - s*m[1], s))
   invisible()
}
cr.m <- lda(cr.t, crabs$sex)$means
points(cr.m, pch = 3, mkh = 0.3)
perp(cr.m[1, ], cr.m[2, ])

cr.lda <- lda(cr.t, crabs.grp)
x <- seq(-6, 6, 0.25)
y <- seq(-2, 2, 0.25)
Xcon <- matrix(c(rep(x,length(y)),
              rep(y, rep(length(x), length(y)))),,2)
cr.pr <- predict(cr.lda, Xcon)$post[, c("B", "O")] %*% c(1,1)
contour(x, y, matrix(cr.pr, length(x), length(y)),
       levels = 0.5, labex = 0, add = TRUE, lty=  3)

for(i in c("O", "o",  "B", "b"))
 print(var(lcrabs[crabs.grp == i, ]))

fgl.ld <- predict(lda(type ~ ., fgl), dimen = 2)$x
eqscplot(fgl.ld, type = "n", xlab = "LD1", ylab = "LD2")
# either
# for(i in seq(along = levels(fgl$type))) {
#    set <- fgl$type[-40] == levels(fgl$type)[i]
#    points(fgl.ld[set,], pch = 18, cex = 0.6, col = 2 + i)}
# key(text = list(levels(fgl$type), col = 3:8))
# or
text(fgl.ld, cex = 0.6,
     labels = c("F", "N", "V", "C", "T", "H")[fgl$type[-40]])

fgl.rld <- predict(lda(type ~ ., fgl, method = "t"), dimen = 2)$x
eqscplot(fgl.rld, type = "n", xlab = "LD1", ylab = "LD2")
# either
# for(i in seq(along = levels(fgl$type))) {
#   set <- fgl$type[-40] == levels(fgl$type)[i]
#   points(fgl.rld[set,], pch = 18, cex = 0.6, col = 2 + i)}
# key(text = list(levels(fgl$type), col = 3:8))
# or
text(fgl.rld, cex = 0.6,
     labels = c("F", "N", "V", "C", "T", "H")[fgl$type[-40]])


# 12.2  Classification theory

#decrease len if you have little memory.
predplot <- function(object, main="", len = 100, ...)
{
    plot(Cushings[,1], Cushings[,2], log="xy", type="n",
         xlab = "Tetrahydrocortisone", ylab = "Pregnanetriol", main = main)
    for(il in 1:4) {
        set <- Cushings$Type==levels(Cushings$Type)[il]
        text(Cushings[set, 1], Cushings[set, 2],
             labels=as.character(Cushings$Type[set]), col = 2 + il) }
    xp <- seq(0.6, 4.0, length=len)
    yp <- seq(-3.25, 2.45, length=len)
    cushT <- expand.grid(Tetrahydrocortisone = xp,
                         Pregnanetriol = yp)
    Z <- predict(object, cushT, ...); zp <- as.numeric(Z$class)
    zp <- Z$post[,3] - pmax(Z$post[,2], Z$post[,1])
    contour(exp(xp), exp(yp), matrix(zp, len),
            add = TRUE, levels = 0, labex = 0)
    zp <- Z$post[,1] - pmax(Z$post[,2], Z$post[,3])
    contour(exp(xp), exp(yp), matrix(zp, len),
            add = TRUE, levels = 0, labex = 0)
    invisible()
}

cushplot <- function(xp, yp, Z)
{
    plot(Cushings[, 1], Cushings[, 2], log = "xy", type = "n",
         xlab = "Tetrahydrocortisone", ylab = "Pregnanetriol")
    for(il in 1:4) {
        set <- Cushings$Type==levels(Cushings$Type)[il]
        text(Cushings[set, 1], Cushings[set, 2],
             labels = as.character(Cushings$Type[set]), col = 2 + il) }
    zp <- Z[, 3] - pmax(Z[, 2], Z[, 1])
    contour(exp(xp), exp(yp), matrix(zp, np),
            add = TRUE, levels = 0, labex = 0)
    zp <- Z[, 1] - pmax(Z[, 2], Z[, 3])
    contour(exp(xp), exp(yp), matrix(zp, np),
            add = TRUE, levels = 0, labex = 0)
    invisible()
}

cush <- log(as.matrix(Cushings[, -3]))
tp <- Cushings$Type[1:21, drop = TRUE]
cush.lda <- lda(cush[1:21,], tp); predplot(cush.lda, "LDA")
cush.qda <- qda(cush[1:21,], tp); predplot(cush.qda, "QDA")
predplot(cush.qda, "QDA (predictive)", method = "predictive")
predplot(cush.qda, "QDA (debiased)", method = "debiased")

Cf <- data.frame(tp = tp,
  Tetrahydrocortisone = log(Cushings[1:21, 1]),
  Pregnanetriol = log(Cushings[1:21, 2]) )
cush.multinom <- multinom(tp ~ Tetrahydrocortisone
  + Pregnanetriol, Cf, maxit = 250)
xp <- seq(0.6, 4.0, length = 100); np <- length(xp)
yp <- seq(-3.25, 2.45, length = 100)
cushT <- expand.grid(Tetrahydrocortisone = xp,
                     Pregnanetriol = yp)
Z <- predict(cush.multinom, cushT, type = "probs")
cushplot(xp, yp, Z)

library(tree)
cush.tr <- tree(tp ~ Tetrahydrocortisone + Pregnanetriol, Cf)
plot(cush[, 1], cush[, 2], type = "n",
    xlab = "Tetrahydrocortisone", ylab = "Pregnanetriol")
for(il in 1:4) {
 set <- Cushings$Type==levels(Cushings$Type)[il]
 text(cush[set, 1], cush[set, 2],
      labels = as.character(Cushings$Type[set]), col = 2 + il) }
par(cex = 1.5); partition.tree(cush.tr, add = TRUE); par(cex = 1)


# 12.3  Non-parametric rules

Z <- knn(scale(cush[1:21, ], FALSE, c(3.4, 5.7)),
        scale(cushT, FALSE, c(3.4, 5.7)), tp)
cushplot(xp, yp, class.ind(Z))
Z <- knn(scale(cush[1:21, ], FALSE, c(3.4, 5.7)),
        scale(cushT, FALSE, c(3.4, 5.7)), tp, k = 3)
cushplot(xp, yp, class.ind(Z))


# 12.4  Neural networks

pltnn <- function(main, ...) {
   plot(Cushings[,1], Cushings[,2], log="xy", type="n",
   xlab="Tetrahydrocortisone", ylab = "Pregnanetriol", main=main, ...)
   for(il in 1:4) {
       set <- Cushings$Type==levels(Cushings$Type)[il]
       text(Cushings[set, 1], Cushings[set, 2],
          as.character(Cushings$Type[set]), col = 2 + il) }
}

plt.bndry <- function(size=0, decay=0, ...)
{
   cush.nn <- nnet(cush, tpi, skip=TRUE, softmax=TRUE, size=size,
      decay=decay, maxit=1000)
   invisible(b1(predict(cush.nn, cushT), ...))
}

b1 <- function(Z, ...)
{
   zp <- Z[,3] - pmax(Z[,2], Z[,1])
   contour(exp(xp), exp(yp), matrix(zp, np),
      add=TRUE, levels=0, labex=0, ...)
   zp <- Z[,1] - pmax(Z[,3], Z[,2])
   contour(exp(xp), exp(yp), matrix(zp, np),
      add=TRUE, levels=0, labex=0, ...)
}

cush <- cush[1:21,]; tpi <- class.ind(tp)
# functions pltnn and plt.bndry given in the scripts
par(mfrow = c(2, 2))
pltnn("Size = 2")
set.seed(1); plt.bndry(size = 2, col = 2)
set.seed(3); plt.bndry(size = 2, col = 3)
plt.bndry(size = 2, col = 4)

pltnn("Size = 2, lambda = 0.001")
set.seed(1); plt.bndry(size = 2, decay = 0.001, col = 2)
set.seed(2); plt.bndry(size = 2, decay = 0.001, col = 4)

pltnn("Size = 2, lambda = 0.01")
set.seed(1); plt.bndry(size = 2, decay = 0.01, col = 2)
set.seed(2); plt.bndry(size = 2, decay = 0.01, col = 4)

pltnn("Size = 5, 20  lambda = 0.01")
set.seed(2); plt.bndry(size = 5, decay = 0.01, col = 1)
set.seed(2); plt.bndry(size = 20, decay = 0.01, col = 2)

# functions pltnn and b1 are in the scripts
pltnn("Many local maxima")
Z <- matrix(0, nrow(cushT), ncol(tpi))
for(iter in 1:20) {
   set.seed(iter)
   cush.nn <- nnet(cush, tpi, skip = TRUE, softmax = TRUE, size = 3,
       decay = 0.01, maxit = 1000, trace = FALSE)
   Z <- Z + predict(cush.nn, cushT)
   cat("final value", format(round(cush.nn$value,3)), "\n")
   b1(predict(cush.nn, cushT), col = 2, lwd = 0.5)
}
pltnn("Averaged")
b1(Z, lwd = 3)


# 12.5  Support vector machines

library(e1071)
crabs.svm <- svm(crabs$sp ~ ., data = lcrabs, cost = 100, gamma = 1)
table(true = crabs$sp, predicted = predict(crabs.svm, lcrabs))

svm(crabs$sp ~ ., data = lcrabs, cost = 100, gamma = 1, cross = 10)



# 12.6  Forensic glass example

set.seed(123)
# dump random partition from S-PLUS
rand <- c(9, 6, 7, 10, 8, 8, 2, 2, 10, 1, 5, 2, 3, 8, 6, 8, 2, 6, 4,
4, 6, 1, 3, 2, 5, 5, 5, 3, 1, 9, 10, 2, 8, 2, 1, 6, 2, 7, 7, 8, 4, 1,
9, 5, 5, 1, 4, 6, 8, 6, 5, 7, 9, 2, 1, 1, 10, 9, 7, 6, 4, 7, 4, 8, 9,
9, 1, 8, 9, 5, 3, 3, 4, 8, 8, 6, 6, 9, 3, 10, 3, 10, 6, 6, 5, 10, 10,
2, 10, 6, 1, 4, 7, 8, 9, 10, 7, 10, 8, 4, 6, 8, 9, 10, 1, 9, 10, 6, 8,
4, 10, 8, 2, 10, 2, 3, 10, 1, 5, 9, 4, 4, 8, 2, 7, 6, 4, 8, 10, 4, 8,
10, 6, 10, 4, 9, 4, 1, 6, 5, 3, 2, 4, 1, 3, 4, 8, 4, 3, 7, 2, 5, 4, 5,
10, 7, 4, 2, 6, 3, 2, 2, 8, 4, 10, 8, 10, 2, 10, 6, 5, 2, 3, 2, 6, 2,
7, 7, 8, 9, 7, 10, 8, 6, 7, 9, 7, 10, 3, 2, 7, 5, 6, 1, 3, 9, 7, 7, 1,
8, 7, 8, 8, 8, 10, 4, 5, 9, 4, 6, 9, 6, 10, 2)

con <- function(...)
{
    print(tab <- table(...))
    diag(tab) <- 0
    cat("error rate = ",
        round(100*sum(tab)/length(list(...)[[1]]), 2), "%\n")
    invisible()
}
CVtest <- function(fitfn, predfn, ...)
{
    res <- fgl$type
    for (i in sort(unique(rand))) {
        cat("fold ", i, "\n", sep = "")
        learn <- fitfn(rand != i, ...)
        res[rand == i] <- predfn(learn, rand == i)
    }
    res
}
res.multinom <- CVtest(
  function(x, ...) multinom(type ~ ., fgl[x, ], ...),
  function(obj, x) predict(obj, fgl[x, ], type = "class"),
  maxit = 1000, trace = FALSE)

con(true = fgl$type, predicted = res.multinom)

res.lda <- CVtest(
  function(x, ...) lda(type ~ ., fgl[x, ], ...),
  function(obj, x) predict(obj, fgl[x, ])$class )
con(true = fgl$type, predicted = res.lda)

fgl0 <- fgl[ , -10] # drop type
{ res <- fgl$type
  for (i in sort(unique(rand))) {
      cat("fold ", i ,"\n", sep = "")
      sub <- rand == i
      res[sub] <- knn(fgl0[!sub, ], fgl0[sub, ], fgl$type[!sub],
                      k = 1)
  }
  res } -> res.knn1
con(true = fgl$type, predicted = res.knn1)

res.lb <- knn(fgl0, fgl0, fgl$type, k = 3, prob = TRUE, use.all = FALSE)
table(attr(res.lb, "prob"))

library(rpart)
res.rpart <- CVtest(
  function(x, ...) {
    tr <- rpart(type ~ ., fgl[x,], ...)
    cp <- tr$cptable
    r <- cp[, 4] + cp[, 5]
    rmin <- min(seq(along = r)[cp[, 4] < min(r)])
    cp0 <- cp[rmin, 1]
    cat("size chosen was", cp[rmin, 2] + 1, "\n")
    prune(tr, cp = 1.01*cp0)
  },
  function(obj, x)
    predict(obj, fgl[x, ], type = "class"),
  cp = 0.001
)
con(true = fgl$type, predicted = res.rpart)

fgl1 <- fgl
fgl1[1:9] <- lapply(fgl[, 1:9], function(x)
               {r <- range(x); (x - r[1])/diff(r)})

CVnn2 <- function(formula, data,
                  size = rep(6,2), lambda = c(0.001, 0.01),
                  nreps = 1, nifold = 5, verbose = 99, ...)
{
    CVnn1 <- function(formula, data, nreps=1, ri, verbose,  ...)
    {
        truth <- data[,deparse(formula[[2]])]
        res <-  matrix(0, nrow(data), length(levels(truth)))
        if(verbose > 20) cat("  inner fold")
        for (i in sort(unique(ri))) {
            if(verbose > 20) cat(" ", i,  sep="")
            for(rep in 1:nreps) {
                learn <- nnet(formula, data[ri !=i,], trace = FALSE, ...)
                res[ri == i,] <- res[ri == i,] +
                    predict(learn, data[ri == i,])
            }
        }
        if(verbose > 20) cat("\n")
        sum(as.numeric(truth) != max.col(res/nreps))
    }
    truth <- data[,deparse(formula[[2]])]
    res <-  matrix(0, nrow(data), length(levels(truth)))
    choice <- numeric(length(lambda))
    for (i in sort(unique(rand))) {
        if(verbose > 0) cat("fold ", i,"\n", sep="")
        ri <- sample(nifold, sum(rand!=i), replace=TRUE)
        for(j in seq(along=lambda)) {
            if(verbose > 10)
                cat("  size =", size[j], "decay =", lambda[j], "\n")
            choice[j] <- CVnn1(formula, data[rand != i,], nreps=nreps,
                               ri=ri, size=size[j], decay=lambda[j],
                               verbose=verbose, ...)
        }
        decay <- lambda[which.is.max(-choice)]
        csize <- size[which.is.max(-choice)]
        if(verbose > 5) cat("  #errors:", choice, "  ") #
        if(verbose > 1) cat("chosen size = ", csize,
                            " decay = ", decay, "\n", sep="")
        for(rep in 1:nreps) {
            learn <- nnet(formula, data[rand != i,], trace=FALSE,
                          size=csize, decay=decay, ...)
            res[rand == i,] <- res[rand == i,] +
                predict(learn, data[rand == i,])
        }
    }
    factor(levels(truth)[max.col(res/nreps)], levels = levels(truth))
}

if(FALSE) { # only run this if you have time to wait
res.nn2 <- CVnn2(type ~ ., fgl1, skip = TRUE, maxit = 500, nreps = 10)
con(true = fgl$type, predicted = res.nn2)
}

res.svm <- CVtest(
  function(x, ...) svm(type ~ ., fgl[x, ], ...),
  function(obj, x) predict(obj, fgl[x, ]),
  cost = 100, gamma = 1 )
con(true = fgl$type, predicted = res.svm)

svm(type ~ ., data = fgl, cost = 100, gamma = 1, cross = 10)


cd0 <- lvqinit(fgl0, fgl$type, prior = rep(1, 6)/6, k = 3)
cd1 <- olvq1(fgl0, fgl$type, cd0)
con(true = fgl$type, predicted = lvqtest(cd1, fgl0))

CV.lvq <- function()
{
    res <- fgl$type
    for(i in sort(unique(rand))) {
        cat("doing fold", i, "\n")
        cd0 <- lvqinit(fgl0[rand != i,], fgl$type[rand != i],
                       prior = rep(1, 6)/6, k = 3)
        cd1 <- olvq1(fgl0[rand != i,], fgl$type[rand != i], cd0)
        cd1 <- lvq3(fgl0[rand != i,], fgl$type[rand != i],
                    cd1, niter = 10000)
        res[rand == i] <- lvqtest(cd1, fgl0[rand == i, ])
    }
    res
}
con(true = fgl$type, predicted = CV.lvq())


# 12.7  Calibration plots

CVprobs <- function(fitfn, predfn, ...)
{
    res <- matrix(, 214, 6)
    for (i in sort(unique(rand))) {
        cat("fold ", i, "\n", sep = "")
        learn <- fitfn(rand != i, ...)
        res[rand == i, ] <- predfn(learn, rand == i)
    }
    res
}
probs.multinom <- CVprobs(
  function(x, ...) multinom(type ~ ., fgl[x, ], ...),
  function(obj, x) predict(obj, fgl[x, ], type = "probs"),
  maxit = 1000, trace = FALSE)

probs.yes <- as.vector(class.ind(fgl$type))
probs <- as.vector(probs.multinom)
par(pty = "s")
plot(c(0, 1), c(0, 1), type = "n", xlab = "predicted probability",
     ylab = "", xaxs = "i", yaxs = "i", las = 1)
rug(probs[probs.yes == 0], 0.02, side = 1, lwd = 0.5)
rug(probs[probs.yes == 1], 0.02, side = 3, lwd = 0.5)
abline(0, 1)
newp <- seq(0, 1, length = 100)
lines(newp, predict(loess(probs.yes ~ probs, span = 1), newp))

# End of ch12
