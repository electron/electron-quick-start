#ifndef dplyr_DataFrameSubsetVisitors_H
#define dplyr_DataFrameSubsetVisitors_H

#include <tools/pointer_vector.h>
#include <tools/match.h>
#include <tools/utils.h>

#include <dplyr/tbl_cpp.h>
#include <dplyr/subset_visitor.h>
#include <dplyr/bad.h>

namespace dplyr {

class DataFrameSubsetVisitors {
private:

  const Rcpp::DataFrame& data;
  pointer_vector<SubsetVectorVisitor> visitors;
  SymbolVector visitor_names;
  int nvisitors;

public:
  typedef SubsetVectorVisitor visitor_type;

  DataFrameSubsetVisitors(const Rcpp::DataFrame& data_) :
    data(data_),
    visitors(),
    visitor_names(data.names()),
    nvisitors(visitor_names.size())
  {
    CharacterVector names = data.names();
    for (int i = 0; i < nvisitors; i++) {
      SubsetVectorVisitor* v = subset_visitor(data[i], names[i]);
      visitors.push_back(v);
    }
  }

  DataFrameSubsetVisitors(const DataFrame& data_, const SymbolVector& names) :
    data(data_),
    visitors(),
    visitor_names(names),
    nvisitors(visitor_names.size())
  {

    CharacterVector data_names = data.names();
    IntegerVector indx = names.match_in_table(data_names);

    int n = indx.size();
    for (int i = 0; i < n; i++) {

      int pos = indx[i];
      if (pos == NA_INTEGER) {
        bad_col(names[i], "is unknown");
      }

      SubsetVectorVisitor* v = subset_visitor(data[pos - 1], data_names[pos - 1]);
      visitors.push_back(v);

    }

  }

  template <typename Container>
  DataFrame subset(const Container& index, const CharacterVector& classes) const {
    List out(nvisitors);
    for (int k = 0; k < nvisitors; k++) {
      out[k] = get(k)->subset(index);
    }
    copy_most_attributes(out, data);
    structure(out, output_size(index), classes);
    return out;
  }

  inline int size() const {
    return nvisitors;
  }
  inline SubsetVectorVisitor* get(int k) const {
    return visitors[k];
  }

  const SymbolString name(int k) const {
    return visitor_names[k];
  }

  inline int nrows() const {
    return data.nrows();
  }

private:

  inline void structure(List& x, int nrows, CharacterVector classes) const {
    set_class(x, classes);
    set_rownames(x, nrows);
    x.names() = visitor_names;
    copy_vars(x, data);
  }

};

template <>
inline DataFrame DataFrameSubsetVisitors::subset(const LogicalVector& index, const CharacterVector& classes) const {
  const int n = index.size();
  std::vector<int> idx;
  idx.reserve(n);
  for (int i = 0; i < n; i++) {
    if (index[i] == TRUE) {
      idx.push_back(i);
    }
  }
  return subset(idx, classes);
}

template <typename Index>
DataFrame subset(DataFrame df, const Index& indices, const SymbolVector& columns, const CharacterVector& classes) {
  return DataFrameSubsetVisitors(df, columns).subset(indices, classes);
}

template <typename Index>
DataFrame subset(DataFrame df, const Index& indices, CharacterVector classes) {
  return DataFrameSubsetVisitors(df).subset(indices, classes);
}

} // namespace dplyr

#include <dplyr/subset_visitor_impl.h>

#endif
