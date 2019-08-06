#ifndef dplyr_MatrixColumnVisitor_H
#define dplyr_MatrixColumnVisitor_H

#include <tools/comparisons.h>

namespace dplyr {

template <int RTYPE>
class MatrixColumnVisitor : public VectorVisitor {
public:

  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;
  typedef typename Rcpp::Matrix<RTYPE>::Column Column;

  class ColumnVisitor {
  public:
    typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;
    typedef comparisons<RTYPE> compare;
    typedef boost::hash<STORAGE> hasher;

    ColumnVisitor(Rcpp::Matrix<RTYPE>& data, int column) :
      column(data.column(column)) {}

    inline size_t hash(int i) const {
      return hash_fun(const_cast<Column&>(column)[i]);
    }

    inline bool equal(int i, int j) const {
      return compare::equal_or_both_na(const_cast<Column&>(column)[i],  const_cast<Column&>(column)[j]);
    }

    inline bool less(int i, int j) const {
      return compare::is_less(const_cast<Column&>(column)[i],  const_cast<Column&>(column)[j]);
    }

    inline bool equal_or_both_na(int i, int j) const {
      return compare::equal_or_both_na(const_cast<Column&>(column)[i],  const_cast<Column&>(column)[j]);
    }

    inline bool greater(int i, int j) const {
      return compare::is_greater(const_cast<Column&>(column)[i],  const_cast<Column&>(column)[j]);
    }

  private:
    Column column;
    hasher hash_fun;
  };

  MatrixColumnVisitor(const Rcpp::Matrix<RTYPE>& data_) : data(data_), visitors() {
    for (int h = 0; h < data.ncol(); h++) {
      visitors.push_back(ColumnVisitor(data, h));
    }
  }

  inline size_t hash(int i) const {
    size_t seed = visitors[0].hash(i);
    for (size_t h = 1; h < visitors.size(); h++) {
      boost::hash_combine(seed, visitors[h].hash(i));
    }
    return seed;
  }

  inline bool equal(int i, int j) const {
    if (i == j) return true;
    for (size_t h = 0; h < visitors.size(); h++) {
      if (!visitors[h].equal(i, j)) return false;
    }
    return true;
  }

  inline bool equal_or_both_na(int i, int j) const {
    if (i == j) return true;
    for (size_t h = 0; h < visitors.size(); h++) {
      if (!visitors[h].equal_or_both_na(i, j)) return false;
    }
    return true;
  }

  inline bool less(int i, int j) const {
    if (i == j) return false;
    for (size_t h = 0; h < visitors.size(); h++) {
      const ColumnVisitor& v = visitors[h];
      if (!v.equal(i, j)) {
        return v.less(i, j);
      }
    }
    return i < j;
  }

  inline bool greater(int i, int j) const {
    if (i == j) return false;
    for (size_t h = 0; h < visitors.size(); h++) {
      const ColumnVisitor& v = visitors[h];
      if (!v.equal(i, j)) {
        return v.greater(i, j);
      }
    }
    return i < j;
  }

  inline int size() const {
    return data.nrow();
  }

  bool is_na(int) const {
    return false;
  }

private:
  Rcpp::Matrix<RTYPE> data;
  std::vector<ColumnVisitor> visitors;
};

template <int RTYPE>
class RecyclingMatrixColumnVisitor : public VectorVisitor {
public:

  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  RecyclingMatrixColumnVisitor(const Rcpp::Matrix<RTYPE>& data_, int g_, int n_) :
    data(data_),
    g(g_),
    n(n_)
  {}

  inline size_t hash(int i) const {
    return 0;
  }

  inline bool equal(int i, int j) const {
    return true;
  }

  inline bool equal_or_both_na(int i, int j) const {
    return true;
  }

  inline bool less(int i, int j) const {
    return false;
  }

  inline bool greater(int i, int j) const {
    return false;
  }

  inline int size() const {
    return n;
  }

  bool is_na(int) const {
    return false;
  }

private:
  Rcpp::Matrix<RTYPE> data;
  int g;
  int n;
};



}

#endif
