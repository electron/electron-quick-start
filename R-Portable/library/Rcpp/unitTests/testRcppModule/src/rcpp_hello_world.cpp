#include "rcpp_hello_world.h"

SEXP rcpp_hello_world_cpp(){
    using namespace Rcpp ;

    CharacterVector x = CharacterVector::create( "foo", "bar" )  ;
    NumericVector y   = NumericVector::create( 0.0, 1.0 ) ;
    List z            = List::create( x, y ) ;

    return z ;
}
