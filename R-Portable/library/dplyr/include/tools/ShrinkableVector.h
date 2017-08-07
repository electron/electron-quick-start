#ifndef dplyr_ShrinkableVector_H
#define dplyr_ShrinkableVector_H

#include <tools/Encoding.h>
#include <tools/utils.h>

namespace Rcpp {

template <int RTYPE>
class ShrinkableVector {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  ShrinkableVector(int n, SEXP origin) :
    data(no_init(n)), max_size(n), start(internal::r_vector_start<RTYPE>(data)), gp(LEVELS(data))
  {
    copy_most_attributes(data, origin);
    SET_DPLYR_SHRINKABLE_VECTOR((SEXP)data);
  }

  inline void resize(int n) {
    SETLENGTH(data, n);
  }

  inline operator SEXP() const {
    return data;
  }

  inline void borrow(const SlicingIndex& indices, STORAGE* begin) {
    int n = indices.size();
    for (int i = 0; i < n; i++) {
      start[i] = begin[indices[i]];
    }
    SETLENGTH(data, n);
  }

  ~ShrinkableVector() {
    // restore the initial length so that R can reclaim the memory
    SETLENGTH(data, max_size);
    UNSET_DPLYR_SHRINKABLE_VECTOR((SEXP)data);
  }

private:
  Rcpp::Vector<RTYPE> data;
  int max_size;
  STORAGE* start;
  unsigned short gp;

};

inline bool is_ShrinkableVector(SEXP x) {
  return IS_DPLYR_SHRINKABLE_VECTOR(x);
}

}

#endif
