#ifndef dplyr_hybrid_expression_h
#define dplyr_hybrid_expression_h

#include <dplyr/hybrid/Column.h>
#include <tools/SymbolString.h>
#include <dplyr/data/DataMask.h>
#include <dplyr/symbols.h>
#include <dplyr/lifecycle.h>

namespace dplyr {
namespace hybrid {

enum hybrid_id {
  NOMATCH,

  IN, MAX, MEAN, MIN, SUM, CUME_DIST, DENSE_RANK, FIRST, GROUP_INDICES,
  LAG, LAST, LEAD, MIN_RANK, N, N_DISTINCT, NTH, NTILE,
  PERCENT_RANK, ROW_NUMBER, SD, VAR
};

struct hybrid_function {
  hybrid_function(SEXP name_, SEXP package_, hybrid_id id_) :
    name(name_), package(package_), id(id_)
  {}
  SEXP name;
  SEXP package;
  hybrid_id id;
};

dplyr_hash_map<SEXP, hybrid_function>& get_hybrid_inline_map();
dplyr_hash_map<SEXP, hybrid_function>& get_hybrid_named_map();

// When we do hybrid evaluation of fun(...) we need to make
// sure that fun is the function we want, and not masked
struct FindFunData {
  const SEXP symbol;
  const SEXP env;
  SEXP res;

  FindFunData(SEXP symbol_, SEXP env_) :
    symbol(symbol_),
    env(env_),
    res(R_NilValue)
  {}

  inline Rboolean findFun() {
    return R_ToplevelExec(protected_findFun, reinterpret_cast<void*>(this));
  }

  static void protected_findFun(void* data) {
    FindFunData* find_data = reinterpret_cast<FindFunData*>(data);
    find_data->protected_findFun();
  }

  inline void protected_findFun() {
    SEXP rho = env;

    while (rho != R_EmptyEnv) {
      SEXP vl = Rf_findVarInFrame3(rho, symbol, TRUE);

      if (vl != R_UnboundValue) {
        // a promise, we need to evaluate it to find out if it
        // is a function promise
        if (TYPEOF(vl) == PROMSXP) {
          PROTECT(vl);
          vl = Rf_eval(vl, rho);
          UNPROTECT(1);
        }

        // we found a function
        if (TYPEOF(vl) == CLOSXP || TYPEOF(vl) == BUILTINSXP || TYPEOF(vl) == SPECIALSXP) {
          res = vl;
          return;
        }

        // a missing, just let R evaluation work as we have no way to
        // assert if the missing argument would have evaluated to a function or data
        if (vl == R_MissingArg) {
          return;
        }
      }

      // go in the parent environment
      rho = ENCLOS(rho);
    }

    return;
  }
};

template <typename SlicedTibble>
class Expression {
private:
  SEXP expr;
  SEXP env;
  SEXP caller_env;

  SEXP func;
  SEXP package;
  bool valid;

  const DataMask<SlicedTibble>& data_mask;

  int n;
  std::vector<SEXP> values;
  std::vector<SEXP> tags;

  hybrid_id id;

  SEXP dot_alias;
  int colwise_position;

public:
  typedef std::pair<bool, SEXP> ArgPair;

  Expression(SEXP expr_, const DataMask<SlicedTibble>& data_mask_, SEXP env_, SEXP caller_env_) :
    expr(expr_),
    env(env_),
    caller_env(caller_env_),
    func(R_NilValue),
    package(R_NilValue),
    data_mask(data_mask_),
    n(0),
    id(NOMATCH),
    dot_alias(R_NilValue),
    colwise_position(-1)
  {
    // handle the case when the expression has been colwise spliced
    SEXP position_attr = Rf_getAttrib(expr, symbols::position);
    if (!Rf_isNull(position_attr)) {
      colwise_position = Rcpp::as<int>(position_attr);
    }

    // the function called, e.g. n, or dplyr::n
    SEXP head = CAR(expr);

    // when it's a inline_colwise_function, we use the formula attribute
    // to test for hybridability
    if (TYPEOF(head) == CLOSXP && Rf_inherits(head, "inline_colwise_function")) {
      dot_alias = CADR(expr);
      expr = CADR(Rf_getAttrib(head, symbols::formula));
      if (TYPEOF(expr) != LANGSXP) {
        return;
      }
      head = CAR(expr);
    }

    if (TYPEOF(head) == SYMSXP) {
      handle_symbol(head);
    } else if (TYPEOF(head) == CLOSXP || TYPEOF(head) == BUILTINSXP || TYPEOF(head) == SPECIALSXP) {
      handle_function(head);
    } else if (TYPEOF(head) == LANGSXP && Rf_length(head) == 3 && CAR(head) == symbols::double_colon && TYPEOF(CADR(head)) == SYMSXP && TYPEOF(CADDR(head)) == SYMSXP) {
      handle_explicit(head);
    }

    handle_arguments(expr);
  }

  // the number of arguments in the call
  inline int size() const {
    return n;
  }

  inline hybrid_id get_id() const {
    return id;
  }

  // expression or value for the ith argument
  inline SEXP value(int i) const {
    return values[i];
  }

  // is the i-th argument called `symbol`
  inline bool is_named(int i, SEXP symbol) const {
    return tags[i] == symbol;
  }

  // is the i-th argument unnamed
  inline bool is_unnamed(int i) const {
    return Rf_isNull(tags[i]);
  }

  // is the ith argument a logical scalar
  inline bool is_scalar_logical(int i, bool& test) const {
    SEXP val = values[i];
    bool res = TYPEOF(val) == LGLSXP && Rf_length(val) == 1 ;
    if (res) {
      test = LOGICAL(val)[0];
    }
    return res;
  }

  // is the i-th argument a scalar int
  inline bool is_scalar_int(int i, int& out) const {
    SEXP val = values[i];
    bool unary_minus = false;

    // unary minus
    if (TYPEOF(val) == LANGSXP && Rf_length(val) == 2 && CAR(val) == symbols::op_minus) {
      val = CADR(val);
      unary_minus = true;
    }

    // symbol
    if (TYPEOF(val) == SYMSXP) {
      // reject if it's a column
      Column col;
      if (is_column(i, col)) {
        return false;
      }

      // keep trying if this the symbol is a binding in the .env
      val = Rf_findVarInFrame3(env, val, FALSE);
      if (val == R_UnboundValue) {
        return false;
      }
    }

    switch (TYPEOF(val)) {
    case INTSXP:
    {
      if (Rf_length(val) != 1) return false;
      int value = INTEGER(val)[0];
      if (Rcpp::IntegerVector::is_na(value)) {
        return false;
      }
      out = unary_minus ? -value : value;
      return true;
    }
    case REALSXP:
    {
      if (Rf_length(val) != 1) return false;
      int value = Rcpp::internal::r_coerce<REALSXP, INTSXP>(REAL(val)[0]);
      if (Rcpp::IntegerVector::is_na(value)) {
        return false;
      }
      out = unary_minus ? -value : value;
      return true;
    }
    default:
      break;
    }
    return false;
  }

  // is the ith argument a column
  inline bool is_column(int i, Column& column) const {
    LOG_VERBOSE << "is_column(" << i << ")";

    SEXP val = PROTECT(values[i]);
    int nprot = 1;
    // when val is a quosure, grab its expression
    //
    // this allows for things like mean(!!quo(x)) or mean(!!quo(!!sym("x")))
    // to go through hybrid evaluation
    if (rlang::is_quosure(val)) {
      LOG_VERBOSE << "is quosure";
      val = PROTECT(rlang::quo_get_expr(val));
      nprot++;
    }

    LOG_VERBOSE << "is_column_impl(false)";
    bool result = is_column_impl(i, val, column, false) || is_desc_column_impl(i, val, column);
    UNPROTECT(nprot);
    return result;
  }

  inline SEXP get_fun() const {
    return func;
  }

  inline SEXP get_package() const {
    return package;
  }

private:
  SEXP resolve_rlang_lambda(SEXP f) {
    if (Rf_inherits(f, "rlang_lambda_function") && Rf_length(expr) == 2 && TYPEOF(CADR(expr)) == SYMSXP) {
      dot_alias =  CADR(expr);

      // look again:
      SEXP body = BODY(f);

      if (TYPEOF(body) == BCODESXP) {
        body = VECTOR_ELT(BODY_EXPR(body), 0);
      }

      if (TYPEOF(body) == LANGSXP) {
        SEXP head = CAR(body);

        if (TYPEOF(head) == SYMSXP) {
          // the body's car of the lambda is a symbol
          // need to resolve it
          FindFunData finder_lambda(head, CLOENV(f));
          if (finder_lambda.findFun()) {
            f = finder_lambda.res;
            expr = body;
          }
        } else if (TYPEOF(head) == CLOSXP || TYPEOF(head) == BUILTINSXP || TYPEOF(head) == SPECIALSXP) {
          // already a function, just use that
          f = head;
        }
      }
    }
    return f;
  }

  inline bool is_desc_column_impl(int i, SEXP val, Column& column) const {
    return TYPEOF(val) == LANGSXP &&
           Rf_length(val) == 1 &&
           CAR(val) == symbols::desc &&
           is_column_impl(i, CADR(val), column, true)
           ;
  }


  inline bool is_column_impl(int i, SEXP val, Column& column, bool desc) const {
    if (TYPEOF(val) == SYMSXP) {
      return test_is_column(i, val, column, desc);
    }

    if (TYPEOF(val) == LANGSXP && Rf_length(val) == 3 && CADR(val) == symbols::dot_data) {
      SEXP fun = CAR(val);
      SEXP rhs = CADDR(val);

      if (fun == R_DollarSymbol) {
        // .data$x
        if (TYPEOF(rhs) == SYMSXP) return test_is_column(i, rhs, column, desc);

        // .data$"x"
        if (TYPEOF(rhs) == STRSXP && Rf_length(rhs) == 1) return test_is_column(i, Rf_installChar(STRING_ELT(rhs, 0)), column, desc);
      } else if (fun == R_Bracket2Symbol) {
        // .data[["x"]]
        if (TYPEOF(rhs) == STRSXP && Rf_length(rhs) == 1) return test_is_column(i, Rf_installChar(STRING_ELT(rhs, 0)), column, desc);
      }
    }
    return false;
  }

  inline bool test_is_column(int i, Rcpp::Symbol s, Column& column, bool desc) const {
    bool is_alias = !Rf_isNull(dot_alias) && (s == symbols::dot || s == symbols::dot_x);
    SEXP data;
    if (i == 0 && colwise_position > 0 && is_alias) {
      // we know the position for sure because this has been colwise spliced
      const ColumnBinding<SlicedTibble>* subset = data_mask.get_subset_binding(colwise_position - 1);
      if (subset->is_summary()) {
        return false;
      }
      data = subset->get_data();
    } else {
      // otherwise use the hashmap
      if (is_alias) {
        s = dot_alias;
      }
      SymbolString symbol(s);

      // does the data mask have this symbol, and if so is it a real column (not a summarised)
      const ColumnBinding<SlicedTibble>* subset = data_mask.maybe_get_subset_binding(symbol);
      if (!subset || subset->is_summary()) {
        return false;
      }
      data = subset->get_data() ;
    }

    column.data = data;
    column.is_desc = desc;
    return true;
  }

  inline void handle_symbol_match(FindFunData& finder) {
    // The function resolves to finder.res
    // If this happens to be a rlang_lambda_function we need to look further
    SEXP f = resolve_rlang_lambda(finder.res);

    dplyr_hash_map<SEXP, hybrid_function>& map = get_hybrid_inline_map();
    dplyr_hash_map<SEXP, hybrid_function>::const_iterator it = map.find(f);
    if (it != map.end()) {
      func = it->second.name;
      package = it->second.package;
      id = it->second.id;
    }
  }

  inline void handle_symbol_workaround(SEXP head) {
    dplyr_hash_map<SEXP, hybrid_function>& named_map = get_hybrid_named_map();
    dplyr_hash_map<SEXP, hybrid_function>::const_iterator it = named_map.find(head);

    if (it != named_map.end()) {
      // here when the name of the function is known by hybrid but the
      // function by that name was not found
      //
      // that means the relevant package was not loaded
      //
      // in 0.8.0 we warn and proceed anyway, to ease the transition from older versions
      func = head;
      package = it->second.package;
      id = it->second.id;

      std::stringstream stream;
      stream << "Calling `"
             << CHAR(PRINTNAME(head))
             << "()` without importing or prefixing it is deprecated, use `"
             << CHAR(PRINTNAME(package))
             << "::"
             << CHAR(PRINTNAME(head))
             << "()`.";

      lifecycle::signal_soft_deprecated(stream.str(), caller_env);
    }
  }

  inline void handle_symbol(SEXP head) {
    // the head is a symbol, so we lookup what it resolves to
    // then match that against the hash map
    FindFunData finder(head, env);
    if (finder.findFun()) {
      if (Rf_isNull(finder.res)) {
        // no match was found, but
        // handle n(), row_number(), group_indices() in case dplyr is not imported
        // this is a workaround to smooth the transition to 0.8.0
        handle_symbol_workaround(head);
      } else {
        handle_symbol_match(finder);
      }
    }
  }

  inline void handle_function(SEXP head) {
    // head is an inlined function. if it is an rlang_lambda_function, we need to look inside
    SEXP f = resolve_rlang_lambda(head);

    dplyr_hash_map<SEXP, hybrid_function>::const_iterator it = get_hybrid_inline_map().find(f);
    if (it != get_hybrid_inline_map().end()) {
      func = it->second.name;
      package = it->second.package;
      id = it->second.id;
    }
  }

  inline void handle_explicit(SEXP head) {
    // a call of the `::` function, so we do not need lookup
    func = CADDR(head);
    package = CADR(head);

    dplyr_hash_map<SEXP, hybrid_function>::const_iterator it = get_hybrid_named_map().find(func);
    if (it != get_hybrid_named_map().end() && it->second.package == package) {
      id = it->second.id;
    }
  }

  inline void handle_arguments(SEXP expr) {
    for (SEXP p = CDR(expr); !Rf_isNull(p); p = CDR(p)) {
      n++;
      values.push_back(CAR(p));
      tags.push_back(TAG(p));
    }
  }

};

}
}

#endif
