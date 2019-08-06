#ifndef dplyr_hybrid_column_h
#define dplyr_hybrid_column_h

namespace dplyr {
namespace hybrid {

struct Column {
  SEXP data;
  bool is_desc;

  inline bool is_trivial() const {
    return !Rf_isObject(data) && !Rf_isS4(data) && RCPP_GET_CLASS(data) == R_NilValue;
  }
};

}
}

#endif
