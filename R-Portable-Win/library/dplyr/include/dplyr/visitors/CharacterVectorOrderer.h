#ifndef dplyr_CharacterVectorOrderer_H
#define dplyr_CharacterVectorOrderer_H

#include <tools/hash.h>

namespace dplyr {

class CharacterVectorOrderer {
public:

  CharacterVectorOrderer(const Rcpp::CharacterVector& data_);

  inline Rcpp::IntegerVector get() const {
    return orders;
  }

private:
  Rcpp::IntegerVector orders;
};

}

#endif
