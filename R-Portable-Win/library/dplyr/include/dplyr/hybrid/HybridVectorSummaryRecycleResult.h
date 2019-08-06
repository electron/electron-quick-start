#ifndef DPLYR_HYBRID_HybridVectorSummaryRecycleResult_H
#define DPLYR_HYBRID_HybridVectorSummaryRecycleResult_H

#include <dplyr/hybrid/HybridVectorVectorResult.h>

namespace dplyr {
namespace hybrid {

template <int RTYPE, typename SlicedTibble, typename Impl>
class HybridVectorSummaryRecycleResult :
  public HybridVectorVectorResult<RTYPE, SlicedTibble, HybridVectorSummaryRecycleResult<RTYPE, SlicedTibble, Impl> >
{
public:
  typedef HybridVectorVectorResult<RTYPE, SlicedTibble, HybridVectorSummaryRecycleResult> Parent;
  typedef Rcpp::Vector<RTYPE> Vector;

  HybridVectorSummaryRecycleResult(const SlicedTibble& data) : Parent(data) {}

  void fill(const typename SlicedTibble::slicing_index& indices, Vector& out) const {
    int n = indices.size();
    typename Vector::stored_type value = self()->value(indices);
    for (int i = 0; i < n; i++) out[indices[i]] = value;
  }

private:

  inline const Impl* self() const {
    return static_cast<const Impl*>(this);
  }

};

}
}



#endif


