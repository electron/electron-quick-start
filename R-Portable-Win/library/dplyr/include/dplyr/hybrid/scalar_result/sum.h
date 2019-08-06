#ifndef dplyr_hybrid_sum_h
#define dplyr_hybrid_sum_h

#include <dplyr/hybrid/HybridVectorScalarResult.h>
#include <dplyr/hybrid/Dispatch.h>
#include <dplyr/hybrid/Expression.h>

namespace dplyr {
namespace hybrid {

namespace internal {

template <int RTYPE, typename STORAGE, typename slicing_index, bool NA_RM>
struct SumImpl {
  static STORAGE process(STORAGE* data_ptr, const slicing_index& indices) {
    long double res = 0;
    int n = indices.size();
    for (int i = 0; i < n; i++) {
      STORAGE value = data_ptr[indices[i]];

      // this is both NA and NaN
      if (Rcpp::traits::is_na<RTYPE>(value)) {
        if (NA_RM) {
          continue;
        }

        return value;
      }

      res += value;
    }

    if (RTYPE == INTSXP && (res > INT_MAX || res <= INT_MIN)) {
      Rcpp::warning("integer overflow - use sum(as.numeric(.))");
      return Rcpp::traits::get_na<INTSXP>();
    }

    return (STORAGE)res;
  }
};

// General case (for INTSXP and LGLSXP)
template <int RTYPE, bool NA_RM, typename SlicedTibble>
class SumTemplate : public HybridVectorScalarResult < RTYPE == LGLSXP ? INTSXP : RTYPE, SlicedTibble, SumTemplate<RTYPE, NA_RM, SlicedTibble> >  {
public :
  static const int rtype = RTYPE == LGLSXP ? INTSXP : RTYPE;
  typedef typename Rcpp::Vector<RTYPE>::stored_type STORAGE;

  typedef HybridVectorScalarResult<rtype, SlicedTibble, SumTemplate> Parent ;

  SumTemplate(const SlicedTibble& data_, Column column_) :
    Parent(data_),
    data_ptr(Rcpp::internal::r_vector_start<RTYPE>(column_.data))
  {}

  STORAGE process(const typename SlicedTibble::slicing_index& indices) const {
    return SumImpl<RTYPE, STORAGE, typename SlicedTibble::slicing_index, NA_RM>::process(data_ptr, indices);
  }

private:
  STORAGE* data_ptr;
};

template <typename SlicedTibble, typename Operation>
class SumDispatch {
public:
  SumDispatch(const SlicedTibble& data_, Column variable_, bool narm_, const Operation& op_):
    data(data_),
    variable(variable_),
    narm(narm_),
    op(op_)
  {}

  SEXP get() const {
    // dispatch to the method below based on na.rm
    if (narm) {
      return operate_narm<true>();
    } else {
      return operate_narm<false>();
    }
  }

private:
  const SlicedTibble& data;
  Column variable;
  bool narm;
  const Operation& op;

  template <bool NARM>
  SEXP operate_narm() const {
    // try to dispatch to the right class
    switch (TYPEOF(variable.data)) {
    case INTSXP:
      return op(SumTemplate<INTSXP, NARM, SlicedTibble>(data, variable));
    case REALSXP:
      return op(SumTemplate<REALSXP, NARM, SlicedTibble>(data, variable));
    case LGLSXP:
      return op(SumTemplate<LGLSXP, NARM, SlicedTibble>(data, variable));
    }

    // give up, effectively let R evaluate the call
    return R_UnboundValue;
  }

};


} // namespace internal

template <typename SlicedTibble, typename Operation>
SEXP sum_(const SlicedTibble& data, Column variable, bool narm, const Operation& op) {
  return internal::SumDispatch<SlicedTibble, Operation>(data, variable, narm, op).get();
}

template <typename SlicedTibble, typename Operation>
SEXP sum_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  Column x;

  switch (expression.size()) {
  case 1:
    // sum( <column> )
    if (expression.is_unnamed(0) && expression.is_column(0, x) && x.is_trivial()) {
      return sum_(data, x, /* na.rm = */ false, op);
    }
    break;
  case 2:
    bool test;
    if (expression.is_unnamed(0) && expression.is_column(0, x) && x.is_trivial() &&
        expression.is_named(1, symbols::narm) && expression.is_scalar_logical(1, test)
       ) {
      return sum_(data, x, test, op);
    }
  default:
    break;
  }
  return R_UnboundValue;
}

}
}


#endif
