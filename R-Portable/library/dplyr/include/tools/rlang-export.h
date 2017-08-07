#ifndef RLANG_EXPORT_H
#define RLANG_EXPORT_H

#define R_NO_REMAP
#include <Rinternals.h>
#include <Rversion.h>
#include <R_ext/Rdynload.h>


#if (defined(R_VERSION) && R_VERSION < R_Version(3, 4, 0))
typedef union {
  void* p;
  DL_FUNC fn;
} fn_ptr;
SEXP R_MakeExternalPtrFn(DL_FUNC p, SEXP tag, SEXP prot);
DL_FUNC R_ExternalPtrAddrFn(SEXP s);
#endif

void rlang_register_pointer(const char* ns, const char* ptr_name, DL_FUNC fn);

#endif
