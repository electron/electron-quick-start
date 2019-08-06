#ifndef dplyr__Quosure_h
#define dplyr__Quosure_h

#include <tools/SymbolString.h>
#include <tools/utils.h>
#include "SymbolVector.h"
#include <dplyr/symbols.h>

namespace dplyr {

class Quosure {
public:
  Quosure(SEXP data_) : data(data_) {}

  inline operator SEXP() const {
    return data;
  }

  SEXP expr() const {
    return rlang::quo_get_expr(data);
  }
  SEXP env() const {
    return rlang::quo_get_env(data);
  }

private:
  // quosure typically come from the R side, so don't need
  // further protection, so it's the user responsability to protect
  // them if needed, as in arrange.cpp
  SEXP data;
};

class NamedQuosure {
public:
  NamedQuosure(SEXP data_, SymbolString name__) :
    quosure(data_),
    name_(name__)
  {}

  SEXP expr() const {
    return quosure.expr();
  }
  SEXP env() const {
    return quosure.env();
  }
  const SymbolString& name() const {
    return name_;
  }
  SEXP get() const {
    return quosure;
  }

  bool is_rlang_lambda() const {
    SEXP expr_ = expr();
    return TYPEOF(expr_) == LANGSXP && Rf_inherits(CAR(expr_), "rlang_lambda_function");
  }

private:
  Quosure quosure;
  SymbolString name_;
};

} // namespace dplyr

namespace dplyr {

class QuosureList {
public:
  QuosureList(const Rcpp::List& data_) : data() {
    int n = data_.size();
    if (n == 0) return;

    data.reserve(n);

    Rcpp::Shield<SEXP> names(Rf_getAttrib(data_, symbols::names));
    for (int i = 0; i < n; i++) {
      SEXP x = data_[i];

      if (!rlang::is_quosure(x)) {
        Rcpp::stop("corrupt tidy quote");
      }

      data.push_back(NamedQuosure(x, SymbolString(STRING_ELT(names, i))));
    }
  }

  const NamedQuosure& operator[](int i) const {
    return data[i];
  }

  int size() const {
    return data.size();
  }

  bool single_env() const {
    if (data.size() <= 1) return true;
    SEXP env = data[0].env();
    for (size_t i = 1; i < data.size(); i++) {
      if (data[i].env() != env) return false;
    }
    return true;
  }

  SEXP names() const {
    R_xlen_t n = data.size();
    Rcpp::Shield<SEXP> out(Rf_allocVector(STRSXP, n));

    for (size_t i = 0; i < data.size(); ++i) {
      SET_STRING_ELT(out, i, data[i].name().get_sexp());
    }

    return out;
  }

private:
  std::vector<NamedQuosure> data;
};

} // namespace dplyr

#endif
