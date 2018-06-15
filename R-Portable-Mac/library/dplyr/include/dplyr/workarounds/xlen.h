#ifndef DPLYR_WORKAROUND_XLEN_H
#define DPLYR_WORKAROUND_XLEN_H

#ifdef LONG_VECTOR_SUPPORT

namespace Rcpp {

template <>
inline SEXP wrap(const R_xlen_t& x) {
  if (x < -R_SHORT_LEN_MAX || x > R_SHORT_LEN_MAX) {
    return Rf_ScalarReal(static_cast<double>(x));
  }
  else {
    return Rf_ScalarInteger(static_cast<int>(x));
  }
}

}

#endif

#endif
