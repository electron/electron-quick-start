### R code from vignette source 'Rcpp-attributes.Rnw'

###################################################
### code chunk number 1: Rcpp-attributes.Rnw:41-43
###################################################
prettyVersion <- packageDescription("Rcpp")$Version
prettyDate <- format(Sys.Date(), "%B %e, %Y")


###################################################
### code chunk number 3: Rcpp-attributes.Rnw:149-151 (eval = FALSE)
###################################################
## sourceCpp("convolve.cpp")
## convolveCpp(x, y)


###################################################
### code chunk number 5: Rcpp-attributes.Rnw:179-180 (eval = FALSE)
###################################################
## function(file, colNames=character(), comment="#", header=TRUE)


###################################################
### code chunk number 19: Rcpp-attributes.Rnw:518-528 (eval = FALSE)
###################################################
## cppFunction('
##     int fibonacci(const int x) {
##         if (x < 2)
##             return x;
##         else
##             return (fibonacci(x - 1)) + fibonacci(x - 2);
##     }
## ')
## 
## evalCpp('std::numeric_limits<double>::max()')


###################################################
### code chunk number 20: Rcpp-attributes.Rnw:533-534 (eval = FALSE)
###################################################
## cppFunction(depends = 'RcppArmadillo', code = '...')


###################################################
### code chunk number 21: Rcpp-attributes.Rnw:565-566 (eval = FALSE)
###################################################
## Rcpp.package.skeleton("NewPackage", attributes = TRUE)


###################################################
### code chunk number 22: Rcpp-attributes.Rnw:572-574 (eval = FALSE)
###################################################
## Rcpp.package.skeleton("NewPackage", example_code = FALSE,
##                       cpp_files = c("convolve.cpp"))


###################################################
### code chunk number 26: Rcpp-attributes.Rnw:626-627 (eval = FALSE)
###################################################
## compileAttributes()


###################################################
### code chunk number 30: Rcpp-attributes.Rnw:715-720 (eval = FALSE)
###################################################
## #' The length of a string (in characters).
## #'
## #' @param str input character vector
## #' @return characters in each element of the vector
## strLength <- function(str)


