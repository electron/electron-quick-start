#ifndef dplyr_hybrid_rank_h
#define dplyr_hybrid_rank_h

#include <dplyr/hybrid/HybridVectorVectorResult.h>
#include <dplyr/hybrid/Column.h>
#include <dplyr/hybrid/Expression.h>

#include <dplyr/visitors/SliceVisitor.h>
#include <dplyr/visitors/Comparer.h>

namespace dplyr {
namespace hybrid {

namespace internal {

struct min_rank_increment {
  typedef Rcpp::IntegerVector OutputVector;
  typedef int scalar_type;
  enum { rtype = INTSXP };

  template <typename Container>
  inline int post_increment(const Container& x, int) const {
    return x.size();
  }

  template <typename Container>
  inline int pre_increment(const Container&, int) const {
    return 0;
  }

  inline int start() const {
    return 1;
  }

};

struct dense_rank_increment {
  typedef Rcpp::IntegerVector OutputVector;
  typedef int scalar_type;
  enum { rtype = INTSXP };

  template <typename Container>
  inline int post_increment(const Container&, int) const {
    return 1;
  }

  template <typename Container>
  inline int pre_increment(const Container&, int) const {
    return 0;
  }

  inline int start() const {
    return 1;
  }

};

struct percent_rank_increment {
  typedef Rcpp::NumericVector OutputVector;
  typedef double scalar_type;
  enum { rtype = REALSXP };

  template <typename Container>
  inline double post_increment(const Container& x, int m) const {
    return (double)x.size() / (m - 1);
  }

  template <typename Container>
  inline double pre_increment(const Container&, int) const {
    return 0.0;
  }

  inline double start() const {
    return 0.0;
  }


};

struct cume_dist_increment {
  typedef Rcpp::NumericVector OutputVector;
  typedef double scalar_type;
  enum { rtype = REALSXP };

  template <typename Container>
  inline double post_increment(const Container&, int) const {
    return 0.0;
  }

  template <typename Container>
  inline double pre_increment(const Container& x, int m) const {
    return (double)x.size() / m;
  }

  inline double start() const {
    return 0.0;
  }
};

template <int RTYPE, bool ascending = true>
class RankComparer {
  typedef comparisons<RTYPE> compare;

public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  inline bool operator()(STORAGE lhs, STORAGE rhs) const {
    if (ascending) {
      return compare::is_less(lhs, rhs);
    } else {
      return compare::is_greater(lhs, rhs);
    }
  }
};

template <int RTYPE>
class RankEqual {
  typedef comparisons<RTYPE> compare;

public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  inline bool operator()(STORAGE lhs, STORAGE rhs) const {
    return compare::equal_or_both_na(lhs, rhs);
  }
};

template <typename T>
inline T fix_na(T value) {
  return value;
}

template <>
inline double fix_na<double>(double value) {
  return R_IsNA(value) ? NA_REAL : value;
}

template <typename SlicedTibble, int RTYPE, bool ascending, typename Increment>
class RankImpl :
  public HybridVectorVectorResult<Increment::rtype, SlicedTibble, RankImpl<SlicedTibble, RTYPE, ascending, Increment> >,
  public Increment
{
public:
  typedef HybridVectorVectorResult<Increment::rtype, SlicedTibble, RankImpl> Parent;

  typedef typename Increment::OutputVector OutputVector;
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  typedef visitors::SliceVisitor<Rcpp::Vector<RTYPE>, typename SlicedTibble::slicing_index> SliceVisitor;
  typedef visitors::WriteSliceVisitor<OutputVector, typename SlicedTibble::slicing_index> WriteSliceVisitor;

  typedef RankComparer<RTYPE, ascending> Comparer;
  typedef RankEqual<RTYPE> Equal;


  typedef dplyr_hash_map<STORAGE, std::vector<int>, boost::hash<STORAGE>, Equal > Map;
  typedef std::map<STORAGE, const std::vector<int>*, Comparer> oMap;

  RankImpl(const SlicedTibble& data, SEXP x) : Parent(data), vec(x) {}

  void fill(const typename SlicedTibble::slicing_index& indices, OutputVector& out) const {
    Map map;
    SliceVisitor slice(vec, indices);
    WriteSliceVisitor out_slice(out, indices);

    int m = indices.size();
    for (int j = 0; j < m; j++) {
      map[ fix_na(slice[j]) ].push_back(j);
    }
    STORAGE na = Rcpp::traits::get_na<RTYPE>();
    typename Map::const_iterator it = map.find(na);
    if (it != map.end()) {
      m -= it->second.size();
    }

    oMap ordered;

    it = map.begin();
    for (; it != map.end(); ++it) {
      ordered[it->first] = &it->second;
    }
    typename oMap::const_iterator oit = ordered.begin();
    typename Increment::scalar_type j = Increment::start();
    for (; oit != ordered.end(); ++oit) {
      STORAGE key = oit->first;
      const std::vector<int>& chunk = *oit->second;
      int n = chunk.size();
      j += Increment::pre_increment(chunk, m);
      if (Rcpp::traits::is_na<RTYPE>(key)) {
        typename Increment::scalar_type inc_na =
          Rcpp::traits::get_na< Rcpp::traits::r_sexptype_traits<typename Increment::scalar_type>::rtype >();
        for (int k = 0; k < n; k++) {
          out_slice[ chunk[k] ] = inc_na;
        }
      } else {
        for (int k = 0; k < n; k++) {
          out_slice[ chunk[k] ] = j;
        }
      }
      j += Increment::post_increment(chunk, m);
    }

  }

private:
  Rcpp::Vector<RTYPE> vec;
};


template <typename SlicedTibble, int RTYPE, typename Increment, typename Operation>
inline SEXP rank_impl(const SlicedTibble& data, SEXP x, bool is_desc, const Operation& op) {
  if (is_desc) {
    return op(RankImpl<SlicedTibble, RTYPE, false, Increment>(data, x));
  } else {
    return op(RankImpl<SlicedTibble, RTYPE, true, Increment>(data, x));
  }
}

template <typename SlicedTibble, typename Operation, typename Increment>
inline SEXP rank_(const SlicedTibble& data, Column column, const Operation& op) {
  SEXP x = column.data;
  switch (TYPEOF(x)) {
  case INTSXP:
    return internal::rank_impl<SlicedTibble, INTSXP, Increment, Operation>(data, x, column.is_desc, op);
  case REALSXP:
    return internal::rank_impl<SlicedTibble, REALSXP, Increment, Operation>(data, x, column.is_desc, op);
  default:
    break;
  }
  return R_UnboundValue;
}

}

template <typename SlicedTibble, typename Operation, typename Increment>
SEXP rank_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  Column x;
  if (expression.is_unnamed(0) && expression.is_column(0, x) && x.is_trivial()) {
    return internal::rank_<SlicedTibble, Operation, Increment>(data, x, op);
  }
  return R_UnboundValue;
}

template <typename SlicedTibble, typename Operation>
inline SEXP min_rank_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  return rank_dispatch<SlicedTibble, Operation, internal::min_rank_increment>(data, expression, op);
}

template <typename SlicedTibble, typename Operation>
inline SEXP dense_rank_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  return rank_dispatch<SlicedTibble, Operation, internal::dense_rank_increment>(data, expression, op);
}

template <typename SlicedTibble, typename Operation>
inline SEXP percent_rank_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  return rank_dispatch<SlicedTibble, Operation, internal::percent_rank_increment>(data, expression, op);
}

template <typename SlicedTibble, typename Operation>
inline SEXP cume_dist_dispatch(const SlicedTibble& data, const Expression<SlicedTibble>& expression, const Operation& op) {
  return rank_dispatch<SlicedTibble, Operation, internal::cume_dist_increment>(data, expression, op);
}

}
}

#endif
