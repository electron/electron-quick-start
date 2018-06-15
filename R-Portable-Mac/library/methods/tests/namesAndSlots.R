setClass("B", contains = "numeric")
xx <- new("B", 1)
names(xx) <- "A"
stopifnot(identical(names(xx), "A"))
setClass("A", representation(xx = "numeric"))
a <- new("A", xx = 1)
stopifnot(is(tryCatch(names(a) <- "A" , error = function(e)e), "error"))
setClass("C", representation(xx = "numeric", names= "character"))
c <- new("C", xx = 1, names = "A")
c@names <- "B"
stopifnot(is(tryCatch(names(c) <- "A" , error = function(e)e), "error"))
setClass("D", contains = "numeric", representation(names = "character"))
d <- new("D", 1)
names(d) <- "A"
stopifnot(identical(d@names, "A"))
## test the checks on @<- primitive assignment
stopifnot(is(tryCatch(a@yy <- 1 , error = function(e)e), "error"))
stopifnot(is(tryCatch(a@xx <- "A" , error = function(e)e), "error"))
