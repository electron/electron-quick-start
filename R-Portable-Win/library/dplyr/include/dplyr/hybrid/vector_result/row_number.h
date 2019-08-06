#ifndef dplyr_hybrid_row_number_h
#define dplyr_hybrid_row_number_h

#include <dplyr/hybrid/HybridVectorVectorResult.h>
#include <dplyr/hybrid/Column.h>

#include <dplyr/visitors/SliceVisitor.h>
#include <dplyr/visitors/Comparer.h>
#include <dplyr/hybrid/Expression.h>

namespace dplyr {
namespace hybrid {

namespace internal {

template <typename SlicedTibble>
class RowNumber0 : public HybridVectorVectorResult<INTSXP, SlicedTibble, RowNumber0<SlicedTibble> > {
public:
  typedef HybridVectorVectorResult<INTSXP, SlicedTibble, RowNumber0<SlicedTibble> > Parent;

  RowNumber0(const SlicedTibble& data) : Parent(data) {}

  void fill(const typename SlicedTibble::slicing_index& indices, Rcpp::IntegerVector& out) const {
    int n = indices.size();
    for (int i = 0; i < n; i++) {
      out[indices[i]] = i + 1 ;
    }
  }

};

template <typename SlicedTibble, int RTYPE, bool ascending>
class RowNumber1 : public HybridVectorVectorResult<INTSXP, SlicedTibble, RowNumber1<SlicedTibble, RTYPE, ascending> > {
public:
  typedef HybridVectorVectorResult<INTSXP, SlicedTibble, RowNumber1 > Parent;
  typedef typename Rcpp::Vector<RTYPE>::stored_type STORAGE;
  typedef visitors::SliceVisitor<Rcpp::Vector<RTYPE>, typename SlicedTibble::slicing_index> SliceVisitor;
  typedef visitors::WriteSliceVisitor<Rcpp::IntegerVector, typename SlicedTibble::slicing_index> WriteSliceVisitor;
  typedef visitors::Comparer<RTYPE, SliceVisitor, ascending> Comparer;

  RowNumber1(const SlicedTibble& data, SEXP x) : Parent(data), vec(x) {}

  void fill(const typename SlicedTibble::slicing_index& indices, Rcpp::IntegerVector& out) const {
    int n = indices.size();

    SliceVisitor slice(vec, indices);
    WriteSliceVisitor out_slice(out, indices);

    std::vector<int> idx(n);
    for (int i = 0; i < n; i++) idx[i] = i;

    // sort idx by vec in the subset given by indices
    std::sort(idx.begin(), idx.end(), Comparer(slice));

    // deal with NA
    int m = indices.size();
    int j = m - 1;
    for (; j >= 0; j--) {
      if (Rcpp::traits::is_na<RTYPE>(slice[idx[j]])) {
        out_slice[idx[j]] = NA_INTEGER;
      } else {
        break;
      }
    }
    for (; j >= 0; j--) {
      out_slice[idx[j]] = j + 1;
    }
  }

private:
  Rcpp::Vector<RTYPE> vec;
};

}

template <typename SlicedTibble>
inline internal::RowNumber0<SlicedTibble> row_number_(const SlicedTibble& data) {
  return internal::RowNumber0<SlicedTibble>(data);
}

template <typename SlicedTibble, typename Operation>
inline SEXP row_number_1(const SlicedTibble& data, Column column, const Operation& op) {
  SEXP x = column.data;
  switch (TYPEOF(x)) {
  case INTSXP:
    return op(internal::RowNumber1<SlicedTibble, INTSXP, true>(data, x));
  case REALSXP:
    return op(internal::RowNumber1<SlicedTibble, REALSXP, true>(data, x));
  default:
    break;
  }
  return R_UnboundValue;
}

template <typename SlicedTibble, typename Operation>
SEXP row_number_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  switch (expression.size()) {
  case 0:
    // row_number()
    return op(row_number_(data));
  case 1:
    // row_number( <column> )
    Column x;
    if (expression.is_unnamed(0) && expression.is_column(0, x) && x.is_trivial()) {
      return row_number_1(data, x, op);
    }
  default:
    break;
  }
  return R_UnboundValue;
}

}
}

#endif
