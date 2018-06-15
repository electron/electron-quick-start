### R code from vignette source 'kernlab.Rnw'

###################################################
### code chunk number 1: preliminaries
###################################################
library(kernlab)
options(width = 70)


###################################################
### code chunk number 2: rbf1
###################################################
## create a RBF kernel function with sigma hyper-parameter 0.05 
rbf <- rbfdot(sigma = 0.05)
rbf
## create two random feature vectors
x <- rnorm(10)
y <- rnorm(10)
## compute dot product between x,y
rbf(x, y)


###################################################
### code chunk number 3: kernelMatrix
###################################################
## create a RBF kernel function with sigma hyper-parameter 0.05 
poly <- polydot(degree=2)
## create artificial data set
x <- matrix(rnorm(60), 6, 10)
y <- matrix(rnorm(40), 4, 10)
## compute kernel matrix
kx <- kernelMatrix(poly, x)
kxy <- kernelMatrix(poly, x, y)


###################################################
### code chunk number 4: ksvm
###################################################
## simple example using the promotergene data set
data(promotergene)
## create test and training set
tindex <- sample(1:dim(promotergene)[1],5)
genetrain <- promotergene[-tindex, ]
genetest <- promotergene[tindex,]
## train a support vector machine
gene <- ksvm(Class~.,data=genetrain,kernel="rbfdot",kpar="automatic",C=60,cross=3,prob.model=TRUE)
gene
predict(gene, genetest)
predict(gene, genetest, type="probabilities")


###################################################
### code chunk number 5: kernlab.Rnw:629-635
###################################################
set.seed(123)
x <- rbind(matrix(rnorm(120),,2),matrix(rnorm(120,mean=3),,2))
y <- matrix(c(rep(1,60),rep(-1,60)))

svp <- ksvm(x,y,type="C-svc")
plot(svp,data=x)


###################################################
### code chunk number 6: rvm
###################################################
x <- seq(-20, 20, 0.5)
y <- sin(x)/x + rnorm(81, sd = 0.03)
y[41] <- 1


###################################################
### code chunk number 7: rvm2
###################################################
rvmm <- rvm(x, y,kernel="rbfdot",kpar=list(sigma=0.1))
rvmm
ytest <- predict(rvmm, x)


###################################################
### code chunk number 8: kernlab.Rnw:686-689
###################################################
plot(x, y, cex=0.5)
lines(x, ytest, col = "red")
points(x[RVindex(rvmm)],y[RVindex(rvmm)],pch=21)


###################################################
### code chunk number 9: ranking
###################################################
data(spirals)
ran <- spirals[rowSums(abs(spirals) < 0.55) == 2,]
ranked <- ranking(ran, 54, kernel = "rbfdot", kpar = list(sigma = 100), edgegraph = TRUE)
ranked[54, 2] <- max(ranked[-54, 2])
c<-1:86
op <- par(mfrow = c(1, 2),pty="s")
plot(ran)
plot(ran, cex=c[ranked[,3]]/40)


###################################################
### code chunk number 10: onlearn
###################################################
## create toy data set
x <- rbind(matrix(rnorm(90),,2),matrix(rnorm(90)+3,,2))
y <- matrix(c(rep(1,45),rep(-1,45)),,1)

## initialize onlearn object
on <- inlearn(2,kernel="rbfdot",kpar=list(sigma=0.2),type="classification")
ind <- sample(1:90,90)
## learn one data point at the time
for(i in ind)
on <- onlearn(on,x[i,],y[i],nu=0.03,lambda=0.1)
sign(predict(on,x))


###################################################
### code chunk number 11: kernlab.Rnw:894-897
###################################################
data(spirals)
sc <- specc(spirals, centers=2)
plot(spirals, pch=(23 - 2*sc))


###################################################
### code chunk number 12: kpca
###################################################
data(spam)
train <- sample(1:dim(spam)[1],400)
kpc <- kpca(~.,data=spam[train,-58],kernel="rbfdot",kpar=list(sigma=0.001),features=2)
kpcv <- pcv(kpc)
plot(rotated(kpc),col=as.integer(spam[train,58]),xlab="1st Principal Component",ylab="2nd Principal Component")


###################################################
### code chunk number 13: kfa
###################################################
data(promotergene)
f <- kfa(~.,data=promotergene,features=2,kernel="rbfdot",kpar=list(sigma=0.013))
plot(predict(f,promotergene),col=as.numeric(promotergene[,1]),xlab="1st Feature",ylab="2nd Feature")


