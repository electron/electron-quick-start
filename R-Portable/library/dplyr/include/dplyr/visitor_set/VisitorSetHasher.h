#ifndef dplyr_VisitorSetHasher_H
#define dplyr_VisitorSetHasher_H

namespace dplyr {

template <typename VisitorSet>
class VisitorSetHasher {
public:
  VisitorSetHasher() : visitors(0) {}

  VisitorSetHasher(VisitorSet* visitors_) : visitors(visitors_) {};
  inline size_t operator()(int i) const {
    return visitors->hash(i);
  }

private:
  VisitorSet* visitors;
};

}

#endif
