#ifndef SOURCETOOLS_R_R_FUNCTIONS_H
#define SOURCETOOLS_R_R_FUNCTIONS_H

#include <string>
#include <set>

#include <sourcetools/r/RUtils.h>

namespace sourcetools {
namespace r {

inline SEXP eval(const std::string& fn, SEXP envSEXP = NULL)
{
  Protect protect;
  if (envSEXP == NULL)
  {
    SEXP strSEXP = protect(Rf_mkString("sourcetools"));
    envSEXP = R_FindNamespace(strSEXP);
  }

  SEXP callSEXP = protect(Rf_lang1(Rf_install(fn.c_str())));
  SEXP resultSEXP = protect(Rf_eval(callSEXP, envSEXP));
  return resultSEXP;
}

inline std::set<std::string> objectsOnSearchPath()
{
  std::set<std::string> results;
  Protect protect;

  SEXP objectsSEXP;
  protect(objectsSEXP = eval("search_objects"));

  for (R_xlen_t i = 0; i < Rf_length(objectsSEXP); ++i)
  {
    SEXP strSEXP = VECTOR_ELT(objectsSEXP, i);
    for (R_xlen_t j = 0; j < Rf_length(strSEXP); ++j)
    {
      SEXP charSEXP = STRING_ELT(strSEXP, j);
      std::string element(CHAR(charSEXP), Rf_length(charSEXP));
      results.insert(element);
    }
  }

  return results;
}

namespace util {

inline void setNames(SEXP dataSEXP, const char** names, std::size_t n)
{
  RObjectFactory factory;
  SEXP namesSEXP = factory.create(STRSXP, n);
  for (std::size_t i = 0; i < n; ++i)
    SET_STRING_ELT(namesSEXP, i, Rf_mkChar(names[i]));
  Rf_setAttrib(dataSEXP, R_NamesSymbol, namesSEXP);
}

inline void listToDataFrame(SEXP listSEXP, int n)
{
  r::Protect protect;
  SEXP classSEXP = protect(Rf_mkString("data.frame"));
  Rf_setAttrib(listSEXP, R_ClassSymbol, classSEXP);

  SEXP rownamesSEXP = protect(Rf_allocVector(INTSXP, 2));
  INTEGER(rownamesSEXP)[0] = NA_INTEGER;
  INTEGER(rownamesSEXP)[1] = -n;
  Rf_setAttrib(listSEXP, R_RowNamesSymbol, rownamesSEXP);
}

inline SEXP functionBody(SEXP fnSEXP)
{
  SEXP bodyFunctionSEXP = Rf_findFun(Rf_install("body"), R_BaseNamespace);

  r::Protect protect;
  SEXP callSEXP = protect(Rf_lang2(bodyFunctionSEXP, fnSEXP));
  return Rf_eval(callSEXP, R_BaseNamespace);
}

} // namespace util

} // namespace r
} // namespace sourcetools

#endif /* SOURCETOOLS_R_R_FUNCTIONS_H */
