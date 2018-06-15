## bam donttest case
library(mgcv)
set.seed(3); k <- 12; bs <- "cr"
dat <- gamSim(1,n=25000,dist="normal",scale=20)
ba <- bam(y ~ s(x0,bs=bs,k=k)+s(x1,bs=bs,k=k)+s(x2,bs=bs,k=k)+
            s(x3,bs=bs,k=k),data=dat,method="GCV.Cp") ## use GCV
summary(ba)

