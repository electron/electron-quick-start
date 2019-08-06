#ifndef DPLY_VISITORS_SUBSET_DataFrameSubsetVisitors_H
#define DPLY_VISITORS_SUBSET_DataFrameSubsetVisitors_H

#include <tools/utils.h>
#include <tools/bad.h>
#include <dplyr/visitors/subset/column_subset.h>

namespace dplyr {

class DataFrameSubsetVisitors {
private:
  Rcpp::DataFrame data;
  SEXP frame;

public:
  DataFrameSubsetVisitors(const Rcpp::DataFrame& data_, SEXP frame_): data(data_), frame(frame_) {}

  inline int size() const {
    return data.size();
  }

  template <typename Index>
  Rcpp::DataFrame subset_all(const Index& index) const {
    return dataframe_subset<Index>(data, index, get_class(data), frame);
  }

  template <typename Index>
  SEXP subset_one(int i, const Index& index) const {
    return column_subset(data[i], index, frame);
  }

};

}

#endif

