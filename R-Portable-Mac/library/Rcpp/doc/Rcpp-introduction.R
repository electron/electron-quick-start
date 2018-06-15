## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(cache=TRUE)
library(Rcpp)

## ----evalCpp, eval=FALSE-------------------------------------------------
#  library("Rcpp")
#  evalCpp("2 + 2")

## ----isOddR, cache=TRUE--------------------------------------------------
isOddR <- function(num = 10L) {
   result <- (num %% 2L == 1L)
   return(result)
}

## ----isOddRcpp, cache=TRUE, eval=FALSE-----------------------------------
#  library("Rcpp")
#  cppFunction("
#  bool isOddCpp(int num = 10) {
#     bool result = (num % 2 == 1);
#     return result;
#  }")
#  isOddCpp(42L)

## ----microbenchmark_isOdd, dependson=c("isOddR", "isOddRcpp"), eval=FALSE----
#  library("microbenchmark")
#  results <- microbenchmark(isOddR   = isOddR(12L),
#                            isOddCpp = isOddCpp(12L))
#  print(summary(results)[, c(1:7)],digits=1)

## ----rnormScalar---------------------------------------------------------
evalCpp("R::rnorm(0, 1)")

## ----normWithSeed--------------------------------------------------------
set.seed(123)
evalCpp("R::rnorm(0, 1)")

## ----rnormWithSeedFromR--------------------------------------------------
set.seed(123)
# Implicit mean of 0, sd of 1
rnorm(1)

## ----rnormExCpp----------------------------------------------------------
set.seed(123)
evalCpp("Rcpp::rnorm(3)")

## ----rnormExR------------------------------------------------------------
set.seed(123)
rnorm(3)

## ----bootstrap_in_r------------------------------------------------------
# Function declaration
bootstrap_r <- function(ds, B = 1000) {
  
  # Preallocate storage for statistics
  boot_stat <- matrix(NA, nrow = B, ncol = 2)
  
  # Number of observations
  n <- length(ds)
  
  # Perform bootstrap 
  for(i in seq_len(B)) {
     # Sample initial data
     gen_data <- ds[ sample(n, n, replace=TRUE) ]
     # Calculate sample data mean and SD
     boot_stat[i,] <- c(mean(gen_data),
                        sd(gen_data))
  }
  
  # Return bootstrap result
  return(boot_stat)
}

## ----bootstrap_example---------------------------------------------------
# Set seed to generate data
set.seed(512)
# Generate data
initdata <- rnorm(1000, mean = 21, sd = 10)
# Set a new _different_ seed for bootstrapping
set.seed(883)
# Perform bootstrap
result_r <- bootstrap_r(initdata)

## ----dist_graphs, echo = FALSE, results = "hide"-------------------------
make_boot_graph <- function(ds, actual, type, ylim){
  hist(ds, main = paste(type, "Bootstrap"), xlab = "Samples",
       col = "lightblue", lwd = 2, prob = TRUE, ylim = ylim, cex.axis = .85, cex.lab = .90)
  abline(v = actual, col = "orange2", lwd = 2)
  lines(density(ds))
}
pdf("bootstrap.pdf", width=6.5, height=3.25)
par(mfrow=c(1,2))
make_boot_graph(result_r[,1], 21, "Mean", c(0, 1.23))
make_boot_graph(result_r[,2], 10, "SD", c(0, 1.85))
dev.off()

## ----bootstrap_cpp-------------------------------------------------------
# Use the same seed use in R and C++ 
set.seed(883)
# Perform bootstrap with C++ function
result_cpp <- bootstrap_cpp(initdata)

## ----check_r_to_cpp------------------------------------------------------
# Compare output
all.equal(result_r, result_cpp)

## ----benchmark_r_to_cpp--------------------------------------------------
library(rbenchmark)

benchmark(r = bootstrap_r(initdata),
          cpp = bootstrap_cpp(initdata))[, 1:4]

## ----skeleton, eval = FALSE----------------------------------------------
#  library("Rcpp")
#  Rcpp.package.skeleton("samplePkg")

