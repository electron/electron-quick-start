### R code from vignette source 'Rcpp-unitTests.Rnw'

###################################################
### code chunk number 1: Rcpp-unitTests.Rnw:14-18
###################################################
require(Rcpp)
prettyVersion <- packageDescription("Rcpp")$Version
prettyDate <- format(Sys.Date(), "%B %e, %Y")
library(RUnit)


###################################################
### code chunk number 2: unitTesting
###################################################
pkg <- "Rcpp"

if( Sys.getenv( "TRAVIS" ) == "true" ){
  writeLines( "not running any tests as part of checking the vignette when doing continuous integration with travis" )
} else {  
  
  ## Check the environemnt variable to see if all tests should be run
  if (Sys.getenv("RunAllRcppTests") != "yes") {
      writeLines("The environment variable 'RunAllRcppTests' was not set to 'yes', so skipping some tests.")
  }
  
  if (file.exists("unitTests-results")) unlink("unitTests-results", recursive = TRUE)
  dir.create("unitTests-results")
  path <- system.file("unitTests", package=pkg)
  testSuite <- defineTestSuite(name=paste(pkg, "unit testing"), dirs=path)
  tests <- runTestSuite(testSuite)
  err <- getErrors(tests)
  if (err$nFail > 0) stop(sprintf("unit test problems: %d failures", err$nFail))
  if (err$nErr > 0) stop( sprintf("unit test problems: %d errors", err$nErr))
  printHTMLProtocol(tests, fileName=sprintf("unitTests-results/%s-unitTests.html", pkg))
  printTextProtocol(tests, fileName=sprintf("unitTests-results/%s-unitTests.txt" , pkg))
  
  #if (file.exists("/tmp")) {
  #    invisible(sapply(c("txt", "html"), function(ext) {
  #        fname <- sprintf("unitTests-results/%s-unitTests.%s", pkg, ext)
  #        file.copy(fname, "/tmp", overwrite=TRUE)
  #    }))
  #}
}


###################################################
### code chunk number 3: importResults
###################################################
results <- "unitTests-results/Rcpp-unitTests.txt"
if (file.exists(results)) {
    writeLines(readLines(results))
} else{
    writeLines("Unit test results not available")
}


