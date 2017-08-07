#ifndef dplyr_GroupedSubsetBase_H
#define dplyr_GroupedSubsetBase_H

#include <tools/SlicingIndex.h>

namespace dplyr {

class GroupedSubset {
public:
  GroupedSubset() {};
  virtual ~GroupedSubset() {};
  virtual SEXP get(const SlicingIndex& indices) = 0;
  virtual SEXP get_variable() const = 0;
  virtual bool is_summary() const = 0;
};

typedef GroupedSubset RowwiseSubset;

}

#endif //dplyr_GroupedSubsetBase_H
