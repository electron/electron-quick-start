#ifndef dplyr_tools_RowwiseDataFrame_H
#define dplyr_tools_RowwiseDataFrame_H

#include <tools/SlicingIndex.h>

#include <tools/SymbolVector.h>
#include <tools/SymbolString.h>
#include <tools/Quosure.h>

namespace dplyr {

class RowwiseDataFrame;

class RowwiseDataFrameIndexIterator {
public:
  RowwiseDataFrameIndexIterator() : i(0) {}

  RowwiseDataFrameIndexIterator& operator++() {
    ++i;
    return *this;
  }

  RowwiseSlicingIndex operator*() const {
    return RowwiseSlicingIndex(i);
  }

  int i;
};

class RowwiseDataFrame {
public:
  typedef RowwiseDataFrameIndexIterator group_iterator;
  typedef RowwiseSlicingIndex slicing_index;

  RowwiseDataFrame(SEXP x):
    data_(x)
  {}
  RowwiseDataFrame(SEXP x, const RowwiseDataFrame& /* model */):
    data_(x)
  {}

  group_iterator group_begin() const {
    return RowwiseDataFrameIndexIterator();
  }

  Rcpp::DataFrame& data() {
    return data_;
  }
  const Rcpp::DataFrame& data() const {
    return data_;
  }

  inline int nvars() const {
    return 0;
  }

  inline SymbolString symbol(int) {
    Rcpp::stop("Rowwise data frames don't have grouping variables");
  }

  inline SEXP label(int) {
    return R_NilValue;
  }

  inline int nrows() const {
    return data_.nrows();
  }

  inline int ngroups() const {
    return nrows();
  }

  inline R_xlen_t max_group_size() const {
    return 1;
  }

  inline const SymbolVector& get_vars() const {
    return vars;
  }

  static inline Rcpp::CharacterVector classes() {
    static Rcpp::CharacterVector classes = Rcpp::CharacterVector::create("rowwise_df", "tbl_df", "tbl", "data.frame");
    return classes;
  }

  void check_not_groups(const QuosureList& quosures) const {}

private:
  Rcpp::DataFrame data_;
  SymbolVector vars;
};

}

namespace Rcpp {

template <>
inline bool is<dplyr::RowwiseDataFrame>(SEXP x) {
  return Rf_inherits(x, "rowwise_df");
}

}

#endif
