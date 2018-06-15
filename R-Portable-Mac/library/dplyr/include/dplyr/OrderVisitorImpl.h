#ifndef dplyr_OrderVectorVisitor_Impl_H
#define dplyr_OrderVectorVisitor_Impl_H

#include <dplyr/checks.h>

#include <dplyr/comparisons.h>

#include <dplyr/CharacterVectorOrderer.h>
#include <dplyr/OrderVisitor.h>
#include <dplyr/DataFrameVisitors.h>
#include <dplyr/MatrixColumnVisitor.h>
#include <dplyr/bad.h>

namespace dplyr {

// version used for ascending = true
template <int RTYPE, bool ascending, typename VECTOR>
class OrderVectorVisitorImpl : public OrderVisitor {
  typedef comparisons<RTYPE> compare;

public:
  /**
   * The type of data : int, double, SEXP, Rcomplex
   */
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  OrderVectorVisitorImpl(const VECTOR& vec_) : vec(vec_) {}

  inline bool equal(int i, int j) const {
    return compare::equal_or_both_na(vec[i], vec[j]);
  }

  inline bool before(int i, int j) const {
    return compare::is_less(vec[i], vec[j]);
  }

  SEXP get() {
    return vec;
  }

private:
  VECTOR vec;
};

// version used for ascending = false
template <int RTYPE, typename VECTOR>
class OrderVectorVisitorImpl<RTYPE, false, VECTOR> : public OrderVisitor {
  typedef comparisons<RTYPE> compare;

public:

  /**
   * The type of data : int, double, SEXP, Rcomplex
   */
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  OrderVectorVisitorImpl(const VECTOR& vec_) : vec(vec_) {}

  inline bool equal(int i, int j) const {
    return compare::equal_or_both_na(vec[i], vec[j]);
  }

  inline bool before(int i, int j) const {
    return compare::is_greater(vec[i], vec[j]);
  }

  SEXP get() {
    return vec;
  }

private:
  VECTOR vec;
};

template <bool ascending>
class OrderCharacterVectorVisitorImpl : public OrderVisitor {
public:
  OrderCharacterVectorVisitorImpl(const CharacterVector& vec_) :
    vec(vec_),
    orders(CharacterVectorOrderer(vec).get())
  {}

  inline bool equal(int i, int j) const {
    return orders.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return orders.before(i, j);
  }

  SEXP get() {
    return vec;
  }

private:
  CharacterVector vec;
  OrderVectorVisitorImpl<INTSXP, ascending, IntegerVector> orders;
};

// ---------- data frame columns

// ascending = true
template <bool ascending>
class OrderVisitorDataFrame : public OrderVisitor {
public:
  OrderVisitorDataFrame(const DataFrame& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.less(i, j);
  }

  inline SEXP get() {
    return data;
  }

private:
  DataFrame data;
  DataFrameVisitors visitors;
};

template <>
class OrderVisitorDataFrame<false> : public OrderVisitor {
public:
  OrderVisitorDataFrame(const DataFrame& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.greater(i, j);
  }

  inline SEXP get() {
    return data;
  }

private:
  DataFrame data;
  DataFrameVisitors visitors;
};

// ---------- matrix columns

// ascending = true
template <int RTYPE, bool ascending>
class OrderVisitorMatrix : public OrderVisitor {
public:
  OrderVisitorMatrix(const Matrix<RTYPE>& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.less(i, j);
  }

  inline SEXP get() {
    return data;
  }

private:
  Matrix<RTYPE> data;
  MatrixColumnVisitor<RTYPE> visitors;
};

// ascending = false
template <int RTYPE>
class OrderVisitorMatrix<RTYPE, false> : public OrderVisitor {
public:
  OrderVisitorMatrix(const Matrix<RTYPE>& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.greater(i, j);
  }

  inline SEXP get() {
    return data;
  }

private:
  Matrix<RTYPE> data;
  MatrixColumnVisitor<RTYPE> visitors;
};


inline OrderVisitor* order_visitor(SEXP vec, const bool ascending, const int i);

template <bool ascending>
OrderVisitor* order_visitor_asc(SEXP vec);

template <bool ascending>
OrderVisitor* order_visitor_asc_matrix(SEXP vec);

template <bool ascending>
OrderVisitor* order_visitor_asc_vector(SEXP vec);

inline OrderVisitor* order_visitor(SEXP vec, const bool ascending, const int i) {
  try {
    if (ascending) {
      return order_visitor_asc<true>(vec);
    }
    else {
      return order_visitor_asc<false>(vec);
    }
  }
  catch (const Rcpp::exception& e) {
    bad_pos_arg(i + 1, e.what());
  }
}

template <bool ascending>
inline OrderVisitor* order_visitor_asc(SEXP vec) {
  if (Rf_isMatrix(vec)) {
    return order_visitor_asc_matrix<ascending>(vec);
  }
  else {
    return order_visitor_asc_vector<ascending>(vec);
  }
}

template <bool ascending>
inline OrderVisitor* order_visitor_asc_matrix(SEXP vec) {
  switch (check_supported_type(vec)) {
  case DPLYR_INTSXP:
    return new OrderVisitorMatrix<INTSXP, ascending>(vec);
  case DPLYR_REALSXP:
    return new OrderVisitorMatrix<REALSXP, ascending>(vec);
  case DPLYR_LGLSXP:
    return new OrderVisitorMatrix<LGLSXP, ascending>(vec);
  case DPLYR_STRSXP:
    return new OrderVisitorMatrix<STRSXP, ascending>(vec);
  case DPLYR_CPLXSXP:
    return new OrderVisitorMatrix<CPLXSXP, ascending>(vec);
  case DPLYR_VECSXP:
    stop("Matrix can't be a list");
  }

  stop("Unreachable");
  return 0;
}

template <bool ascending>
inline OrderVisitor* order_visitor_asc_vector(SEXP vec) {
  switch (TYPEOF(vec)) {
  case INTSXP:
    return new OrderVectorVisitorImpl<INTSXP, ascending, Vector<INTSXP > >(vec);
  case REALSXP:
    return new OrderVectorVisitorImpl<REALSXP, ascending, Vector<REALSXP> >(vec);
  case LGLSXP:
    return new OrderVectorVisitorImpl<LGLSXP, ascending, Vector<LGLSXP > >(vec);
  case STRSXP:
    return new OrderCharacterVectorVisitorImpl<ascending>(vec);
  case CPLXSXP:
    return new OrderVectorVisitorImpl<CPLXSXP, ascending, Vector<CPLXSXP > >(vec);
  case VECSXP:
  {
    if (Rf_inherits(vec, "data.frame")) {
      return new OrderVisitorDataFrame<ascending>(vec);
    }
    break;
  }
  default:
    break;
  }

  stop("is of unsupported type %s", Rf_type2char(TYPEOF(vec)));
}
}

#endif
