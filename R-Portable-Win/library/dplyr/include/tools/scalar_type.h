#ifndef DPLYR_SCALAR_TYPE_H
#define DPLYR_SCALAR_TYPE_H

namespace dplyr {

namespace traits {

template <int RTYPE>
struct scalar_type {
  typedef typename Rcpp::traits::storage_type<RTYPE>::type type;
};

template <>
struct scalar_type<STRSXP> {
  typedef Rcpp::String type;
};

}

}

#endif //DPLYR_SCALAR_TYPE_H
