#ifndef DPLYR_DPLYR_COLUMN_H
#define DPLYR_DPLYR_COLUMN_H

class Column {
public:
  Column(SEXP data_, const dplyr::SymbolString& name_) : data(data_), name(name_) {}

public:
  const Rcpp::RObject& get_data() const {
    return data;
  }

  const dplyr::SymbolString& get_name() const {
    return name;
  }

  Column update_data(SEXP new_data) const {
    return Column(new_data, name);
  }

private:
  Rcpp::RObject data;
  dplyr::SymbolString name;
};

#endif //DPLYR_DPLYR_COLUMN_H
