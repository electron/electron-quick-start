#ifndef dplyr_Result_Sd_H
#define dplyr_Result_Sd_H

#include <dplyr/Result/Processor.h>

namespace dplyr {

template <int RTYPE, bool NA_RM>
class Sd : public Processor<REALSXP, Sd<RTYPE, NA_RM> > {
public:
  typedef Processor<REALSXP, Sd<RTYPE, NA_RM> > Base;

  Sd(SEXP x, bool is_summary = false) :
    Base(x),
    var(x, is_summary)
  {}
  ~Sd() {}

  inline double process_chunk(const SlicingIndex& indices) {
    return sqrt(var.process_chunk(indices));
  }

private:
  Var<RTYPE, NA_RM> var;
};

}

#endif
