library(iterators)

test00 <- function() {}

# test vector iterator creation
test01 <- function() {
  x <- iter(1:10)
}

# test hasNext, nextElem
test02 <- function() {
  x <- iter(1:10)
  checkEquals(nextElem(x), 1)
  for(i in 1:9) nextElem(x)
  checkException(nextElem(x))
}

# check checkFunc
test03 <- function() {
  x <- iter(1:100, checkFunc=function(i) i%%10==0)
  checkEquals(nextElem(x), 10)
  for(i in 1:9) nextElem(x)
  checkException(nextElem(x))
}

# test matrix iterator creation
test04 <- function() {
  x <- matrix(1:10,ncol=2)
}

# test hasNext, nextElem
test05 <- function() {
  x <- matrix(1:10,ncol=2)
  # by cell
  y <- iter(x,by='cell')
  checkEquals(nextElem(y), 1)
  for(i in 1:9) nextElem(y)
  checkException(nextElem(y))

  # by col
  y <- iter(x,by='column')
  checkEquals(nextElem(y), matrix(1:5, ncol=1))
  nextElem(y)
  checkException(nextElem(y))

  # by row
  y <- iter(x,by='row')
  checkEquals(nextElem(y), matrix(c(1,6),nrow=1))
  for(i in 1:4) nextElem(y)
  checkException(nextElem(y))
}
  
# test checkFunc
test06 <- function() {
  # create a larger matrix
  x <- matrix(1:100, ncol=20)

  # by cell
  y <- iter(x, by='cell', checkFunc=function(i) i%%10==0)
  checkEquals(nextElem(y), 10)
  for(i in 1:9) nextElem(y)
  checkException(nextElem(y))

  # by col
  y <- iter(x, by='column', checkFunc=function(i) i[5]%%10==0)
  checkEquals(nextElem(y), as.matrix(x[,2]))
  for(i in 1:9) nextElem(y)
  checkException(nextElem(y))

  # by row
  # create an easier matrix to deal with
  x <- matrix(1:100, nrow=20, byrow=TRUE)
  y <- iter(x, by='row', checkFunc=function(i) i[5]%%10==0)
  checkEquals(as.vector(nextElem(y)), x[2,])
  for(i in 1:9) nextElem(y)
  checkException(nextElem(y))
} 

# test data frame iterator creation
test07 <- function() {
  x <- data.frame(1:10, 11:20)
  y <- iter(x)
}
# test hasNext, nextElem
test08 <- function() {
  x <- data.frame(1:10, 11:20)
  # by row
  y <- iter(x, by='row')
  checkEquals(nextElem(y), x[1,])
  for(i in 1:9) nextElem(y)
  checkException(nextElem(y))

  # by col
  y <- iter(x, by='column')
  checkEquals(nextElem(y), x[,1])
  nextElem(y)
  checkException(nextElem(y))
}

# test checkFunc
test09 <- function() {
  x <- data.frame(1:10, 11:20)
  # by row
  y <- iter(x, by='row', checkFunc=function(i) i[[1]][1]%%2==0)
  checkEquals(nextElem(y),x[2,])
  for(i in 1:4) nextElem(y)
  checkException(nextElem(y))

  # by col
  y <- iter(x, by='column', checkFunc=function(i) i[[1]][1]%%11==0)
  checkEquals(nextElem(y), x[,2])
  checkException(nextElem(y))
}

# test function iterator creation
# we need to test a function that takes no arguement as
# well as one that takes the index
test10 <- function() {
  noArgFunc <- function() 1
  needArgFunc <- function(i)
    if(i>100)
      stop('too high')
    else
      i
}
  
# test hasNext, nextElem
test11 <- function() {
  noArgFunc <- function() 1
  needArgFunc <- function(i) if(i>100)      stop('too high')    else      i
  y <- iter(noArgFunc)
  checkEquals(nextElem(y), 1)
  nextElem(y)

  y <- iter(needArgFunc)
  checkEquals(nextElem(y), 1)
  for (i in 1:99) nextElem(y)
  checkException(nextElem(y))
}
 
# test checkFunc
test12 <- function() {
  noArgFunc <- function() 1
  needArgFunc <- function(i)
    if(i>100)
      stop('too high')
    else
      i
  y <- iter(noArgFunc, checkFunc=function(i) i==1)
  checkEquals(nextElem(y), 1)
  nextElem(y)

  y <- iter(needArgFunc, checkFunc=function(i) i%%10==0)
  checkEquals(nextElem(y), 10)
  for(i in 1:9) nextElem(y)
  checkException(nextElem(y))
}
