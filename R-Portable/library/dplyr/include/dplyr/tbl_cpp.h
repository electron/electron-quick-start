#ifndef dplyr_tools_tbl_cpp_H
#define dplyr_tools_tbl_cpp_H

#include <dplyr/RowwiseDataFrame.h>

namespace dplyr {

template <typename Df>
inline void set_rownames(Df& data, int n) {
  data.attr("row.names") =
    Rcpp::IntegerVector::create(Rcpp::IntegerVector::get_na(), -n);
}

template <typename Data>
inline Rcpp::CharacterVector classes_grouped() {
  return Rcpp::CharacterVector::create("grouped_df", "tbl_df", "tbl", "data.frame");
}

template <>
inline Rcpp::CharacterVector classes_grouped<RowwiseDataFrame>() {
  return Rcpp::CharacterVector::create("rowwise_df", "tbl_df", "tbl", "data.frame");
}

inline Rcpp::CharacterVector classes_not_grouped() {
  return Rcpp::CharacterVector::create("tbl_df", "tbl", "data.frame");
}

}

#endif
