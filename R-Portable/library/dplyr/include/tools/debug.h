#ifndef dplyr_tools_debug_H
#define dplyr_tools_debug_H

// borrowed from Rcpp11
#ifndef RCPP_DEBUG_OBJECT
#define RCPP_DEBUG_OBJECT(OBJ) Rf_PrintValue( Rf_eval( Rf_lang2( Rf_install( "str"), OBJ ), R_GlobalEnv ) );
#endif

#ifndef RCPP_INSPECT_OBJECT
#define RCPP_INSPECT_OBJECT(OBJ) Rf_PrintValue( Rf_eval( Rf_lang2( Rf_install( ".Internal"), Rf_lang2( Rf_install( "inspect" ), OBJ ) ), R_GlobalEnv ) );
#endif

#endif // #ifndef dplyr_tools_debug_H
