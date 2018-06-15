## ---- eval = FALSE-------------------------------------------------------
#  sourceCpp("convolve.cpp")
#  convolveCpp(x, y)

## ---- eval = FALSE-------------------------------------------------------
#  function(file, colNames=character(),
#           comment="#", header=TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  cppFunction('
#    int fibonacci(const int x) {
#      if (x < 2)
#        return x;
#      else
#        return (fibonacci(x-1)) + fibonacci(x-2);
#    }
#  ')
#  
#  evalCpp('std::numeric_limits<double>::max()')

## ---- eval = FALSE-------------------------------------------------------
#  cppFunction(depends='RcppArmadillo', code='...')

## ---- eval = FALSE-------------------------------------------------------
#  Rcpp.package.skeleton("NewPackage",
#                        attributes = TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  Rcpp.package.skeleton("NewPackage",
#                        example_code = FALSE,
#                        cpp_files = c("convolve.cpp"))

## ---- eval = FALSE-------------------------------------------------------
#  compileAttributes()

## ---- eval = FALSE-------------------------------------------------------
#  #' The length of a string (in characters).
#  #'
#  #' @param str input character vector
#  #' @return characters in each element of the vector
#  strLength <- function(str)

