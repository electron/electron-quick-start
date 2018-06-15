#ifndef dplyr_Result_is_smaller_H
#define dplyr_Result_is_smaller_H

namespace dplyr {
namespace internal {

template <int RTYPE>
inline bool is_smaller(typename Rcpp::traits::storage_type<RTYPE>::type lhs, typename Rcpp::traits::storage_type<RTYPE>::type rhs) {
  return lhs < rhs;
}
template <>
inline bool is_smaller<STRSXP>(SEXP lhs, SEXP rhs) {
  return strcmp(CHAR(lhs), CHAR(rhs)) < 0;
}

} // namespace internal
} // namespace dplyr

#endif
