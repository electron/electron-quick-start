#ifndef dplyr_VisitorSetHash_H
#define dplyr_VisitorSetHash_H

#include <tools/hash.h>

namespace dplyr {

template <typename Class>
class VisitorSetHash {
public:
  size_t hash(int j) const {
    const Class& obj = static_cast<const Class&>(*this);
    int n = obj.size();
    if (n == 0) {
      Rcpp::stop("Need at least one column for `hash()`");
    }
    size_t seed = obj.get(0)->hash(j);
    for (int k = 1; k < n; k++) {
      boost::hash_combine(seed, obj.get(k)->hash(j));
    }
    return seed;
  }
};

}

#endif
