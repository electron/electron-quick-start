## ---- eval=FALSE---------------------------------------------------------
#  vignette("Rcpp-jss-2011")
#  vignette("Rcpp-introduction")
#  vignette("Rcpp-attributes")

## ---- eval=FALSE---------------------------------------------------------
#  vignette("Rcpp-package")

## ---- eval = FALSE-------------------------------------------------------
#  fx <- cxxfunction(signature(x = "numeric"),
#      'NumericVector xx(x);
#       return wrap(
#                std::accumulate(xx.begin(),
#                                xx.end(),
#                                0.0)
#              );',
#      plugin = "Rcpp")
#  res <- fx(seq(1, 10, by=0.5))
#  res

## ---- eval = FALSE, echo=FALSE-------------------------------------------
#  stopifnot(identical(res, sum(seq(1, 10, by=0.5))))

## ---- eval = FALSE-------------------------------------------------------
#  list.files( system.file( "unitTests", package = "Rcpp" ), pattern = "^runit[.]" )

## ---- eval=FALSE---------------------------------------------------------
#  fx <- cxxfunction(signature(),
#                    paste(readLines("myfile.cpp"),
#                          collapse="\n"),
#                    plugin = "Rcpp")

## ---- eval = FALSE-------------------------------------------------------
#  cppFunction('double accu(NumericVector x) {
#     return(
#        std::accumulate(x.begin(), x.end(), 0.0)
#     );
#  }')
#  res <- accu(seq(1, 10, by=0.5))
#  res

## ---- eval = FALSE-------------------------------------------------------
#  inc <- 'template <typename T>
#          class square :
#            public std::unary_function<T,T> {
#              public:
#                T operator()( T t) const {
#                  return t*t;
#                }
#          };
#         '
#  
#  src <- '
#         double x = Rcpp::as<double>(xs);
#         int i = Rcpp::as<int>(is);
#         square<double> sqdbl;
#         square<int> sqint;
#         return Rcpp::DataFrame::create(
#                      Rcpp::Named("x", sqdbl(x)),
#                      Rcpp::Named("i", sqint(i)));
#         '
#  fun <- cxxfunction(signature(xs="numeric",
#                               is="integer"),
#                     body=src, include=inc,
#                     plugin="Rcpp")
#  
#  fun(2.2, 3L)

## ---- eval = FALSE-------------------------------------------------------
#  lines = '// copy the data to armadillo structures
#  arma::colvec x = Rcpp::as<arma::colvec> (x_);
#  arma::mat Y = Rcpp::as<arma::mat>(Y_) ;
#  arma::colvec z = Rcpp::as<arma::colvec>(z_) ;
#  
#  // calculate the result
#  double result = arma::as_scalar(
#                   arma::trans(x) * arma::inv(Y) * z
#                  );
#  
#  // return it to R
#  return Rcpp::wrap( result );'
#  
#  writeLines(a, file = "myfile.cpp")

## ---- eval = FALSE-------------------------------------------------------
#  fx <- cxxfunction(signature(x_="numeric",
#                              Y_="matrix",
#                              z_="numeric" ),
#                    paste(readLines("myfile.cpp"),
#                          collapse="\n"),
#                    plugin="RcppArmadillo" )
#  fx(1:4, diag(4), 1:4)

## ---- eval = FALSE-------------------------------------------------------
#  fx <- cxxfunction(signature(),
#                    'RNGScope();
#                     return rnorm(5, 0, 100);',
#                    plugin="Rcpp")
#  set.seed(42)
#  fx()
#  fx()

## ---- eval = FALSE-------------------------------------------------------
#  cppFunction('Rcpp::NumericVector ff(int n) {
#                return rnorm(n, 0, 100);  }')
#  set.seed(42)
#  ff(5)
#  ff(5)
#  set.seed(42)
#  rnorm(5, 0, 100)
#  rnorm(5, 0, 100)

## ---- eval = FALSE-------------------------------------------------------
#  src <- 'Rcpp::NumericVector v(4);
#          v[0] = R_NegInf; // -Inf
#          v[1] = NA_REAL;  // NA
#          v[2] = R_PosInf; // Inf
#          v[3] = 42;       // c.f. Hitchhiker Guide
#          return Rcpp::wrap(v);'
#  fun <- cxxfunction(signature(), src, plugin="Rcpp")
#  fun()

## ---- eval = FALSE-------------------------------------------------------
#  txt <- 'arma::mat Am = Rcpp::as< arma::mat >(A);
#          arma::mat Bm = Rcpp::as< arma::mat >(B);
#          return Rcpp::wrap( Am * Bm );'
#  mmult <- cxxfunction(signature(A="numeric",
#                                 B="numeric"),
#                       body=txt,
#                       plugin="RcppArmadillo")
#  A <- matrix(1:9, 3, 3)
#  B <- matrix(9:1, 3, 3)
#  C <- mmult(A, B)

## ----eval=FALSE----------------------------------------------------------
#  A <- matrix(1:9, 3, 3)
#  B <- matrix(9:1, 3, 3)
#  A %*% B

## ---- eval = FALSE-------------------------------------------------------
#  # simple example of seeding RNG and
#  # drawing one random number
#  gslrng <- '
#  int seed = Rcpp::as<int>(par) ;
#  gsl_rng_env_setup();
#  gsl_rng *r = gsl_rng_alloc (gsl_rng_default);
#  gsl_rng_set (r, (unsigned long) seed);
#  double v = gsl_rng_get (r);
#  gsl_rng_free(r);
#  return Rcpp::wrap(v);'
#  
#  plug <- Rcpp::Rcpp.plugin.maker(
#      include.before = "#include <gsl/gsl_rng.h>",
#      libs = paste(
#  "-L/usr/local/lib/R/site-library/Rcpp/lib -lRcpp",
#  "-Wl,-rpath,/usr/local/lib/R/site-library/Rcpp/lib",
#  "-L/usr/lib -lgsl -lgslcblas -lm")
#  )
#  registerPlugin("gslDemo", plug )
#  fun <- cxxfunction(signature(par="numeric"),
#                     gslrng, plugin="gslDemo")
#  fun(0)

## ---- eval=FALSE---------------------------------------------------------
#  myplugin <- getPlugin("Rcpp")
#  myplugin$env$PKG_CXXFLAGS <- "-std=c++11"
#  f <- cxxfunction(signature(),
#                   settings = myplugin, body = '
#      // fails without -std=c++0x
#      std::vector<double> x = { 1.0, 2.0, 3.0 };
#      return Rcpp::wrap(x);
#  ')
#  f()

## ---- eval = FALSE-------------------------------------------------------
#  src <- '
#    Rcpp::NumericMatrix x(2,2);
#    x.fill(42);           // or another value
#    Rcpp::List dimnms =   // list with 2 vecs
#      Rcpp::List::create( // with static names
#        Rcpp::CharacterVector::create("cc", "dd"),
#        Rcpp::CharacterVector::create("ee", "ff")
#      );
#    // and assign it
#    x.attr("dimnames") = dimnms;
#    return(x);
#  '
#  fun <- cxxfunction(signature(),
#                     body=src, plugin="Rcpp")
#  fun()

## ---- eval = FALSE-------------------------------------------------------
#  BigInts <- cxxfunction(signature(),
#    'std::vector<long> bigints;
#     bigints.push_back(12345678901234567LL);
#     bigints.push_back(12345678901234568LL);
#     Rprintf("Difference of %ld\\n",
#         12345678901234568LL - 12345678901234567LL);
#     return wrap(bigints);',
#    plugin="Rcpp", includes="#include <vector>")
#  
#  retval <- BigInts()
#  
#  # Unique 64-bit integers were cast to identical
#  # lower precision numerics behind my back with
#  # no warnings or errors whatsoever.  Error.
#  
#  stopifnot(length(unique(retval)) == 2)

## ---- eval = FALSE-------------------------------------------------------
#  a <- 1.5:4.5
#  b <- 1.5:4.5
#  implicit_ref(a)
#  a
#  explicit_ref(b)
#  b

## ---- eval=FALSE---------------------------------------------------------
#  a <- 1:5
#  b <- 1:5
#  class(a)
#  int_vec_type(a)
#  a
#  num_vec_type(b)
#  b

## ---- eval=FALSE---------------------------------------------------------
#  x <- 1:10
#  const_override_ex(x)
#  x

## ---- eval=FALSE---------------------------------------------------------
#  vec_scalar_assign(5L, 3.14)

## ---- eval=FALSE---------------------------------------------------------
#  mat_scalar_assign(2L, 3.0)

## ---- eval = FALSE-------------------------------------------------------
#  test_long_vector_support()

## ---- eval=FALSE---------------------------------------------------------
#  set.seed(123)
#  (X <- sample(c(LETTERS[1:5], letters[1:6]), 11))
#  preferred_sort(X)
#  stl_sort(X)

## ---- eval=FALSE---------------------------------------------------------
#  x <- c("B", "b", "c", "A", "a")
#  sort(x)
#  rcpp_sort(x)

