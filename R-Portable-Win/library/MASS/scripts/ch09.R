#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 9   Tree-based Methods

library(MASS)
pdf(file="ch09.pdf", width=8, height=6, pointsize=9)
options(digits=5)

library(rpart)

# Figure 9.3
shuttle.rp <- rpart(use ~ ., data=shuttle, minbucket=0, xval = 0,
                    maxsurrogate = 0, cp = 0, subset = 1:253)
post(shuttle.rp, horizontal = FALSE, height=10, width=8, title = "",
     pointsize = 8, pretty = 0)


# 9.3   Implementation in rpart

set.seed(123)
cpus.rp <- rpart(log10(perf) ~ ., cpus[ , 2:8], cp = 1e-3)
cpus.rp
print(cpus.rp, cp = 0.01) # default pruning

plot(cpus.rp, uniform = TRUE)
text(cpus.rp, digits = 3)

printcp(cpus.rp)
plotcp(cpus.rp)

cpus.rp1 <- prune(cpus.rp, cp = 0.006)
print(cpus.rp1, digits = 3)
plot(cpus.rp1, branch = 0.4, uniform = TRUE)
text(cpus.rp1, digits = 3)

# for figure 9.2
cpus.rp2 <- prune(cpus.rp, cp = 0.03)
post(cpus.rp2, horizontal = FALSE, title = "", digits=4, pointsize=18)


set.seed(123)
fgl.rp <- rpart(type ~ ., fgl, cp = 0.001)
plotcp(fgl.rp)
printcp(fgl.rp)

fgl.rp2 <- prune(fgl.rp, cp = 0.02)
plot(fgl.rp2, uniform = TRUE)
text(fgl.rp2, use.n = TRUE)
fgl.rp2

summary(fgl.rp2)

set.seed(123)
fgl.rp3 <- rpart(type ~ ., fgl, cp = 0.001,
                 parms = list(split="information"))
plotcp(fgl.rp3)
printcp(fgl.rp3)

fgl.rp4 <- prune(fgl.rp3, cp = 0.03)
plot(fgl.rp4, uniform = TRUE); text(fgl.rp4, use.n = TRUE)

plot(cpus.rp, branch = 0.6, compress = TRUE, uniform = TRUE)
text(cpus.rp, digits = 3, all = TRUE, use.n = TRUE)


# 9.3   Implementation in tree

library(tree)
## the stopping criteria differ slightly between R and S-PLUS
cpus.ltr <- tree(log10(perf) ~ ., data = cpus[, 2:8], mindev = 0.005)
summary(cpus.ltr)

cpus.ltr
plot(cpus.ltr, type="u");  text(cpus.ltr)

par(mfrow = c(1, 2), pty = "s")
set.seed(321)
plot(cv.tree(cpus.ltr, , prune.tree))
cpus.ltr1 <- prune.tree(cpus.ltr, best = 10)
plot(cpus.ltr1, type = "u")
text(cpus.ltr1, digits = 3)
par(mfrow = c(1, 1), pty = "m")

fgl.tr <- tree(type ~ ., fgl)
summary(fgl.tr)
plot(fgl.tr)
text(fgl.tr, all = TRUE, cex = 0.5)

par(mfrow = c(1, 2), pty = "s")
set.seed(123)
fgl.cv <- cv.tree(fgl.tr,, prune.misclass)
for(i in 2:5)  fgl.cv$dev <- fgl.cv$dev +
    cv.tree(fgl.tr,, prune.misclass)$dev
fgl.cv$dev <- fgl.cv$dev/5
fgl.cv
plot(fgl.cv)

fgl.tr1 <- prune.misclass(fgl.tr, best = 9)
plot(fgl.tr1, type = "u")
text(fgl.tr1, all = TRUE)

# End of ch09
