#ifndef dplyr_OrderVectorVisitor_Impl_H
#define dplyr_OrderVectorVisitor_Impl_H

#include <dplyr/checks.h>

#include <tools/comparisons.h>

#include <dplyr/visitors/CharacterVectorOrderer.h>
#include <dplyr/visitors/order/OrderVisitor.h>
#include <dplyr/visitors/vector/DataFrameVisitors.h>
#include <dplyr/visitors/vector/MatrixColumnVisitor.h>
#include <tools/bad.h>

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

private:
  VECTOR vec;
};

template <bool ascending>
class OrderCharacterVectorVisitorImpl : public OrderVisitor {
public:
  OrderCharacterVectorVisitorImpl(const Rcpp::CharacterVector& vec_) :
    vec(vec_),
    orders(CharacterVectorOrderer(vec).get())
  {}

  inline bool equal(int i, int j) const {
    return orders.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return orders.before(i, j);
  }

private:
  Rcpp::CharacterVector vec;
  OrderVectorVisitorImpl<INTSXP, ascending, Rcpp::IntegerVector> orders;
};

// ---------- int 64

template <bool ascensing>
class OrderInt64VectorVisitor : public OrderVisitor {
public:

  OrderInt64VectorVisitor(const Rcpp::NumericVector& vec_) :
    vec(vec_),
    data(reinterpret_cast<int64_t*>(vec.begin()))
  {}

  inline bool equal(int i, int j) const {
    return comparisons_int64::equal_or_both_na(data[i], data[j]);
  }

  inline bool before(int i, int j) const {
    return ascensing ? comparisons_int64::is_less(data[i], data[j]) : comparisons_int64::is_greater(data[i], data[j]);
  }

private:
  Rcpp::NumericVector vec;
  int64_t* data;
};


// ---------- data frame columns

// ascending = true
template <bool ascending>
class OrderVisitorDataFrame : public OrderVisitor {
public:
  OrderVisitorDataFrame(const Rcpp::DataFrame& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.less(i, j);
  }

private:
  Rcpp::DataFrame data;
  DataFrameVisitors visitors;
};

template <>
class OrderVisitorDataFrame<false> : public OrderVisitor {
public:
  OrderVisitorDataFrame(const Rcpp::DataFrame& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.greater(i, j);
  }

private:
  Rcpp::DataFrame data;
  DataFrameVisitors visitors;
};

// ---------- matrix columns

// ascending = true
template <int RTYPE, bool ascending>
class OrderVisitorMatrix : public OrderVisitor {
public:
  OrderVisitorMatrix(const Rcpp::Matrix<RTYPE>& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.less(i, j);
  }

private:
  Rcpp::Matrix<RTYPE> data;
  MatrixColumnVisitor<RTYPE> visitors;
};

// ascending = false
template <int RTYPE>
class OrderVisitorMatrix<RTYPE, false> : public OrderVisitor {
public:
  OrderVisitorMatrix(const Rcpp::Matrix<RTYPE>& data_) : data(data_), visitors(data) {}

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool before(int i, int j) const {
    return visitors.greater(i, j);
  }

private:
  Rcpp::Matrix<RTYPE> data;
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
  case DPLYR_RAWSXP:
    return new OrderVisitorMatrix<RAWSXP, ascending>(vec);
  case DPLYR_VECSXP:
    Rcpp::stop("Matrix can't be a list");
  }

  Rcpp::stop("Unreachable");
  return 0;
}

template <bool ascending>
inline OrderVisitor* order_visitor_asc_vector(SEXP vec) {
  switch (TYPEOF(vec)) {
  case INTSXP:
    return new OrderVectorVisitorImpl<INTSXP, ascending, Rcpp::Vector<INTSXP > >(vec);
  case REALSXP:
    if (Rf_inherits(vec, "integer64")) {
      return new OrderInt64VectorVisitor<ascending>(vec);
    }
    return new OrderVectorVisitorImpl<REALSXP, ascending, Rcpp::Vector<REALSXP> >(vec);
  case LGLSXP:
    return new OrderVectorVisitorImpl<LGLSXP, ascending, Rcpp::Vector<LGLSXP > >(vec);
  case STRSXP:
    return new OrderCharacterVectorVisitorImpl<ascending>(vec);
  case CPLXSXP:
    return new OrderVectorVisitorImpl<CPLXSXP, ascending, Rcpp::Vector<CPLXSXP > >(vec);
  case RAWSXP:
    return new OrderVectorVisitorImpl<RAWSXP, ascending, Rcpp::Vector<RAWSXP > >(vec);
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

  Rcpp::stop("is of unsupported type %s", Rf_type2char(TYPEOF(vec)));
}
}

#endif
