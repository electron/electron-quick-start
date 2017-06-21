## regression test for PR#15346

library(foreign)

## The testEmpty.xpt dataset was created using the following code:
## library(SASxport)
## data(iris)
## write.xport(Iris1=iris[1:2,],    # two row dataset
##             empty=data.frame(),  # empty dataset
##             Iris2=iris[3:4,],    # two row dataset
##             file="testEmpty.xpt",
##             autogen.formats=FALSE # prevent autocreation of FORMATS dataset
##             )

## Test that lookup.xport retrieves all three datsets
empty.f <- lookup.xport(file="testEmpty.xpt")
empty.f
stopifnot(length(empty.f) == 3L)


dat.f <- read.xport(file="testEmpty.xpt")
dat.f
stopifnot(length(dat.f)==3)

