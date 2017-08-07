#ifndef dplyr_GroupedCallReducer_H
#define dplyr_GroupedCallReducer_H

#include <tools/Call.h>

#include <dplyr/Result/CallbackProcessor.h>
#include <dplyr/Result/GroupedCallProxy.h>

namespace dplyr {

template <typename Data, typename Subsets>
class GroupedCallReducer : public CallbackProcessor< GroupedCallReducer<Data, Subsets> > {
public:
  GroupedCallReducer(Rcpp::Call call, const Subsets& subsets, const Environment& env, const SymbolString& name_) :
    proxy(call, subsets, env),
    name(name_)
  {
  }

  virtual ~GroupedCallReducer() {};

  inline SEXP process_chunk(const SlicingIndex& indices) {
    return proxy.get(indices);
  }

  const SymbolString& get_name() const {
    return name;
  }

private:
  GroupedCallProxy<Data, Subsets> proxy;
  const SymbolString name;
};

} // namespace dplyr

#endif
