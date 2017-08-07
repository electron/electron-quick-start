#ifndef dplyr_collapse_H
#define dplyr_collapse_H

namespace dplyr {

template <int RTYPE>
const char* to_string_utf8(typename Rcpp::traits::storage_type<RTYPE>::type from) {
  SEXP s = Rcpp::internal::r_coerce<RTYPE, STRSXP>(from);
  return Rf_translateCharUTF8(s);
}

template <int RTYPE>
std::string collapse_utf8(const Vector<RTYPE>& x, const char* sep = ", ", const char* quote = "") {
  std::stringstream ss;
  int n = x.size();
  if (n > 0) {
    ss << quote << to_string_utf8<RTYPE>(x[0]) << quote;
    for (int i = 1; i < n; i++) {
      const char* st = to_string_utf8<RTYPE>(x[i]);
      ss << sep << quote << st << quote;
    }
  }

  return ss.str();
}

}
#endif
