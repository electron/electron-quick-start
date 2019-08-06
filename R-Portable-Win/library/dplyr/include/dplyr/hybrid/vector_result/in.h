#ifndef dplyr_hybrid_in_h
#define dplyr_hybrid_in_h

#include <dplyr/hybrid/HybridVectorVectorResult.h>
#include <dplyr/hybrid/Column.h>
#include <dplyr/hybrid/Expression.h>

#include <tools/hash.h>

namespace dplyr {
namespace hybrid {

namespace internal {

template <typename SlicedTibble, int RTYPE>
class In_Column_Column : public HybridVectorVectorResult<LGLSXP, SlicedTibble, In_Column_Column<SlicedTibble, RTYPE> > {
public:
  typedef HybridVectorVectorResult<LGLSXP, SlicedTibble, In_Column_Column> Parent;
  typedef Rcpp::Vector<RTYPE> Vector;
  typedef typename Vector::stored_type stored_type;

  In_Column_Column(const SlicedTibble& data, SEXP x, SEXP y) :
    Parent(data),
    lhs(x),
    rhs(y)
  {}

  void fill(const typename SlicedTibble::slicing_index& indices, Rcpp::LogicalVector& out) const {
    int n = indices.size();

    dplyr_hash_set<stored_type> set(n);
    for (int i = 0; i < indices.size(); i++) {
      set.insert((stored_type)rhs[indices[i]]);
    }

    for (int i = 0; i < n; i++) {
      stored_type value = lhs[indices[i]];
      if (Vector::is_na(value)) {
        out[ indices[i] ] = false;
      } else {
        out[ indices[i] ] = set.count(value);
      }
    }
  }

private:
  Vector lhs;
  Vector rhs;
};

}

template <typename SlicedTibble, typename Operation>
inline SEXP in_column_column(const SlicedTibble& data, Column col_x, Column col_y, const Operation& op) {
  if (TYPEOF(col_x.data) != TYPEOF(col_y.data)) return R_UnboundValue;
  SEXP x = col_x.data, y = col_y.data;

  switch (TYPEOF(x)) {
  case LGLSXP:
    return op(internal::In_Column_Column<SlicedTibble, LGLSXP>(data, x, y));
  case RAWSXP:
    return op(internal::In_Column_Column<SlicedTibble, RAWSXP>(data, x, y));
  case INTSXP:
    return op(internal::In_Column_Column<SlicedTibble, INTSXP>(data, x, y));
  case REALSXP:
    return op(internal::In_Column_Column<SlicedTibble, REALSXP>(data, x, y));
  case STRSXP:
    return op(internal::In_Column_Column<SlicedTibble, STRSXP>(data, x, y));
  case CPLXSXP:
    return op(internal::In_Column_Column<SlicedTibble, CPLXSXP>(data, x, y));
  case VECSXP:
    return op(internal::In_Column_Column<SlicedTibble, VECSXP>(data, x, y));
  default:
    break;
  }
  return R_UnboundValue;

}

template <typename SlicedTibble, typename Operation>
inline SEXP in_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  if (expression.size() == 2) {
    // <column> %in% <column>

    Column lhs;
    Column rhs;

    if (expression.is_unnamed(0) && expression.is_column(0, lhs) && lhs.is_trivial() && expression.is_unnamed(1) && expression.is_column(1, rhs) && rhs.is_trivial()) {
      return in_column_column(data, lhs, rhs, op);
    }
  }
  return R_UnboundValue;
}

}
}

#endif
