library(iterators)

# return an iterator that returns subvectors of a vector.
# can specify either "chunks" or "chunkSize" arguments
# since that is what the "idiv" function supports.
ivector <- function(x, ...) {
 i <- 1
 it <- idiv(length(x), ...)

 nextEl <- function() {
   n <- nextElem(it)
   ix <- seq(i, length=n)
   i <<- i + n
   x[ix]
 }

 obj <- list(nextElem=nextEl)
 class(obj) <- c('ivector', 'abstractiter', 'iter')
 obj
}

# create a vector iterator that returns three subvectors
it <- ivector(1:25, chunks=3)
print(as.list(it))

# create a vector iterator that returns subvectors
# with a maximum length of 10
it <- ivector(1:25, chunkSize=10)
print(as.list(it))
