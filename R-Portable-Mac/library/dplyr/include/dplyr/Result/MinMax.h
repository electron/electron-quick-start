#ifndef dplyr_Result_MinMax_H
#define dplyr_Result_MinMax_H

#include <dplyr/Result/is_smaller.h>
#include <dplyr/Result/Processor.h>

namespace dplyr {

template <int RTYPE, bool MINIMUM, bool NA_RM>
class MinMax : public Processor<REALSXP, MinMax<RTYPE, MINIMUM, NA_RM> > {

public:
  typedef Processor<REALSXP, MinMax<RTYPE, MINIMUM, NA_RM> > Base;
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

private:
  static const double Inf;

public:
  MinMax(SEXP x, bool is_summary_ = false) :
    Base(x),
    data_ptr(Rcpp::internal::r_vector_start<RTYPE>(x)),
    is_summary(is_summary_)
  {}
  ~MinMax() {}

  double process_chunk(const SlicingIndex& indices) {
    if (is_summary) return data_ptr[ indices.group() ];

    const int n = indices.size();
    double res = Inf;

    for (int i = 0; i < n; ++i) {
      STORAGE current = data_ptr[indices[i]];

      if (Rcpp::Vector<RTYPE>::is_na(current)) {
        if (NA_RM)
          continue;
        else
          return NA_REAL;
      }
      else {
        double current_res = current;
        if (is_better(current_res, res))
          res = current_res;
      }
    }

    return res;
  }

  inline static bool is_better(const double current, const double res) {
    if (MINIMUM)
      return internal::is_smaller<REALSXP>(current, res);
    else
      return internal::is_smaller<REALSXP>(res, current);
  }

private:
  STORAGE* data_ptr;
  bool is_summary;
};

template <int RTYPE, bool MINIMUM, bool NA_RM>
const double MinMax<RTYPE, MINIMUM, NA_RM>::Inf = (MINIMUM ? R_PosInf : R_NegInf);

}

#endif
