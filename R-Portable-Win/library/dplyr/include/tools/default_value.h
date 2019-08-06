#ifndef dplyr_dplyr_default_value_H
#define dplyr_dplyr_default_value_H

namespace dplyr {

template <int RTYPE>
inline typename Rcpp::traits::storage_type<RTYPE>::type default_value() {
  return Rcpp::Vector<RTYPE>::get_na() ;
}

template <>
inline Rbyte default_value<RAWSXP>() {
  return (Rbyte)0 ;
}

template <>
inline SEXP default_value<VECSXP>() {
  return R_NilValue ;
}

template <int RTYPE>
inline bool is_nan(typename Rcpp::Vector<RTYPE>::stored_type value) {
  return false;
}
template <>
inline bool is_nan<REALSXP>(double value) {
  return R_IsNaN(value);
}

}
#endif
