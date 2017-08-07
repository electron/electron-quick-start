#ifndef dplyr_SummarisedVariable_H
#define dplyr_SummarisedVariable_H

namespace dplyr {

class SummarisedVariable {
public:
  SummarisedVariable(SEXP x) : data(x) {}

  inline operator SEXP() const {
    return data;
  }
private:
  SEXP data;
};

}

#endif
