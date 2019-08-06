#ifndef dplyr_comparison_H
#define dplyr_comparison_H

namespace dplyr {

template <int RTYPE>
struct comparisons {
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  static inline bool is_less(STORAGE lhs, STORAGE rhs) {
    if (is_na(lhs)) return false;
    if (is_na(rhs)) return true;

    return lhs < rhs;
  }

  static inline bool is_greater(STORAGE lhs, STORAGE rhs) {
    return lhs > rhs;
  }

  static inline bool equal_or_both_na(STORAGE lhs, STORAGE rhs) {
    return lhs == rhs;
  }

  static inline bool is_na(STORAGE x) {
    return Rcpp::traits::is_na<RTYPE>(x);
  }

};

struct comparisons_int64 {
  static inline bool is_less(int64_t lhs, int64_t rhs) {
    if (is_na(lhs)) return false;
    if (is_na(rhs)) return true;

    return lhs < rhs;
  }

  static inline bool is_greater(int64_t lhs, int64_t rhs) {
    return lhs > rhs;
  }

  static inline bool equal_or_both_na(int64_t lhs, int64_t rhs) {
    return lhs == rhs;
  }

  static inline bool is_na(int64_t x) {
    return x == NA_INT64;
  }

  static int64_t NA_INT64;
};

template <>
struct comparisons<RAWSXP> {
  typedef Rbyte STORAGE;

  static inline bool is_less(STORAGE lhs, STORAGE rhs) {
    return lhs < rhs;
  }

  static inline bool is_greater(STORAGE lhs, STORAGE rhs) {
    return lhs > rhs;
  }

  static inline bool equal_or_both_na(STORAGE lhs, STORAGE rhs) {
    return lhs == rhs;
  }

  static inline bool is_na(STORAGE) {
    return false ;
  }

};


template <>
struct comparisons<STRSXP> {
  static inline bool is_less(SEXP lhs, SEXP rhs) {
    // we need this because CHAR(NA_STRING) gives "NA"
    if (is_na(lhs)) return false;
    if (is_na(rhs)) return true;
    return strcmp(CHAR(lhs), CHAR(rhs)) < 0;
  }

  static inline bool is_greater(SEXP lhs, SEXP rhs) {
    if (is_na(lhs)) return false;
    if (is_na(rhs)) return true;
    return strcmp(CHAR(lhs), CHAR(rhs)) > 0;
  }

  static inline bool equal_or_both_na(SEXP lhs, SEXP rhs) {
    return lhs == rhs;
  }

  static inline bool is_na(SEXP x) {
    return Rcpp::traits::is_na<STRSXP>(x);
  }

};

// taking advantage of the particularity of NA_REAL
template <>
struct comparisons<REALSXP> {

  static inline bool is_less(double lhs, double rhs) {
    if (is_nan(lhs)) {
      return false;
    } else if (is_na(lhs)) {
      return is_nan(rhs);
    } else {
      // lhs >= rhs is false if rhs is NA or NaN
      return !(lhs >= rhs);
    }

  }

  static inline bool is_greater(double lhs, double rhs) {
    if (is_nan(lhs)) {
      return false;
    } else if (is_na(lhs)) {
      return is_nan(rhs);
    } else {
      // lhs <= rhs is false if rhs is NA or NaN
      return !(lhs <= rhs);
    }

  }

  static inline bool equal_or_both_na(double lhs, double rhs) {
    return
      lhs == rhs ||
      (is_nan(lhs) && is_nan(rhs)) ||
      (is_na(lhs) && is_na(rhs));
  }

  static inline bool is_na(double x) {
    return ISNA(x);
  }

  static inline bool is_nan(double x) {
    return Rcpp::traits::is_nan<REALSXP>(x);
  }

};

template <>
struct comparisons<CPLXSXP> {

  static inline bool is_less(Rcomplex lhs, Rcomplex rhs) {
    if (is_na(lhs)) return false;
    if (is_na(rhs)) return true;

    return lhs.r < rhs.r || (lhs.r == rhs.r && lhs.i < rhs.i);
  }

  static inline bool is_greater(Rcomplex lhs, Rcomplex rhs) {
    if (is_na(lhs)) return false;
    if (is_na(rhs)) return true;

    return !(lhs.r < rhs.r || (lhs.r == rhs.r && lhs.i <= rhs.i));
  }

  static inline bool equal_or_both_na(Rcomplex lhs, Rcomplex rhs) {
    return lhs.r == rhs.r && lhs.i == rhs.i;
  }

  static inline bool is_na(Rcomplex x) {
    return Rcpp::traits::is_na<CPLXSXP>(x);
  }

};


}

#endif
