## ---- eval = FALSE-------------------------------------------------------
#  ## Note - this is R code.
#  ## cppFunction in Rcpp allows rapid testing.
#  require(Rcpp)
#  
#  cppFunction("
#  NumericVector exfun(NumericVector x, int i){
#      x = x*i;
#      return x;
#  }")
#  
#  exfun(1:5, 3)
#  
#  ## Use evalCpp to evaluate C++ expressions
#  evalCpp("std::numeric_limits<double>::max()")

## ---- eval = FALSE-------------------------------------------------------
#  # In R, create a package shell. For details,
#  # see the "Writing R Extensions" manual and
#  # the "Rcpp-package" vignette.
#  
#  Rcpp.package.skeleton("myPackage")
#  
#  # Add R code to pkg R/ directory. Call C++
#  # function. Do type-checking in R.
#  
#  myfunR <- function(Rx, Ry) {
#      ret = .Call("myCfun", Rx, Ry,
#                  package="myPackage")
#      return(ret)
#  }

## ---- eval=FALSE---------------------------------------------------------
#  require(myPackage)
#  
#  aa <- 1.5
#  bb <- 1.5
#  cc <- myfunR(aa, bb)
#  aa == bb
#  # FALSE, C++ modifies aa
#  
#  aa <- 1:2
#  bb <- 1:2
#  cc <-  myfunR(aa, bb)
#  identical(aa, bb)
#  # TRUE, R/C++ types don't match
#  # so a copy was made

## ---- eval=FALSE---------------------------------------------------------
#  Rcpp::sourceCpp("path/to/file/Rcpp_example.cpp")
#  x <- 1:5
#  all.equal(muRcpp(x), mean(x))
#  all.equal(var(x),varRcpp(x))

