#ifndef dplyr_Collecter_H
#define dplyr_Collecter_H

#include <tools/all_na.h>
#include <tools/hash.h>

#include <dplyr/registration.h>
#include <dplyr/vector_class.h>

namespace dplyr {

static inline bool inherits_from(SEXP x, const std::set<std::string>& classes) {
  std::vector<std::string> x_classes, inherited_classes;
  if (!OBJECT(x)) {
    return false;
  }
  x_classes = Rcpp::as< std::vector<std::string> >(Rf_getAttrib(x, R_ClassSymbol));
  std::sort(x_classes.begin(), x_classes.end());
  std::set_intersection(x_classes.begin(), x_classes.end(),
                        classes.begin(), classes.end(),
                        std::back_inserter(inherited_classes));
  return !inherited_classes.empty();
}

static bool is_class_known(SEXP x) {
  static std::set<std::string> known_classes;
  if (known_classes.empty()) {
    known_classes.insert("hms");
    known_classes.insert("difftime");
    known_classes.insert("POSIXct");
    known_classes.insert("factor");
    known_classes.insert("Date");
    known_classes.insert("AsIs");
    known_classes.insert("integer64");
    known_classes.insert("table");
  }
  if (OBJECT(x)) {
    return inherits_from(x, known_classes);
  } else {
    return true;
  }
}

static inline void warn_loss_attr(SEXP x) {
  /* Attributes are lost with unknown classes */
  if (!is_class_known(x)) {
    SEXP classes = Rf_getAttrib(x, R_ClassSymbol);
    Rf_warning("Vectorizing '%s' elements may not preserve their attributes",
               CHAR(STRING_ELT(classes, 0)));
  }
}

static inline bool all_logical_na(SEXP x, SEXPTYPE xtype) {
  return LGLSXP == xtype && all_na(x);
}

class Collecter {
public:
  virtual ~Collecter() {};
  virtual void collect(const SlicingIndex& index, SEXP v, int offset = 0) = 0;
  virtual SEXP get() = 0;
  virtual bool compatible(SEXP) = 0;
  virtual bool can_promote(SEXP) const = 0;
  virtual bool is_factor_collecter() const {
    return false;
  }
  virtual bool is_logical_all_na() const {
    return false;
  }
  virtual std::string describe() const = 0;
};

template <int RTYPE>
class Collecter_Impl : public Collecter {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  Collecter_Impl(int n_): data(n_, Rcpp::traits::get_na<RTYPE>()) {}

  void collect(const SlicingIndex& index, SEXP v, int offset = 0) {
    if (all_logical_na(v, TYPEOF(v))) {
      collect_logicalNA(index);
    } else {
      collect_sexp(index, v, offset);
    }
  }

  inline SEXP get() {
    return data;
  }

  inline bool compatible(SEXP x) {
    return RTYPE == TYPEOF(x) || all_logical_na(x, TYPEOF(x));
  }

  bool can_promote(SEXP) const {
    return false;
  }

  std::string describe() const {
    return vector_class<RTYPE>();
  }

  bool is_logical_all_na() const {
    return all_logical_na(data, RTYPE);
  }

protected:
  Vector<RTYPE> data;

private:
  void collect_logicalNA(const SlicingIndex& index) {
    for (int i = 0; i < index.size(); i++) {
      data[index[i]] = Rcpp::traits::get_na<RTYPE>();
    }
  }

  void collect_sexp(const SlicingIndex& index, SEXP v, int offset = 0) {
    warn_loss_attr(v);
    Vector<RTYPE> source(v);
    STORAGE* source_ptr = Rcpp::internal::r_vector_start<RTYPE>(source);
    source_ptr = source_ptr + offset;
    for (int i = 0; i < index.size(); i++) {
      data[index[i]] = source_ptr[i];
    }
  }

};

template <>
class Collecter_Impl<REALSXP> : public Collecter {
public:
  Collecter_Impl(int n_): data(n_, NA_REAL) {}

  void collect(const SlicingIndex& index, SEXP v, int offset = 0) {
    warn_loss_attr(v);
    NumericVector source(v);
    double* source_ptr = source.begin() + offset;
    for (int i = 0; i < index.size(); i++) {
      data[index[i]] = source_ptr[i];
    }
  }

  inline SEXP get() {
    return data;
  }

  inline bool compatible(SEXP x) {
    int RTYPE = TYPEOF(x);
    return (RTYPE == REALSXP && !Rf_inherits(x, "POSIXct") && !Rf_inherits(x, "Date")) ||
           (RTYPE == INTSXP && !Rf_inherits(x, "factor")) ||
           all_logical_na(x, RTYPE);
  }

  bool can_promote(SEXP) const {
    return false;
  }

  std::string describe() const {
    return "numeric";
  }

protected:
  NumericVector data;

};

template <>
class Collecter_Impl<STRSXP> : public Collecter {
public:
  Collecter_Impl(int n_): data(n_, NA_STRING) {}

  void collect(const SlicingIndex& index, SEXP v, int offset = 0) {
    warn_loss_attr(v);
    if (TYPEOF(v) == STRSXP) {
      collect_strings(index, v, offset);
    } else if (Rf_inherits(v, "factor")) {
      collect_factor(index, v, offset);
    } else if (all_logical_na(v, TYPEOF(v))) {
      collect_logicalNA(index, v);
    } else {
      CharacterVector vec(v);
      collect_strings(index, vec, offset);
    }
  }

  inline SEXP get() {
    return data;
  }

  inline bool compatible(SEXP x) {
    return (STRSXP == TYPEOF(x)) || Rf_inherits(x, "factor") || all_logical_na(x, TYPEOF(x));
  }

  bool can_promote(SEXP) const {
    return false;
  }

  std::string describe() const {
    return "character";
  }

protected:
  CharacterVector data;

private:

  void collect_logicalNA(const SlicingIndex& index, LogicalVector) {
    int n = index.size();
    for (int i = 0; i < n; i++) {
      SET_STRING_ELT(data, index[i], NA_STRING);
    }
  }

  void collect_strings(const SlicingIndex& index, CharacterVector source,
                       int offset = 0) {
    SEXP* p_source = Rcpp::internal::r_vector_start<STRSXP>(source) + offset;
    int n = index.size();
    for (int i = 0; i < n; i++) {
      SET_STRING_ELT(data, index[i], p_source[i]);
    }
  }

  void collect_factor(const SlicingIndex& index, IntegerVector source,
                      int offset = 0) {
    CharacterVector levels = get_levels(source);
    Rf_warning("binding character and factor vector, coercing into character vector");
    for (int i = 0; i < index.size(); i++) {
      if (source[i] == NA_INTEGER) {
        data[index[i]] = NA_STRING;
      } else {
        data[index[i]] = levels[source[i + offset] - 1];
      }
    }
  }

};

template <>
class Collecter_Impl<INTSXP> : public Collecter {
public:
  Collecter_Impl(int n_): data(n_, NA_INTEGER) {}

  void collect(const SlicingIndex& index, SEXP v, int offset = 0) {
    warn_loss_attr(v);
    IntegerVector source(v);
    int* source_ptr = source.begin() + offset;
    for (int i = 0; i < index.size(); i++) {
      data[index[i]] = source_ptr[i];
    }
  }

  inline SEXP get() {
    return data;
  }

  inline bool compatible(SEXP x) {
    int RTYPE = TYPEOF(x);
    return ((INTSXP == RTYPE) && !Rf_inherits(x, "factor")) || all_logical_na(x, RTYPE);
  }

  bool can_promote(SEXP x) const {
    return TYPEOF(x) == REALSXP && !Rf_inherits(x, "POSIXct") && !Rf_inherits(x, "Date");
  }

  std::string describe() const {
    return "integer";
  }

protected:
  IntegerVector data;

};

template <int RTYPE>
class TypedCollecter : public Collecter_Impl<RTYPE> {
public:
  TypedCollecter(int n, SEXP types_) :
    Collecter_Impl<RTYPE>(n), types(types_) {}

  inline SEXP get() {
    Vector<RTYPE> data = Collecter_Impl<RTYPE>::data;
    set_class(data, types);
    return data;
  }

  inline bool compatible(SEXP x) {
    String type = STRING_ELT(types, 0);
    return Rf_inherits(x, type.get_cstring()) || all_logical_na(x, TYPEOF(x));
  }

  inline bool can_promote(SEXP) const {
    return false;
  }

  std::string describe() const {
    return collapse_utf8<STRSXP>(types);
  }

private:
  SEXP types;
};

class POSIXctCollecter : public Collecter_Impl<REALSXP> {
public:
  typedef Collecter_Impl<REALSXP> Parent;

  POSIXctCollecter(int n, SEXP tz_) :
    Parent(n), tz(tz_) {}

  void collect(const SlicingIndex& index, SEXP v, int offset = 0) {
    if (Rf_inherits(v, "POSIXct")) {
      Parent::collect(index, v, offset);
      update_tz(v);
    } else if (all_logical_na(v, TYPEOF(v))) {
      Parent::collect(index, v, offset);
    }
  }

  inline SEXP get() {
    set_class(data, get_time_classes());
    if (!tz.isNULL()) {
      Parent::data.attr("tzone") = tz;
    }
    return Parent::data;
  }

  inline bool compatible(SEXP x) {
    return Rf_inherits(x, "POSIXct") || all_logical_na(x, TYPEOF(x));
  }

  inline bool can_promote(SEXP) const {
    return false;
  }

  std::string describe() const {
    return collapse_utf8<STRSXP>(get_time_classes());
  }

private:
  void update_tz(SEXP v) {
    RObject v_tz(Rf_getAttrib(v, Rf_install("tzone")));
    // if the new tz is NULL, keep previous value
    if (v_tz.isNULL()) return;

    if (tz.isNULL()) {
      // if current tz is NULL, grab the new one
      tz = v_tz;
    } else {
      // none are NULL, so compare them
      // if they are equal, fine
      if (STRING_ELT(tz, 0) == STRING_ELT(v_tz, 0)) return;

      // otherwise, settle to UTC
      tz = wrap("UTC");
    }
  }

  RObject tz;
};

class DifftimeCollecter : public Collecter_Impl<REALSXP> {
public:
  typedef Collecter_Impl<REALSXP> Parent;

  DifftimeCollecter(int n, std::string units_, SEXP types_) :
    Parent(n), units(units_), types(types_) {}

  void collect(const SlicingIndex& index, SEXP v, int offset = 0) {
    if (Rf_inherits(v, "difftime")) {
      collect_difftime(index, v, offset);
    } else if (all_logical_na(v, TYPEOF(v))) {
      Parent::collect(index, v, offset);
    }
  }

  inline SEXP get() {
    set_class(Parent::data, types);
    Parent::data.attr("units") = wrap(units);
    return Parent::data;
  }

  inline bool compatible(SEXP x) {
    return Rf_inherits(x, "difftime") || all_logical_na(x, TYPEOF(x));
  }

  inline bool can_promote(SEXP) const {
    return false;
  }

  std::string describe() const {
    return collapse_utf8<STRSXP>(types);
  }

private:
  bool is_valid_difftime(RObject x) {
    return
      x.inherits("difftime") &&
      x.sexp_type() == REALSXP &&
      get_units_map().is_valid_difftime_unit(Rcpp::as<std::string>(x.attr("units")));
  }


  void collect_difftime(const SlicingIndex& index, RObject v, int offset = 0) {
    if (!is_valid_difftime(v)) {
      stop("Invalid difftime object");
    }
    std::string v_units = Rcpp::as<std::string>(v.attr("units"));
    if (!get_units_map().is_valid_difftime_unit(units)) {
      // if current unit is NULL, grab the new one
      units = v_units;
      // then collect the data:
      Parent::collect(index, v, offset);
    } else {
      // We had already defined the units.
      // Does the new vector have the same units?
      if (units == v_units) {
        Parent::collect(index, v, offset);
      } else {
        // If units are different convert the existing data and the new vector
        // to seconds (following the convention on
        // r-source/src/library/base/R/datetime.R)
        double factor_data = get_units_map().time_conversion_factor(units);
        if (factor_data != 1.0) {
          for (int i = 0; i < Parent::data.size(); i++) {
            Parent::data[i] = factor_data * Parent::data[i];
          }
        }
        units = "secs";
        double factor_v = get_units_map().time_conversion_factor(v_units);
        if (Rf_length(v) < index.size()) {
          stop("Wrong size of vector to collect");
        }
        for (int i = 0; i < index.size(); i++) {
          Parent::data[index[i]] = factor_v * (REAL(v)[i + offset]);
        }
      }
    }
  }

  class UnitsMap {
    typedef std::map<std::string, double> units_map;
    const units_map valid_units;

    static units_map create_valid_units() {
      units_map valid_units;
      double factor = 1;

      // Acceptable units based on r-source/src/library/base/R/datetime.R
      valid_units.insert(std::make_pair("secs", factor));
      factor *= 60;
      valid_units.insert(std::make_pair("mins", factor));
      factor *= 60;
      valid_units.insert(std::make_pair("hours", factor));
      factor *= 24;
      valid_units.insert(std::make_pair("days", factor));
      factor *= 7;
      valid_units.insert(std::make_pair("weeks", factor));
      return valid_units;
    }

  public:
    UnitsMap() : valid_units(create_valid_units()) {}

    bool is_valid_difftime_unit(const std::string& x_units) const {
      return (valid_units.find(x_units) != valid_units.end());
    }

    double time_conversion_factor(const std::string& v_units) const {
      units_map::const_iterator it = valid_units.find(v_units);
      if (it == valid_units.end()) {
        stop("Invalid difftime units (%s).", v_units.c_str());
      }

      return it->second;
    }
  };

  static const UnitsMap& get_units_map() {
    static UnitsMap map;
    return map;
  }

private:
  std::string units;
  SEXP types;

};


class FactorCollecter : public Collecter {
public:
  typedef dplyr_hash_map<SEXP, int> LevelsMap;

  FactorCollecter(int n, SEXP model_):
    data(n, IntegerVector::get_na()),
    model(model_),
    levels(get_levels(model_)),
    levels_map()
  {
    int nlevels = levels.size();
    for (int i = 0; i < nlevels; i++) levels_map[ levels[i] ] = i + 1;
  }

  bool is_factor_collecter() const {
    return true;
  }

  void collect(const SlicingIndex& index, SEXP v, int offset = 0) {
    if (offset != 0) stop("Nonzero offset ot supported by FactorCollecter");
    if (Rf_inherits(v, "factor") && has_same_levels_as(v)) {
      collect_factor(index, v);
    } else if (all_logical_na(v, TYPEOF(v))) {
      collect_logicalNA(index);
    }
  }

  inline SEXP get() {
    set_levels(data, levels);
    set_class(data, get_class(model));
    return data;
  }

  inline bool compatible(SEXP x) {
    return ((Rf_inherits(x, "factor") && has_same_levels_as(x)) ||
            all_logical_na(x, TYPEOF(x)));
  }

  inline bool can_promote(SEXP x) const {
    return TYPEOF(x) == STRSXP || Rf_inherits(x, "factor");
  }

  inline bool has_same_levels_as(SEXP x) const {
    CharacterVector levels_other = get_levels(x);

    int nlevels = levels_other.size();
    if (nlevels != (int)levels_map.size()) return false;

    for (int i = 0; i < nlevels; i++)
      if (! levels_map.count(levels_other[i]))
        return false;
    return true;
  }

  inline std::string describe() const {
    return "factor";
  }

private:
  IntegerVector data;
  RObject model;
  CharacterVector levels;
  LevelsMap levels_map;

  void collect_factor(const SlicingIndex& index, SEXP v) {
    // here we can assume that v is a factor with the right levels
    // we however do not assume that they are in the same order
    IntegerVector source(v);
    CharacterVector levels = get_levels(source);
    SEXP* levels_ptr = Rcpp::internal::r_vector_start<STRSXP>(levels);
    int* source_ptr = Rcpp::internal::r_vector_start<INTSXP>(source);
    for (int i = 0; i < index.size(); i++) {
      if (source_ptr[i] == NA_INTEGER) {
        data[ index[i] ] = NA_INTEGER;
      } else {
        SEXP x = levels_ptr[ source_ptr[i] - 1 ];
        data[ index[i] ] = levels_map.find(x)->second;
      }
    }
  }

  void collect_logicalNA(const SlicingIndex& index) {
    for (int i = 0; i < index.size(); i++) {
      data[ index[i] ] = NA_INTEGER;
    }
  }
};

template <>
inline bool Collecter_Impl<LGLSXP>::can_promote(SEXP) const {
  return is_logical_all_na();
}

inline Collecter* collecter(SEXP model, int n) {
  switch (TYPEOF(model)) {
  case INTSXP:
    if (Rf_inherits(model, "POSIXct"))
      return new POSIXctCollecter(n, Rf_getAttrib(model, Rf_install("tzone")));
    if (Rf_inherits(model, "factor"))
      return new FactorCollecter(n, model);
    if (Rf_inherits(model, "Date"))
      return new TypedCollecter<INTSXP>(n, get_date_classes());
    return new Collecter_Impl<INTSXP>(n);
  case REALSXP:
    if (Rf_inherits(model, "POSIXct"))
      return new POSIXctCollecter(n, Rf_getAttrib(model, Rf_install("tzone")));
    if (Rf_inherits(model, "difftime"))
      return
        new DifftimeCollecter(
          n,
          Rcpp::as<std::string>(Rf_getAttrib(model, Rf_install("units"))),
          Rf_getAttrib(model, R_ClassSymbol));
    if (Rf_inherits(model, "Date"))
      return new TypedCollecter<REALSXP>(n, get_date_classes());
    if (Rf_inherits(model, "integer64"))
      return new TypedCollecter<REALSXP>(n, CharacterVector::create("integer64"));
    return new Collecter_Impl<REALSXP>(n);
  case CPLXSXP:
    return new Collecter_Impl<CPLXSXP>(n);
  case LGLSXP:
    return new Collecter_Impl<LGLSXP>(n);
  case STRSXP:
    return new Collecter_Impl<STRSXP>(n);
  case VECSXP:
    if (Rf_inherits(model, "POSIXlt")) {
      stop("POSIXlt not supported");
    }
    if (Rf_inherits(model, "data.frame")) {
      stop("Columns of class data.frame not supported");
    }
    return new Collecter_Impl<VECSXP>(n);
  default:
    break;
  }

  stop("is of unsupported type %s", Rf_type2char(TYPEOF(model)));
}

inline Collecter* promote_collecter(SEXP model, int n, Collecter* previous) {
  // handle the case where the previous collecter was a
  // Factor collecter and model is a factor. when this occurs, we need to
  // return a Collecter_Impl<STRSXP> because the factors don't have the
  // same levels
  if (Rf_inherits(model, "factor") && previous->is_factor_collecter()) {
    Rf_warning("Unequal factor levels: coercing to character");
    return new Collecter_Impl<STRSXP>(n);
  }

  // logical NA can be promoted to whatever type comes next
  if (previous->is_logical_all_na()) {
    return collecter(model, n);
  }

  switch (TYPEOF(model)) {
  case INTSXP:
    if (Rf_inherits(model, "Date"))
      return new TypedCollecter<INTSXP>(n, get_date_classes());
    if (Rf_inherits(model, "factor"))
      return new Collecter_Impl<STRSXP>(n);
    return new Collecter_Impl<INTSXP>(n);
  case REALSXP:
    if (Rf_inherits(model, "POSIXct"))
      return new POSIXctCollecter(n, Rf_getAttrib(model, Rf_install("tzone")));
    if (Rf_inherits(model, "Date"))
      return new TypedCollecter<REALSXP>(n, get_date_classes());
    if (Rf_inherits(model, "integer64"))
      return new TypedCollecter<REALSXP>(n, CharacterVector::create("integer64"));
    return new Collecter_Impl<REALSXP>(n);
  case LGLSXP:
    return new Collecter_Impl<LGLSXP>(n);
  case STRSXP:
    if (previous->is_factor_collecter())
      Rf_warning("binding factor and character vector, coercing into character vector");
    return new Collecter_Impl<STRSXP>(n);
  default:
    break;
  }
  stop("is of unsupported type %s", Rf_type2char(TYPEOF(model)));
}

}

#endif
