#ifndef dplyr_MultipleVectorVisitors_H
#define dplyr_MultipleVectorVisitors_H

#include <boost/shared_ptr.hpp>

#include <dplyr/visitor_set/VisitorSetEqual.h>
#include <dplyr/visitor_set/VisitorSetHash.h>
#include <dplyr/visitor_set/VisitorSetLess.h>
#include <dplyr/visitor_set/VisitorSetGreater.h>

#include <dplyr/visitors/vector/VectorVisitor.h>
#include <tools/utils.h>

namespace dplyr {

class MultipleVectorVisitors :
  public VisitorSetEqual<MultipleVectorVisitors>,
  public VisitorSetHash<MultipleVectorVisitors>,
  public VisitorSetLess<MultipleVectorVisitors>,
  public VisitorSetGreater<MultipleVectorVisitors> {

private:
  // TODO: this does not need to be shared_ptr
  std::vector< boost::shared_ptr<VectorVisitor> > visitors;
  int length;
  int ngroups;

public:
  typedef VectorVisitor visitor_type;

  MultipleVectorVisitors(const Rcpp::List& data, int length_, int ngroups_) :
    visitors(),
    length(length_),
    ngroups(ngroups_)
  {
    visitors.reserve(data.size());
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
    return length;
  }

  inline bool is_na(int index) const {
    int n = size();
    for (int i = 0; i < n; i++) if (visitors[i]->is_na(index)) return true;
    return false;
  }

private:

  // prevent copy construction
  MultipleVectorVisitors(const MultipleVectorVisitors&);

  inline void push_back(SEXP x) {
    int s = get_size(x);
    if (s == length) {
      visitors.push_back(boost::shared_ptr<VectorVisitor>(visitor(x)));
    } else if (s != ngroups) {
      Rcpp::stop("incompatible size, should be either %d or %d (the number of groups)", length, ngroups);
    }
  }

};

} // namespace dplyr

#include <dplyr/visitors/vector/visitor_impl.h>

#endif
