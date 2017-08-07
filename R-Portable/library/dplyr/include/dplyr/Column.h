#ifndef DPLYR_DPLYR_COLUMN_H
#define DPLYR_DPLYR_COLUMN_H

class Column {
public:
  Column(SEXP data_, const SymbolString& name_) : data(data_), name(name_) {}

public:
  const RObject& get_data() const {
    return data;
  }

  const SymbolString& get_name() const {
    return name;
  }

  Column update_data(SEXP new_data) const {
    return Column(new_data, name);
  }

private:
  RObject data;
  SymbolString name;
};

#endif //DPLYR_DPLYR_COLUMN_H
