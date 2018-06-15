#ifndef dplyr_JoinVisitor_H
#define dplyr_JoinVisitor_H

#include <dplyr/Column.h>
#include <dplyr/visitor_set/VisitorSetIndexSet.h>

namespace dplyr {

class DataFrameJoinVisitors;

class JoinVisitor {
public:
  virtual ~JoinVisitor() {}

  virtual size_t hash(int i) = 0;
  virtual bool equal(int i, int j) = 0;

  virtual SEXP subset(const std::vector<int>& indices) = 0;
  virtual SEXP subset(const VisitorSetIndexSet<DataFrameJoinVisitors>& set) = 0;

};

JoinVisitor* join_visitor(const Column& left, const Column& right, bool warn, bool accept_na_match = true);

}

#endif
