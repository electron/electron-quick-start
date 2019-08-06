#ifndef dplyr_tools_match_h
#define dplyr_tools_match_h


namespace dplyr {

inline SEXP r_match(SEXP x, SEXP y, SEXP incomparables = R_NilValue) {
  static Rcpp::Function match("match", R_BaseEnv);

  if (R_VERSION == R_Version(3, 3, 0)) {
    // Work around matching bug in R 3.3.0: #1806
    // https://bugs.r-project.org/bugzilla3/show_bug.cgi?id=16885
    if (Rf_isNull(incomparables)) {
      Rcpp::Shield<SEXP> empty_lgl(Rf_allocVector(LGLSXP, 0));
      return match(x, y, NA_INTEGER, empty_lgl);
    }
    else {
      return match(x, y, NA_INTEGER, incomparables);
    }
  }
  else {
    return match(x, y, NA_INTEGER, incomparables);
  }
}

}

#endif
