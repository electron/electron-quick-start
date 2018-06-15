#ifndef dplyr_DataFrameColumnSubsetVisitors_H
#define dplyr_DataFrameColumnSubsetVisitors_H

#include <dplyr/SubsetVectorVisitor.h>

namespace dplyr {

class DataFrameColumnSubsetVisitor : public SubsetVectorVisitor {
public:
  DataFrameColumnSubsetVisitor(const DataFrame& data_) : data(data_), visitors(data) {}

  inline SEXP subset(const Rcpp::IntegerVector& index) const {
    return visitors.subset(index, get_class(data));
  }

  inline SEXP subset(const std::vector<int>& index) const {
    return visitors.subset(index, get_class(data));
  }

  inline SEXP subset(const SlicingIndex& index) const {
    return visitors.subset(index, get_class(data));
  }

  inline SEXP subset(const ChunkIndexMap& index) const {
    return visitors.subset(index, get_class(data));
  }

  inline SEXP subset(EmptySubset index) const {
    return visitors.subset(index, get_class(data));
  }

  inline int size() const {
    return visitors.nrows();
  }

  inline std::string get_r_type() const {
    return "data.frame";
  }

  inline bool is_compatible(SubsetVectorVisitor* other, std::stringstream&, const SymbolString&) const {
    return is_same_typeid(other);
  }

private:
  DataFrame data;
  DataFrameSubsetVisitors visitors;
};

}

#endif
