#ifndef dplyr_DataFrameColumnVisitors_H
#define dplyr_DataFrameColumnVisitors_H

#include <dplyr/DataFrameVisitors.h>

namespace dplyr {

class DataFrameColumnVisitor : public VectorVisitor {
public:
  DataFrameColumnVisitor(const DataFrame& data_) : data(data_), visitors(data) {}

  inline size_t hash(int i) const {
    return visitors.hash(i);
  }

  inline bool equal(int i, int j) const {
    return visitors.equal(i, j);
  }

  inline bool equal_or_both_na(int i, int j) const {
    return visitors.equal_or_both_na(i, j);
  }

  inline bool less(int i, int j) const {
    return visitors.less(i, j);
  }

  inline bool greater(int i, int j) const {
    return visitors.greater(i, j);
  }

  virtual int size() const {
    return visitors.nrows();
  }

  virtual std::string get_r_type() const {
    return "data.frame";
  }

  bool is_na(int) const {
    return false;
  }

private:
  DataFrame data;
  DataFrameVisitors visitors;
};

}

#endif
