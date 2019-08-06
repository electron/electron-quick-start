#ifndef dplyr_tools_set_rownames_H
#define dplyr_tools_set_rownames_H

namespace dplyr {

template <typename Df>
inline void set_rownames(Df& data, int n) {
  Rcpp::Shield<SEXP> row_names(Rf_allocVector(INTSXP, 2));
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = -n;
  Rf_setAttrib(data, R_RowNamesSymbol, row_names);
}

}

#endif
