#ifndef dplyr_Result_VectorSliceVisitor_H
#define dplyr_Result_VectorSliceVisitor_H

#include <tools/wrap_subset.h>

namespace dplyr {

template <int RTYPE>
class VectorSliceVisitor {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  VectorSliceVisitor(const Vector<RTYPE>& data_, const SlicingIndex& index_) :
    data(data_),
    n(index_.size()),
    index(index_)
  {}

  inline STORAGE operator[](int i) const {
    return data[index[i]];
  }

  inline int size() const {
    return n;
  }

  inline operator SEXP() const {
    return wrap_subset<RTYPE>(data, index);
  }

private:
  const Vector<RTYPE>& data;
  int n;
  const SlicingIndex& index;
};

}

#endif
