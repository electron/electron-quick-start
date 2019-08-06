#ifndef dplyr_tools_NaturalDataFrame_H
#define dplyr_tools_NaturalDataFrame_H

#include <tools/SlicingIndex.h>

#include <tools/SymbolVector.h>
#include <tools/bad.h>
#include <tools/Quosure.h>

namespace dplyr {

class NaturalDataFrame;

class NaturalDataFrameIndexIterator {
public:
  NaturalDataFrameIndexIterator(int n_): n(n_) {}

  NaturalDataFrameIndexIterator& operator++() {
    return *this;
  }

  NaturalSlicingIndex operator*() const {
    return NaturalSlicingIndex(n);
  }

private:
  int n;
};

class NaturalDataFrame {
public:
  typedef NaturalDataFrameIndexIterator group_iterator;
  typedef NaturalSlicingIndex slicing_index;

  NaturalDataFrame(SEXP x):
    data_(x)
  {}
  NaturalDataFrame(SEXP x, const NaturalDataFrame& /* model */):
    data_(x)
  {}

  NaturalDataFrameIndexIterator group_begin() const {
    return NaturalDataFrameIndexIterator(nrows());
  }

  SymbolString symbol(int i) const {
    return SymbolString() ;
  }

  Rcpp::DataFrame& data() {
    return data_;
  }
  const Rcpp::DataFrame& data() const {
    return data_;
  }

  inline int ngroups() const {
    return 1;
  }

  inline int nvars() const {
    return 0;
  }

  inline int nrows() const {
    return data_.nrows();
  }

  inline SEXP label(int i) const {
    return R_NilValue ;
  }

  inline bool has_group(const SymbolString& g) const {
    return false ;
  }

  inline int size() const {
    return data_.size() ;
  }
  inline SEXP operator[](int i) {
    return data_[i];
  }

  inline const SymbolVector& get_vars() const {
    return vars;
  }

  static inline Rcpp::CharacterVector classes() {
    static Rcpp::CharacterVector classes = Rcpp::CharacterVector::create("tbl_df", "tbl", "data.frame");
    return classes;
  }

  inline R_xlen_t max_group_size() const {
    return nrows();
  }

  void check_not_groups(const QuosureList& quosures) const {}

private:
  Rcpp::DataFrame data_;
  SymbolVector vars;
};

}

#endif
