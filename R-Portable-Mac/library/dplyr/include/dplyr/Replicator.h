#ifndef dplyr_Replicator_H
#define dplyr_Replicator_H

#include <tools/utils.h>

namespace dplyr {

class Replicator {
public:
  virtual ~Replicator() {}
  virtual SEXP collect() = 0;
};

template <int RTYPE, typename Data>
class ReplicatorImpl : public Replicator {
public:
  typedef typename Rcpp::traits::storage_type<RTYPE>::type STORAGE;

  ReplicatorImpl(SEXP v, int n_, int ngroups_) :
    data(no_init(n_ * ngroups_)), source(v), n(n_), ngroups(ngroups_) {}

  SEXP collect() {
    for (int i = 0, k = 0; i < ngroups; i++) {
      for (int j = 0; j < n; j++, k++) {
        data[k] = source[j];
      }
    }
    copy_most_attributes(data, source);
    return data;
  }

private:
  Vector<RTYPE> data;
  Vector<RTYPE> source;
  int n;
  int ngroups;
};

template <typename Data>
inline Replicator* replicator(SEXP v, const Data& gdf) {
  int n = Rf_length(v);
  switch (TYPEOF(v)) {
  case INTSXP:
    return new ReplicatorImpl<INTSXP, Data> (v, n, gdf.ngroups());
  case REALSXP:
    return new ReplicatorImpl<REALSXP, Data> (v, n, gdf.ngroups());
  case STRSXP:
    return new ReplicatorImpl<STRSXP, Data> (v, n, gdf.ngroups());
  case LGLSXP:
    return new ReplicatorImpl<LGLSXP, Data> (v, n, gdf.ngroups());
  case CPLXSXP:
    return new ReplicatorImpl<CPLXSXP, Data> (v, n, gdf.ngroups());
  default:
    break;
  }

  stop("is of unsupported type %s", Rf_type2char(TYPEOF(v)));
}

} // namespace dplyr


#endif
