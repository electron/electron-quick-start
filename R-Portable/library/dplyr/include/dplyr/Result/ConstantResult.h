#ifndef dplyr_Result_ConstantResult_H
#define dplyr_Result_ConstantResult_H

#include <dplyr/Result/Result.h>

namespace dplyr {

template <int RTYPE>
class ConstantResult : public Result {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  ConstantResult(SEXP x) : value(Rcpp::internal::r_vector_start<RTYPE>(x)[0]) {}

  SEXP process(const GroupedDataFrame& gdf) {
    return Vector<RTYPE>(gdf.ngroups(), value);
  }

  SEXP process(const RowwiseDataFrame& gdf) {
    return Vector<RTYPE>(gdf.ngroups(), value);
  }

  virtual SEXP process(const FullDataFrame&) {
    return Vector<RTYPE>::create(value);
  }

  virtual SEXP process(const SlicingIndex&) {
    return Vector<RTYPE>::create(value);
  }

  STORAGE value;
};

template <int RTYPE>
class TypedConstantResult : public Result {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  TypedConstantResult(SEXP x, SEXP classes_) :
    value(Rcpp::internal::r_vector_start<RTYPE>(x)[0]), classes(classes_) {}

  SEXP process(const GroupedDataFrame& gdf) {
    return get(gdf.ngroups());
  }

  SEXP process(const RowwiseDataFrame& gdf) {
    return get(gdf.ngroups());
  }

  virtual SEXP process(const FullDataFrame&) {
    return get(1);
  }

  virtual SEXP process(const SlicingIndex&) {
    return get(1);
  }

private:

  SEXP get(int n) const {
    Vector<RTYPE> res(n, value);
    set_class(res, classes);
    return res;
  }

  STORAGE value;
  SEXP classes;
};

template <int RTYPE>
class DifftimeConstantResult : public Result {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  DifftimeConstantResult(SEXP x) :
    value(Rcpp::internal::r_vector_start<RTYPE>(x)[0]),
    units(Rf_getAttrib(x, Rf_install("units")))
  {}

  SEXP process(const GroupedDataFrame& gdf) {
    return get(gdf.ngroups());
  }

  SEXP process(const RowwiseDataFrame& gdf) {
    return get(gdf.ngroups());
  }

  virtual SEXP process(const FullDataFrame&) {
    return get(1);
  }

  virtual SEXP process(const SlicingIndex&) {
    return get(1);
  }

private:

  SEXP get(int n) const {
    Vector<RTYPE> res(n, value);
    set_class(res, "difftime");
    res.attr("units") = units;
    return res;
  }

  STORAGE value;
  CharacterVector units;
};

}

#endif
