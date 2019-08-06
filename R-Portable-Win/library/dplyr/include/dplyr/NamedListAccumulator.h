#ifndef dplyr_NamedListAccumulator_H
#define dplyr_NamedListAccumulator_H

#include <tools/SymbolMap.h>

#include <dplyr/checks.h>
#include <dplyr/data/RowwiseDataFrame.h>

namespace dplyr {

template <typename SlicedTibble>
class NamedListAccumulator {
private:
  SymbolMap symbol_map;
  std::vector<Rcpp::RObject> data; // owns the results

public:
  NamedListAccumulator() {}

  inline void set(const SymbolString& name, Rcpp::RObject x) {
    if (! Rcpp::traits::same_type<SlicedTibble, RowwiseDataFrame>::value)
      check_supported_type(x, name);
    MARK_NOT_MUTABLE(x);
    SymbolMapIndex index = symbol_map.insert(name);
    if (index.origin == NEW) {
      data.push_back(x);
    } else {
      data[index.pos] = x;
    }

  }

  inline void rm(const SymbolString& name) {
    SymbolMapIndex index = symbol_map.rm(name);
    if (index.origin != NEW) {
      data.erase(data.begin() + index.pos);
    }
  }

  inline operator Rcpp::List() const {
    Rcpp::List out = wrap(data);
    Rf_namesgets(out, symbol_map.get_names().get_vector());
    return out;
  }

  inline size_t size() const {
    return data.size();
  }

  inline const SymbolVector& names() const {
    return symbol_map.get_names();
  }

};

}
#endif
