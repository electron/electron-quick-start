#ifndef dplyr_allow_list_H
#define dplyr_allow_list_H

namespace dplyr {

inline bool allow_list(SEXP x) {
  if (Rf_isMatrix(x)) {
    // might have to refine later
    return true;
  }
  switch (TYPEOF(x)) {
  case RAWSXP:
    return true;
  case INTSXP:
    return true;
  case REALSXP:
    return true;
  case LGLSXP:
    return true;
  case STRSXP:
    return true;
  case CPLXSXP:
    return true;
  case VECSXP: {
    if (Rf_inherits(x, "POSIXlt")) return false;
    return true;
  }

  default:
    break;
  }
  return false;
}

}
#endif
