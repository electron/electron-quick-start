#ifndef dplyr_hybrid_group_indices_h
#define dplyr_hybrid_group_indices_h

#include <dplyr/hybrid/HybridVectorScalarResult.h>

namespace dplyr {
namespace hybrid {

namespace internal {

template <typename SlicedTibble>
class GroupIndices : public HybridVectorScalarResult<INTSXP, SlicedTibble, GroupIndices<SlicedTibble> > {
public:
  typedef HybridVectorScalarResult<INTSXP, SlicedTibble, GroupIndices> Parent ;

  GroupIndices(const SlicedTibble& data) : Parent(data) {}

  inline int process(const typename SlicedTibble::slicing_index& indices) const {
    return indices.group() + 1;
  }
};
}

// group_indices()
template <typename SlicedTibble, typename Expression, typename Operation>
inline SEXP group_indices_dispatch(const SlicedTibble& data, const Expression& expression, const Operation& op) {
  return expression.size() == 0 ? op(internal::GroupIndices<SlicedTibble>(data)) : R_UnboundValue;
}

}
}

#endif
