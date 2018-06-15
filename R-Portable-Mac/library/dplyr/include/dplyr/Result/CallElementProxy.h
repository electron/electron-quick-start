#ifndef dplyr_CallElementProxy_H
#define dplyr_CallElementProxy_H

namespace dplyr {

class CallElementProxy {
public:
  CallElementProxy(SEXP symbol_, SEXP object_) :
    symbol(symbol_), object(object_)
  {}

  inline void set(SEXP value) {
    SETCAR(object, value);
  }

  SEXP symbol;
  SEXP object;
};

}

#endif
