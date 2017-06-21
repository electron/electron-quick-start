### R code from vignette source 'Rcpp-extending.Rnw'

###################################################
### code chunk number 1: Rcpp-extending.Rnw:45-50
###################################################
prettyVersion <- packageDescription("Rcpp")$Version
prettyDate <- format(Sys.Date(), "%B %e, %Y")
require(inline)
require(highlight)
require(Rcpp)


###################################################
### code chunk number 3: Rcpp-extending.Rnw:92-112
###################################################
code <- '
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
List fx(List input){ // we get a list from R

// pull std::vector<double> from R list
// this is achieved through an implicit call to Rcpp::as
std::vector<double> x = input["x"] ;

// return an R list
// this is achieved through implicit call to Rcpp::wrap
return List::create(
    _["front"] = x.front(),
    _["back"]  = x.back()
    );
}
'
writeLines( code, "code.cpp" )


###################################################
### code chunk number 4: Rcpp-extending.Rnw:114-115
###################################################
external_highlight( "code.cpp", type = "LATEX", doc = FALSE )


###################################################
### code chunk number 5: Rcpp-extending.Rnw:118-121
###################################################
Rcpp::sourceCpp(file= "code.cpp")
input <- list( x = seq(1, 10, by = 0.5) )
fx( input )


###################################################
### code chunk number 15: Rcpp-extending.Rnw:357-358
###################################################
unlink( "code.cpp" )


