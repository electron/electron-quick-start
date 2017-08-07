#ifndef dplyr_white_list_H
#define dplyr_white_list_H

namespace dplyr {

inline bool white_list(SEXP x) {
  if (Rf_isMatrix(x)) {
    // might have to refine later
    return true;
  }
  switch (TYPEOF(x)) {
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

