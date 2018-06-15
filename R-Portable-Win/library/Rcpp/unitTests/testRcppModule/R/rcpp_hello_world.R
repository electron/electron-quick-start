
rcpp_hello_world <- function(){
    .Call( "rcpp_hello_world_cpp", PACKAGE = "testRcppModule" )
}

