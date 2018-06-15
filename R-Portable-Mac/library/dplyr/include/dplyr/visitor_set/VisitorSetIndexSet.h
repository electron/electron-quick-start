#ifndef dplyr_VisitorSetIndexSet_H
#define dplyr_VisitorSetIndexSet_H

#include <tools/hash.h>

#include <dplyr/visitor_set/VisitorSetHasher.h>
#include <dplyr/visitor_set/VisitorSetEqualPredicate.h>

namespace dplyr {

template <typename VisitorSet>
class VisitorSetIndexSet : public dplyr_hash_set<int, VisitorSetHasher<VisitorSet>, VisitorSetEqualPredicate<VisitorSet> > {
private:
  typedef VisitorSetHasher<VisitorSet> Hasher;
  typedef VisitorSetEqualPredicate<VisitorSet> EqualPredicate;
  typedef dplyr_hash_set<int, Hasher, EqualPredicate> Base;

public:
  VisitorSetIndexSet() : Base() {}

  VisitorSetIndexSet(VisitorSet& visitors_) :
    Base(1024, Hasher(&visitors_), EqualPredicate(&visitors_))
  {}
  VisitorSetIndexSet(VisitorSet* visitors_) :
    Base(1024, Hasher(visitors_), EqualPredicate(visitors_))
  {}
};

}
#endif
