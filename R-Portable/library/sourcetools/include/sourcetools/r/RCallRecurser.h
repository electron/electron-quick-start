#ifndef SOURCETOOLS_R_R_CALL_RECURSER_H
#define SOURCETOOLS_R_R_CALL_RECURSER_H

#include <vector>

#include <sourcetools/core/core.h>

#include <sourcetools/r/RHeaders.h>
#include <sourcetools/r/RFunctions.h>


namespace sourcetools {
namespace r {

class CallRecurser : noncopyable
{
public:

  class Operation
  {
  public:
    virtual void apply(SEXP dataSEXP) = 0;
    virtual ~Operation() {}
  };

  explicit CallRecurser(SEXP dataSEXP)
  {
    if (Rf_isPrimitive(dataSEXP))
      dataSEXP_ = R_NilValue;
    else if (Rf_isFunction(dataSEXP))
      dataSEXP_ = r::util::functionBody(dataSEXP);
    else if (TYPEOF(dataSEXP) == LANGSXP)
      dataSEXP_ = dataSEXP;
    else
      dataSEXP_ = R_NilValue;
  }

  void add(Operation* pOperation)
  {
    operations_.push_back(pOperation);
  }

  void run()
  {
    runImpl(dataSEXP_);
  }

  void runImpl(SEXP dataSEXP)
  {
    for (std::vector<Operation*>::iterator it = operations_.begin();
         it != operations_.end();
         ++it)
    {
      (*it)->apply(dataSEXP);
    }

    if (TYPEOF(dataSEXP) == LANGSXP)
    {
      while (dataSEXP != R_NilValue)
      {
        runImpl(CAR(dataSEXP));
        dataSEXP = CDR(dataSEXP);
      }
    }
  }

private:
  SEXP dataSEXP_;
  std::vector<Operation*> operations_;
};

} // namespace r
} // namespace sourcetools

#endif /* SOURCETOOLS_R_R_CALL_RECURSER_H */
