#ifndef _bindrcpp_bindrcpp_types_H_
#define _bindrcpp_bindrcpp_types_H_

#include <RcppCommon.h>

#include <Rcpp.h>

namespace bindrcpp {

struct PAYLOAD { void* p; explicit PAYLOAD(void* p_) : p(p_) {}; };

typedef SEXP (*GETTER_FUNC_STRING_TYPED)(const Rcpp::String& name, bindrcpp::PAYLOAD payload);
typedef SEXP (*GETTER_FUNC_SYMBOL_TYPED)(const Rcpp::Symbol& name, bindrcpp::PAYLOAD payload);
typedef SEXP (*GETTER_FUNC_STRING_WRAPPED)(const Rcpp::String& name, Rcpp::List payload);
typedef SEXP (*GETTER_FUNC_SYMBOL_WRAPPED)(const Rcpp::Symbol& name, Rcpp::List payload);

typedef GETTER_FUNC_SYMBOL_TYPED GETTER_FUNC_SYMBOL;
typedef GETTER_FUNC_STRING_TYPED GETTER_FUNC_STRING;

}

namespace Rcpp {
  using namespace bindrcpp;

  template <> inline SEXP wrap(const PAYLOAD& payload) {
    return List::create(XPtr<PAYLOAD>(new PAYLOAD(payload)));
  }
  template <> inline SEXP wrap(const GETTER_FUNC_STRING_TYPED& fun) {
    return List::create(XPtr<GETTER_FUNC_STRING_TYPED>(new GETTER_FUNC_STRING_TYPED(fun)));
  }
  template <> inline SEXP wrap(const GETTER_FUNC_SYMBOL_TYPED& fun) {
    return List::create(XPtr<GETTER_FUNC_SYMBOL_TYPED>(new GETTER_FUNC_SYMBOL_TYPED(fun)));
  }
  template <> inline SEXP wrap(const GETTER_FUNC_STRING_WRAPPED& fun) {
    return List::create(XPtr<GETTER_FUNC_STRING_WRAPPED>(new GETTER_FUNC_STRING_WRAPPED(fun)));
  }
  template <> inline SEXP wrap(const GETTER_FUNC_SYMBOL_WRAPPED& fun) {
    return List::create(XPtr<GETTER_FUNC_SYMBOL_WRAPPED>(new GETTER_FUNC_SYMBOL_WRAPPED(fun)));
  }
  template <> inline PAYLOAD as(SEXP x) {
    List xl = x;
    XPtr<PAYLOAD> xpayload(static_cast<SEXP>(xl[0]));
    return *xpayload.get();
  }
  template <> inline GETTER_FUNC_STRING_TYPED as(SEXP x) {
    List xl = x;
    XPtr<GETTER_FUNC_STRING_TYPED> xfun(static_cast<SEXP>(xl[0]));
    return *xfun.get();
  }
  template <> inline GETTER_FUNC_SYMBOL_TYPED as(SEXP x) {
    List xl = x;
    XPtr<GETTER_FUNC_SYMBOL_TYPED> xfun(static_cast<SEXP>(xl[0]));
    return *xfun.get();
  }
  template <> inline GETTER_FUNC_STRING_WRAPPED as(SEXP x) {
    List xl = x;
    XPtr<GETTER_FUNC_STRING_WRAPPED> xfun(static_cast<SEXP>(xl[0]));
    return *xfun.get();
  }
  template <> inline GETTER_FUNC_SYMBOL_WRAPPED as(SEXP x) {
    List xl = x;
    XPtr<GETTER_FUNC_SYMBOL_WRAPPED> xfun(static_cast<SEXP>(xl[0]));
    return *xfun.get();
  }
}

#endif
