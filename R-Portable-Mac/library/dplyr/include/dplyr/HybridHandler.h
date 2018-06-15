#ifndef dplyr_dplyr_HybridHandler_H
#define dplyr_dplyr_HybridHandler_H

namespace dplyr {
class ILazySubsets;
class Result;
}

typedef dplyr::Result* (*HybridHandler)(SEXP, const dplyr::ILazySubsets&, int);

#endif // dplyr_dplyr_HybridHandlerMap_H
