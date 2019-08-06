#ifndef dplyr_VisitorSetEqual_H
#define dplyr_VisitorSetEqual_H

namespace dplyr {

template <typename Class>
class VisitorSetEqual {
public:
  bool equal(int i, int j) const {
    const Class& obj = static_cast<const Class&>(*this);
    if (i == j) return true;
    int n = obj.size();
    for (int k = 0; k < n; k++)
      if (! obj.get(k)->equal(i, j)) return false;
    return true;
  }

  bool equal_or_both_na(int i, int j) const {
    const Class& obj = static_cast<const Class&>(*this);
    if (i == j) return true;
    int n = obj.size();
    for (int k = 0; k < n; k++)
      if (! obj.get(k)->equal_or_both_na(i, j)) return false;
    return true;
  }
};

}

#endif
