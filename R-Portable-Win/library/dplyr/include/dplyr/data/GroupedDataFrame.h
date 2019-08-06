#ifndef dplyr_tools_GroupedDataFrame_H
#define dplyr_tools_GroupedDataFrame_H

#include <tools/SlicingIndex.h>
#include <tools/VectorView.h>

#include <tools/SymbolVector.h>
#include <tools/SymbolMap.h>
#include <tools/bad.h>
#include <dplyr/symbols.h>
#include <tools/Quosure.h>

namespace dplyr {
class GroupedDataFrame;

class GroupedDataFrameIndexIterator {
public:
  GroupedDataFrameIndexIterator(const GroupedDataFrame& gdf_);

  GroupedDataFrameIndexIterator& operator++();

  GroupedSlicingIndex operator*() const;

  int i;
  const GroupedDataFrame& gdf;
  Rcpp::ListView indices;
};

class GroupedDataFrame {
private:
  GroupedDataFrame(const GroupedDataFrame&);

public:
  typedef GroupedDataFrameIndexIterator group_iterator;
  typedef GroupedSlicingIndex slicing_index;

  GroupedDataFrame(Rcpp::DataFrame x);
  GroupedDataFrame(Rcpp::DataFrame x, const GroupedDataFrame& model);

  group_iterator group_begin() const {
    return GroupedDataFrameIndexIterator(*this);
  }

  SymbolString symbol(int i) const {
    return symbols.get_name(i);
  }

  Rcpp::DataFrame& data() {
    return data_;
  }
  const Rcpp::DataFrame& data() const {
    return data_;
  }

  inline int size() const {
    return data_.size();
  }

  inline int ngroups() const {
    return groups.nrow();
  }

  inline int nvars() const {
    return nvars_ ;
  }

  inline int nrows() const {
    return data_.nrows();
  }

  inline SEXP label(int i) const {
    return groups[i];
  }

  inline bool has_group(const SymbolString& g) const {
    return symbols.has(g);
  }

  inline SEXP indices() const {
    return groups[groups.size() - 1] ;
  }

  inline const SymbolVector& get_vars() const {
    return symbols.get_names();
  }

  inline const Rcpp::DataFrame& group_data() const {
    return groups;
  }

  template <typename Data>
  static void set_groups(Data& x, SEXP groups) {
    Rf_setAttrib(x, symbols::groups, groups);
  }

  template <typename Data>
  static void strip_groups(Data& x) {
    set_groups(x, R_NilValue);
  }

  template <typename Data1, typename Data2>
  static void copy_groups(Data1& x, const Data2& y) {
    copy_attrib(x, y, symbols::groups);
  }

  static inline Rcpp::CharacterVector classes() {
    static Rcpp::CharacterVector classes = Rcpp::CharacterVector::create("grouped_df", "tbl_df", "tbl", "data.frame");
    return classes;
  }

  bool drops() const {
    SEXP drop_attr = Rf_getAttrib(groups, symbols::dot_drop);
    return Rf_isNull(drop_attr) || (Rcpp::is<bool>(drop_attr) && LOGICAL(drop_attr)[0] != FALSE);
  }

  inline R_xlen_t max_group_size() const {
    R_xlen_t res = 0;
    SEXP rows = indices();
    R_xlen_t ng = XLENGTH(rows);
    for (R_xlen_t i = 0; i < ng; i++) {
      res = std::max(XLENGTH(VECTOR_ELT(rows, i)), res);
    }
    return res;
  }

  void check_not_groups(const QuosureList& quosures) const {
    int n = quosures.size();
    for (int i = 0; i < n; i++) {
      if (has_group(quosures[i].name()))
        bad_col(quosures[i].name(), "can't be modified because it's a grouping variable");
    }
  }

private:

  SymbolVector group_vars() const ;

  Rcpp::DataFrame data_;
  SymbolMap symbols;
  Rcpp::DataFrame groups;
  int nvars_;

};

inline GroupedDataFrameIndexIterator::GroupedDataFrameIndexIterator(const GroupedDataFrame& gdf_) :
  i(0), gdf(gdf_), indices(gdf.indices()) {}

inline GroupedDataFrameIndexIterator& GroupedDataFrameIndexIterator::operator++() {
  i++;
  return *this;
}

inline GroupedSlicingIndex GroupedDataFrameIndexIterator::operator*() const {
  return GroupedSlicingIndex(indices[i], i);
}

}

namespace Rcpp {

template <>
inline bool is<dplyr::GroupedDataFrame>(SEXP x) {
  return Rf_inherits(x, "grouped_df");
}

template <>
class ConstReferenceInputParameter<dplyr::GroupedDataFrame> {
public:
  typedef const dplyr::GroupedDataFrame& const_reference ;

  ConstReferenceInputParameter(SEXP x_) : df(x_), obj(df) {}

  inline operator const_reference() {
    return obj ;
  }

private:
  DataFrame df;
  dplyr::GroupedDataFrame obj ;
} ;

}

#endif
