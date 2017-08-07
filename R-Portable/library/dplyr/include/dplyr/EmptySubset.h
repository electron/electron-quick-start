#ifndef dplyr_EmptySubset_H
#define dplyr_EmptySubset_H

namespace dplyr {
class EmptySubset {
public:
  int size() const {
    return 0;
  }
};
}
#endif
