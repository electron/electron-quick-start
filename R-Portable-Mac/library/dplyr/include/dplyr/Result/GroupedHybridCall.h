#ifndef dplyr_GroupedHybridCall_H
#define dplyr_GroupedHybridCall_H

#include <boost/scoped_ptr.hpp>

#include <tools/Call.h>

#include <dplyr/Result/Result.h>

#include <bindrcpp.h>

namespace dplyr {

inline static
SEXP rlang_object(const char* name) {
  static Environment rlang = Rcpp::Environment::namespace_env("rlang");
  return rlang[name];
}


class IHybridCallback {
protected:
  virtual ~IHybridCallback() {}

public:
  virtual SEXP get_subset(const SymbolString& name) const = 0;
};


class GroupedHybridEnv {
public:
  GroupedHybridEnv(const CharacterVector& names_, const Environment& env_, const IHybridCallback* callback_) :
    names(names_), env(env_), callback(callback_), has_overscope(false)
  {
    LOG_VERBOSE;
  }

  ~GroupedHybridEnv() {
    if (has_overscope) {
      static Function overscope_clean = rlang_object("overscope_clean");
      overscope_clean(overscope);
    }
  }

public:
  const Environment& get_overscope() const {
    provide_overscope();
    return overscope;
  }

private:
  void provide_overscope() const {
    if (has_overscope)
      return;

    // Environment::new_child() performs an R callback, creating the environment
    // in R should be slightly faster
    Environment active_env =
      create_env_string(
        names, &GroupedHybridEnv::hybrid_get_callback,
        PAYLOAD(const_cast<void*>(reinterpret_cast<const void*>(callback))), env);

    // If bindr (via bindrcpp) supported the creation of a child environment, we could save the
    // call to Rcpp_eval() triggered by active_env.new_child()
    Environment bottom = active_env.new_child(true);
    bottom[".data"] = rlang_new_data_source(active_env);

    // Install definitions for formula self-evaluation and unguarding
    Function new_overscope = rlang_object("new_overscope");
    overscope = new_overscope(bottom, active_env, env);

    has_overscope = true;
  }

  static List rlang_new_data_source(Environment env) {
    static Function as_dictionary = rlang_object("as_dictionary");
    return
      as_dictionary(
        env,
        _["lookup_msg"] = "Column `%s`: not found in data",
        _["read_only"] = true
      );
  }

  static SEXP hybrid_get_callback(const String& name, bindrcpp::PAYLOAD payload) {
    LOG_VERBOSE;
    IHybridCallback* callback_ = reinterpret_cast<IHybridCallback*>(payload.p);
    return callback_->get_subset(SymbolString(name));
  }

private:
  const CharacterVector names;
  const Environment env;
  const IHybridCallback* callback;

  mutable Environment overscope;
  mutable bool has_overscope;
};


class GroupedHybridCall {
public:
  GroupedHybridCall(const Call& call_, const ILazySubsets& subsets_, const Environment& env_) :
    original_call(call_), subsets(subsets_), env(env_)
  {
    LOG_VERBOSE;
  }

public:
  // FIXME: replace the search & replace logic with overscoping
  Call simplify(const SlicingIndex& indices) const {
    set_indices(indices);
    Call call = clone(original_call);
    while (simplified(call)) {}
    clear_indices();
    return call;
  }

private:
  bool simplified(Call& call) const {
    LOG_VERBOSE;
    // initial
    if (TYPEOF(call) == LANGSXP || TYPEOF(call) == SYMSXP) {
      boost::scoped_ptr<Result> res(get_handler(call, subsets, env));
      if (res) {
        // replace the call by the result of process
        call = res->process(get_indices());

        // no need to go any further, we simplified the top level
        return true;
      }
      if (TYPEOF(call) == LANGSXP)
        return replace(CDR(call));
    }
    return false;
  }

  bool replace(SEXP p) const {
    LOG_VERBOSE;
    SEXP obj = CAR(p);
    if (TYPEOF(obj) == LANGSXP) {
      boost::scoped_ptr<Result> res(get_handler(obj, subsets, env));
      if (res) {
        SETCAR(p, res->process(get_indices()));
        return true;
      }

      if (replace(CDR(obj))) return true;
    }

    if (TYPEOF(p) == LISTSXP) {
      return replace(CDR(p));
    }

    return false;
  }

  const SlicingIndex& get_indices() const {
    return *indices;
  }

  void set_indices(const SlicingIndex& indices_) const {
    indices = &indices_;
  }

  void clear_indices() const {
    indices = NULL;
  }

private:
  // Initialization
  const Call original_call;
  const ILazySubsets& subsets;
  const Environment env;

private:
  // State
  mutable const SlicingIndex* indices;
};


class GroupedHybridEval : public IHybridCallback {
public:
  GroupedHybridEval(const Call& call_, const ILazySubsets& subsets_, const Environment& env_) :
    indices(NULL), subsets(subsets_), env(env_),
    hybrid_env(subsets_.get_variable_names().get_vector(), env_, this),
    hybrid_call(call_, subsets_, env_)
  {
    LOG_VERBOSE;
  }

  const SlicingIndex& get_indices() const {
    return *indices;
  }

public: // IHybridCallback
  SEXP get_subset(const SymbolString& name) const {
    LOG_VERBOSE;
    return subsets.get(name, get_indices());
  }

public:
  SEXP eval(const SlicingIndex& indices_) {
    set_indices(indices_);
    SEXP ret = eval_with_indices();
    clear_indices();
    return ret;
  }

private:
  void set_indices(const SlicingIndex& indices_) {
    indices = &indices_;
  }

  void clear_indices() {
    indices = NULL;
  }

  SEXP eval_with_indices() {
    Call call = hybrid_call.simplify(get_indices());
    LOG_INFO << type2name(call);

    if (TYPEOF(call) == LANGSXP || TYPEOF(call) == SYMSXP) {
      LOG_VERBOSE << "performing evaluation in overscope";
      return Rcpp_eval(call, hybrid_env.get_overscope());
    }
    return call;
  }

private:
  const SlicingIndex* indices;
  const ILazySubsets& subsets;
  Environment env;
  const GroupedHybridEnv hybrid_env;
  const GroupedHybridCall hybrid_call;
};


} // namespace dplyr

#endif
