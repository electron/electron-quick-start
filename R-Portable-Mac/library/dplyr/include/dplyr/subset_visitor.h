#ifndef dplyr_subset_visitor_H
#define dplyr_subset_visitor_H

#include <dplyr/SubsetVectorVisitor.h>

namespace dplyr {

inline SubsetVectorVisitor* subset_visitor(SEXP vec, const SymbolString& name);

}

#endif
