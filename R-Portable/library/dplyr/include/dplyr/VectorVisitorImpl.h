#ifndef dplyr_VectorVisitor_Impl_H
#define dplyr_VectorVisitor_Impl_H

#include <tools/collapse.h>
#include <tools/utils.h>

#include <dplyr/CharacterVectorOrderer.h>
#include <dplyr/comparisons.h>
#include <dplyr/VectorVisitor.h>

namespace dplyr {

template <int RTYPE> std::string VectorVisitorType();
template <> inline std::string VectorVisitorType<INTSXP>() {
  return "integer";
}
template <> inline std::string VectorVisitorType<REALSXP>() {
  return "numeric";
}
template <> inline std::string VectorVisitorType<LGLSXP>() {
  return "logical";
}
template <> inline std::string VectorVisitorType<STRSXP>() {
  return "character";
}
template <> inline std::string VectorVisitorType<CPLXSXP>() {
  return "complex";
}
template <> inline std::string VectorVisitorType<VECSXP>() {
  return "list";
}

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

  inline std::string get_r_type() const {
    return VectorVisitorType<RTYPE>();
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

class FactorVisitor : public VectorVisitorImpl<INTSXP> {
  typedef comparisons<STRSXP> string_compare;

public:
  typedef VectorVisitorImpl<INTSXP> Parent;

  FactorVisitor(const IntegerVector& vec_) : Parent(vec_) {
    levels = get_levels(vec);
    levels_ptr = Rcpp::internal::r_vector_start<STRSXP>(levels);
  }

  inline bool equal(int i, int j) const {
    return vec[i] == vec[j];
  }

  inline bool less(int i, int j) const {
    return
      string_compare::is_less(
        vec[i] < 0 ? NA_STRING : levels_ptr[vec[i]],
        vec[j] < 0 ? NA_STRING : levels_ptr[vec[j]]
      );
  }

  inline bool greater(int i, int j) const {
    return
      string_compare::is_greater(
        vec[i] < 0 ? NA_STRING : levels_ptr[vec[i]],
        vec[j] < 0 ? NA_STRING : levels_ptr[vec[j]]
      );
  }

  inline std::string get_r_type() const {
    return get_single_class(Parent::vec);
  }

private:
  CharacterVector levels;
  SEXP* levels_ptr;
};


template <>
class VectorVisitorImpl<STRSXP> : public VectorVisitor {
public:

  VectorVisitorImpl(const CharacterVector& vec_) :
    vec(vec_),
    orders(CharacterVectorOrderer(vec).get())
  {}

  size_t hash(int i) const {
    return orders[i];
  }
  inline bool equal(int i, int j) const {
    return orders[i] == orders[j];
  }

  inline bool less(int i, int j) const {
    return orders[i] < orders[j];
  }

  inline bool equal_or_both_na(int i, int j) const {
    return orders[i] == orders[j];
  }

  inline bool greater(int i, int j) const {
    return orders[i] > orders[j];
  }

  inline std::string get_r_type() const {
    return VectorVisitorType<STRSXP>();
  }

  int size() const {
    return vec.size();
  }

  bool is_na(int i) const {
    return CharacterVector::is_na(vec[i]);
  }

protected:
  CharacterVector vec;
  IntegerVector orders;

};

}

#endif
