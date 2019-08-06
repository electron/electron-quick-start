#ifndef dplyr_VisitorHash_H
#define dplyr_VisitorHash_H

namespace dplyr {

template <typename Visitor>
class VisitorHash {
public:
  VisitorHash(const Visitor& v_) : v(v_) {}

  inline size_t operator()(int i) const {
    return v.hash(i);
  }

private:
  const Visitor& v;
};
}

#endif
