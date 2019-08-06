#ifndef dplyr_checks_H
#define dplyr_checks_H

#include <tools/SymbolString.h>
#include <tools/bad.h>

namespace dplyr {

enum SupportedType {
  DPLYR_LGLSXP = LGLSXP,
  DPLYR_INTSXP = INTSXP,
  DPLYR_REALSXP = REALSXP,
  DPLYR_CPLXSXP = CPLXSXP,
  DPLYR_STRSXP = STRSXP,
  DPLYR_VECSXP = VECSXP,
  DPLYR_RAWSXP = RAWSXP
};

inline std::string type_name(SEXP x) {
  switch (TYPEOF(x)) {
  case NILSXP:
    return "NULL";
  case SYMSXP:
    return "symbol";
  case S4SXP:
    return "S4";
  case LGLSXP:
    return "logical vector";
  case INTSXP:
    return "integer vector";
  case REALSXP:
    return "double vector";
  case STRSXP:
    return "character vector";
  case CPLXSXP:
    return "complex vector";
  case RAWSXP:
    return "raw vector";
  case VECSXP:
    return "list";
  case LANGSXP:
    return "quoted call";
  case EXPRSXP:
    return "expression";
  case ENVSXP:
    return "environment";

  case SPECIALSXP:
  case BUILTINSXP:
  case CLOSXP:
    return "function";

  // Everything else can fall back to R's default
  default:
    return std::string(Rf_type2char(TYPEOF(x)));
  }
}

inline SupportedType check_supported_type(SEXP x, const SymbolString& name = Rcpp::String()) {
  switch (TYPEOF(x)) {
  case LGLSXP:
    return DPLYR_LGLSXP;
  case INTSXP:
    return DPLYR_INTSXP;
  case REALSXP:
    return DPLYR_REALSXP;
  case CPLXSXP:
    return DPLYR_CPLXSXP;
  case STRSXP:
    return DPLYR_STRSXP;
  case VECSXP:
    return DPLYR_VECSXP;
  case RAWSXP:
    return DPLYR_RAWSXP;
  default:
    if (name.is_empty()) {
      Rcpp::stop("is of unsupported type %s", type_name(x));
    } else {
      bad_col(name, "is of unsupported type {type}",
              Rcpp::_["type"] = type_name(x));
    }
  }
}

inline void check_length(const int actual, const int expected, const char* comment, const SymbolString& name) {
  if (actual == expected || actual == 1) return;

  static Rcpp::Function check_length_col("check_length_col", Rcpp::Environment::namespace_env("dplyr"));
  static Rcpp::Function identity("identity", Rcpp::Environment::base_env());
  Rcpp::String message = check_length_col(actual, expected, Rcpp::CharacterVector::create(name.get_sexp()), std::string(comment), Rcpp::_[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  Rcpp::stop(message.get_cstring());
}

inline void check_not_null(SEXP result, const SymbolString& name) {
  if (Rf_isNull(result)) {
    bad_col(name, "is of unsupported type NULL");
  }
}


}
#endif
