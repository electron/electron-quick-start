#ifndef dplyr_tools_VectorView_H
#define dplyr_tools_VectorView_H

namespace Rcpp {

typedef Vector<INTSXP, NoProtectStorage> IntegerVectorView;
typedef Vector<VECSXP, NoProtectStorage> ListView;
typedef DataFrame_Impl<NoProtectStorage> DataFrameView;

}

#endif
