#ifndef dplyr_dplyr_HybridHandlerMap_H
#define dplyr_dplyr_HybridHandlerMap_H

#include <tools/hash.h>
#include <dplyr/HybridHandler.h>

typedef dplyr_hash_map<SEXP, HybridHandler> HybridHandlerMap;

void install_simple_handlers(HybridHandlerMap& handlers);
void install_minmax_handlers(HybridHandlerMap& handlers);
void install_count_handlers(HybridHandlerMap& handlers);
void install_nth_handlers(HybridHandlerMap& handlers);
void install_window_handlers(HybridHandlerMap& handlers);
void install_offset_handlers(HybridHandlerMap& handlers);
void install_in_handlers(HybridHandlerMap& handlers);
void install_debug_handlers(HybridHandlerMap& handlers);

bool hybridable(RObject arg);

#endif // dplyr_dplyr_HybridHandlerMap_H
