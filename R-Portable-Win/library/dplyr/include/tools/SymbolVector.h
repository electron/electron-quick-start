#ifndef dplyr_tools_SymbolVector_h
#define dplyr_tools_SymbolVector_h

#include <Rcpp.h>
#include <tools/SymbolString.h>
#include <tools/match.h>

namespace dplyr {

class SymbolVector {
public:

  SymbolVector() {}

  template <class T>
  explicit SymbolVector(T v_) : v(v_) {}

  explicit SymbolVector(SEXP x) : v(init(x)) {}
  explicit SymbolVector(Rcpp::RObject x) : v(init(x)) {}

  void push_back(const SymbolString& s) {
    v.push_back(s.get_string());
  }

  void remove(const R_xlen_t idx) {
    v.erase(v.begin() + idx);
  }

  const SymbolString operator[](const R_xlen_t i) const {
    return SymbolString(v[i]);
  }

  void set(int i, const SymbolString& x) {
    v[i] = x.get_string();
  }

  R_xlen_t size() const {
    return v.size();
  }

  int match(const SymbolString& s) const {
    Rcpp::Shield<SEXP> vs(Rf_ScalarString(s.get_sexp()));
    Rcpp::Shield<SEXP> res(r_match(vs, v));
    return Rcpp::as<int>(res);
  }

  SEXP match_in_table(const Rcpp::CharacterVector& t) const {
    return r_match(v, t);
  }

  const Rcpp::CharacterVector& get_vector() const {
    return v;
  }

private:

  Rcpp::CharacterVector v;

  SEXP init(SEXP x_) {
    Rcpp::Shield<SEXP> x(x_);
    switch (TYPEOF(x)) {
    case NILSXP:
      return Rcpp::CharacterVector();
    case STRSXP:
      return x;
    case VECSXP:
    {
      R_xlen_t n = XLENGTH(x);
      Rcpp::CharacterVector res(n);
      for (R_xlen_t i = 0; i < n; i++) {
        SEXP elt = VECTOR_ELT(x, i);
        if (TYPEOF(elt) != SYMSXP) {
          Rcpp::stop("cannot convert to SymbolVector");
        }
        res[i] = PRINTNAME(elt);
      }
      return res;
    }
    default:
      break;
    }
    return x;
  }
};

}

namespace Rcpp {

template <> inline SEXP wrap(const dplyr::SymbolVector& x) {
  return x.get_vector();
}

template <>
class ConstReferenceInputParameter<dplyr::SymbolVector> {
public:
  typedef const dplyr::SymbolVector& const_reference ;

  ConstReferenceInputParameter(SEXP x_) : obj(x_) {}

  inline operator const_reference() {
    return obj ;
  }

private:
  dplyr::SymbolVector obj ;
} ;


}

#endif
