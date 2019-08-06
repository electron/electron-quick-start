#ifndef dplyr_tools_SymbolString_h
#define dplyr_tools_SymbolString_h

#include <tools/encoding.h>

namespace dplyr {

class SymbolString  {
public:
  SymbolString() {}

  SymbolString(const char* str) : s(str) {}

  SymbolString(SEXP other) : s(other) {}

  SymbolString(const Rcpp::String& other) : s(other) {}

  SymbolString(const Rcpp::String::StringProxy& other) : s(other) {}

  SymbolString(const Rcpp::String::const_StringProxy& other) : s(other) {}

  // Symbols are always encoded in the native encoding (#1950)
  explicit SymbolString(const Rcpp::Symbol& symbol) : s(CHAR(PRINTNAME(symbol)), CE_NATIVE) {}

public:
  const Rcpp::String& get_string() const {
    return s;
  }

  const Rcpp::Symbol get_symbol() const {
    return Rcpp::Symbol(Rf_translateChar(s.get_sexp()));
  }

  const std::string get_utf8_cstring() const {
    static Rcpp::Environment rlang = Rcpp::Environment::namespace_env("rlang");
    static Rcpp::Function as_string = Rcpp::Function("as_string", rlang);
    Rcpp::Shield<SEXP> call(Rf_lang2(R_QuoteSymbol, get_symbol()));
    Rcpp::Shield<SEXP> utf8_string(as_string(call));
    return CHAR(STRING_ELT(utf8_string, 0));
  }

  bool is_empty() const {
    return s == "";
  }

  SEXP get_sexp() const {
    return s.get_sexp();
  }

  bool operator==(const SymbolString& other) const {
    return Rf_NonNullStringMatch(get_sexp(), other.get_sexp());
  }

private:
  Rcpp::String s;
};

}

#endif
