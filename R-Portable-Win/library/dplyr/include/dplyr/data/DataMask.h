#ifndef dplyr_DataMask_H
#define dplyr_DataMask_H

#include <tools/SymbolMap.h>
#include <tools/Quosure.h>

#include <dplyr/data/GroupedDataFrame.h>
#include <dplyr/data/RowwiseDataFrame.h>
#include <dplyr/data/NaturalDataFrame.h>

#include <dplyr/visitors/subset/column_subset.h>

#include <boost/shared_ptr.hpp>
#include <boost/weak_ptr.hpp>

#include <dplyr/symbols.h>

SEXP eval_callback(void* data_);

namespace dplyr {

template <class SlicedTibble> class DataMask;
template <class SlicedTibble> class DataMaskProxy;
template <class SlicedTibble> class DataMaskWeakProxy;

// Manages a single binding, used by the DataMask classes below
template <typename SlicedTibble>
struct ColumnBinding {
private:
  typedef typename SlicedTibble::slicing_index Index;

  // is this a summary binding, i.e. does it come from summarise
  bool summary;

  // symbol of the binding
  SEXP symbol;

  // data. it is own either by the original data frame or by the
  // accumulator, so no need for additional protection here
  SEXP data;

public:

  ColumnBinding(bool summary_, SEXP symbol_, SEXP data_) :
    summary(summary_),
    symbol(symbol_),
    data(data_)
  {}

  // the active binding function calls eventually calls DataMask<>::materialize
  // which calls this method
  inline SEXP get(
    const Index& indices,
    SEXP mask_resolved)
  {
    return materialize(indices, mask_resolved);
  }

  inline void clear(SEXP mask_resolved) {
    Rf_defineVar(symbol, R_UnboundValue, mask_resolved);
  }

  // summary accessor
  bool is_summary() const {
    return summary;
  }

  // data accessor
  inline SEXP get_data() const {
    return data;
  }

  void rm() {
    data = R_NilValue;
  }

  bool is_null() const {
    return data == R_NilValue;
  }

  // update the resolved binding in mask_resolved withe the given indices
  // DataMask<> only calls this on previously materialized bindings
  // this is only used for its side effect of storing the result
  // in the right environment
  inline void update_indices(
    const Index& indices,
    SEXP mask_resolved)
  {
    materialize(indices, mask_resolved);
  }

  // setup the active binding with a function made by dplyr:::.make_active_binding_fun
  //
  // .make_active_binding_fun holds the position and a pointer to the DataMask
  inline void install(
    SEXP mask_active,
    SEXP mask_resolved,
    int pos,
    boost::shared_ptr< DataMaskProxy<SlicedTibble> >& data_mask_proxy
  ) {
    static Rcpp::Function make_active_binding_fun(
      ".make_active_binding_fun",
      Rcpp::Environment::namespace_env("dplyr")
    );

    // external pointer to the weak proxy of the data mask
    // eventually this calls back to the reak DataMask
    Rcpp::XPtr< DataMaskWeakProxy<SlicedTibble> > weak_proxy(
      new DataMaskWeakProxy<SlicedTibble>(data_mask_proxy)
    );

    Rcpp::Shield<SEXP> fun(make_active_binding_fun(pos, weak_proxy));

    R_MakeActiveBinding(
      // the name of the binding
      symbol,

      // the function
      fun,

      // where to set it up as an active binding
      mask_active
    );
  }

  // nothing to do here, this is only relevant for ColumnBinding<NaturalDataFrame>
  inline void update(SEXP mask_active, SEXP mask_resolved) {}

  // remove the binding in the mask_active environment
  // so that standard evaluation does not find it
  //
  // this is a fairly expensive callback to R, but it only happens
  // when we use the syntax <column> = NULL
  inline void detach(SEXP mask_active, SEXP mask_resolved) {
    Rcpp::Language("rm", symbol, Rcpp::_["envir"] = mask_active).eval(R_BaseEnv);
  }

private:

  // materialize the subset of data using column_subset
  // and store the result in the given environment
  inline SEXP materialize(
    const typename SlicedTibble::slicing_index& indices,
    SEXP mask_resolved)
  {
    SEXP frame = ENCLOS(ENCLOS(mask_resolved));

    // materialize
    Rcpp::Shield<SEXP> value(summary ?
                             column_subset(data, Index(indices.group()), frame) :
                             column_subset(data, indices, frame)
                            );
    MARK_NOT_MUTABLE(value);

    // store it in the mask_resolved environment
    Rf_defineVar(symbol, value, mask_resolved);

    return value;
  }

};

// special case for NaturalDataFrame because there is no need
// for active bindings in this case
//
// - if this is a summary, it is length 1 and can be returned as is
// - otherwise, it can also be returned as is because the
//   NaturalDataFrame::slicing_index always want the entire column
template <>
struct ColumnBinding<NaturalDataFrame> {
public:
  ColumnBinding(bool summary_, SEXP symbol_, SEXP data_) :
    summary(summary_),
    symbol(symbol_),
    data(data_)
  {}

  // nothing to do here, this is never actually used
  inline SEXP get(
    const NaturalDataFrame::slicing_index& indices,
    SEXP mask_resolved)
  {
    return data;
  }

  inline void clear(SEXP mask_resolved) {}

  bool is_summary() const {
    return summary;
  }

  inline SEXP get_data() const {
    return data;
  }

  void rm() {
    data = R_NilValue;
  }

  bool is_null() const {
    return data == R_NilValue;
  }

  // never used
  inline void update_indices(
    const NaturalDataFrame::slicing_index& /* indices */,
    SEXP /* env */)
  {}

  // TODO: when .data knows how to look ancestry, this should use mask_resolved instead
  //
  // it does not really install an active binding because there is no need for that
  inline void install(
    SEXP mask_active,
    SEXP mask_resolved,
    int /* pos */,
    boost::shared_ptr< DataMaskProxy<NaturalDataFrame> >& /* data_mask_proxy */)
  {
    Rf_defineVar(symbol, data, mask_active);
  }

  // update the (not so active) binding
  // this is used by cases like
  // mutate( x = fun(x) )
  inline void update(SEXP mask_active, SEXP mask_resolved) {
    Rf_defineVar(symbol, data, mask_active);
  }

  // remove the binding in the mask_active environment
  // so that standard evaluation does not find it
  inline void detach(SEXP mask_active, SEXP mask_resolved) {
    Rcpp::Language("rm", symbol, Rcpp::_["envir"] = mask_active).eval();
  }

private:

  bool summary;
  SEXP symbol;
  SEXP data;
};

// base class for instantiations of the DataMaskWeakProxy<> template
// the base class is used when called from the active binding in R
class DataMaskWeakProxyBase {
public:
  DataMaskWeakProxyBase() {
    LOG_VERBOSE;
  }
  virtual ~DataMaskWeakProxyBase() {
    LOG_VERBOSE;
  }

  virtual SEXP materialize(int idx) = 0;
};

// This holds a pointer to a real DataMask<>
//
// A DataMaskProxy<> is only used in a shared_ptr<DataMaskProxy<>>
// that is held by the DataMask<>
//
// This is needed because weak_ptr needs a shared_ptr
template <typename SlicedTibble>
class DataMaskProxy {
private:
  DataMask<SlicedTibble>* real;

public:
  DataMaskProxy(DataMask<SlicedTibble>* real_) : real(real_) {}

  SEXP materialize(int idx) {
    return real->materialize(idx);
  }
};

// This holds a weak_ptr to a DataMaskProxy<SlicedTibble> that ultimately
// calls back to the DataMask if it is still alive
template <typename SlicedTibble>
class DataMaskWeakProxy : public DataMaskWeakProxyBase {
private:
  boost::weak_ptr< DataMaskProxy<SlicedTibble> > real;

public:
  DataMaskWeakProxy(boost::shared_ptr< DataMaskProxy<SlicedTibble> > real_) :
    real(real_)
  {}

  virtual SEXP materialize(int idx) {
    int nprot = 0;
    SEXP res = R_NilValue;
    {
      boost::shared_ptr< DataMaskProxy<SlicedTibble> > lock(real.lock());
      if (lock) {
        res = PROTECT(lock.get()->materialize(idx));
        ++nprot;
      }
    }
    if (nprot == 0) {
      Rcpp::warning("Hybrid callback proxy out of scope");
    }

    UNPROTECT(nprot);
    return res;
  }
};

// typical use
//
// // a tibble (grouped, rowwise, or natural)
// SlicedTibble data(...) ;
// DataMask<SlicedTibble> mask(data);
//
// if using hybrid evaluation, we only need to check for existence of variables
// in the map with mask.maybe_get_subset_binding(SymbolString)
// This returns a ColumnBinding<SlicedTibble>
//
// if using standard evaluation, first the data_mask must be rechain()
// so that it's top environment has the env as a parent
//
// data_mask.rechain(SEXP env) ;
//
// this effectively sets up the R data mask, so that we can evaluate r expressions
// so for each group:
//
// data_mask.update(indices)
//
// this keeps a track of the current indices
// - for bindings that have not been resolved before, nothing needs to happen
//
// - for bindings that were previously resolved (as tracked by the
//   materialized vector) they are re-materialized pro-actively
//   in the resolved environment
template <class SlicedTibble>
class DataMask {
  typedef typename SlicedTibble::slicing_index slicing_index;

private:
  // data for the unwind-protect callback
  struct MaskData {
    SEXP expr;
    SEXP mask;
    SEXP env;
  };

public:

  // constructor
  // - fills the symbol map quickly (no hashing), assuming
  //   the names are all different
  // - fills the column_bindings vector
  //
  // - delays setting up the environment until needed
  DataMask(const SlicedTibble& gdf) :
    column_bindings(),
    symbol_map(gdf.data()),
    active_bindings_ready(false),
    proxy(new DataMaskProxy<SlicedTibble>(this))
  {
    const Rcpp::DataFrame& data = gdf.data();
    Rcpp::Shield<SEXP> names(Rf_getAttrib(data, symbols::names));
    int n = data.size();
    LOG_INFO << "processing " << n << " vars: " << names;

    // install the column_bindings without lookups in symbol_map
    // i.e. not using input_column
    for (int i = 0; i < n; i++) {
      column_bindings.push_back(
        ColumnBinding<SlicedTibble>(
          false, SymbolString(STRING_ELT(names, i)).get_symbol(),
          data[i]
        )
      );
    }

    previous_group_size = get_context_env()["..group_size"];
    previous_group_number = get_context_env()["..group_number"];
  }

  ~DataMask() {
    get_context_env()["..group_size"] = previous_group_size;
    get_context_env()["..group_number"] = previous_group_number;
    if (active_bindings_ready) {
      clear_resolved();
    }
  }

  // returns a pointer to the ColumnBinding if it exists
  // this is mostly used by the hybrid evaluation
  const ColumnBinding<SlicedTibble>*
  maybe_get_subset_binding(const SymbolString& symbol) const {
    int pos = symbol_map.find(symbol);
    if (pos >= 0 && !column_bindings[pos].is_null()) {
      return &column_bindings[pos];
    } else {
      return 0;
    }
  }

  const ColumnBinding<SlicedTibble>*
  get_subset_binding(int position) const {
    const ColumnBinding<SlicedTibble>& res = column_bindings[position];
    if (res.is_null()) {
      return 0;
    }
    return &res;
  }

  // remove this variable from the environments
  void rm(const SymbolString& symbol) {
    int idx = symbol_map.find(symbol);
    if (idx < 0)
      return;

    if (active_bindings_ready) {
      column_bindings[idx].detach(mask_active, mask_resolved);
    }

    // so that hybrid evaluation does not find it
    // see maybe_get_subset_binding above
    column_bindings[idx].rm();
  }

  // add a new binding, used by mutate
  void input_column(const SymbolString& symbol, SEXP x) {
    input_impl(symbol, false, x);
  }

  // add a new summarised variable, used by summarise
  void input_summarised(const SymbolString& symbol, SEXP x) {
    input_impl(symbol, true, x);
  }

  // the number of bindings
  int size() const {
    return column_bindings.size();
  }

  // no need to call this when treating the expression with hybrid evaluation
  // this is why the setup if the environments is lazy,
  // as we might not need them at all
  void setup() {
    if (!active_bindings_ready) {
      Rcpp::Shelter<SEXP> shelter;

      // the active bindings have not been used at all
      // so setup the environments ...
      mask_active = shelter(child_env(R_EmptyEnv));
      mask_resolved = shelter(child_env(mask_active));

      // ... and install the bindings
      for (size_t i = 0; i < column_bindings.size(); i++) {
        column_bindings[i].install(mask_active, mask_resolved, i, proxy);
      }

      // setup the data mask with
      //
      // bottom    : the environment with the "resolved" bindings,
      //             this is initially empty but gets filled
      //             as soon as the active binding is resolved
      //
      // top       : the environment containing active bindings.
      //
      // data_mask : where .data etc ... are installed
      data_mask = shelter(rlang::new_data_mask(mask_resolved, mask_active));

      // install the pronoun
      Rf_defineVar(symbols::dot_data, shelter(rlang::as_data_pronoun(data_mask)), data_mask);

      active_bindings_ready = true;
    } else {
      clear_resolved();
    }
  }

  SEXP get_data_mask() const {
    return data_mask;
  }


  // get ready to evaluate an R expression for a given group
  // as identified by the indices
  void update(const slicing_index& indices) {
    // hold the current indices, as they might be needed by the active bindings
    set_current_indices(indices);

    // re-materialize the bindings that we know we need
    // because they have been used by previous groups when evaluating the same
    // expression
    for (size_t i = 0; i < materialized.size(); i++) {
      column_bindings[materialized[i]].update_indices(indices, mask_resolved);
    }
  }

  // called from the active binding, see utils-bindings.(R|cpp)
  //
  // the bindings are installed in the mask_bindings environment
  // with this R function:
  //
  // .make_active_binding_fun <- function(index, mask_proxy_xp){
  //   function() {
  //     materialize_binding(index, mask_proxy_xp)
  //   }
  // }
  //
  // each binding is instaled only once, the function holds:
  // - index:          the position in the column_bindings vector
  // - mask_proxy_xp : an external pointer to (a proxy to) this DataMask
  //
  //  materialize_binding is defined in utils-bindings.cpp as:
  //
  // SEXP materialize_binding(
  //   int idx,
  //   XPtr<DataMaskWeakProxyBase> mask_proxy_xp)
  // {
  //   return mask_proxy_xp->materialize(idx);
  // }
  virtual SEXP materialize(int idx) {
    // materialize the subset (or just fetch it on the Natural case)
    //
    // the materialized result is stored in
    // the mask_resolved environment,
    // so we don't need to further protect `res`
    SEXP res = column_bindings[idx].get(
                 get_current_indices(), mask_resolved
               );

    // remember to pro-actievely materialize this binding on the next group
    materialized.push_back(idx);

    return res;
  }

  SEXP eval(const Quosure& quo, const slicing_index& indices) {
    // update the bindings
    update(indices);

    // update the data context variables, these are used by n(), ...
    get_context_env()["..group_size"] = indices.size();
    get_context_env()["..group_number"] = indices.group() + 1;

#if (R_VERSION < R_Version(3, 5, 0))
    Rcpp::Shield<SEXP> call_quote(Rf_lang2(fns::quote, quo));
    Rcpp::Shield<SEXP> call_eval_tidy(Rf_lang3(rlang_eval_tidy(), quo, data_mask));

    return Rcpp::Rcpp_fast_eval(call_eval_tidy, R_BaseEnv);
#else

    // TODO: forward the caller env of dplyr verbs to `eval_tidy()`
    MaskData data = { quo, data_mask, R_BaseEnv };

    return Rcpp::unwindProtect(&eval_callback, (void*) &data);
#endif
  }

private:
  // forbid copy construction of this class
  DataMask(const DataMask&);
  DataMask();

  // the bindings managed by this data mask
  std::vector< ColumnBinding<SlicedTibble> > column_bindings ;

  // indices of the bdings that have been materialized
  std::vector<int> materialized ;

  // symbol map, used to retrieve a binding from its name
  SymbolMap symbol_map;

  // The 3 environments of the data mask
  Rcpp::Environment mask_active;  // where the active bindings live
  Rcpp::Environment mask_resolved; // where the resolved active bindings live
  Rcpp::Environment data_mask; // actual data mask, contains the .data pronoun

  // are the active bindings ready ?
  bool active_bindings_ready;

  // The current indices
  const slicing_index* current_indices;

  // previous values for group_number and group_size
  Rcpp::RObject previous_group_size;
  Rcpp::RObject previous_group_number;

  boost::shared_ptr< DataMaskProxy<SlicedTibble> > proxy;

  void set_current_indices(const slicing_index& indices) {
    current_indices = &indices;
  }

  const slicing_index& get_current_indices() {
    return *current_indices;
  }

  // input a new binding, from mutate or summarise
  void input_impl(const SymbolString& symbol, bool summarised, SEXP x) {
    // lookup in the symbol map for the position and whether it is a new binding
    SymbolMapIndex index = symbol_map.insert(symbol);

    ColumnBinding<SlicedTibble> binding(summarised, symbol.get_symbol(), x);

    if (index.origin == NEW) {
      // when this is a new variable, install the active binding
      // but only if the bindings have already been installed
      // otherwise, nothing needs to be done
      if (active_bindings_ready) {
        binding.install(mask_active, mask_resolved, index.pos, proxy);
      }

      // push the new binding at the end of the vector
      column_bindings.push_back(binding);
    } else {
      // otherwise, update it
      if (active_bindings_ready) {
        binding.update(mask_active, mask_resolved);
      }

      column_bindings[index.pos] = binding;

    }
  }

  Rcpp::Environment& get_context_env() const {
    static Rcpp::Environment context_env(
      Rcpp::Environment::namespace_env("dplyr")["context_env"]
    );
    return context_env;
  }

  void clear_resolved() {
    // remove the materialized bindings from the mask_resolved environment
    for (size_t i = 0; i < materialized.size(); i++) {
      column_bindings[materialized[i]].clear(mask_resolved);
    }

    // forget about which indices are materialized
    materialized.clear();
  }

  static SEXP eval_callback(void* data_) {
    MaskData* data = (MaskData*) data_;
    return rlang::eval_tidy(data->expr, data->mask, data->env);
  }

  static SEXP rlang_eval_tidy() {
    static Rcpp::Language call("::", symbols::rlang, symbols::eval_tidy);
    return call;
  }

};

}
#endif
