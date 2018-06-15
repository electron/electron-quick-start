#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP rcpp_hello_world_cpp();
extern SEXP _rcpp_module_boot_NumEx();
extern SEXP _rcpp_module_boot_RcppClassModule();
extern SEXP _rcpp_module_boot_stdVector();

static const R_CallMethodDef CallEntries[] = {
    {"rcpp_hello_world_cpp", (DL_FUNC) &rcpp_hello_world_cpp, 0},
    {"_rcpp_module_boot_NumEx", (DL_FUNC) &_rcpp_module_boot_NumEx, 0},
    {"_rcpp_module_boot_RcppClassModule", (DL_FUNC) &_rcpp_module_boot_RcppClassModule, 0},
    {"_rcpp_module_boot_stdVector", (DL_FUNC) &_rcpp_module_boot_stdVector, 0},
    {NULL, NULL, 0}
};

void R_init_testRcppModule(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
