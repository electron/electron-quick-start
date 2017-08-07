#ifndef dplyr_VisitorSetGreater_H
#define dplyr_VisitorSetGreater_H

namespace dplyr {

template <typename Class>
class VisitorSetGreater {
public:
  bool greater(int i, int j) const {
    if (i == j) return false;
    const Class& obj = static_cast<const Class&>(*this);
    int n = obj.size();
    for (int k = 0; k < n; k++) {
      typename Class::visitor_type* visitor = obj.get(k);
      if (! visitor->equal(i, j)) {
        return visitor->greater(i, j);
      }
    }
    // if we end up here, it means rows i and j are equal
    // we break the tie using the indices
    return i < j;
  }
};

}

#endif
