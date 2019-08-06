#ifndef dplyr_hybrid_count_h
#define dplyr_hybrid_count_h

#include <dplyr/hybrid/HybridVectorScalarResult.h>

namespace dplyr {
namespace hybrid {

template <typename SlicedTibble>
class Count : public HybridVectorScalarResult<INTSXP, SlicedTibble, Count<SlicedTibble> > {
public:
  typedef HybridVectorScalarResult<INTSXP, SlicedTibble, Count<SlicedTibble> > Parent ;

  Count(const SlicedTibble& data) : Parent(data) {}

  int process(const typename SlicedTibble::slicing_index& indices) const {
    return indices.size();
  }
} ;

template <typename SlicedTibble>
inline Count<SlicedTibble> n_(const SlicedTibble& data) {
  return Count<SlicedTibble>(data);
}

template <typename SlicedTibble, typename Expression, typename Operation>
inline SEXP n_dispatch(const SlicedTibble& data, const Expression& expression, const Operation& op) {
  return expression.size() == 0 ? op(n_(data)) : R_UnboundValue;
}


}
}


#endif
