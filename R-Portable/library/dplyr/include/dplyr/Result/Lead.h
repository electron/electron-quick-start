#ifndef dplyr_Result_Lead_H
#define dplyr_Result_Lead_H

#include <tools/scalar_type.h>
#include <tools/utils.h>

#include <dplyr/Result/Result.h>

namespace dplyr {

template <int RTYPE>
class Lead : public Result {
public:
  typedef typename traits::scalar_type<RTYPE>::type STORAGE;

  Lead(SEXP data_, int n_, const RObject& def_, bool is_summary_) :
    data(data_),
    n(n_),
    def(Vector<RTYPE>::get_na()),
    is_summary(is_summary_)
  {
    if (!Rf_isNull(def_)) {
      def = as<STORAGE>(def_);
    }
  }

  virtual SEXP process(const GroupedDataFrame& gdf) {
    int nrows = gdf.nrows();
    int ng = gdf.ngroups();

    Vector<RTYPE> out = no_init(nrows);
    if (is_summary) {
      for (int i = 0; i < nrows; i++) out[i] = def;
    } else {
      GroupedDataFrame::group_iterator git = gdf.group_begin();
      for (int i = 0; i < ng; i++, ++git) {
        process_slice(out, *git, *git);
      }
    }
    copy_most_attributes(out, data);
    return out;
  }

  virtual SEXP process(const RowwiseDataFrame& gdf) {
    int nrows = gdf.nrows();

    Vector<RTYPE> out(nrows, def);
    copy_most_attributes(out, data);
    return out;
  }

  virtual SEXP process(const FullDataFrame& df) {
    int nrows = df.nrows();
    Vector<RTYPE> out = no_init(nrows);
    const SlicingIndex& index = df.get_index();
    process_slice(out, index, index);
    copy_most_attributes(out, data);
    return out;
  }

  virtual SEXP process(const SlicingIndex& index) {
    int nrows = index.size();
    Vector<RTYPE> out = no_init(nrows);
    NaturalSlicingIndex fake(nrows);
    process_slice(out, index, fake);
    copy_most_attributes(out, data);
    return out;
  }

private:

  void process_slice(Vector<RTYPE>& out, const SlicingIndex& index, const SlicingIndex& out_index) {
    int chunk_size = index.size();
    int i = 0;
    for (; i < chunk_size - n; i++) {
      out[out_index[i]] = data[index[i + n]];
    }
    for (; i < chunk_size; i++) {
      out[out_index[i]] = def;
    }
  }

  Vector<RTYPE> data;
  int n;
  STORAGE def;
  bool is_summary;
};

}

#endif
