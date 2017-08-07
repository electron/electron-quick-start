#ifndef dplyr_VisitorEqualPredicate_H
#define dplyr_VisitorEqualPredicate_H

namespace dplyr {

template <typename Visitor>
class VisitorEqualPredicate {
public:
  VisitorEqualPredicate(const Visitor& v_) : v(v_) {}

  inline bool operator()(int i, int j) const {
    return v.equal_or_both_na(i, j);
  }

private:
  const Visitor& v;
};
}

#endif
