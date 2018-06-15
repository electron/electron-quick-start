#ifndef dplyr_Result_Mean_H
#define dplyr_Result_Mean_H

#include <dplyr/Result/Processor.h>

namespace dplyr {
namespace internal {

// version for NA_RM == true
template <int RTYPE, bool NA_RM, typename Index>
struct Mean_internal {
  static double process(typename Rcpp::traits::storage_type<RTYPE>::type* ptr,  const Index& indices) {
    typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;
    long double res = 0.0;
    int n = indices.size();
    int m = 0;
    for (int i = 0; i < n; i++) {
      STORAGE value = ptr[ indices[i] ];
      if (! Rcpp::traits::is_na<RTYPE>(value)) {
        res += value;
        m++;
      }
    }
    if (m == 0) return R_NaN;
    res /= m;

    if (R_FINITE(res)) {
      long double t = 0.0;
      for (int i = 0; i < n; i++) {
        STORAGE value = ptr[indices[i]];
        if (! Rcpp::traits::is_na<RTYPE>(value)) {
          t += value - res;
        }
      }
      res += t / m;
    }

    return (double)res;
  }
};

// special cases for NA_RM == false
template <typename Index>
struct Mean_internal<INTSXP, false, Index> {
  static double process(int* ptr, const Index& indices) {
    long double res = 0.0;
    int n = indices.size();
    for (int i = 0; i < n; i++) {
      int value = ptr[ indices[i] ];
      // need to handle missing value specifically
      if (value == NA_INTEGER) {
        return NA_REAL;
      }
      res += value;
    }
    res /= n;

    if (R_FINITE((double)res)) {
      long double t = 0.0;
      for (int i = 0; i < n; i++) {
        t += ptr[indices[i]] - res;
      }
      res += t / n;
    }
    return (double)res;
  }
};

template <typename Index>
struct Mean_internal<REALSXP, false, Index> {
  static double process(double* ptr, const Index& indices) {
    long double res = 0.0;
    int n = indices.size();
    for (int i = 0; i < n; i++) {
      res += ptr[ indices[i] ];
    }
    res /= n;

    if (R_FINITE((double)res)) {
      long double t = 0.0;
      for (int i = 0; i < n; i++) {
        t += ptr[indices[i]] - res;
      }
      res += t / n;
    }
    return (double)res;
  }
};

} // namespace internal

template <int RTYPE, bool NA_RM>
class Mean : public Processor< REALSXP, Mean<RTYPE, NA_RM> > {
public:
  typedef Processor< REALSXP, Mean<RTYPE, NA_RM> > Base;
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  Mean(SEXP x, bool is_summary_ = false) :
    Base(x),
    data_ptr(Rcpp::internal::r_vector_start<RTYPE>(x)),
    is_summary(is_summary_)
  {}
  ~Mean() {}

  inline double process_chunk(const SlicingIndex& indices) {
    if (is_summary) return data_ptr[indices.group()];
    return internal::Mean_internal<RTYPE, NA_RM, SlicingIndex>::process(data_ptr, indices);
  }

private:
  STORAGE* data_ptr;
  bool is_summary;
};

}

#endif
