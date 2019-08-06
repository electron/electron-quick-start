####  eval / parse / deparse / substitute ...

####  Part 2
####  ======  Recommended packages allowed  .. output tests *sloppily*

source(file.path(Sys.getenv("SRCDIR"), "eval-fns.R"), echo = TRUE)
                                        #---------

if(require("Matrix")) withAutoprint({ cat("Trying some Matrix objects, too\n")
    D5. <- Diagonal(x = 5:1)
    D5N <- D5.; D5N[5,5] <- NA
    example(Matrix)
    ## a subset from  example(sparseMatrix) :
    i <- c(1,3:8); j <- c(2,9,6:10); x <- 7 * (1:7)
    A <- sparseMatrix(i, j, x = x)
    sA <- sparseMatrix(i, j, x = x, symmetric = TRUE)
    tA <- sparseMatrix(i, j, x = x, triangular= TRUE)
    ## dims can be larger than the maximum row or column indices
    AA <- sparseMatrix(c(1,3:8), c(2,9,6:10), x = 7 * (1:7), dims = c(10,20))
    ## i, j and x can be in an arbitrary order, as long as they are consistent
    set.seed(1); (perm <- sample(1:7))
    A1 <- sparseMatrix(i[perm], j[perm], x = x[perm])
    ## the (i,j) pairs can be repeated, in which case the x's are summed
    args <- data.frame(i = c(i, 1), j = c(j, 2), x = c(x, 2))
    Aa <- do.call(sparseMatrix, args)
    A. <- do.call(sparseMatrix, c(args, list(use.last.ij = TRUE)))
    ## for a pattern matrix, of course there is no "summing":
    nA <- do.call(sparseMatrix, args[c("i","j")])
    dn <- list(LETTERS[1:3], letters[1:5])
    ## pointer vectors can be used, and the (i,x) slots are sorted if necessary:
    m <- sparseMatrix(i = c(3,1, 3:2, 2:1), p= c(0:2, 4,4,6), x = 1:6, dimnames = dn)
    ## no 'x' --> patter*n* matrix:
    n <- sparseMatrix(i=1:6, j=rev(2:7))
    ## an empty sparse matrix:
    e <- sparseMatrix(dims = c(4,6), i={}, j={})
    ## a symmetric one:
    sy <- sparseMatrix(i= c(2,4,3:5), j= c(4,7:5,5), x = 1:5,
                       dims = c(7,7), symmetric=TRUE)
})

runEPD_checks() # Action!

summary(warnings())
## at the very end
cat('Time elapsed: ', proc.time(), "\n")
