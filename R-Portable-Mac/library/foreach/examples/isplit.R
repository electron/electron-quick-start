# iterator for splitting data using a factor
library(foreach)

# let's use isplit on a data frame
a <- foreach(i=isplit(airquality, airquality$Month), .combine=rbind) %do%
  quantile(i$value, na.rm=TRUE)

# make it pretty and print it
rownames(a) <- levels(as.factor(airquality$Month))
print(a)

# use a list of factors to do an aggregated operation
it <- isplit(as.data.frame(state.x77),
             list(Region=state.region, Cold=state.x77[,'Frost'] > 130),
             drop=TRUE)
a <- foreach(i=it, .combine=rbind) %do% {
  x <- mean(i$value)
  dim(x) <- c(1, length(x))
  colnames(x) <- names(i$value)
  cbind(i$key, as.data.frame(x))
}
print(a)

# compare with the standard aggregate function
b <- aggregate(state.x77,
               list(Region=state.region, Cold=state.x77[,'Frost'] > 130),
               mean)
print(b)

cat('results identical:\n')
print(identical(a, b))
