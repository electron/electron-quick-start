#ifndef dplyr_GroupedSubset_H
#define dplyr_GroupedSubset_H

#include <tools/ShrinkableVector.h>

#include <dplyr/DataFrameSubsetVisitors.h>
#include <dplyr/SummarisedVariable.h>
#include <dplyr/Result/GroupedSubsetBase.h>

namespace dplyr {

template <int RTYPE>
class GroupedSubsetTemplate : public GroupedSubset {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;
  GroupedSubsetTemplate(SEXP x, int max_size) :
    object(x), output(max_size, object), start(Rcpp::internal::r_vector_start<RTYPE>(object)) {}

  virtual SEXP get(const SlicingIndex& indices) {
    output.borrow(indices, start);
    return output;
  }
  virtual SEXP get_variable() const {
    return object;
  }
  virtual bool is_summary() const {
    return false;
  }

private:
  SEXP object;
  ShrinkableVector<RTYPE> output;
  STORAGE* start;
};

class DataFrameGroupedSubset : public GroupedSubset {
public:
  DataFrameGroupedSubset(SEXP x) : data(x), visitors(data) {}

  virtual SEXP get(const SlicingIndex& indices) {
    return visitors.subset(indices, get_class(data));
  }

  virtual SEXP get_variable() const {
    return data;
  }

  virtual bool is_summary() const {
    return false;
  }

private:
  DataFrame data;
  DataFrameSubsetVisitors visitors;
};

inline GroupedSubset* grouped_subset(SEXP x, int max_size) {
  switch (TYPEOF(x)) {
  case INTSXP:
    return new GroupedSubsetTemplate<INTSXP>(x, max_size);
  case REALSXP:
    return new GroupedSubsetTemplate<REALSXP>(x, max_size);
  case LGLSXP:
    return new GroupedSubsetTemplate<LGLSXP>(x, max_size);
  case STRSXP:
    return new GroupedSubsetTemplate<STRSXP>(x, max_size);
  case VECSXP:
    if (Rf_inherits(x, "data.frame"))
      return new DataFrameGroupedSubset(x);
    if (Rf_inherits(x, "POSIXlt")) {
      stop("POSIXlt not supported");
    }
    return new GroupedSubsetTemplate<VECSXP>(x, max_size);
  case CPLXSXP:
    return new GroupedSubsetTemplate<CPLXSXP>(x, max_size);
  default:
    break;
  }
  stop("is of unsupported type %s", Rf_type2char(TYPEOF(x)));
}


template <int RTYPE>
class SummarisedSubsetTemplate : public GroupedSubset {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  SummarisedSubsetTemplate(SummarisedVariable x) :
    object(x), output(1)
  {
    copy_most_attributes(output, object);
  }

  virtual SEXP get(const SlicingIndex& indices) {
    output[0] = object[indices.group()];
    return output;
  }
  virtual SEXP get_variable() const {
    return object;
  }
  virtual bool is_summary() const {
    return true;
  }

private:
  Rcpp::Vector<RTYPE> object;
  Rcpp::Vector<RTYPE> output;
};

template <>
inline SEXP SummarisedSubsetTemplate<VECSXP>::get(const SlicingIndex& indices) {
  return List::create(object[indices.group()]);
}

inline GroupedSubset* summarised_subset(SummarisedVariable x) {
  switch (TYPEOF(x)) {
  case LGLSXP:
    return new SummarisedSubsetTemplate<LGLSXP>(x);
  case INTSXP:
    return new SummarisedSubsetTemplate<INTSXP>(x);
  case REALSXP:
    return new SummarisedSubsetTemplate<REALSXP>(x);
  case STRSXP:
    return new SummarisedSubsetTemplate<STRSXP>(x);
  case VECSXP:
    return new SummarisedSubsetTemplate<VECSXP>(x);
  case CPLXSXP:
    return new SummarisedSubsetTemplate<CPLXSXP>(x);
  default:
    break;
  }
  stop("is of unsupported type %s", Rf_type2char(TYPEOF(x)));
}
}

#endif
