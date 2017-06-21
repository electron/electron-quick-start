## accumulate here tests of the relation between S4 and S3 classes

## $<-.data.frame did stupid things with the class attribute
## that clobbered S4 classes extending "data.frame"
## Test that the S4 method (R 2.13.0) works transparently

set.seed(864)

xx <- data.frame(a=rnorm(10),
                 b=as.factor(sample(c("T", "F"), 10, TRUE)),
                 row.names = paste("R",1:10,sep=":"))

setClass("myData", representation(extra = "character"),
         contains = "data.frame")

mx <- new("myData", xx, extra = "testing")

## three kinds of $<-: replace, add, delete (NULL value)

mx$a <- mx$a * 2
xx$a <- xx$a * 2

mx$c <- 1:10
xx$c <- 1:10

mx$b <- NULL
xx$b <- NULL

stopifnot(identical(mx, new("myData", xx, extra = "testing")))
