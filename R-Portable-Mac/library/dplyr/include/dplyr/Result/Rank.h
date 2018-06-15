#ifndef dplyr_Result_Rank_H
#define dplyr_Result_Rank_H

#include <tools/hash.h>

#include <dplyr/GroupedDataFrame.h>

#include <dplyr/comparisons.h>
#include <dplyr/visitor.h>

#include <dplyr/Order.h>

#include <dplyr/Result/Result.h>
#include <dplyr/Result/VectorSliceVisitor.h>

namespace dplyr {
namespace internal {

struct min_rank_increment {
  typedef IntegerVector OutputVector;
  typedef int scalar_type;

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
  typedef IntegerVector OutputVector;
  typedef int scalar_type;

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
  typedef NumericVector OutputVector;
  typedef double scalar_type;

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
  typedef NumericVector OutputVector;
  typedef double scalar_type;

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

}


template <int RTYPE, bool ascending = true>
class RankComparer {
  typedef comparisons<RTYPE> compare;

public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  inline bool operator()(STORAGE lhs, STORAGE rhs) const {
    return compare::is_less(lhs, rhs);
  }
};

template <int RTYPE>
class RankComparer<RTYPE, false> {
  typedef comparisons<RTYPE> compare;

public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;
  inline bool operator()(STORAGE lhs, STORAGE rhs) const {
    return compare::is_greater(lhs, rhs);
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

// powers both dense_rank and min_rank, see dplyr.cpp for how it is used
template <int RTYPE, typename Increment, bool ascending = true>
class Rank_Impl : public Result, public Increment {
public:
  typedef typename Increment::OutputVector OutputVector;
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  typedef VectorSliceVisitor<RTYPE> Slice;
  typedef RankComparer<RTYPE, ascending> Comparer;
  typedef RankEqual<RTYPE> Equal;

  typedef dplyr_hash_map<STORAGE, std::vector<int>, boost::hash<STORAGE>, Equal > Map;
  typedef std::map<STORAGE, const std::vector<int>*, Comparer> oMap;

  Rank_Impl(SEXP data_) : data(data_), map() {}

  virtual SEXP process(const GroupedDataFrame& gdf) {
    int ng = gdf.ngroups();
    int n  = gdf.nrows();
    if (n == 0) return IntegerVector(0);
    GroupedDataFrame::group_iterator git = gdf.group_begin();
    OutputVector out = no_init(n);
    for (int i = 0; i < ng; i++, ++git) {
      process_slice(out, *git);
    }
    return out;
  }

  virtual SEXP process(const RowwiseDataFrame& gdf) {
    return IntegerVector(gdf.nrows(), 1);
  }

  virtual SEXP process(const FullDataFrame& df) {
    int n = df.nrows();
    if (n == 0) return IntegerVector(0);
    OutputVector out = no_init(n);
    process_slice(out, df.get_index());
    return out;
  }

  virtual SEXP process(const SlicingIndex& index) {
    int n = index.size();
    if (n == 0) return IntegerVector(0);
    OutputVector out = no_init(n);
    process_slice(out, index);
    return out;
  }

private:

  void process_slice(OutputVector& out, const SlicingIndex& index) {
    map.clear();
    Slice slice(&data, index);
    int m = index.size();
    for (int j = 0; j < m; j++) {
      map[ slice[j] ].push_back(j);
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
          out[ chunk[k] ] = inc_na;
        }
      } else {
        for (int k = 0; k < n; k++) {
          out[ chunk[k] ] = j;
        }
      }
      j += Increment::post_increment(chunk, m);
    }
  }


  Vector<RTYPE> data;
  Map map;
};

template <int RTYPE, bool ascending = true>
class RowNumber : public Result {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  typedef VectorSliceVisitor<RTYPE> Slice;
  typedef OrderVectorVisitorImpl<RTYPE, ascending, Slice> Visitor;
  typedef Compare_Single_OrderVisitor<Visitor> Comparer;

  RowNumber(SEXP data_) : data(data_) {}

  virtual SEXP process(const GroupedDataFrame& gdf) {
    std::vector<int> tmp(gdf.max_group_size());

    int ng = gdf.ngroups();
    int n  = gdf.nrows();
    if (n == 0) return IntegerVector(0);
    GroupedDataFrame::group_iterator git = gdf.group_begin();
    IntegerVector out(n);
    for (int i = 0; i < ng; i++, ++git) {
      const SlicingIndex& index = *git;

      // tmp <- 0:(m-1)
      int m = index.size();
      for (int j = 0; j < m; j++) tmp[j] = j;

      Slice slice(&data, index);
      // order( gdf.group(i) )
      Visitor visitor(slice);
      Comparer comparer(visitor);
      std::sort(tmp.begin(), tmp.begin() + m, comparer);
      int j = m - 1;
      for (; j >= 0; j--) {
        if (Rcpp::traits::is_na<RTYPE>(slice[ tmp[j] ])) {
          m--;
          out[ index[j] ] = NA_INTEGER;
        } else {
          break;
        }
      }
      for (; j >= 0; j--) {
        out[ index[j] ] = tmp[j] + 1;
      }
    }
    return out;

  }

  virtual SEXP process(const RowwiseDataFrame& gdf) {
    return IntegerVector(gdf.nrows(), 1);
  }

  virtual SEXP process(const FullDataFrame& df) {
    return process(df.get_index());
  }

  virtual SEXP process(const SlicingIndex& index) {
    int nrows = index.size();
    if (nrows == 0) return IntegerVector(0);
    IntegerVector x = seq(0, nrows - 1);
    Slice slice(&data, index);
    Visitor visitor(slice);
    std::sort(x.begin(), x.end(), Comparer(visitor));
    IntegerVector out = no_init(nrows);
    int j = nrows - 1;
    for (; j >= 0; j--) {
      if (Rcpp::traits::is_na<RTYPE>(slice[ x[j] ])) {
        out[ x[j] ] = NA_INTEGER;
      } else {
        break;
      }
    }
    for (; j >= 0; j--) {
      out[ x[j] ] = j + 1;
    }
    return out;
  }

private:
  Vector<RTYPE> data;
};

template <int RTYPE, bool ascending = true>
class Ntile : public Result {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  typedef VectorSliceVisitor<RTYPE> Slice;
  typedef OrderVectorVisitorImpl<RTYPE, ascending, Slice> Visitor;
  typedef Compare_Single_OrderVisitor<Visitor> Comparer;

  Ntile(SEXP data_, double ntiles_) : data(data_), ntiles(ntiles_) {}

  virtual SEXP process(const GroupedDataFrame& gdf) {
    std::vector<int> tmp(gdf.max_group_size());

    int ng = gdf.ngroups();
    int n  = gdf.nrows();
    if (n == 0) return IntegerVector(0);
    GroupedDataFrame::group_iterator git = gdf.group_begin();
    IntegerVector out(n);
    for (int i = 0; i < ng; i++, ++git) {
      const SlicingIndex& index = *git;

      // tmp <- 0:(m-1)
      int m = index.size();
      for (int j = 0; j < m; j++) tmp[j] = j;
      Slice slice(&data, index);

      // order( gdf.group(i) )
      Visitor visitor(slice);
      Comparer comparer(visitor);
      std::sort(tmp.begin(), tmp.begin() + m, comparer);
      int j = m - 1;
      for (; j >= 0; j--) {
        if (Rcpp::traits::is_na<RTYPE>(slice[tmp[j]])) {
          out[index[j]] = NA_INTEGER;
          m--;
        } else {
          break;
        }
      }
      for (; j >= 0; j--) {
        out[ index[j] ] = (int)floor((ntiles * tmp[j]) / m) + 1;
      }
    }
    return out;

  }

  virtual SEXP process(const RowwiseDataFrame& gdf) {
    return IntegerVector(gdf.nrows(), 1);
  }

  virtual SEXP process(const FullDataFrame& df) {
    return process(df.get_index());
  }

  virtual SEXP process(const SlicingIndex& index) {
    int nrows = index.size();
    if (nrows == 0) return IntegerVector(0);
    IntegerVector x = seq(0, nrows - 1);
    Slice slice(&data, index);
    Visitor visitor(slice);
    std::sort(x.begin(), x.end(), Comparer(visitor));
    IntegerVector out = no_init(nrows);
    int i = nrows - 1;
    for (; i >= 0; i--) {
      if (Rcpp::traits::is_na<RTYPE>(slice[x[i]])) {
        nrows--;
        out[x[i]] = NA_INTEGER;
      } else {
        break;
      }
    }

    for (; i >= 0; i--) {
      out[ x[i] ] = (int)floor(ntiles * i / nrows) + 1;
    }
    return out;
  }

private:
  Vector<RTYPE> data;
  double ntiles;
};

class RowNumber_0 : public Result {
public:

  virtual SEXP process(const GroupedDataFrame& gdf) {
    int n = gdf.nrows(), ng = gdf.ngroups();
    if (n == 0) return IntegerVector(0);

    IntegerVector res = no_init(n);
    GroupedDataFrame::group_iterator git = gdf.group_begin();
    for (int i = 0; i < ng; i++, ++git) {
      const SlicingIndex& index = *git;
      int m = index.size();
      for (int j = 0; j < m; j++) res[index[j]] = j + 1;
    }
    return res;
  }

  virtual SEXP process(const RowwiseDataFrame& gdf) {
    return IntegerVector(gdf.nrows(), 1);
  }

  virtual SEXP process(const FullDataFrame& df) {
    if (df.nrows() == 0) return IntegerVector(0);
    IntegerVector res = seq(1, df.nrows());
    return res;
  }

  virtual SEXP process(const SlicingIndex& index) {
    if (index.size() == 0) return IntegerVector(0);
    IntegerVector res = seq(1, index.size());
    return res;
  }

};

}

#include <dplyr/visitor_impl.h>

#endif
