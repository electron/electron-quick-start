#ifndef dplyr_MultipleVectorVisitors_H
#define dplyr_MultipleVectorVisitors_H

#include <boost/shared_ptr.hpp>

#include <dplyr/visitor_set/VisitorSetMixin.h>

#include <dplyr/visitor.h>

namespace dplyr {

class MultipleVectorVisitors :
  public VisitorSetEqual<MultipleVectorVisitors>,
  public VisitorSetHash<MultipleVectorVisitors>,
  public VisitorSetLess<MultipleVectorVisitors>,
  public VisitorSetGreater<MultipleVectorVisitors> {

private:
  std::vector< boost::shared_ptr<VectorVisitor> > visitors;

public:
  typedef VectorVisitor visitor_type;

  MultipleVectorVisitors() : visitors() {}

  MultipleVectorVisitors(List data) :
    visitors()
  {
    int n = data.size();
    for (int i = 0; i < n; i++) {
      push_back(data[i]);
    }
  }

  inline int size() const {
    return visitors.size();
  }
  inline VectorVisitor* get(int k) const {
    return visitors[k].get();
  }
  inline int nrows() const {
    if (visitors.size() == 0) {
      stop("Need at least one column for `nrows()`");
    }
    return visitors[0]->size();
  }
  inline void push_back(SEXP x) {
    visitors.push_back(boost::shared_ptr<VectorVisitor>(visitor(x)));
  }

  inline bool is_na(int index) const {
    int n = size();
    for (int i = 0; i < n; i++) if (visitors[i]->is_na(index)) return true;
    return false;
  }

};

} // namespace dplyr

#include <dplyr/visitor_impl.h>

#endif
