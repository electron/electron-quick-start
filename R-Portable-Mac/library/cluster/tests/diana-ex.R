library(cluster)
options(digits = 6)
data(votes.repub)
di.votes <- daisy(votes.repub)

.p00 <- proc.time()
summary(diana(votes.repub, metric = "manhattan", stand = TRUE))
summary(diana(di.votes, keep.diss = FALSE))
cat('Time elapsed: ', proc.time() - .p00,'\n')

data(agriculture)
data(ruspini)

.p0 <- proc.time()
dia.agr <- diana(agriculture)
drusp0  <- diana(ruspini, keep.diss=FALSE, keep.data=FALSE)
drusp1  <- diana(ruspini, metric = "manhattan")
cat('Time elapsed: ', proc.time() - .p0,'\n')

summary(dia.agr)
summary(drusp0)
summary(drusp1)
str    (drusp1)

## From system.file("scripts/ch11.R", package = "MASS")
data(swiss)
swiss.x <- as.matrix(swiss[,-1])
.p1 <- proc.time()
dCH <- diana(swiss.x)
cat('Time elapsed: ', proc.time() - .p1,'\n')
str(as.dendrogram(as.hclust(dCH)))# keep back-compatible
