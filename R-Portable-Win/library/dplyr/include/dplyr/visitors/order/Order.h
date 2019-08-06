#ifndef dplyr_Order_H
#define dplyr_Order_H

#include <tools/pointer_vector.h>
#include <dplyr/visitors/order/OrderVisitorImpl.h>

namespace dplyr {

class OrderVisitors {
private:

  class Compare {
  public:
    Compare(const OrderVisitors& obj_) :
      obj(obj_)
    {}

    inline bool operator()(int i, int j) const {
      if (i == j) return false;
      for (int k = 0; k < obj.n; k++) {
        if (! obj.visitors[k]->equal(i - 1, j - 1)) {
          return obj.visitors[k]->before(i - 1, j - 1);
        }
      }
      return i < j;
    }

  private:
    const OrderVisitors& obj;
  };

public:

  OrderVisitors(Rcpp::List args, Rcpp::LogicalVector ascending, int n_) :
    visitors(n_),
    n(n_),
    nrows(0)
  {
    nrows = Rf_length(args[0]);
    for (int i = 0; i < n; i++) {
      visitors[i] = order_visitor(args[i], ascending[i], i);
    }
  }

  inline Rcpp::IntegerVector apply() const {
    if (nrows == 0) return Rcpp::IntegerVector(0);
    Rcpp::IntegerVector x = Rcpp::seq(1, nrows);
    std::sort(x.begin(), x.end(), Compare(*this));
    return x;
  }

  pointer_vector<OrderVisitor> visitors;
  int n;
  int nrows;

private:
  OrderVisitors(const OrderVisitors&);
};

} // namespace dplyr


#endif
