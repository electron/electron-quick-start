#ifndef dplyr_wrap_subset_H
#define dplyr_wrap_subset_H

namespace dplyr {

template <int RTYPE, typename Container>
SEXP wrap_subset(SEXP input, const Container& indices) {
  int n = indices.size();
  Rcpp::Vector<RTYPE> res = Rcpp::no_init(n);
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;
  STORAGE* ptr = Rcpp::internal::r_vector_start<RTYPE>(input);
  for (int i = 0; i < n; i++)
    res[i] = ptr[ indices[i] ];
  return res;
}

}


#endif
