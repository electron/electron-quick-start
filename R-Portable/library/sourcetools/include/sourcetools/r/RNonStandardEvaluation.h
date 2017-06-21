#ifndef SOURCETOOLS_R_R_NON_STANDARD_EVALUATION_H
#define SOURCETOOLS_R_R_NON_STANDARD_EVALUATION_H

#include <set>
#include <map>

#include <sourcetools/r/RHeaders.h>
#include <sourcetools/r/RCallRecurser.h>

namespace sourcetools {
namespace r {
namespace nse {

namespace detail {

inline std::set<std::string> makeNsePrimitives()
{
  std::set<std::string> instance;

  instance.insert("quote");
  instance.insert("substitute");
  instance.insert("eval");
  instance.insert("evalq");
  instance.insert("lazy_dots");

  return instance;
}

inline std::set<std::string>& nsePrimitives()
{
  static std::set<std::string> instance = makeNsePrimitives();
  return instance;
}

class PerformsNonStandardEvaluationOperation
  : public r::CallRecurser::Operation
{
public:

  PerformsNonStandardEvaluationOperation()
    : status_(false)
  {
  }

  virtual void apply(SEXP dataSEXP)
  {
    if (status_ || TYPEOF(dataSEXP) != LANGSXP)
      return;

    if ((status_ = checkCall(dataSEXP)))
      return;

    SEXP fnSEXP = CAR(dataSEXP);
    if (TYPEOF(fnSEXP) == SYMSXP)
      status_ = nsePrimitives().count(CHAR(PRINTNAME(fnSEXP)));
    else if (TYPEOF(fnSEXP) == STRSXP)
      status_ = nsePrimitives().count(CHAR(STRING_ELT(fnSEXP, 0)));

  }

  bool status() const { return status_; }

private:

  bool checkCall(SEXP callSEXP)
  {
    std::size_t n = Rf_length(callSEXP);
    if (n == 0)
      return false;

    SEXP fnSEXP = CAR(callSEXP);
    if (fnSEXP == Rf_install("::") || fnSEXP == Rf_install(":::"))
    {
      SEXP lhsSEXP = CADR(callSEXP);
      SEXP rhsSEXP = CADDR(callSEXP);

      if (lhsSEXP == Rf_install("lazyeval") && rhsSEXP == Rf_install("lazy_dots"))
        return true;
    }

    return false;
  }

private:
  bool status_;
};

} // namespace detail

class Database
{
public:
  bool check(SEXP dataSEXP)
  {
    if (contains(dataSEXP))
      return get(dataSEXP);

    typedef detail::PerformsNonStandardEvaluationOperation Operation;
    scoped_ptr<Operation> operation(new Operation);

    r::CallRecurser recurser(dataSEXP);
    recurser.add(operation);
    recurser.run();

    set(dataSEXP, operation->status());
    return operation->status();
  }

private:

  bool contains(SEXP dataSEXP)
  {
    return map_.count(address(dataSEXP));
  }

  bool get(SEXP dataSEXP)
  {
    return map_[address(dataSEXP)];
  }

  void set(SEXP dataSEXP, bool value)
  {
    map_[address(dataSEXP)] = value;
  }

  std::size_t address(SEXP dataSEXP)
  {
    return reinterpret_cast<std::size_t>(dataSEXP);
  }

  std::map<std::size_t, bool> map_;
};

inline Database& database()
{
  static Database instance;
  return instance;
}

inline bool performsNonStandardEvaluation(SEXP fnSEXP)
{
  return database().check(fnSEXP);
}

} // namespace nse
} // namespace r
} // namespace sourcetools

#endif /* SOURCETOOLS_R_R_NON_STANDARD_EVALUATION_H */
