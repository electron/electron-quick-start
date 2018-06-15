## ---- eval=FALSE---------------------------------------------------------
#  f1 <- cxxfunction( , "", includes = unifModCode,
#                    plugin = "Rcpp" )
#  getDynLib(f1)  ## will display info about 'f1'

## ---- eval=FALSE---------------------------------------------------------
#  setClass("Uniform",
#           representation( pointer = "externalptr"))
#  
#  # helper
#  Uniform_method <- function(name) {
#      paste("Uniform", name, sep = "__")
#  }
#  
#  # syntactic sugar to allow object$method( ... )
#  setMethod("$", "Uniform", function(x, name) {
#      function(...)
#          .Call(Uniform_method(name) ,
#                x@pointer, ...)
#  } )
#  # syntactic sugar to allow new( "Uniform", ... )
#  setMethod("initialize", "Uniform",
#            function(.Object, ...) {
#      .Object@pointer <-
#          .Call(Uniform_method("new"), ...)
#      .Object
#  } )
#  
#  u <- new("Uniform", 0, 10)
#  u$draw( 10L )

## ---- eval=FALSE---------------------------------------------------------
#  inc <- '
#  using namespace Rcpp;
#  
#  double norm( double x, double y ) {
#      return sqrt(x*x + y*y);
#  }
#  
#  RCPP_MODULE(mod) {
#      function("norm", &norm);
#  }
#  '
#  
#  fx <- cxxfunction(signature(),
#                    plugin="Rcpp", include=inc)
#  mod <- Module("mod", getDynLib(fx))

## ---- eval=FALSE---------------------------------------------------------
#  require(nameOfMyModulePackage)
#  mod <- new( mod )
#  mod$norm( 3, 4 )

## ---- eval=FALSE---------------------------------------------------------
#  require(Rcpp)
#  
#  yd <- Module("yada", getDynLib(fx))
#  yd$bar(2L)
#  yd$foo(2L, 10.0)
#  yd$hello()
#  yd$bla()
#  yd$bla1(2L)
#  yd$bla2(2L, 5.0)

## ---- eval=FALSE---------------------------------------------------------
#  require(myModulePackage)    ## if another name
#  
#  bar(2L)
#  foo(2L, 10.0)
#  hello()
#  bla()
#  bla1(2L)
#  bla2(2L, 5.0)

## ---- eval=FALSE---------------------------------------------------------
#  mod <- Module("mod", getDynLib(fx))
#  show(mod$norm)

## ---- eval=FALSE---------------------------------------------------------
#  norm <- mod$norm
#  norm()
#  norm(y = 2)
#  norm(x = 2, y = 3)
#  args(norm)

## ---- eval=FALSE---------------------------------------------------------
#  norm <- mod$norm
#  args(norm)

## ---- eval=FALSE---------------------------------------------------------
#  norm <- mod$norm
#  args(norm)

## ---- eval=FALSE---------------------------------------------------------
#  ## assumes   fx_unif <- cxxfunction(...)   ran
#  unif_module <- Module("unif_module",
#                        getDynLib(fx_unif))
#  Uniform <- unif_module$Uniform
#  u <- new(Uniform, 0, 10)
#  u$draw(10L)
#  u$range()
#  u$max <- 1
#  u$range()
#  u$draw(10)

## ---- eval=FALSE---------------------------------------------------------
#  Bar <- mod_bar$Bar
#  b <- new(Bar, 10)
#  b$x + b$x
#  b$stats()
#  b$x <- 10
#  b$stats()

## ---- eval=FALSE---------------------------------------------------------
#  setMethod("show", yada$World , function(object) {
#      msg <- paste("World object with message : ",
#                   object$greet())
#      writeLines(msg)
#  } )

## ---- eval=FALSE---------------------------------------------------------
#  # for code compiled on the fly using
#  # cxxfunction() into 'fx_vec', we use
#  mod_vec <- Module("mod_vec",
#                    getDynLib(fx_vec),
#                    mustStart = TRUE)
#  vec <- mod_vec$vec
#  # and that is not needed in a package
#  # setup as e.g. one created
#  # via Rcpp.package.skeleton(..., module=TRUE)
#  v <- new(vec)
#  v$reserve(50L)
#  v$assign(1:10)
#  v$push_back(10)
#  v$size()
#  v$capacity()
#  v[[ 0L ]]
#  v$as.vector()

## ---- echo=FALSE,eval=TRUE-----------------------------------------------
options( prompt = " ", continue = " " )

## ---- eval=FALSE---------------------------------------------------------
#  import(Rcpp)

## ---- eval=FALSE---------------------------------------------------------
#  import(Rcpp, evalCpp)

## ---- eval=FALSE---------------------------------------------------------
#  .onLoad <- function(libname, pkgname) {
#      loadRcppModules()
#  }

## ---- eval=FALSE---------------------------------------------------------
#  loadModule("yada")
#  loadModule("stdVector")
#  loadModule("NumEx")

## ---- eval=FALSE---------------------------------------------------------
#  yada <- Module( "yada" )
#  
#  .onLoad <- function(libname, pkgname) {
#      # placeholder
#  }

## ---- echo=FALSE,eval=TRUE-----------------------------------------------
options(prompt = "> ", continue = "+ ")

## ---- eval=FALSE---------------------------------------------------------
#  Rcpp.package.skeleton("testmod", module = TRUE)

## ---- eval=FALSE---------------------------------------------------------
#  yada <- Module("yada")
#  prompt(yada, "yada-module.Rd")

