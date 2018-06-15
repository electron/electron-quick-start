#ifndef dplyr_RowwiseSubset_H
#define dplyr_RowwiseSubset_H

#include <tools/ShrinkableVector.h>
#include <tools/utils.h>

#include <dplyr/checks.h>

#include <dplyr/Result/GroupedSubsetBase.h>

namespace dplyr {

template <int RTYPE>
class RowwiseSubsetTemplate : public RowwiseSubset {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;
  RowwiseSubsetTemplate(SEXP x) :
    object(x), output(1), start(Rcpp::internal::r_vector_start<RTYPE>(object))
  {
    copy_most_attributes(output, x);
    SET_DPLYR_SHRINKABLE_VECTOR((SEXP)output);
  }

  ~RowwiseSubsetTemplate() {
    UNSET_DPLYR_SHRINKABLE_VECTOR((SEXP)output);
  }

  virtual SEXP get(const SlicingIndex& indices) {
    output[0] = start[ indices.group() ];
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
  Vector<RTYPE> output;
  STORAGE* start;
};

template <>
class RowwiseSubsetTemplate<VECSXP> : public RowwiseSubset {
public:
  RowwiseSubsetTemplate(SEXP x) :
    object(x), start(Rcpp::internal::r_vector_start<VECSXP>(object))
  {}

  virtual SEXP get(const SlicingIndex& indices) {
    return start[ indices.group() ];
  }
  virtual SEXP get_variable() const {
    return object;
  }
  virtual bool is_summary() const {
    return false;
  }

private:
  SEXP object;
  SEXP* start;
};


inline RowwiseSubset* rowwise_subset(SEXP x) {
  switch (check_supported_type(x)) {
  case DPLYR_INTSXP:
    return new RowwiseSubsetTemplate<INTSXP>(x);
  case DPLYR_REALSXP:
    return new RowwiseSubsetTemplate<REALSXP>(x);
  case DPLYR_LGLSXP:
    return new RowwiseSubsetTemplate<LGLSXP>(x);
  case DPLYR_STRSXP:
    return new RowwiseSubsetTemplate<STRSXP>(x);
  case DPLYR_CPLXSXP:
    return new RowwiseSubsetTemplate<CPLXSXP>(x);
  case DPLYR_VECSXP:
    return new RowwiseSubsetTemplate<VECSXP>(x);
  }

  stop("Unreachable");
  return 0;
}

}

#endif
