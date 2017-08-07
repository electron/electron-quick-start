#ifndef dplyr_LazyRowwiseSubsets_H
#define dplyr_LazyRowwiseSubsets_H


#include <dplyr/Result/LazyGroupedSubsets.h>
#include <dplyr/RowwiseDataFrame.h>

namespace dplyr {

typedef LazySplitSubsets<RowwiseDataFrame> LazyRowwiseSubsets;
}
#endif
