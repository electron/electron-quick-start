#ifndef dplyr_hybrid_n_distinct_h
#define dplyr_hybrid_n_distinct_h

#include <dplyr/hybrid/HybridVectorScalarResult.h>
#include <dplyr/hybrid/Expression.h>

#include <dplyr/visitor_set/VisitorEqualPredicate.h>
#include <dplyr/visitor_set/VisitorHash.h>
#include <dplyr/visitors/vector/MultipleVectorVisitors.h>

namespace dplyr {
namespace hybrid {

namespace internal {

template <typename SlicedTibble, bool NARM>
class N_Distinct : public HybridVectorScalarResult<INTSXP, SlicedTibble, N_Distinct<SlicedTibble, NARM> > {
public:
  typedef HybridVectorScalarResult<INTSXP, SlicedTibble, N_Distinct> Parent ;

  typedef VisitorHash<MultipleVectorVisitors> Hash;
  typedef VisitorEqualPredicate<MultipleVectorVisitors> Pred;
  typedef dplyr_hash_set<int, Hash, Pred > Set;

  N_Distinct(const SlicedTibble& data, const Rcpp::List& columns_, int nrows_, int ngroups_):
    Parent(data),

    visitors(columns_, nrows_, ngroups_),
    set(data.max_group_size(), Hash(visitors), Pred(visitors))
  {}

  inline int process(const typename SlicedTibble::slicing_index& indices) const {
    set.clear();
    int n = indices.size();

    for (int i = 0; i < n; i++) {
      int index = indices[i];
      if (!NARM || !visitors.is_na(index)) set.insert(index);
    }
    return set.size();
  }

private:
  MultipleVectorVisitors visitors;
  mutable Set set;
};

}

template <typename SlicedTibble, typename Expression, typename Operation>
SEXP n_distinct_dispatch(const SlicedTibble& tbl, const Expression& expression, const Operation& op) {
  std::vector<SEXP> columns;
  columns.reserve(tbl.data().size());

  Rcpp::Shelter<SEXP> shelter;
  bool narm = false;

  int n = expression.size();
  for (int i = 0; i < n; i++) {
    Column column;

    if (expression.is_named(i, symbols::narm)) {
      bool test ;
      // if we have na.rm= TRUE, or na.rm = FALSE, we can handle it
      if (expression.is_scalar_logical(i, test)) {
        narm = test;
      } else {
        // otherwise, we need R to evaluate it, so we give up
        return R_UnboundValue;
      }
    } else if (expression.is_column(i, column) && column.is_trivial()) {
      columns.push_back(shelter(column.data));
    } else {
      // give up, R will handle the call
      return R_UnboundValue;
    }
  }

  // let R handle the call
  if (!columns.size()) {
    return R_UnboundValue;
  }

  Rcpp::Shield<SEXP> s_columns(Rcpp::wrap(columns));
  Rcpp::List lst_columns(s_columns);

  SEXP res;
  if (narm) {
    internal::N_Distinct<SlicedTibble, true> distinct(tbl, lst_columns, tbl.nrows(), tbl.ngroups());
    res = PROTECT(op(distinct));
  } else {
    internal::N_Distinct<SlicedTibble, false> distinct(tbl, lst_columns, tbl.nrows(), tbl.ngroups());
    res = PROTECT(op(distinct));
  }
  UNPROTECT(1);
  return res;
}

}
}

#endif
