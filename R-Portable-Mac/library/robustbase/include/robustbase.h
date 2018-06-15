#ifndef __robustbase_h__
#define __robustbase_h__

#include <R.h>
// for SEXP
#include <Rinternals.h>

#ifdef __cplusplus
extern "C" {
#endif

  SEXP C_psifun(SEXP x_, SEXP c_, SEXP ipsi_, SEXP deriv_)
  {
    static SEXP(*fun)(SEXP, SEXP, SEXP, SEXP) = NULL;
    if (fun == NULL) fun = (SEXP(*)(SEXP, SEXP, SEXP, SEXP))
      R_GetCCallable("robustbase","R_psifun");
    return fun(x_, c_, ipsi_, deriv_);
  }

  SEXP C_chifun(SEXP x_, SEXP c_, SEXP ipsi_, SEXP deriv_)
  {
    static SEXP(*fun)(SEXP, SEXP, SEXP, SEXP) = NULL;
    if (fun == NULL) fun = (SEXP(*)(SEXP, SEXP, SEXP, SEXP))
      R_GetCCallable("robustbase","R_chifun");
    return fun(x_, c_, ipsi_, deriv_);
  }

  SEXP C_wgtfun(SEXP x_, SEXP c_, SEXP ipsi_)
  {
    static SEXP(*fun)(SEXP, SEXP, SEXP) = NULL;
    if (fun == NULL) fun = (SEXP(*)(SEXP, SEXP, SEXP))
      R_GetCCallable("robustbase","R_wgtfun");
    return fun(x_, c_, ipsi_);
  }

  double C_rho(double x_, const double* c_, int ipsi_) {
    static double(*fun)(double, const double[], int) = NULL;
    if (fun == NULL) fun = (double(*)(double, const double[], int))
      R_GetCCallable("robustbase","rho");
    return fun(x_, c_, ipsi_);
  }

  double C_psi(double x_, const double* c_, int ipsi_) {
    static double(*fun)(double, const double[], int) = NULL;
    if (fun == NULL) fun = (double(*)(double, const double[], int))
      R_GetCCallable("robustbase","psi");
    return fun(x_, c_, ipsi_);
  }

  double C_psip(double x_, const double* c_, int ipsi_) {
    static double(*fun)(double, const double[], int) = NULL;
    if (fun == NULL) fun = (double(*)(double, const double[], int))
      R_GetCCallable("robustbase","psip");
    return fun(x_, c_, ipsi_);
  }

  double C_psi2(double x_, const double* c_, int ipsi_) {
    static double(*fun)(double, const double[], int) = NULL;
    if (fun == NULL) fun = (double(*)(double, const double[], int))
      R_GetCCallable("robustbase","psi2");
    return fun(x_, c_, ipsi_);
  }

  double C_wgt(double x_, const double* c_, int ipsi_) {
    static double(*fun)(double, const double[], int) = NULL;
    if (fun == NULL) fun = (double(*)(double, const double[], int))
      R_GetCCallable("robustbase","wgt");
    return fun(x_, c_, ipsi_);
  }

  double C_rho_inf(double x_, const double* c_, int ipsi_) {
    static double(*fun)(double, const double[], int) = NULL;
    if (fun == NULL) fun = (double(*)(double, const double[], int))
      R_GetCCallable("robustbase", "rho_inf");
    return fun(x_, c_, ipsi_);
  }

  double C_normcnst(double x_, const double* c_, int ipsi_) {
    static double(*fun)(double, const double[], int) = NULL;
    if (fun == NULL) fun = (double(*)(double, const double[], int))
      R_GetCCallable("robustbase", "normcnst");
    return fun(x_, c_, ipsi_);
  }

#ifdef __cplusplus
}
#endif

#endif
