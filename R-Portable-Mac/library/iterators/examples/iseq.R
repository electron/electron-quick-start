library(iterators)

# return an iterator that returns subvectors of a sequence
# of a specified length.
# can specify either "chunks" or "chunkSize" arguments
# since that is what the "idiv" function supports.
iseq <- function(n, ...) {
 i <- 1
 it <- idiv(n, ...)

 nextEl <- function() {
   n <- nextElem(it)
   x <- seq(i, length=n)
   i <<- i + n
   x
 }

 obj <- list(nextElem=nextEl)
 class(obj) <- c('iseq', 'abstractiter', 'iter')
 obj
}

# create a sequence iterator that returns three subvectors
it <- iseq(25, chunks=3)
print(as.list(it))

# create a sequence iterator that returns subvectors
# with a maximum length of 10
it <- iseq(25, chunkSize=10)
print(as.list(it))
