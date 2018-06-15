#ifndef dplyr_VisitorSetEqualPredicate_H
#define dplyr_VisitorSetEqualPredicate_H

namespace dplyr {

template <typename VisitorSet>
class VisitorSetEqualPredicate {
public:
  VisitorSetEqualPredicate() : visitors(0) {}

  VisitorSetEqualPredicate(VisitorSet* visitors_) : visitors(visitors_) {};
  inline bool operator()(int i, int j) const {
    return visitors->equal(i, j);
  }

private:
  VisitorSet* visitors;
};

}

#endif
