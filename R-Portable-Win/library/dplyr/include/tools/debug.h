#ifndef dplyr_tools_debug_H
#define dplyr_tools_debug_H

#include <dplyr/symbols.h>

// borrowed from Rcpp11
#ifndef RCPP_DEBUG_OBJECT
#define RCPP_DEBUG_OBJECT(OBJ) Rf_PrintValue( Rf_eval( Rf_lang2( dplyr::symbols::str, OBJ ), R_GlobalEnv ) );
#endif

#ifndef RCPP_INSPECT_OBJECT
#define RCPP_INSPECT_OBJECT(OBJ) Rf_PrintValue( Rf_eval( Rf_lang2( dplyr::symbols::dot_Internal, Rf_lang2( dplyr::symbols::inspect, OBJ ) ), R_GlobalEnv ) );
#endif

#endif // #ifndef dplyr_tools_debug_H
