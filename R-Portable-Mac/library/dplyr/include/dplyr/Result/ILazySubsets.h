#ifndef dplyr_ILazySubsets_H
#define dplyr_ILazySubsets_H

#include <tools/SlicingIndex.h>
#include <tools/SymbolString.h>
#include <tools/SymbolVector.h>

namespace dplyr {

class ILazySubsets {
protected:
  ILazySubsets() {}

public:
  virtual ~ILazySubsets() {}

  virtual const SymbolVector get_variable_names() const = 0;
  virtual SEXP get_variable(const SymbolString& symbol) const = 0;
  virtual SEXP get(const SymbolString& symbol, const SlicingIndex& indices) const = 0;
  virtual bool is_summary(const SymbolString& symbol) const = 0;
  virtual bool has_variable(const SymbolString& symbol) const = 0;
  virtual void input(const SymbolString& symbol, SEXP x) = 0;
  virtual int size() const = 0;
  virtual int nrows() const = 0;

public:
  bool has_non_summary_variable(const SymbolString& symbol) const {
    return has_variable(symbol) && !is_summary(symbol);
  }
};

}

#endif
