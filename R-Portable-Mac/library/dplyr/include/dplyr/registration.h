#ifndef dplyr_registration_H
#define dplyr_registration_H

#include <dplyr/HybridHandler.h>

#if defined(COMPILING_DPLYR)

DataFrame build_index_cpp(DataFrame data);
void registerHybridHandler(const char*, HybridHandler);
SEXP get_time_classes();
SEXP get_date_classes();

#else

#include "dplyr_RcppExports.h"

#endif

#endif

