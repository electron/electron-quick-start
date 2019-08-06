#ifndef dplyr_tools_BoolResult_H
#define dplyr_tools_BoolResult_H

#include <tools/utils.h>
#include <dplyr/symbols.h>

namespace dplyr {

class BoolResult {
public:
  BoolResult(bool result_) : result(result_) {}
  BoolResult(bool result_, const Rcpp::CharacterVector& msg) : result(result_), message(msg) {}

  inline operator SEXP() const {
    Rcpp::LogicalVector res = Rcpp::LogicalVector::create(result);
    Rf_setAttrib(res, symbols::comment, message);
    Rcpp::Shield<SEXP> klass(Rf_mkString("BoolResult"));
    Rf_classgets(res, klass);
    return res;
  }

  inline operator bool() const {
    return result;
  }

  inline std::string why_not() const {
    R_xlen_t n = message.length();
    if (n == 0)
      return "";

    if (n == 1)
      return std::string(message[0]);

    std::stringstream ss;
    ss << "\n";
    for (int i = 0; i < n; ++i) {
      ss << "- " << std::string(message[i]) << "\n";
    }

    return ss.str();
  }

private:
  bool result;
  Rcpp::CharacterVector message;


};

inline BoolResult no_because(const Rcpp::CharacterVector& msg) {
  return BoolResult(false, msg);
}

inline BoolResult yes() {
  return true;
}

}

#endif
