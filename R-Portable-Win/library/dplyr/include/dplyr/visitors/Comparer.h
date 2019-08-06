#ifndef dplyr_visitors_Comparer_h
#define dplyr_visitors_Comparer_h

#include <tools/comparisons.h>

namespace dplyr {
namespace visitors {

template <int RTYPE, typename Vector, bool ascending>
class Comparer {
public:
  typedef typename Vector::stored_type stored_type;
  Comparer(const Vector& vec_) : vec(vec_) {}

  inline bool operator()(int i, int j) const {
    stored_type lhs = vec[i], rhs = vec[j];
    return comparisons<RTYPE>::equal_or_both_na(lhs, rhs) ? i < j : comparisons<RTYPE>::is_less(lhs, rhs) ;
  }

private:
  const Vector& vec;
};

template <int RTYPE, typename Vector>
class Comparer<RTYPE, Vector, false> {
public:
  typedef typename Vector::stored_type stored_type;
  Comparer(const Vector& vec_) : vec(vec_) {}

  inline bool operator()(int i, int j) const {
    stored_type lhs = vec[i], rhs = vec[j];
    return comparisons<RTYPE>::equal_or_both_na(lhs, rhs) ? i < j : comparisons<RTYPE>::is_greater(lhs, rhs) ;
  }

private:
  const Vector& vec;
};

}
}


#endif
