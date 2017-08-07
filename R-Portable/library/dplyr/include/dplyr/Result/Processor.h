#ifndef dplyr_Result_Processor_H
#define dplyr_Result_Processor_H

#include <tools/utils.h>

#include <dplyr/GroupedDataFrame.h>
#include <dplyr/RowwiseDataFrame.h>

#include <dplyr/Result/Result.h>

namespace dplyr {

// if we derive from this instead of deriving from Result, all we have to
// do is implement a process_chunk method that takes a SlicingIndex& as
// input and returns the suitable type (i.e. storage_type<OUTPUT>)
// all the builtin result implementation (Mean, ...) use this.
template <int OUTPUT, typename CLASS>
class Processor : public Result {
public:
  typedef typename Rcpp::traits::storage_type<OUTPUT>::type STORAGE;

  Processor() : data(R_NilValue) {}

  Processor(SEXP data_) : data(data_) {}

  virtual SEXP process(const Rcpp::GroupedDataFrame& gdf) {
    return process_grouped<GroupedDataFrame>(gdf);
  }

  virtual SEXP process(const Rcpp::RowwiseDataFrame& gdf) {
    return process_grouped<RowwiseDataFrame>(gdf);
  }

  virtual SEXP process(const Rcpp::FullDataFrame& df) {
    return promote(process(df.get_index()));
  }

  virtual SEXP process(const SlicingIndex& index) {
    CLASS* obj = static_cast<CLASS*>(this);
    Rcpp::Vector<OUTPUT> res = Rcpp::Vector<OUTPUT>::create(obj->process_chunk(index));
    copy_attributes(res, data);
    return res;
  }

private:

  template <typename Data>
  SEXP process_grouped(const Data& gdf) {
    int n = gdf.ngroups();
    Rcpp::Shield<SEXP> res(Rf_allocVector(OUTPUT, n));
    STORAGE* ptr = Rcpp::internal::r_vector_start<OUTPUT>(res);
    CLASS* obj = static_cast<CLASS*>(this);
    typename Data::group_iterator git = gdf.group_begin();
    for (int i = 0; i < n; i++, ++git)
      ptr[i] = obj->process_chunk(*git);
    copy_attributes(res, data);
    return res;
  }

  inline SEXP promote(SEXP obj) {
    RObject res(obj);
    copy_attributes(res, data);
    return res;
  }


  SEXP data;



};

template <typename CLASS>
class Processor<STRSXP, CLASS> : public Result {
public:
  Processor(SEXP data_): data(data_) {}

  virtual SEXP process(const Rcpp::GroupedDataFrame& gdf) {
    return process_grouped<GroupedDataFrame>(gdf);
  }
  virtual SEXP process(const Rcpp::RowwiseDataFrame& gdf) {
    return process_grouped<RowwiseDataFrame>(gdf);
  }

  virtual SEXP process(const Rcpp::FullDataFrame& df) {
    return process(df.get_index());
  }

  virtual SEXP process(const SlicingIndex& index) {
    CLASS* obj = static_cast<CLASS*>(this);
    return CharacterVector::create(obj->process_chunk(index));
  }

private:

  template <typename Data>
  SEXP process_grouped(const Data& gdf) {
    int n = gdf.ngroups();
    Rcpp::Shield<SEXP> res(Rf_allocVector(STRSXP, n));
    CLASS* obj = static_cast<CLASS*>(this);
    typename Data::group_iterator git = gdf.group_begin();
    for (int i = 0; i < n; i++, ++git)
      SET_STRING_ELT(res, i, obj->process_chunk(*git));
    return res;
  }

  SEXP data;
};

}
#endif
