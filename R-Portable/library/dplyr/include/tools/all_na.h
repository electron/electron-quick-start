#ifndef dplyr_tools_all_na_H
#define dplyr_tools_all_na_H

template <int RTYPE>
inline bool all_na_impl(const Vector<RTYPE>& x) {
  return all(is_na(x)).is_true();
}

template <>
inline bool all_na_impl<REALSXP>(const NumericVector& x) {
  return all(is_na(x) & !is_nan(x)).is_true();
}

inline bool all_na(SEXP x) {
  RCPP_RETURN_VECTOR(all_na_impl, x);
}

#endif
