#ifndef dplyr_dplyr_get_column_H
#define dplyr_dplyr_get_column_H

namespace dplyr {

SymbolString get_column(SEXP, const Environment&, const ILazySubsets&);

}

#endif // #ifndef dplyr_dplyr_get_column_H
