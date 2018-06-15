#ifndef _bindrcpp_bindrcpp_types_H_
#define _bindrcpp_bindrcpp_types_H_

#include <RcppCommon.h>

#include <Rcpp.h>

namespace bindrcpp {

struct PAYLOAD { void* p; explicit PAYLOAD(void* p_) : p(p_) {}; };
typedef SEXP (*GETTER_FUNC_STRING)(const Rcpp::String& name, bindrcpp::PAYLOAD payload);
typedef SEXP (*GETTER_FUNC_SYMBOL)(const Rcpp::Symbol& name, bindrcpp::PAYLOAD payload);

}

namespace Rcpp {
  using namespace bindrcpp;

  template <> inline SEXP wrap(const PAYLOAD& payload) {
    return List::create(XPtr<PAYLOAD>(new PAYLOAD(payload)));
  }
  template <> inline SEXP wrap(const GETTER_FUNC_STRING& fun) {
    return List::create(XPtr<GETTER_FUNC_STRING>(new GETTER_FUNC_STRING(fun)));
  }
  template <> inline SEXP wrap(const GETTER_FUNC_SYMBOL& fun) {
    return List::create(XPtr<GETTER_FUNC_SYMBOL>(new GETTER_FUNC_SYMBOL(fun)));
  }
  template <> inline PAYLOAD as(SEXP x) {
    List xl = x;
    XPtr<PAYLOAD> xpayload(static_cast<SEXP>(xl[0]));
    return *xpayload.get();
  }
  template <> inline GETTER_FUNC_STRING as(SEXP x) {
    List xl = x;
    XPtr<GETTER_FUNC_STRING> xfun(static_cast<SEXP>(xl[0]));
    return *xfun.get();
  }
  template <> inline GETTER_FUNC_SYMBOL as(SEXP x) {
    List xl = x;
    XPtr<GETTER_FUNC_SYMBOL> xfun(static_cast<SEXP>(xl[0]));
    return *xfun.get();
  }
}

#endif
