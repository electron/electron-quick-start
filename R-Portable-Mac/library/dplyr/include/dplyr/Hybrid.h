#ifndef dplyr_dplyr_Hybrid_H
#define dplyr_dplyr_Hybrid_H

namespace dplyr {
class ILazySubsets;
class Result;

Result* get_handler(SEXP, const ILazySubsets&, const Environment&);

}

#endif // dplyr_dplyr_Hybrid_H
