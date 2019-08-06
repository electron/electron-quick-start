#ifndef DPLY_VISITORS_SUBSET_DataFrameSelect_H
#define DPLY_VISITORS_SUBSET_DataFrameSelect_H

#include <tools/utils.h>
#include <tools/bad.h>

namespace dplyr {

class DataFrameSelect {
private:
  Rcpp::List data;

public:
  DataFrameSelect(const Rcpp::DataFrame& data_, const SymbolVector& names): data(names.size()) {
    Rcpp::Shield<SEXP> data_names(vec_names_or_empty(data_));
    Rcpp::Shield<SEXP> indices(names.match_in_table((SEXP)data_names));
    R_xlen_t n = XLENGTH(indices);
    int* p_indices = INTEGER(indices);
    Rcpp::Shield<SEXP> out_names(Rf_allocVector(STRSXP, n));

    for (R_xlen_t i = 0; i < n; i++) {
      R_xlen_t pos = p_indices[i];
      if (pos == NA_INTEGER) {
        bad_col(names[i], "is unknown");
      }
      data[i] = data_[pos - 1];
      SET_STRING_ELT(out_names, i, STRING_ELT(data_names, pos - 1));
    }
    Rf_namesgets(data, out_names);
    copy_class(data, data_);
  }

  DataFrameSelect(const Rcpp::DataFrame& data_, const Rcpp::IntegerVector& indices, bool check = true) : data(indices.size()) {
    Rcpp::Shield<SEXP> data_names(vec_names_or_empty(data_));
    int n = indices.size();
    Rcpp::Shield<SEXP> out_names(Rf_allocVector(STRSXP, n));
    for (int i = 0; i < n; i++) {
      int pos = check ? check_range_one_based(indices[i], data_.size()) : indices[i];
      SET_STRING_ELT(out_names, i, STRING_ELT(data_names, pos - 1));
      data[i] = data_[pos - 1];
    }
    Rf_namesgets(data, out_names);
    copy_class(data, data_);
  }

  inline operator SEXP() const {
    return data;
  }

};

}

#endif
