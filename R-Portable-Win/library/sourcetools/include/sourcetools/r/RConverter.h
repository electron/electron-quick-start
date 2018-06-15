#ifndef SOURCETOOLS_R_R_CONVERTER_H
#define SOURCETOOLS_R_R_CONVERTER_H

#include <vector>
#include <string>

#include <sourcetools/r/RUtils.h>
#include <sourcetools/r/RHeaders.h>

namespace sourcetools {
namespace r {

inline SEXP Rf_mkChar(const std::string& data)
{
  return Rf_mkCharLen(data.c_str(), data.size());
}

inline SEXP Rf_mkString(const std::string& data)
{
  Protect protect;
  SEXP resultSEXP = protect(Rf_allocVector(STRSXP, 1));
  SET_STRING_ELT(resultSEXP, 0, Rf_mkChar(data));
  return resultSEXP;
}

inline SEXP create(const std::vector<std::string>& vector)
{
  Protect protect;
  std::size_t n = vector.size();
  SEXP resultSEXP = protect(Rf_allocVector(STRSXP, n));
  for (std::size_t i = 0; i < n; ++i)
    SET_STRING_ELT(resultSEXP, i, Rf_mkChar(vector[i]));
  return resultSEXP;
}

} // namespace r
} // namespace sourcetools

#endif /* SOURCETOOLS_R_R_CONVERTER_H */
