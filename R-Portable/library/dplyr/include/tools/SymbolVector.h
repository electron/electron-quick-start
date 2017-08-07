#ifndef dplyr_tools_SymbolVector_h
#define dplyr_tools_SymbolVector_h

#include <tools/SymbolString.h>
#include <tools/match.h>

namespace dplyr {

class SymbolVector {
public:
  SymbolVector() {}

  template <class T>
  explicit SymbolVector(T v_) : v(v_) {}

  explicit SymbolVector(SEXP x) : v(init(x)) {}
  explicit SymbolVector(RObject x) : v(init(x)) {}

public:
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
    CharacterVector vs = CharacterVector::create(s.get_string());
    return as<int>(match(vs));
  }

  const IntegerVector match(const CharacterVector& m) const {
    return r_match(m, v);
  }

  const IntegerVector match_in_table(const CharacterVector& t) const {
    return r_match(v, t);
  }

  const CharacterVector get_vector() const {
    return v;
  }

private:
  CharacterVector v;
  SEXP init(SEXP x) {
    if (Rf_isNull(x))
      return CharacterVector();
    else
      return x;
  }
};

}

namespace Rcpp {
using namespace dplyr;

template <> inline SEXP wrap(const SymbolVector& x) {
  return x.get_vector();
}

}

#endif
