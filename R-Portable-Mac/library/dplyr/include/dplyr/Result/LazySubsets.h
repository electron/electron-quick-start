#ifndef dplyr_LazySubsets_H
#define dplyr_LazySubsets_H

#include <tools/SymbolMap.h>
#include <tools/SlicingIndex.h>
#include <dplyr/Result/ILazySubsets.h>

namespace dplyr {

class LazySubsets : public ILazySubsets {
public:
  LazySubsets(const DataFrame& df) : nr(df.nrows()) {
    int nvars = df.size();
    if (nvars) {
      CharacterVector names = df.names();
      for (int i = 0; i < nvars; i++) {
        SEXP column = df[i];
        if (Rf_inherits(column, "matrix")) {
          stop("matrix as column is not supported");
        }
        symbol_map.insert(names[i]);
        data.push_back(df[i]);
      }
    }
  }
  virtual ~LazySubsets() {}

public:
  virtual const SymbolVector get_variable_names() const {
    return symbol_map.get_names();
  }

  virtual SEXP get_variable(const SymbolString& symbol) const {
    return data[ symbol_map.get(symbol) ];
  }

  virtual SEXP get(const SymbolString& symbol, const SlicingIndex& indices) const {
    const int pos = symbol_map.get(symbol);
    SEXP col = data[pos];
    if (!indices.is_identity(col) && Rf_length(col) != 1)
      stop("Attempt to query lazy column with non-natural slicing index");

    return col;
  }

  virtual bool is_summary(const SymbolString& symbol) const {
    return summary_map.has(symbol);
  }

  virtual bool has_variable(const SymbolString& symbol) const {
    return symbol_map.has(symbol);
  }

  virtual void input(const SymbolString& symbol, SEXP x) {
    SymbolMapIndex index = symbol_map.insert(symbol);
    if (index.origin == NEW) {
      data.push_back(x);
    } else {
      data[index.pos] = x;
    }
  }

  virtual int size() const {
    return data.size();
  }

  virtual int nrows() const {
    return nr;
  }

  void input_summarised(const SymbolString& symbol, SummarisedVariable x) {
    input(symbol, x);
    summary_map.insert(symbol);
  }

public:
  void clear() {}

  inline SEXP& operator[](const SymbolString& symbol) {
    return data[symbol_map.get(symbol)];
  }

private:
  SymbolMap symbol_map, summary_map;
  std::vector<SEXP> data;
  int nr;
};

}

#endif
