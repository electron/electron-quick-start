#ifndef DPLY_VISITORS_SUBSET_column_subset_H
#define DPLY_VISITORS_SUBSET_column_subset_H

#include <tools/utils.h>
#include <tools/set_rownames.h>
#include <tools/bad.h>
#include <tools/default_value.h>
#include <tools/SlicingIndex.h>
#include <dplyr/symbols.h>

namespace base {
SEXP bracket_one();
SEXP bracket_two();
}


namespace dplyr {
namespace traits {

template <typename T>
struct can_mark_na ;

template <>
struct can_mark_na<Rcpp::IntegerVector> {
  typedef Rcpp::traits::true_type type;
};
template <>
struct can_mark_na<GroupedSlicingIndex> {
  typedef Rcpp::traits::false_type type;
};
template <>
struct can_mark_na<RowwiseSlicingIndex> {
  typedef Rcpp::traits::false_type type;
};
template <>
struct can_mark_na<NaturalSlicingIndex> {
  typedef Rcpp::traits::false_type type;
};

}

template <int RTYPE, typename Index>
SEXP column_subset_vector_impl(const Rcpp::Vector<RTYPE>& x, const Index& index, Rcpp::traits::true_type) {
  typedef typename Rcpp::Vector<RTYPE>::stored_type STORAGE;
  int n = index.size();
  Rcpp::Vector<RTYPE> res(Rcpp::no_init(n));
  for (int i = 0; i < n; i++) {
    res[i] = index[i] == NA_INTEGER ? default_value<RTYPE>() : (STORAGE)x[index[i] - 1];
  }
  copy_most_attributes(res, x);
  return res;
}

template <int RTYPE, typename Index>
SEXP column_subset_vector_impl(const Rcpp::Vector<RTYPE>& x, const Index& index, Rcpp::traits::false_type) {
  int n = index.size();
  Rcpp::Vector<RTYPE> res(Rcpp::no_init(n));
  for (int i = 0; i < n; i++) {
    res[i] = x[index[i]];
  }
  copy_most_attributes(res, x);
  return res;
}

template <>
inline SEXP column_subset_vector_impl<VECSXP, RowwiseSlicingIndex>(const Rcpp::List& x, const RowwiseSlicingIndex& index, Rcpp::traits::true_type) {
  return x[index[0]];
}
template <>
inline SEXP column_subset_vector_impl<VECSXP, RowwiseSlicingIndex>(const Rcpp::List& x, const RowwiseSlicingIndex& index, Rcpp::traits::false_type) {
  return x[index[0]];
}

template <int RTYPE, typename Index>
SEXP column_subset_matrix_impl(const Rcpp::Matrix<RTYPE>& x, const Index& index, Rcpp::traits::true_type) {
  int n = index.size();
  int nc = x.ncol();
  Rcpp::Matrix<RTYPE> res(Rcpp::no_init(n, nc));
  for (int i = 0; i < n; i++) {
    if (index[i] >= 1) {
      res.row(i) = x.row(index[i] - 1);
    } else {
      res.row(i) = Rcpp::Vector<RTYPE>(nc, default_value<RTYPE>());
    }
  }
  copy_most_attributes(res, x);
  return res;
}

template <int RTYPE, typename Index>
SEXP column_subset_matrix_impl(const Rcpp::Matrix<RTYPE>& x, const Index& index, Rcpp::traits::false_type) {
  int n = index.size();
  int nc = x.ncol();
  Rcpp::Matrix<RTYPE> res(Rcpp::no_init(n, nc));
  for (int i = 0; i < n; i++) {
    res.row(i) = x.row(index[i]);
  }
  copy_most_attributes(res, x);
  return res;
}


template <int RTYPE, typename Index>
SEXP column_subset_impl(SEXP x, const Index& index) {
  if (Rf_isMatrix(x)) {
    return column_subset_matrix_impl<RTYPE, Index>(x, index, typename traits::can_mark_na<Index>::type());
  } else {
    return column_subset_vector_impl<RTYPE, Index>(x, index, typename traits::can_mark_na<Index>::type());
  }
}

template <typename Index>
Rcpp::DataFrame dataframe_subset(const Rcpp::List& data, const Index& index, Rcpp::CharacterVector classes, SEXP frame);

template <typename Index>
SEXP r_column_subset(SEXP x, const Index& index, SEXP frame) {
  Rcpp::Shield<SEXP> one_based_index(index);
  if (Rf_isMatrix(x)) {
    Rcpp::Shield<SEXP> call(Rf_lang5(base::bracket_one(), x, one_based_index, R_MissingArg, Rf_ScalarLogical(false)));
    SET_TAG(CDR(CDR(CDDR(call))), dplyr::symbols::drop);
    return Rcpp::Rcpp_eval(call, frame);
  } else {
    Rcpp::Shield<SEXP> call(Rf_lang3(base::bracket_one(), x, one_based_index));
    return Rcpp::Rcpp_eval(call, frame);
  }
}

template <>
inline SEXP r_column_subset<RowwiseSlicingIndex>(SEXP x, const RowwiseSlicingIndex& index, SEXP frame) {
  if (Rf_isMatrix(x)) {
    Rcpp::Shield<SEXP> call(Rf_lang4(base::bracket_one(), x, index, R_MissingArg));
    return Rcpp::Rcpp_eval(call, frame);
  } else {
    Rcpp::Shield<SEXP> call(Rf_lang3(base::bracket_two(), x, index));
    return Rcpp::Rcpp_eval(call, frame);
  }
}

inline bool is_trivial_POSIXct(SEXP x, SEXP klass) {
  return TYPEOF(x) == REALSXP && TYPEOF(klass) == STRSXP && Rf_length(klass) == 2 && STRING_ELT(klass, 0) == strings::POSIXct && STRING_ELT(klass, 1) == strings::POSIXt;
}

inline bool is_trivial_Date(SEXP x, SEXP klass) {
  return TYPEOF(x) == REALSXP && TYPEOF(klass) == STRSXP && Rf_length(klass) == 1 && STRING_ELT(klass, 0) == strings::Date;
}

template <typename Index>
SEXP column_subset(SEXP x, const Index& index, SEXP frame) {
  if (Rf_inherits(x, "data.frame")) {
    return dataframe_subset(x, index, Rf_getAttrib(x, R_ClassSymbol), frame);
  }

  SEXP klass = Rf_getAttrib(x, R_ClassSymbol);

  // trivial types, treat them specially
  if (!OBJECT(x) && Rf_isNull(klass)) {
    switch (TYPEOF(x)) {
    case LGLSXP:
      return column_subset_impl<LGLSXP, Index>(x, index);
    case RAWSXP:
      return column_subset_impl<RAWSXP, Index>(x, index);
    case INTSXP:
      return column_subset_impl<INTSXP, Index>(x, index);
    case STRSXP:
      return column_subset_impl<STRSXP, Index>(x, index);
    case REALSXP:
      return column_subset_impl<REALSXP, Index>(x, index);
    case CPLXSXP:
      return column_subset_impl<CPLXSXP, Index>(x, index);
    case VECSXP:
      return column_subset_impl<VECSXP, Index>(x, index);
    default:
      break;
    }
  }

  // special case POSIXct (#3988)
  if (is_trivial_POSIXct(x, klass)) {
    return column_subset_impl<REALSXP, Index>(x, index);
  }

  // special case Date (#3988)
  if (is_trivial_Date(x, klass)) {
    return column_subset_impl<REALSXP, Index>(x, index);
  }

  // anything else, fall back to R indexing and
  // possibly dispatch on [ or [[
  return r_column_subset(x, index, frame);
}

template <typename Index>
Rcpp::DataFrame dataframe_subset(const Rcpp::List& data, const Index& index, Rcpp::CharacterVector classes, SEXP frame) {
  int nc = data.size();
  Rcpp::List res(nc);

  for (int i = 0; i < nc; i++) {
    res[i] = column_subset(data[i], index, frame);
  }

  copy_most_attributes(res, data);
  set_class(res, classes);
  set_rownames(res, index.size());
  copy_names(res, data);

  return (SEXP)res;
}

}

#endif
