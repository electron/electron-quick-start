#ifndef dplyr_join_match_H
#define dplyr_join_match_H

#include <tools/comparisons.h>

namespace dplyr {

// not defined on purpose
template <int LHS_RTYPE, int RHS_RTYPE, bool ACCEPT_NA_MATCH>
struct join_match;

// specialization when LHS_TYPE == RHS_TYPE
template <int RTYPE, bool ACCEPT_NA_MATCH>
struct join_match<RTYPE, RTYPE, ACCEPT_NA_MATCH> {
  typedef comparisons<RTYPE> compare;
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  static inline bool is_match(STORAGE lhs, STORAGE rhs) {
    return compare::equal_or_both_na(lhs, rhs) && (ACCEPT_NA_MATCH || !compare::is_na(lhs));
  }
};

// NaN also don't match for reals
template <bool ACCEPT_NA_MATCH>
struct join_match<REALSXP, REALSXP, ACCEPT_NA_MATCH> {
  typedef comparisons<REALSXP> compare;

  static inline bool is_match(double lhs, double rhs) {
    if (ACCEPT_NA_MATCH)
      return compare::equal_or_both_na(lhs, rhs);
    else
      return lhs == rhs && (ACCEPT_NA_MATCH || (!compare::is_na(lhs) && !compare::is_nan(lhs)));
  }
};

// works for both LHS_RTYPE = INTSXP and LHS_RTYPE = LGLSXP
template <int LHS_RTYPE, bool ACCEPT_NA_MATCH>
struct join_match_int_double {
  static inline bool is_match(int lhs, double rhs) {
    LOG_VERBOSE << lhs << " " << rhs;
    if (double(lhs) == rhs) {
      return (lhs != NA_INTEGER);
    }
    else {
      if (ACCEPT_NA_MATCH)
        return (lhs == NA_INTEGER && ISNA(rhs));
      else
        return false;
    }
  }
};

template <bool ACCEPT_NA_MATCH>
struct join_match<INTSXP, REALSXP, ACCEPT_NA_MATCH> : join_match_int_double<INTSXP, ACCEPT_NA_MATCH> {};

template <bool ACCEPT_NA_MATCH>
struct join_match<LGLSXP, REALSXP, ACCEPT_NA_MATCH> : join_match_int_double<LGLSXP, ACCEPT_NA_MATCH> {};

template <int RHS_RTYPE, bool ACCEPT_NA_MATCH>
struct join_match_double_int {
  static inline bool is_match(double lhs, int rhs) {
    return join_match_int_double<RHS_RTYPE, ACCEPT_NA_MATCH>::is_match(rhs, lhs);
  }
};

template <bool ACCEPT_NA_MATCH>
struct join_match<REALSXP, INTSXP, ACCEPT_NA_MATCH> : join_match_double_int<INTSXP, ACCEPT_NA_MATCH> {};

template <bool ACCEPT_NA_MATCH>
struct join_match<REALSXP, LGLSXP, ACCEPT_NA_MATCH> : join_match_double_int<LGLSXP, ACCEPT_NA_MATCH> {};

template <bool ACCEPT_NA_MATCH>
struct join_match<INTSXP, LGLSXP, ACCEPT_NA_MATCH> : join_match<INTSXP, INTSXP, ACCEPT_NA_MATCH> {};

template <bool ACCEPT_NA_MATCH>
struct join_match<LGLSXP, INTSXP, ACCEPT_NA_MATCH> : join_match<INTSXP, INTSXP, ACCEPT_NA_MATCH> {};

}

#endif // #ifndef dplyr_join_match_H
