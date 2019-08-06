#ifndef dplyr_JoinVisitorImpl_H
#define dplyr_JoinVisitorImpl_H

#include <tools/utils.h>
#include <tools/match.h>

#include <dplyr/visitors/join/join_match.h>
#include <dplyr/visitors/join/JoinVisitor.h>
#include <dplyr/visitors/join/Column.h>

#include <dplyr/symbols.h>

namespace dplyr {

JoinVisitor* join_visitor(const Column& left, const Column& right, bool warn, bool accept_na_match = true);

void check_attribute_compatibility(const Column& left, const Column& right);

template <int LHS_RTYPE, int RHS_RTYPE>
class DualVector {
public:
  enum { RTYPE = (LHS_RTYPE > RHS_RTYPE ? LHS_RTYPE : RHS_RTYPE) };

  typedef Rcpp::Vector<LHS_RTYPE> LHS_Vec;
  typedef Rcpp::Vector<RHS_RTYPE> RHS_Vec;
  typedef Rcpp::Vector<RTYPE> Vec;

  typedef typename Rcpp::traits::storage_type<LHS_RTYPE>::type LHS_STORAGE;
  typedef typename Rcpp::traits::storage_type<RHS_RTYPE>::type RHS_STORAGE;
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

public:
  DualVector(LHS_Vec left_, RHS_Vec right_) : left(left_), right(right_) {}

  LHS_STORAGE get_left_value(const int i) const {
    if (i < 0) Rcpp::stop("get_left_value() called with negative argument");
    return left[i];
  }

  RHS_STORAGE get_right_value(const int i) const {
    if (i >= 0) Rcpp::stop("get_right_value() called with nonnegative argument");
    return right[-i - 1];
  }

  bool is_left_na(const int i) const {
    return left.is_na(get_left_value(i));
  }

  bool is_right_na(const int i) const {
    return right.is_na(get_right_value(i));
  }

  bool is_na(const int i) const {
    if (i >= 0) return is_left_na(i);
    else return is_right_na(i);
  }

  LHS_STORAGE get_value_as_left(const int i) const {
    if (i >= 0) return get_left_value(i);
    else {
      RHS_STORAGE x = get_right_value(i);
      if (LHS_RTYPE == RHS_RTYPE) return x;
      else return Rcpp::internal::r_coerce<RHS_RTYPE, LHS_RTYPE>(x);
    }
  }

  RHS_STORAGE get_value_as_right(const int i) const {
    if (i >= 0) {
      LHS_STORAGE x = get_left_value(i);
      if (LHS_RTYPE == RHS_RTYPE) return x;
      else return Rcpp::internal::r_coerce<LHS_RTYPE, RHS_RTYPE>(x);
    }
    else return get_right_value(i);
  }

  STORAGE get_value(const int i) const {
    if (RTYPE == LHS_RTYPE) return get_value_as_left(i);
    else return get_value_as_right(i);
  }

  template <class iterator>
  SEXP subset(iterator it, const int n) {
    // We use the fact that LGLSXP < INTSXP < REALSXP, this defines our coercion precedence
    Rcpp::RObject ret;
    if (LHS_RTYPE == RHS_RTYPE)
      ret = subset_same(it, n);
    else if (LHS_RTYPE > RHS_RTYPE)
      ret = subset_left(it, n);
    else
      ret = subset_right(it, n);

    copy_most_attributes(ret, left);
    return ret;
  }

  template <class iterator>
  SEXP subset_same(iterator it, const int n) {
    Vec res(Rcpp::no_init(n));
    for (int i = 0; i < n; i++, ++it) {
      res[i] = get_value(*it);
    }
    return res;
  }

  template <class iterator>
  SEXP subset_left(iterator it, const int n) {
    LHS_Vec res(Rcpp::no_init(n));
    for (int i = 0; i < n; i++, ++it) {
      res[i] = get_value_as_left(*it);
    }
    return res;
  }

  template <class iterator>
  SEXP subset_right(iterator it, const int n) {
    RHS_Vec res(Rcpp::no_init(n));
    for (int i = 0; i < n; i++, ++it) {
      res[i] = get_value_as_right(*it);
    }
    return res;
  }

private:
  LHS_Vec left;
  RHS_Vec right;
};

template <int LHS_RTYPE, int RHS_RTYPE, bool ACCEPT_NA_MATCH>
class JoinVisitorImpl : public JoinVisitor {
protected:
  typedef DualVector<LHS_RTYPE, RHS_RTYPE> Storage;
  typedef boost::hash<typename Storage::STORAGE> hasher;
  typedef typename Storage::LHS_Vec LHS_Vec;
  typedef typename Storage::RHS_Vec RHS_Vec;
  typedef typename Storage::Vec Vec;

public:
  JoinVisitorImpl(const Column& left, const Column& right, const bool warn) : dual((SEXP)left.get_data(), (SEXP)right.get_data()) {
    if (warn) check_attribute_compatibility(left, right);
  }

  inline size_t hash(int i) {
    // If NAs don't match, we want to distribute their hashes as evenly as possible
    if (!ACCEPT_NA_MATCH && dual.is_na(i)) return static_cast<size_t>(i);

    typename Storage::STORAGE x = dual.get_value(i);
    return hash_fun(x);
  }

  inline bool equal(int i, int j) {
    if (LHS_RTYPE == RHS_RTYPE) {
      // Shortcut for same data type
      return join_match<LHS_RTYPE, LHS_RTYPE, ACCEPT_NA_MATCH>::is_match(dual.get_value(i), dual.get_value(j));
    }
    else if (i >= 0 && j >= 0) {
      return join_match<LHS_RTYPE, LHS_RTYPE, ACCEPT_NA_MATCH>::is_match(dual.get_left_value(i), dual.get_left_value(j));
    } else if (i < 0 && j < 0) {
      return join_match<RHS_RTYPE, RHS_RTYPE, ACCEPT_NA_MATCH>::is_match(dual.get_right_value(i), dual.get_right_value(j));
    } else if (i >= 0 && j < 0) {
      return join_match<LHS_RTYPE, RHS_RTYPE, ACCEPT_NA_MATCH>::is_match(dual.get_left_value(i), dual.get_right_value(j));
    } else {
      return join_match<RHS_RTYPE, LHS_RTYPE, ACCEPT_NA_MATCH>::is_match(dual.get_right_value(i), dual.get_left_value(j));
    }
  }

  SEXP subset(const std::vector<int>& indices) {
    return dual.subset(indices.begin(), indices.size());
  }

  SEXP subset(const VisitorSetIndexSet<DataFrameJoinVisitors>& set) {
    return dual.subset(set.begin(), set.size());
  }

public:
  hasher hash_fun;

private:
  Storage dual;
};

template <bool ACCEPT_NA_MATCH>
class POSIXctJoinVisitor : public JoinVisitorImpl<REALSXP, REALSXP, ACCEPT_NA_MATCH> {
  typedef JoinVisitorImpl<REALSXP, REALSXP, ACCEPT_NA_MATCH> Parent;

public:
  POSIXctJoinVisitor(const Column& left, const Column& right) :
    Parent(left, right, false),
    tzone(R_NilValue)
  {
    Rcpp::Shield<SEXP> tzone_left(Rf_getAttrib(left.get_data(), symbols::tzone));
    Rcpp::Shield<SEXP> tzone_right(Rf_getAttrib(right.get_data(), symbols::tzone));

    bool null_left = Rf_isNull(tzone_left);
    bool null_right = Rf_isNull(tzone_right);
    if (null_left && null_right) return;

    if (null_left) {
      tzone = tzone_right;
    } else if (null_right) {
      tzone = tzone_left;
    } else {
      if (STRING_ELT(tzone_left, 0) == STRING_ELT(tzone_right, 0)) {
        tzone = tzone_left;
      } else {
        tzone = Rf_mkString("UTC");
      }
    }
  }

  inline SEXP subset(const std::vector<int>& indices) {
    return promote(Parent::subset(indices));
  }
  inline SEXP subset(const VisitorSetIndexSet<DataFrameJoinVisitors>& set) {
    return promote(Parent::subset(set));
  }

private:

  inline SEXP promote(Rcpp::NumericVector x) {
    Rf_classgets(x, get_time_classes());
    if (!tzone.isNULL()) {
      Rf_setAttrib(x, symbols::tzone, tzone);
    }
    return x;
  }

private:
  Rcpp::RObject tzone;
};

class DateJoinVisitorGetter {
public:
  virtual ~DateJoinVisitorGetter() {};
  virtual double get(int i) = 0;
  virtual bool is_na(int i) const = 0;
};

template <int LHS_RTYPE, int RHS_RTYPE, bool ACCEPT_NA_MATCH>
class DateJoinVisitor : public JoinVisitorImpl<LHS_RTYPE, RHS_RTYPE, ACCEPT_NA_MATCH> {
  typedef JoinVisitorImpl<LHS_RTYPE, RHS_RTYPE, ACCEPT_NA_MATCH> Parent;

public:
  DateJoinVisitor(const Column& left, const Column& right) : Parent(left, right, false) {}

  inline SEXP subset(const std::vector<int>& indices) {
    return promote(Parent::subset(indices));
  }

  inline SEXP subset(const VisitorSetIndexSet<DataFrameJoinVisitors>& set) {
    return promote(Parent::subset(set));
  }

private:
  static SEXP promote(SEXP x) {
    Rf_classgets(x, get_date_classes());
    return x;
  }

private:
  typename Parent::hasher hash_fun;
};

}

#endif
