#include <Rconfig.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <R_ext/Print.h>
#include <Rversion.h>
#include "cholmod.h"
#include "Matrix.h"

#ifdef	__cplusplus
extern "C" {
// and  bool is defined
#else
# define bool Rboolean
#endif

#ifdef HAVE_VISIBILITY_ATTRIBUTE
# define attribute_hidden __attribute__ ((visibility ("hidden")))
#else
# define attribute_hidden
#endif

CHM_DN attribute_hidden
M_as_cholmod_dense(CHM_DN ans, SEXP x)
{
    static CHM_DN(*fun)(CHM_DN,SEXP) = NULL;
    if(fun == NULL)
	fun = (CHM_DN(*)(CHM_DN,SEXP))
	    R_GetCCallable("Matrix", "as_cholmod_dense");
    return fun(ans, x);
}

CHM_FR attribute_hidden
M_as_cholmod_factor(CHM_FR ans, SEXP x)
{
    static CHM_FR(*fun)(CHM_FR,SEXP) = NULL;
    if(fun == NULL)
	fun = (CHM_FR(*)(CHM_FR,SEXP))
	    R_GetCCallable("Matrix", "as_cholmod_factor");
    return fun(ans, x);
}

CHM_SP attribute_hidden
M_as_cholmod_sparse(CHM_SP ans, SEXP x, Rboolean check_Udiag, Rboolean sort_in_place)
{
    static CHM_SP(*fun)(CHM_SP,SEXP,Rboolean,Rboolean)= NULL;
    if(fun == NULL)
	fun = (CHM_SP(*)(CHM_SP,SEXP,Rboolean,Rboolean))
	    R_GetCCallable("Matrix", "as_cholmod_sparse");
    return fun(ans, x, check_Udiag, sort_in_place);
}

CHM_TR attribute_hidden
M_as_cholmod_triplet(CHM_TR ans, SEXP x, Rboolean check_Udiag)
{
    static CHM_TR(*fun)(CHM_TR,SEXP,Rboolean)= NULL;
    if(fun == NULL)
	fun = (CHM_TR(*)(CHM_TR,SEXP,Rboolean))
	    R_GetCCallable("Matrix", "as_cholmod_triplet");
    return fun(ans, x, check_Udiag);
}

SEXP attribute_hidden
M_Csparse_diagU2N(SEXP x)
{
    static SEXP(*fun)(SEXP) = NULL;
    if(fun == NULL)
	fun = (SEXP(*)(SEXP))
	    R_GetCCallable("Matrix", "Csparse_diagU2N");
    return fun(x);
}

SEXP attribute_hidden
M_chm_factor_to_SEXP(const_CHM_FR f, int dofree)
{
    static SEXP(*fun)(const_CHM_FR,int) = NULL;
    if(fun == NULL)
	fun = (SEXP(*)(const_CHM_FR,int))
	    R_GetCCallable("Matrix", "chm_factor_to_SEXP");
    return fun(f, dofree);
}

double attribute_hidden
M_chm_factor_ldetL2(const_CHM_FR f)
{
    static double(*fun)(const_CHM_FR) = NULL;
    if(fun == NULL)
	fun = (double(*)(const_CHM_FR))
	    R_GetCCallable("Matrix", "chm_factor_ldetL2");
    return fun(f);
}

CHM_FR attribute_hidden
M_chm_factor_update(CHM_FR f, const_CHM_SP A, double mult)
{
    static CHM_FR(*fun)(CHM_FR,const_CHM_SP,double) = NULL;
    if(fun == NULL)
	fun = (CHM_FR(*)(CHM_FR,const_CHM_SP,double))
	    R_GetCCallable("Matrix", "chm_factor_update");
    return fun(f, A, mult);
}

SEXP attribute_hidden
M_chm_sparse_to_SEXP(const_CHM_SP a, int dofree,
		     int uploT, int Rkind, const char *diag, SEXP dn)
{
    static SEXP(*fun)(const_CHM_SP,int,int,int,const char*,SEXP) = NULL;
    if(fun == NULL)
	fun = (SEXP(*)(const_CHM_SP,int,int,int,const char*,SEXP))
	    R_GetCCallable("Matrix", "chm_sparse_to_SEXP");
    return fun(a, dofree, uploT, Rkind, diag, dn);
}

SEXP attribute_hidden
M_chm_triplet_to_SEXP(const CHM_TR a, int dofree,
		      int uploT, int Rkind, const char *diag, SEXP dn)
{
    static SEXP(*fun)(const CHM_TR,int,int,int,const char*,SEXP) = NULL;
    if(fun == NULL)
	fun = (SEXP(*)(const CHM_TR,int,int,int,const char*,SEXP))
	    R_GetCCallable("Matrix", "chm_triplet_to_SEXP");
    return fun(a, dofree, uploT, Rkind, diag, dn);
}

CHM_SP attribute_hidden
M_cholmod_aat(const_CHM_SP A, int *fset, size_t fsize,
	      int mode, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,int*,size_t,
			int,CHM_CM) = NULL;
    if(fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,int*,size_t,
			 int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_aat");
    return fun(A, fset, fsize, mode, Common);
}

int attribute_hidden
M_cholmod_band_inplace(CHM_SP A, int k1, int k2, int mode,
		       CHM_CM Common)
{
    static int(*fun)(CHM_SP,int,int,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_SP,int,int,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_band_inplace");
    return fun(A, k1, k2, mode, Common);
}

CHM_SP attribute_hidden
M_cholmod_add(const_CHM_SP A, const_CHM_SP B,
	      double alpha[2], double beta[2], int values,
	      int sorted, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,const_CHM_SP,
			double*,double*,int,int,
			CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,const_CHM_SP,
			 double*,double*,int,int,
			 CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_add");
    return fun(A, B, alpha, beta, values, sorted, Common);
}

CHM_DN attribute_hidden
M_cholmod_allocate_dense(size_t nrow, size_t ncol, size_t d,
			 int xtype, CHM_CM Common)
{
    static CHM_DN(*fun)(size_t,size_t,size_t,
			int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_DN(*)(size_t,size_t,size_t,
			 int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_allocate_dense");
    return fun(nrow, ncol, d, xtype, Common);
}

CHM_SP attribute_hidden
M_cholmod_allocate_sparse(size_t nrow, size_t ncol, size_t nzmax,
			  int sorted, int packed, int stype,
			  int xtype, CHM_CM Common)
{
    static CHM_SP(*fun)(size_t,size_t,size_t,int,int,
			int,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)
	       (size_t,size_t,size_t,int,int,int,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_allocate_sparse");
    return fun(nrow,ncol,nzmax,sorted,packed,stype,xtype,Common);
}

CHM_TR attribute_hidden
M_cholmod_allocate_triplet(size_t nrow, size_t ncol, size_t nzmax,
			   int stype, int xtype, CHM_CM Common)
{
    static CHM_TR(*fun)(size_t,size_t,size_t, int,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_TR(*)(size_t,size_t,size_t,int,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_allocate_triplet");
    return fun(nrow,ncol,nzmax,stype,xtype,Common);
}

CHM_SP attribute_hidden
M_cholmod_triplet_to_sparse(const cholmod_triplet* T, int nzmax,
			    CHM_CM Common)
{
    static CHM_SP(*fun)(const cholmod_triplet*,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const cholmod_triplet*,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_triplet_to_sparse");
    return fun(T, nzmax, Common);
}

CHM_TR attribute_hidden
M_cholmod_sparse_to_triplet(const_CHM_SP A, CHM_CM Common)
{
    static CHM_TR(*fun)(const_CHM_SP,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_TR(*)(const_CHM_SP,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_sparse_to_triplet");
    return fun(A, Common);
}

CHM_DN attribute_hidden
M_cholmod_sparse_to_dense(const_CHM_SP A, CHM_CM Common)
{
    static CHM_DN(*fun)(const_CHM_SP,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_DN(*)(const_CHM_SP,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_sparse_to_dense");
    return fun(A, Common);
}

CHM_FR attribute_hidden
M_cholmod_analyze(const_CHM_SP A, CHM_CM Common)
{
    static CHM_FR(*fun)(const_CHM_SP,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_FR(*)(const_CHM_SP,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_analyze");
    return fun(A, Common);
}

CHM_FR attribute_hidden
M_cholmod_analyze_p(const_CHM_SP A, int *Perm, int *fset,
		    size_t fsize, CHM_CM Common)
{
    static CHM_FR(*fun)(const_CHM_SP,int*,int*,size_t,
			CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_FR(*)(const_CHM_SP,int*,int*,
			 size_t,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_analyze_p");
    return fun(A, Perm, fset, fsize, Common);
}

CHM_SP attribute_hidden
M_cholmod_copy(const_CHM_SP A, int stype,
	       int mode, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,int,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,int,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_copy");
    return fun(A, stype, mode, Common);
}

CHM_DN attribute_hidden
M_cholmod_copy_dense(const_CHM_DN  A, CHM_CM Common)
{
    static CHM_DN(*fun)(const_CHM_DN,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_DN(*)(const_CHM_DN,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_copy_dense");
    return fun(A, Common);
}

CHM_FR attribute_hidden
M_cholmod_copy_factor(const_CHM_FR L, CHM_CM Common)
{
    static CHM_FR(*fun)(const_CHM_FR,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_FR(*)(const_CHM_FR,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_copy_factor");
    return fun(L, Common);
}

int attribute_hidden
M_cholmod_change_factor(int to_xtype, int to_ll, int to_super, int to_packed,
			int to_monotonic, CHM_FR L, CHM_CM Common)
{
    static int(*fun)(int,int,int,int,int,CHM_FR,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(int,int,int,int,int,CHM_FR,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_change_factor");
    return fun(to_xtype, to_ll, to_super, to_packed, to_monotonic, L, Common);
}

CHM_SP attribute_hidden
M_cholmod_copy_sparse(const_CHM_SP A, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_copy_sparse");
    return fun(A, Common);
}

CHM_SP attribute_hidden
M_cholmod_factor_to_sparse(const_CHM_FR L, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_FR,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_FR,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_factor_to_sparse");
    return fun(L, Common);
}

CHM_SP attribute_hidden
M_cholmod_submatrix(const_CHM_SP A, int *rset, int rsize, int *cset,
		    int csize, int values, int sorted, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,int*,int,int*,int,
			int,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,int*,int,int*,
			 int,int,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_submatrix");
    return fun(A, rset, rsize, cset, csize, values, sorted, Common);
}

CHM_SP attribute_hidden
M_cholmod_dense_to_sparse(const_CHM_DN  X, int values, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_DN,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_DN,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_dense_to_sparse");
    return fun(X, values, Common);
}

int attribute_hidden
M_cholmod_factorize(const_CHM_SP A, CHM_FR L, CHM_CM Common)
{
    static int(*fun)(const_CHM_SP,CHM_FR,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(const_CHM_SP,CHM_FR,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_factorize");
    return fun(A, L, Common);
}

int attribute_hidden
M_cholmod_factorize_p(const_CHM_SP A, double *beta, int *fset,
		      size_t fsize, CHM_FR L,
		      CHM_CM Common)
{
    static int(*fun)(const_CHM_SP,double*,int*,size_t,
		     CHM_FR,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(const_CHM_SP,double*,int*,size_t,
		      CHM_FR,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_factorize_p");
    return fun(A, beta, fset, fsize, L, Common);
}

int attribute_hidden
M_cholmod_finish(CHM_CM Common)
{

    static int(*fun)(CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_finish");
    return fun(Common);
}

int attribute_hidden
M_cholmod_sort(CHM_SP A, CHM_CM Common)
{
    static int(*fun)(CHM_SP,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_SP,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_sort");
    return fun(A, Common);
}

int attribute_hidden
M_cholmod_free_dense(CHM_DN  *A, CHM_CM Common)
{
    static int(*fun)(CHM_DN*,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_DN*,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_free_dense");
    return fun(A, Common);
}

int attribute_hidden
M_cholmod_free_factor(CHM_FR *L, CHM_CM Common)
{
    static int(*fun)(CHM_FR*,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_FR*,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_free_factor");
    return fun(L, Common);
}

int attribute_hidden
M_cholmod_free_sparse(CHM_SP *A, CHM_CM Common)
{
    static int(*fun)(CHM_SP*,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_SP*,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_free_sparse");
    return fun(A, Common);
}

int attribute_hidden
M_cholmod_free_triplet(cholmod_triplet **T, CHM_CM Common)
{
    static int(*fun)(cholmod_triplet**,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(cholmod_triplet**,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_free_triplet");
    return fun(T, Common);
}

long attribute_hidden
M_cholmod_nnz(const_CHM_SP A, CHM_CM Common)
{
    static long(*fun)(const_CHM_SP,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (long(*)(const_CHM_SP,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_nnz");
    return fun(A, Common);
}

int attribute_hidden
M_cholmod_sdmult(const_CHM_SP A, int transpose,
		 const double *alpha, const double *beta,
		 const_CHM_DN X, CHM_DN  Y,
		 CHM_CM Common)
{
    static int(*fun)(const_CHM_SP,int,const double*,
		     const double*,const_CHM_DN,
		     CHM_DN,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(const_CHM_SP,int,const double*,
		      const double*, const_CHM_DN,
		      CHM_DN,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_sdmult");
    return fun(A, transpose, alpha, beta, X, Y, Common);
}

CHM_SP attribute_hidden
M_cholmod_ssmult(const_CHM_SP A, const_CHM_SP B,
		 int stype, int values, int sorted,
		 CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,const_CHM_SP,
			int,int,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,const_CHM_SP,
			 int,int,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_ssmult");
    return fun(A, B, stype, values, sorted, Common);
}

CHM_DN attribute_hidden
M_cholmod_solve(int sys, const_CHM_FR L,
		const_CHM_DN B, CHM_CM Common)
{
    static CHM_DN(*fun)(int,const_CHM_FR,const_CHM_DN,
			CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_DN(*)(int,const_CHM_FR,const_CHM_DN,
			 CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_solve");
    return fun(sys, L, B, Common);
}


/* Feature Requests #6064, 2015-03-27
  https://r-forge.r-project.org/tracker/?func=detail&atid=297&aid=6064&group_id=61
*/
int attribute_hidden
M_cholmod_solve2(int sys,
		 CHM_FR L,
		 CHM_DN B, // right
		 CHM_DN *X,// solution
		 CHM_DN *Yworkspace,
		 CHM_DN *Eworkspace,
		 cholmod_common *c)
{
    static int(*fun)(
	int,
	const_CHM_FR, // L
	const_CHM_DN, // B
	CHM_SP, // Bset
	CHM_DN*, // X
	CHM_DN*, // Xset
	CHM_DN*, // Y
	CHM_DN*, // E
	cholmod_common*) = NULL;

    // Source: ../../src/CHOLMOD/Cholesky/cholmod_solve.c
    if (fun == NULL)
	fun = (int(*)(int,
		      const_CHM_FR, // L
		      const_CHM_DN, // B
		      CHM_SP, // Bset
		      CHM_DN*, // X
		      CHM_DN*, // Xset
		      CHM_DN*, // Y
		      CHM_DN*, // E
		      cholmod_common*)
	    )R_GetCCallable("Matrix", "cholmod_solve2");

    return fun(sys, L, B, NULL,
	       X, NULL, Yworkspace, Eworkspace, c);
}

CHM_SP attribute_hidden
M_cholmod_speye(size_t nrow, size_t ncol,
		int xtype, CHM_CM Common)
{
    static CHM_SP(*fun)(size_t,size_t,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(size_t,size_t,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_speye");
    return fun(nrow, ncol, xtype, Common);
}

CHM_SP attribute_hidden
M_cholmod_spsolve(int sys, const_CHM_FR L,
		  const_CHM_SP B, CHM_CM Common)
{
    static CHM_SP(*fun)(int,const_CHM_FR,
			const_CHM_SP, CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(int,const_CHM_FR,
			 const_CHM_SP, CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_spsolve");
    return fun(sys, L, B, Common);
}

int attribute_hidden
M_cholmod_defaults (CHM_CM Common)
{
    static int(*fun)(CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_defaults");
    return fun(Common);
}

int attribute_hidden
M_cholmod_updown(int update, const_CHM_SP C,
				const_CHM_FR L, CHM_CM Common)
{
	static int(*fun)(int,const_CHM_SP,const_CHM_FR,
						CHM_CM) = NULL;
	if (fun == NULL)
		fun = (int(*)(int,const_CHM_SP,const_CHM_FR,
							CHM_CM))
		R_GetCCallable("Matrix", "cholmod_updown");
	return fun(update, C, L, Common);
}

/* extern cholmod_common c; */

void attribute_hidden
M_R_cholmod_error(int status, const char *file, int line, const char *message)
{
/* NB: keep in sync with R_cholmod_error(), ../../src/chm_common.c */

    if(status < 0) {
/* Note: Matrix itself uses CHM_set_common_env, CHM_store_common
 *   and CHM_restore_common to preserve settings through error calls.
 *  Consider defining your own error handler, *and* possibly restoring
 *  *your* version of the cholmod_common that *you* use.
 */
	error("Cholmod error '%s' at file '%s', line %d", message, file, line);
    }
    else
	warning("Cholmod warning '%s' at file '%s', line %d",
		message, file, line);
}

#if 0  /* no longer used */
/* just to get 'int' instead of 'void' as required by CHOLMOD's print_function */
static int
R_cholmod_printf(const char* fmt, ...)
{
    va_list(ap);

    va_start(ap, fmt);
    Rprintf((char *)fmt, ap);
    va_end(ap);
    return 0;
}
#endif

int attribute_hidden
M_R_cholmod_start(CHM_CM Common)
{
    int val;
    static int(*fun)(CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_start");
    val = fun(Common);
/*-- NB: keep in sync with  R_cholmod_start() --> ../../src/chm_common.c */
    /* do not allow CHOLMOD printing - currently */
    Common->print_function = NULL;/* was  R_cholmod_printf; /.* Rprintf gives warning */
/* Consider using your own error handler: */
    Common->error_handler = M_R_cholmod_error;
    return val;
}

CHM_SP attribute_hidden
M_cholmod_transpose(const_CHM_SP A, int values, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,int,CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_transpose");
    return fun(A, values, Common);
}

CHM_SP attribute_hidden
M_cholmod_vertcat(const_CHM_SP A, const_CHM_SP B, int values, CHM_CM Common)
{
    static CHM_SP(*fun)(const_CHM_SP,const_CHM_SP,int,CHM_CM) = NULL;
    if (fun == NULL)
	fun = (CHM_SP(*)(const_CHM_SP,const_CHM_SP, int, CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_vertcat");
    return fun(A, B, values, Common);
}

SEXP attribute_hidden
M_dpoMatrix_chol(SEXP x)
{
    static SEXP(*fun)(SEXP) = NULL;
    if (fun == NULL)
	fun = (SEXP(*)(SEXP))
	    R_GetCCallable("Matrix", "dpoMatrix_chol");
    return fun(x);
}

CHM_DN attribute_hidden
M_numeric_as_chm_dense(CHM_DN ans, double *v, int nr, int nc)
{
    static CHM_DN(*fun)(CHM_DN,double*,int,int) = NULL;
    if (fun == NULL)
	fun = (CHM_DN(*)(CHM_DN,double*,int,int))
	    R_GetCCallable("Matrix", "numeric_as_chm_dense");
    return fun(ans, v, nr, nc);
}

int attribute_hidden
M_cholmod_scale(const_CHM_DN S, int scale, CHM_SP A,
		CHM_CM Common)
{
    static int(*fun)(const_CHM_DN,int,CHM_SP, CHM_CM) = NULL;
    if (fun == NULL)
	fun = (int(*)(const_CHM_DN,int,CHM_SP, CHM_CM))
	    R_GetCCallable("Matrix", "cholmod_scale");
    return fun(S, scale, A, Common);
}


// for now still *export*  M_Matrix_check_class_etc()
int M_Matrix_check_class_etc(SEXP x, const char **valid)
{
    REprintf("M_Matrix_check_class_etc() is deprecated; use R_check_class_etc() instead");
    return R_check_class_etc(x, valid);
}

const char *Matrix_valid_ge_dense[] = { MATRIX_VALID_ge_dense, ""};
const char *Matrix_valid_ddense[] = { MATRIX_VALID_ddense, ""};
const char *Matrix_valid_ldense[] = { MATRIX_VALID_ldense, ""};
const char *Matrix_valid_ndense[] = { MATRIX_VALID_ndense, ""};
const char *Matrix_valid_dense[] = {
    MATRIX_VALID_ddense,
    MATRIX_VALID_ldense,
    MATRIX_VALID_ndense, ""};

const char *Matrix_valid_Csparse[] = { MATRIX_VALID_Csparse, ""};
const char *Matrix_valid_triplet[] = { MATRIX_VALID_Tsparse, ""};
const char *Matrix_valid_Rsparse[] = { MATRIX_VALID_Rsparse, ""};
const char *Matrix_valid_CHMfactor[]={ MATRIX_VALID_CHMfactor, ""};

bool Matrix_isclass_Csparse(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_Csparse) >= 0;
}

bool Matrix_isclass_triplet(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_triplet) >= 0;
}

bool Matrix_isclass_ge_dense(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_ge_dense) >= 0;
}
bool Matrix_isclass_ddense(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_ddense) >= 0;
}
bool Matrix_isclass_ldense(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_ldense) >= 0;
}
bool Matrix_isclass_ndense(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_ndense) >= 0;
}
bool Matrix_isclass_dense(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_dense) >= 0;
}

bool Matrix_isclass_CHMfactor(SEXP x) {
    return R_check_class_etc(x, Matrix_valid_CHMfactor) >= 0;
}

#ifdef	__cplusplus
}
#endif

