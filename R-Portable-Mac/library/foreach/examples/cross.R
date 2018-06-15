library(foreach)

NUMROWS <- 500
NUMCOLS <- 100
NUMFOLDS <- 10
CHUNKSIZE <- 50
nwsopts <- list(chunkSize=CHUNKSIZE)

xv <- matrix(rnorm(NUMROWS * NUMCOLS), NUMROWS, NUMCOLS)
beta <- c(rnorm(NUMCOLS / 2, 0, 5), rnorm(NUMCOLS / 2, 0, 0.25))
yv <- xv %*% beta + rnorm(NUMROWS, 0, 20)
dat <- data.frame(y=yv, x=xv)
fold <- sample(rep(1:NUMFOLDS, length=NUMROWS))

# the variables dat, fold, and NUMCOLS are automatically exported
print(system.time(
prss <-
  foreach(foldnumber=1:NUMFOLDS, .combine='c', .options.nws=nwsopts) %:%
    foreach(i=2:NUMCOLS, .combine='c', .final=mean) %dopar% {
      glmfit <- glm(y ~ ., data=dat[fold != foldnumber, 1:i])
      yhat <- predict(glmfit, newdata=dat[fold == foldnumber, 1:i])
      sum((yhat - dat[fold == foldnumber, 1]) ^ 2)
    }
))

cat('Results:', prss, '\n')
