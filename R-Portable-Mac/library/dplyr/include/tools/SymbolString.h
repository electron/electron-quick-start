#ifndef dplyr_tools_SymbolString_h
#define dplyr_tools_SymbolString_h

#include <tools/encoding.h>

namespace dplyr {

class SymbolString  {
public:
  SymbolString() {}

  SymbolString(const char* str) : s(str) {}

  SymbolString(const String& other) : s(other) {}

  SymbolString(const String::StringProxy& other) : s(other) {}

  SymbolString(const String::const_StringProxy& other) : s(other) {}

  // Symbols are always encoded in the native encoding (#1950)
  explicit SymbolString(const Symbol& symbol) : s(CHAR(PRINTNAME(symbol)), CE_NATIVE) {}

public:
  const String& get_string() const {
    return s;
  }

  const Symbol get_symbol() const {
    return Symbol(Rf_translateChar(s.get_sexp()));
  }

  const std::string get_utf8_cstring() const {
    static Environment rlang = Environment::namespace_env("rlang");
    static Function as_string = Function("as_string", rlang);
    SEXP utf8_string = as_string(Rf_lang2(R_QuoteSymbol, get_symbol()));
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
  String s;
};

}

#endif
