#ifndef dplyr_Order_H
#define dplyr_Order_H

#include <tools/pointer_vector.h>

#include <dplyr/OrderVisitorImpl.h>

namespace dplyr {

class OrderVisitors_Compare;

class OrderVisitors {
public:

  OrderVisitors(List args, LogicalVector ascending, int n_) :
    visitors(n_), n(n_), nrows(0) {
    nrows = Rf_length(args[0]);
    for (int i = 0; i < n; i++) {
      visitors[i]  = order_visitor(args[i], ascending[i], i);
    }
  }

  OrderVisitors(DataFrame data) :
    visitors(data.size()), n(data.size()), nrows(data.nrows())
  {
    for (int i = 0; i < n; i++)
      visitors[i]  = order_visitor(data[i], true, i);
  }

  Rcpp::IntegerVector apply() const;

  pointer_vector<OrderVisitor> visitors;
  int n;
  int nrows;
};

class OrderVisitors_Compare {
public:
  OrderVisitors_Compare(const OrderVisitors& obj_) :  obj(obj_), n(obj.n) {}

  inline bool operator()(int i, int j) const {
    if (i == j) return false;
    for (int k = 0; k < n; k++)
      if (! obj.visitors[k]->equal(i, j))
        return obj.visitors[k]->before(i, j);
    return i < j;
  }

private:
  const OrderVisitors& obj;
  int n;

};

template <typename OrderVisitorClass>
class Compare_Single_OrderVisitor {
public:
  Compare_Single_OrderVisitor(const OrderVisitorClass& obj_) : obj(obj_) {}

  inline bool operator()(int i, int j) const {
    if (i == j) return false;
    if (obj.equal(i, j)) return i < j;
    return obj.before(i, j);
  }

private:
  const OrderVisitorClass& obj;
};

inline Rcpp::IntegerVector OrderVisitors::apply() const {
  if (nrows == 0) return IntegerVector(0);
  IntegerVector x = seq(0, nrows - 1);
  std::sort(x.begin(), x.end(), OrderVisitors_Compare(*this));
  return x;
}


} // namespace dplyr


#endif
