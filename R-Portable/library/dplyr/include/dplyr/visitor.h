#ifndef dplyr_visitor_H
#define dplyr_visitor_H

#include <dplyr/VectorVisitor.h>

namespace dplyr {

inline VectorVisitor* visitor(SEXP vec);

}

#endif
