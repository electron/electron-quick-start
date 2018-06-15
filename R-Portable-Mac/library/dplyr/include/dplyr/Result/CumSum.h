#ifndef dplyr_Result_CumSum_H
#define dplyr_Result_CumSum_H

#include <dplyr/Result/Mutater.h>

namespace dplyr {

// REALSXP version
template <int RTYPE>
class CumSum : public Mutater<RTYPE, CumSum<RTYPE> > {
public:
  CumSum(SEXP data_) : data(data_) {}

  void process_slice(Vector<RTYPE>& out, const SlicingIndex& index, const SlicingIndex& out_index) {
    double value = 0.0;
    int n = index.size();
    for (int i = 0; i < n; i++) {
      value += data[index[i]];
      out[out_index[i]] = value;
    }
  }

  Vector<RTYPE> data;
};

// INTSXP version
template <>
class CumSum<INTSXP> : public Mutater<INTSXP, CumSum<INTSXP> > {
public:
  CumSum(SEXP data_) : data(data_) {}

  void process_slice(IntegerVector& out, const SlicingIndex& index, const SlicingIndex& out_index) {
    int value = 0;
    int n = index.size();
    for (int i = 0; i < n; i++) {
      int current = data[index[i]];
      if (IntegerVector::is_na(current)) {
        for (int j = i; j < n; j++) {
          out[ out_index[j] ] = NA_INTEGER;
        }
        return;
      }
      value += current;
      out[out_index[i]] = value;
    }
  }

  IntegerVector data;
};

}

#endif
