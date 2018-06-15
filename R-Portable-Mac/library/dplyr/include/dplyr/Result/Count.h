#ifndef dplyr_Result_Count_H
#define dplyr_Result_Count_H

#include <dplyr/Result/Processor.h>

namespace dplyr {

class Count : public Processor<INTSXP, Count> {
public:
  Count() {}
  ~Count() {}

  inline int process_chunk(const SlicingIndex& indices) {
    return indices.size();
  }
};

}

#endif
