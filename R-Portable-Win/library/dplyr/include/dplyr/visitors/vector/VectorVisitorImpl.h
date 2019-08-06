#ifndef dplyr_VectorVisitor_Impl_H
#define dplyr_VectorVisitor_Impl_H

#include <tools/collapse.h>
#include <tools/utils.h>

#include <dplyr/visitors/CharacterVectorOrderer.h>
#include <tools/comparisons.h>
#include <dplyr/visitors/vector/VectorVisitor.h>
#include <tools/encoding.h>

namespace dplyr {

/**
 * Implementations
 */
template <int RTYPE>
class VectorVisitorImpl : public VectorVisitor {
  typedef comparisons<RTYPE> compare;

public:
  typedef Rcpp::Vector<RTYPE> VECTOR;

  /**
   * The type of data : int, double, SEXP, Rcomplex
   */
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  /**
   * Hasher for that type of data
   */
  typedef boost::hash<STORAGE> hasher;

  VectorVisitorImpl(const VECTOR& vec_) : vec(vec_) {}

  /**
   * implementations
   */
  size_t hash(int i) const {
    return hash_fun(vec[i]);
  }
  inline bool equal(int i, int j) const {
    return compare::equal_or_both_na(vec[i], vec[j]);
  }

  inline bool less(int i, int j) const {
    return compare::is_less(vec[i], vec[j]);
  }

  inline bool equal_or_both_na(int i, int j) const {
    return compare::equal_or_both_na(vec[i], vec[j]);
  }

  inline bool greater(int i, int j) const {
    return compare::is_greater(vec[i], vec[j]);
  }

  int size() const {
    return vec.size();
  }

  bool is_na(int i) const {
    return VECTOR::is_na(vec[i]);
  }

protected:
  VECTOR vec;
  hasher hash_fun;

};

template <int RTYPE>
class RecyclingVectorVisitorImpl : public VectorVisitor {
public:
  typedef Rcpp::Vector<RTYPE> VECTOR;

  RecyclingVectorVisitorImpl(const VECTOR& vec_, int g_, int n_) : vec(vec_), g(g_), n(n_) {}

  /**
  * implementations
  */
  size_t hash(int i) const {
    return 0 ;
  }
  inline bool equal(int i, int j) const {
    return true;
  }

  inline bool less(int i, int j) const {
    return false;
  }

  inline bool equal_or_both_na(int i, int j) const {
    return true;
  }

  inline bool greater(int i, int j) const {
    return false;
  }

  int size() const {
    return n;
  }

  bool is_na(int i) const {
    return VECTOR::is_na(vec[g]);
  }

protected:
  VECTOR vec;
  int g;
  int n;
};

template <>
class VectorVisitorImpl<STRSXP> : public VectorVisitor {
public:
  typedef comparisons<INTSXP> int_compare;

  VectorVisitorImpl(const Rcpp::CharacterVector& vec_) :
    vec(reencode_char(vec_)), has_orders(false)
  {}

  size_t hash(int i) const {
    return reinterpret_cast<size_t>(get_item(i));
  }
  inline bool equal(int i, int j) const {
    return equal_or_both_na(i, j);
  }

  inline bool less(int i, int j) const {
    provide_orders();
    return int_compare::is_less(orders[i], orders[j]);
  }

  inline bool equal_or_both_na(int i, int j) const {
    return get_item(i) == get_item(j);
  }

  inline bool greater(int i, int j) const {
    provide_orders();
    return int_compare::is_greater(orders[i], orders[j]);
  }

  int size() const {
    return vec.size();
  }

  bool is_na(int i) const {
    return Rcpp::CharacterVector::is_na(vec[i]);
  }

private:
  SEXP get_item(const int i) const {
    return static_cast<SEXP>(vec[i]);
  }

  void provide_orders() const {
    if (has_orders)
      return;

    orders = CharacterVectorOrderer(vec).get();
    has_orders = true;
  }

private:
  Rcpp::CharacterVector vec;
  mutable Rcpp::IntegerVector orders;
  mutable bool has_orders;

};

}

#endif
