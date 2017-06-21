#ifndef SOURCETOOLS_R_R_UTILS_H
#define SOURCETOOLS_R_R_UTILS_H

#include <vector>

#include <sourcetools/core/core.h>

#include <sourcetools/r/RHeaders.h>

namespace sourcetools {
namespace r {

class Protect : noncopyable
{
public:
  Protect(): n_(0) {}
  ~Protect() { UNPROTECT(n_); }

  SEXP operator()(SEXP objectSEXP)
  {
    ++n_;
    return PROTECT(objectSEXP);
  }

private:
  int n_;
};

class RObjectFactory : noncopyable
{
public:

  RObjectFactory()
    : n_(0)
  {
  }

  template <typename T, typename F>
  SEXP create(SEXPTYPE type, const std::vector<T>& vector, F f)
  {
    ++n_;
    std::size_t n = vector.size();
    SEXP resultSEXP = PROTECT(Rf_allocVector(type, n));
    for (std::size_t i = 0; i < n; ++i)
      f(resultSEXP, i, vector[i]);
    return resultSEXP;
  }

  SEXP create(SEXPTYPE type, std::size_t n)
  {
    ++n_;
    return PROTECT(Rf_allocVector(type, n));
  }

  ~RObjectFactory()
  {
    UNPROTECT(n_);
  }

private:
  std::size_t n_;
};

class ListBuilder : noncopyable
{
public:

  void add(const std::string& name, SEXP value)
  {
    names_.push_back(name);
    data_.push_back(protect_(value));
  }

  operator SEXP() const
  {
    std::size_t n = data_.size();

    SEXP resultSEXP = protect_(Rf_allocVector(VECSXP, n));
    SEXP namesSEXP  = protect_(Rf_allocVector(STRSXP, n));

    for (std::size_t i = 0; i < n; ++i)
    {
      SET_VECTOR_ELT(resultSEXP, i, data_[i]);
      SET_STRING_ELT(namesSEXP, i, Rf_mkCharLen(names_[i].c_str(), names_[i].size()));
    }

    Rf_setAttrib(resultSEXP, R_NamesSymbol, namesSEXP);
    return resultSEXP;
  }

private:
  std::vector<std::string> names_;
  std::vector<SEXP> data_;
  mutable Protect protect_;
};

} // namespace r
} // namespace sourcetools

#endif /* SOURCETOOLS_R_R_UTILS_H */
