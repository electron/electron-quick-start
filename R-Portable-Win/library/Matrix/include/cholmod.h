#ifndef MATRIX_CHOLMOD_H
#define MATRIX_CHOLMOD_H

#include <stddef.h>
#include <limits.h>

// Rather use C99 -- which we require in R anyway
#include <inttypes.h>


#ifdef	__cplusplus
extern "C" {
#endif

// from ../../src/SuiteSparse_config/SuiteSparse_config.h :
#ifndef SuiteSparse_long

/* #ifdef _WIN64 */

/* #define SuiteSparse_long __int64 */
/* #define SuiteSparse_long_max _I64_MAX */
/* #define SuiteSparse_long_idd "I64d" */

/* #else */

/* #define SuiteSparse_long long */
/* #define SuiteSparse_long_max LONG_MAX */
/* #define SuiteSparse_long_idd "ld" */

/* #endif */

#define SuiteSparse_long int64_t
    // typically long (but on WIN64)
#define SuiteSparse_ulong uint64_t
    //  only needed for ../COLAMD/Source/colamd.c (original has 'unsigned Int' which fails!!)
#define SuiteSparse_long_max 9223372036854775801
    // typically LONG_MAX (but ..)
#define SuiteSparse_long_idd PRId64
    // typically "ld"

#define SuiteSparse_long_id "%" SuiteSparse_long_idd
#endif

/* For backward compatibility with prior versions of SuiteSparse.  The UF_*
 * macros are deprecated and will be removed in a future version. */
#ifndef UF_long
#define UF_long     SuiteSparse_long
#define UF_long_max SuiteSparse_long_max
#define UF_long_idd SuiteSparse_long_idd
#define UF_long_id  SuiteSparse_long_id
#endif


#define CHOLMOD_HAS_VERSION_FUNCTION

#define CHOLMOD_DATE "April 25, 2013"
#define CHOLMOD_VER_CODE(main,sub) ((main) * 1000 + (sub))
#define CHOLMOD_MAIN_VERSION 2
#define CHOLMOD_SUB_VERSION 1
#define CHOLMOD_SUBSUB_VERSION 2
#define CHOLMOD_VERSION \
    CHOLMOD_VER_CODE(CHOLMOD_MAIN_VERSION,CHOLMOD_SUB_VERSION)
// from ../../src/CHOLMOD/Include/cholmod_core.h - line 275 :
/* Each CHOLMOD object has its own type code. */

#define CHOLMOD_COMMON 0
#define CHOLMOD_SPARSE 1
#define CHOLMOD_FACTOR 2
#define CHOLMOD_DENSE 3
#define CHOLMOD_TRIPLET 4

/* ========================================================================== */
/* === CHOLMOD Common ======================================================= */
/* ========================================================================== */

/* itype defines the types of integer used: */
#define CHOLMOD_INT 0		/* all integer arrays are int */
#define CHOLMOD_INTLONG 1	/* most are int, some are SuiteSparse_long */
#define CHOLMOD_LONG 2		/* all integer arrays are SuiteSparse_long */

/* The itype of all parameters for all CHOLMOD routines must match.
 * FUTURE WORK: CHOLMOD_INTLONG is not yet supported.
 */

/* dtype defines what the numerical type is (double or float): */
#define CHOLMOD_DOUBLE 0	/* all numerical values are double */
#define CHOLMOD_SINGLE 1	/* all numerical values are float */

/* The dtype of all parameters for all CHOLMOD routines must match.
 *
 * Scalar floating-point values are always passed as double arrays of size 2
 * (for the real and imaginary parts).  They are typecast to float as needed.
 * FUTURE WORK: the float case is not supported yet.
 */

/* xtype defines the kind of numerical values used: */
#define CHOLMOD_PATTERN 0	/* pattern only, no numerical values */
#define CHOLMOD_REAL 1		/* a real matrix */
#define CHOLMOD_COMPLEX 2	/* a complex matrix (ANSI C99 compatible) */
#define CHOLMOD_ZOMPLEX 3	/* a complex matrix (MATLAB compatible) */

/* Definitions for cholmod_common: */
#define CHOLMOD_MAXMETHODS 9	/* maximum number of different methods that */
				/* cholmod_analyze can try. Must be >= 9. */

/* Common->status values.  zero means success, negative means a fatal error,
 * positive is a warning. */
#define CHOLMOD_OK 0			/* success */
#define CHOLMOD_NOT_INSTALLED (-1)	/* failure: method not installed */
#define CHOLMOD_OUT_OF_MEMORY (-2)	/* failure: out of memory */
#define CHOLMOD_TOO_LARGE (-3)		/* failure: integer overflow occured */
#define CHOLMOD_INVALID (-4)		/* failure: invalid input */
#define CHOLMOD_GPU_PROBLEM (-5)        /* failure: GPU fatal error */
#define CHOLMOD_NOT_POSDEF (1)		/* warning: matrix not pos. def. */
#define CHOLMOD_DSMALL (2)		/* warning: D for LDL'  or diag(L) or */
					/* LL' has tiny absolute value */

/* ordering method (also used for L->ordering) */
#define CHOLMOD_NATURAL 0	/* use natural ordering */
#define CHOLMOD_GIVEN 1		/* use given permutation */
#define CHOLMOD_AMD 2		/* use minimum degree (AMD) */
#define CHOLMOD_METIS 3		/* use METIS' nested dissection */
#define CHOLMOD_NESDIS 4	/* use CHOLMOD's version of nested dissection:*/
				/* node bisector applied recursively, followed
				 * by constrained minimum degree (CSYMAMD or
				 * CCOLAMD) */
#define CHOLMOD_COLAMD 5	/* use AMD for A, COLAMD for A*A' */

/* POSTORDERED is not a method, but a result of natural ordering followed by a
 * weighted postorder.  It is used for L->ordering, not method [ ].ordering. */
#define CHOLMOD_POSTORDERED 6	/* natural ordering, postordered. */

/* supernodal strategy (for Common->supernodal) */
#define CHOLMOD_SIMPLICIAL 0	/* always do simplicial */
#define CHOLMOD_AUTO 1		/* select simpl/super depending on matrix */
#define CHOLMOD_SUPERNODAL 2	/* always do supernodal */

typedef struct cholmod_common_struct
{
    /* ---------------------------------------------------------------------- */
    /* parameters for symbolic/numeric factorization and update/downdate */
    /* ---------------------------------------------------------------------- */

    double dbound ;	/* Smallest absolute value of diagonal entries of D
			 * for LDL' factorization and update/downdate/rowadd/
	* rowdel, or the diagonal of L for an LL' factorization.
	* Entries in the range 0 to dbound are replaced with dbound.
	* Entries in the range -dbound to 0 are replaced with -dbound.  No
	* changes are made to the diagonal if dbound <= 0.  Default: zero */

    double grow0 ;	/* For a simplicial factorization, L->i and L->x can
			 * grow if necessary.  grow0 is the factor by which
	* it grows.  For the initial space, L is of size MAX (1,grow0) times
	* the required space.  If L runs out of space, the new size of L is
	* MAX(1.2,grow0) times the new required space.   If you do not plan on
	* modifying the LDL' factorization in the Modify module, set grow0 to
	* zero (or set grow2 to 0, see below).  Default: 1.2 */

    double grow1 ;

    size_t grow2 ;	/* For a simplicial factorization, each column j of L
			 * is initialized with space equal to
	* grow1*L->ColCount[j] + grow2.  If grow0 < 1, grow1 < 1, or grow2 == 0,
	* then the space allocated is exactly equal to L->ColCount[j].  If the
	* column j runs out of space, it increases to grow1*need + grow2 in
	* size, where need is the total # of nonzeros in that column.  If you do
	* not plan on modifying the factorization in the Modify module, set
	* grow2 to zero.  Default: grow1 = 1.2, grow2 = 5. */

    size_t maxrank ;	/* rank of maximum update/downdate.  Valid values:
			 * 2, 4, or 8.  A value < 2 is set to 2, and a
	* value > 8 is set to 8.  It is then rounded up to the next highest
	* power of 2, if not already a power of 2.  Workspace (Xwork, below) of
	* size nrow-by-maxrank double's is allocated for the update/downdate.
	* If an update/downdate of rank-k is requested, with k > maxrank,
	* it is done in steps of maxrank.  Default: 8, which is fastest.
	* Memory usage can be reduced by setting maxrank to 2 or 4.
	*/

    double supernodal_switch ;	/* supernodal vs simplicial factorization */
    int supernodal ;		/* If Common->supernodal <= CHOLMOD_SIMPLICIAL
				 * (0) then cholmod_analyze performs a
	* simplicial analysis.  If >= CHOLMOD_SUPERNODAL (2), then a supernodal
	* analysis is performed.  If == CHOLMOD_AUTO (1) and
	* flop/nnz(L) < Common->supernodal_switch, then a simplicial analysis
	* is done.  A supernodal analysis done otherwise.
	* Default:  CHOLMOD_AUTO.  Default supernodal_switch = 40 */

    int final_asis ;	/* If TRUE, then ignore the other final_* parameters
			 * (except for final_pack).
			 * The factor is left as-is when done.  Default: TRUE.*/

    int final_super ;	/* If TRUE, leave a factor in supernodal form when
			 * supernodal factorization is finished.  If FALSE,
			 * then convert to a simplicial factor when done.
			 * Default: TRUE */

    int final_ll ;	/* If TRUE, leave factor in LL' form when done.
			 * Otherwise, leave in LDL' form.  Default: FALSE */

    int final_pack ;	/* If TRUE, pack the columns when done.  If TRUE, and
			 * cholmod_factorize is called with a symbolic L, L is
	* allocated with exactly the space required, using L->ColCount.  If you
	* plan on modifying the factorization, set Common->final_pack to FALSE,
	* and each column will be given a little extra slack space for future
	* growth in fill-in due to updates.  Default: TRUE */

    int final_monotonic ;   /* If TRUE, ensure columns are monotonic when done.
			 * Default: TRUE */

    int final_resymbol ;/* if cholmod_factorize performed a supernodal
			 * factorization, final_resymbol is true, and
	* final_super is FALSE (convert a simplicial numeric factorization),
	* then numerically zero entries that resulted from relaxed supernodal
	* amalgamation are removed.  This does not remove entries that are zero
	* due to exact numeric cancellation, since doing so would break the
	* update/downdate rowadd/rowdel routines.  Default: FALSE. */

    /* supernodal relaxed amalgamation parameters: */
    double zrelax [3] ;
    size_t nrelax [3] ;

	/* Let ns be the total number of columns in two adjacent supernodes.
	 * Let z be the fraction of zero entries in the two supernodes if they
	 * are merged (z includes zero entries from prior amalgamations).  The
	 * two supernodes are merged if:
	 *    (ns <= nrelax [0]) || (no new zero entries added) ||
	 *    (ns <= nrelax [1] && z < zrelax [0]) ||
	 *    (ns <= nrelax [2] && z < zrelax [1]) || (z < zrelax [2])
	 *
	 * Default parameters result in the following rule:
	 *    (ns <= 4) || (no new zero entries added) ||
	 *    (ns <= 16 && z < 0.8) || (ns <= 48 && z < 0.1) || (z < 0.05)
	 */

    int prefer_zomplex ;    /* X = cholmod_solve (sys, L, B, Common) computes
			     * x=A\b or solves a related system.  If L and B are
	 * both real, then X is real.  Otherwise, X is returned as
	 * CHOLMOD_COMPLEX if Common->prefer_zomplex is FALSE, or
	 * CHOLMOD_ZOMPLEX if Common->prefer_zomplex is TRUE.  This parameter
	 * is needed because there is no supernodal zomplex L.  Suppose the
	 * caller wants all complex matrices to be stored in zomplex form
	 * (MATLAB, for example).  A supernodal L is returned in complex form
	 * if A is zomplex.  B can be real, and thus X = cholmod_solve (L,B)
	 * should return X as zomplex.  This cannot be inferred from the input
	 * arguments L and B.  Default: FALSE, since all data types are
	 * supported in CHOLMOD_COMPLEX form and since this is the native type
	 * of LAPACK and the BLAS.  Note that the MATLAB/cholmod.c mexFunction
	 * sets this parameter to TRUE, since MATLAB matrices are in
	 * CHOLMOD_ZOMPLEX form.
	 */

    int prefer_upper ;	    /* cholmod_analyze and cholmod_factorize work
			     * fastest when a symmetric matrix is stored in
	 * upper triangular form when a fill-reducing ordering is used.  In
	 * MATLAB, this corresponds to how x=A\b works.  When the matrix is
	 * ordered as-is, they work fastest when a symmetric matrix is in lower
	 * triangular form.  In MATLAB, R=chol(A) does the opposite.  This
	 * parameter affects only how cholmod_read returns a symmetric matrix.
	 * If TRUE (the default case), a symmetric matrix is always returned in
	 * upper-triangular form (A->stype = 1).  */

    int quick_return_if_not_posdef ;	/* if TRUE, the supernodal numeric
					 * factorization will return quickly if
	* the matrix is not positive definite.  Default: FALSE. */

    /* ---------------------------------------------------------------------- */
    /* printing and error handling options */
    /* ---------------------------------------------------------------------- */

    int print ;		/* print level. Default: 3 */
    int precise ;	/* if TRUE, print 16 digits.  Otherwise print 5 */
    int (*print_function) (const char *, ...) ;	/* pointer to printf */

    int try_catch ;	/* if TRUE, then ignore errors; CHOLMOD is in the middle
			 * of a try/catch block.  No error message is printed
	 * and the Common->error_handler function is not called. */

    void (*error_handler) (int status, const char *file,
        int line, const char *message) ;

	/* Common->error_handler is the user's error handling routine.  If not
	 * NULL, this routine is called if an error occurs in CHOLMOD.  status
	 * can be CHOLMOD_OK (0), negative for a fatal error, and positive for
	 * a warning. file is a string containing the name of the source code
	 * file where the error occured, and line is the line number in that
	 * file.  message is a string describing the error in more detail. */

    /* ---------------------------------------------------------------------- */
    /* ordering options */
    /* ---------------------------------------------------------------------- */

    /* The cholmod_analyze routine can try many different orderings and select
     * the best one.  It can also try one ordering method multiple times, with
     * different parameter settings.  The default is to use three orderings,
     * the user's permutation (if provided), AMD which is the fastest ordering
     * and generally gives good fill-in, and METIS.  CHOLMOD's nested dissection
     * (METIS with a constrained AMD) usually gives a better ordering than METIS
     * alone (by about 5% to 10%) but it takes more time.
     *
     * If you know the method that is best for your matrix, set Common->nmethods
     * to 1 and set Common->method [0] to the set of parameters for that method.
     * If you set it to 1 and do not provide a permutation, then only AMD will
     * be called.
     *
     * If METIS is not available, the default # of methods tried is 2 (the user
     * permutation, if any, and AMD).
     *
     * To try other methods, set Common->nmethods to the number of methods you
     * want to try.  The suite of default methods and their parameters is
     * described in the cholmod_defaults routine, and summarized here:
     *
     *	    Common->method [i]:
     *	    i = 0: user-provided ordering (cholmod_analyze_p only)
     *	    i = 1: AMD (for both A and A*A')
     *	    i = 2: METIS
     *	    i = 3: CHOLMOD's nested dissection (NESDIS), default parameters
     *	    i = 4: natural
     *	    i = 5: NESDIS with nd_small = 20000
     *	    i = 6: NESDIS with nd_small = 4, no constrained minimum degree
     *	    i = 7: NESDIS with no dense node removal
     *	    i = 8: AMD for A, COLAMD for A*A'
     *
     * You can modify the suite of methods you wish to try by modifying
     * Common.method [...] after calling cholmod_start or cholmod_defaults.
     *
     * For example, to use AMD, followed by a weighted postordering:
     *
     *	    Common->nmethods = 1 ;
     *	    Common->method [0].ordering = CHOLMOD_AMD ;
     *	    Common->postorder = TRUE ;
     *
     * To use the natural ordering (with no postordering):
     *
     *	    Common->nmethods = 1 ;
     *	    Common->method [0].ordering = CHOLMOD_NATURAL ;
     *	    Common->postorder = FALSE ;
     *
     * If you are going to factorize hundreds or more matrices with the same
     * nonzero pattern, you may wish to spend a great deal of time finding a
     * good permutation.  In this case, try setting Common->nmethods to 9.
     * The time spent in cholmod_analysis will be very high, but you need to
     * call it only once.
     *
     * cholmod_analyze sets Common->current to a value between 0 and nmethods-1.
     * Each ordering method uses the set of options defined by this parameter.
     */

    int nmethods ;	/* The number of ordering methods to try.  Default: 0.
			 * nmethods = 0 is a special case.  cholmod_analyze
	* will try the user-provided ordering (if given) and AMD.  Let fl and
	* lnz be the flop count and nonzeros in L from AMD's ordering.  Let
	* anz be the number of nonzeros in the upper or lower triangular part
	* of the symmetric matrix A.  If fl/lnz < 500 or lnz/anz < 5, then this
	* is a good ordering, and METIS is not attempted.  Otherwise, METIS is
	* tried.   The best ordering found is used.  If nmethods > 0, the
	* methods used are given in the method[ ] array, below.  The first
	* three methods in the default suite of orderings is (1) use the given
	* permutation (if provided), (2) use AMD, and (3) use METIS.  Maximum
	* allowed value is CHOLMOD_MAXMETHODS.  */

    int current ;	/* The current method being tried.  Default: 0.  Valid
			 * range is 0 to nmethods-1. */

    int selected ;	/* The best method found. */

    /* The suite of ordering methods and parameters: */

    struct cholmod_method_struct
    {
	/* statistics for this method */
	double lnz ;	    /* nnz(L) excl. zeros from supernodal amalgamation,
			     * for a "pure" L */

	double fl ;	    /* flop count for a "pure", real simplicial LL'
			     * factorization, with no extra work due to
	    * amalgamation.  Subtract n to get the LDL' flop count.   Multiply
	    * by about 4 if the matrix is complex or zomplex. */

	/* ordering method parameters */
	double prune_dense ;/* dense row/col control for AMD, SYMAMD, CSYMAMD,
			     * and NESDIS (cholmod_nested_dissection).  For a
	    * symmetric n-by-n matrix, rows/columns with more than
	    * MAX (16, prune_dense * sqrt (n)) entries are removed prior to
	    * ordering.  They appear at the end of the re-ordered matrix.
	    *
	    * If prune_dense < 0, only completely dense rows/cols are removed.
	    *
	    * This paramater is also the dense column control for COLAMD and
	    * CCOLAMD.  For an m-by-n matrix, columns with more than
	    * MAX (16, prune_dense * sqrt (MIN (m,n))) entries are removed prior
	    * to ordering.  They appear at the end of the re-ordered matrix.
	    * CHOLMOD factorizes A*A', so it calls COLAMD and CCOLAMD with A',
	    * not A.  Thus, this parameter affects the dense *row* control for
	    * CHOLMOD's matrix, and the dense *column* control for COLAMD and
	    * CCOLAMD.
	    *
	    * Removing dense rows and columns improves the run-time of the
	    * ordering methods.  It has some impact on ordering quality
	    * (usually minimal, sometimes good, sometimes bad).
	    *
	    * Default: 10. */

	double prune_dense2 ;/* dense row control for COLAMD and CCOLAMD.
			    *  Rows with more than MAX (16, dense2 * sqrt (n))
	    * for an m-by-n matrix are removed prior to ordering.  CHOLMOD's
	    * matrix is transposed before ordering it with COLAMD or CCOLAMD,
	    * so this controls the dense *columns* of CHOLMOD's matrix, and
	    * the dense *rows* of COLAMD's or CCOLAMD's matrix.
	    *
	    * If prune_dense2 < 0, only completely dense rows/cols are removed.
	    *
	    * Default: -1.  Note that this is not the default for COLAMD and
	    * CCOLAMD.  -1 is best for Cholesky.  10 is best for LU.  */

	double nd_oksep ;   /* in NESDIS, when a node separator is computed, it
			     * discarded if nsep >= nd_oksep*n, where nsep is
	    * the number of nodes in the separator, and n is the size of the
	    * graph being cut.  Valid range is 0 to 1.  If 1 or greater, the
	    * separator is discarded if it consists of the entire graph.
	    * Default: 1 */

	double other1 [4] ; /* future expansion */

	size_t nd_small ;    /* do not partition graphs with fewer nodes than
			     * nd_small, in NESDIS.  Default: 200 (same as
			     * METIS) */

	size_t other2 [4] ; /* future expansion */

	int aggressive ;    /* Aggresive absorption in AMD, COLAMD, SYMAMD,
			     * CCOLAMD, and CSYMAMD.  Default: TRUE */

	int order_for_lu ;  /* CCOLAMD can be optimized to produce an ordering
			     * for LU or Cholesky factorization.  CHOLMOD only
	    * performs a Cholesky factorization.  However, you may wish to use
	    * CHOLMOD as an interface for CCOLAMD but use it for your own LU
	    * factorization.  In this case, order_for_lu should be set to FALSE.
	    * When factorizing in CHOLMOD itself, you should *** NEVER *** set
	    * this parameter FALSE.  Default: TRUE. */

	int nd_compress ;   /* If TRUE, compress the graph and subgraphs before
			     * partitioning them in NESDIS.  Default: TRUE */

	int nd_camd ;	    /* If 1, follow the nested dissection ordering
			     * with a constrained minimum degree ordering that
	    * respects the partitioning just found (using CAMD).  If 2, use
	    * CSYMAMD instead.  If you set nd_small very small, you may not need
	    * this ordering, and can save time by setting it to zero (no
	    * constrained minimum degree ordering).  Default: 1. */

	int nd_components ; /* The nested dissection ordering finds a node
			     * separator that splits the graph into two parts,
	    * which may be unconnected.  If nd_components is TRUE, each of
	    * these connected components is split independently.  If FALSE,
	    * each part is split as a whole, even if it consists of more than
	    * one connected component.  Default: FALSE */

	/* fill-reducing ordering to use */
	int ordering ;

	size_t other3 [4] ; /* future expansion */

    } method [CHOLMOD_MAXMETHODS + 1] ;

    int postorder ;	/* If TRUE, cholmod_analyze follows the ordering with a
			 * weighted postorder of the elimination tree.  Improves
	* supernode amalgamation.  Does not affect fundamental nnz(L) and
	* flop count.  Default: TRUE. */

    /* ---------------------------------------------------------------------- */
    /* memory management routines */
    /* ---------------------------------------------------------------------- */

    void *(*malloc_memory) (size_t) ;		/* pointer to malloc */
    void *(*realloc_memory) (void *, size_t) ;  /* pointer to realloc */
    void (*free_memory) (void *) ;		/* pointer to free */
    void *(*calloc_memory) (size_t, size_t) ;	/* pointer to calloc */

    /* ---------------------------------------------------------------------- */
    /* routines for complex arithmetic */
    /* ---------------------------------------------------------------------- */

    int (*complex_divide) (double ax, double az, double bx, double bz,
	    double *cx, double *cz) ;

	/* flag = complex_divide (ax, az, bx, bz, &cx, &cz) computes the complex
	 * division c = a/b, where ax and az hold the real and imaginary part
	 * of a, and b and c are stored similarly.  flag is returned as 1 if
	 * a divide-by-zero occurs, or 0 otherwise.  By default, the function
	 * pointer Common->complex_divide is set equal to cholmod_divcomplex.
	 */

    double (*hypotenuse) (double x, double y) ;

	/* s = hypotenuse (x,y) computes s = sqrt (x*x + y*y), but does so more
	 * accurately.  By default, the function pointer Common->hypotenuse is
	 * set equal to cholmod_hypot.  See also the hypot function in the C99
	 * standard, which has an identical syntax and function.  If you have
	 * a C99-compliant compiler, you can set Common->hypotenuse = hypot.  */

    /* ---------------------------------------------------------------------- */
    /* METIS workarounds */
    /* ---------------------------------------------------------------------- */

    double metis_memory ;   /* This is a parameter for CHOLMOD's interface to
			     * METIS, not a parameter to METIS itself.  METIS
	* uses an amount of memory that is difficult to estimate precisely
	* beforehand.  If it runs out of memory, it terminates your program.
	* All routines in CHOLMOD except for CHOLMOD's interface to METIS
	* return an error status and safely return to your program if they run
	* out of memory.  To mitigate this problem, the CHOLMOD interface
	* can allocate a single block of memory equal in size to an empirical
	* upper bound of METIS's memory usage times the Common->metis_memory
	* parameter, and then immediately free it.  It then calls METIS.  If
	* this pre-allocation fails, it is possible that METIS will fail as
	* well, and so CHOLMOD returns with an out-of-memory condition without
	* calling METIS.
	*
	* METIS_NodeND (used in the CHOLMOD_METIS ordering option) with its
	* default parameter settings typically uses about (4*nz+40n+4096)
	* times sizeof(int) memory, where nz is equal to the number of entries
	* in A for the symmetric case or AA' if an unsymmetric matrix is
	* being ordered (where nz includes both the upper and lower parts
	* of A or AA').  The observed "upper bound" (with 2 exceptions),
	* measured in an instrumented copy of METIS 4.0.1 on thousands of
	* matrices, is (10*nz+50*n+4096) * sizeof(int).  Two large matrices
	* exceeded this bound, one by almost a factor of 2 (Gupta/gupta2).
	*
	* If your program is terminated by METIS, try setting metis_memory to
	* 2.0, or even higher if needed.  By default, CHOLMOD assumes that METIS
	* does not have this problem (so that CHOLMOD will work correctly when
	* this issue is fixed in METIS).  Thus, the default value is zero.
	* This work-around is not guaranteed anyway.
	*
	* If a matrix exceeds this predicted memory usage, AMD is attempted
	* instead.  It, too, may run out of memory, but if it does so it will
	* not terminate your program.
	*/

    double metis_dswitch ;	/* METIS_NodeND in METIS 4.0.1 gives a seg */
    size_t metis_nswitch ;	/* fault with one matrix of order n = 3005 and
				 * nz = 6,036,025.  This is a very dense graph.
     * The workaround is to use AMD instead of METIS for matrices of dimension
     * greater than Common->metis_nswitch (default 3000) or more and with
     * density of Common->metis_dswitch (default 0.66) or more.
     * cholmod_nested_dissection has no problems with the same matrix, even
     * though it uses METIS_NodeComputeSeparator on this matrix.  If this
     * seg fault does not affect you, set metis_nswitch to zero or less,
     * and CHOLMOD will not switch to AMD based just on the density of the
     * matrix (it will still switch to AMD if the metis_memory parameter
     * causes the switch).
     */

    /* ---------------------------------------------------------------------- */
    /* workspace */
    /* ---------------------------------------------------------------------- */

    /* CHOLMOD has several routines that take less time than the size of
     * workspace they require.  Allocating and initializing the workspace would
     * dominate the run time, unless workspace is allocated and initialized
     * just once.  CHOLMOD allocates this space when needed, and holds it here
     * between calls to CHOLMOD.  cholmod_start sets these pointers to NULL
     * (which is why it must be the first routine called in CHOLMOD).
     * cholmod_finish frees the workspace (which is why it must be the last
     * call to CHOLMOD).
     */

    size_t nrow ;	/* size of Flag and Head */
    SuiteSparse_long mark ;	/* mark value for Flag array */
    size_t iworksize ;	/* size of Iwork.  Upper bound: 6*nrow+ncol */
    size_t xworksize ;	/* size of Xwork,  in bytes.
			 * maxrank*nrow*sizeof(double) for update/downdate.
			 * 2*nrow*sizeof(double) otherwise */

    /* initialized workspace: contents needed between calls to CHOLMOD */
    void *Flag ;	/* size nrow, an integer array.  Kept cleared between
			 * calls to cholmod rouines (Flag [i] < mark) */

    void *Head ;	/* size nrow+1, an integer array. Kept cleared between
			 * calls to cholmod routines (Head [i] = EMPTY) */

    void *Xwork ; 	/* a double array.  Its size varies.  It is nrow for
			 * most routines (cholmod_rowfac, cholmod_add,
	* cholmod_aat, cholmod_norm, cholmod_ssmult) for the real case, twice
	* that when the input matrices are complex or zomplex.  It is of size
	* 2*nrow for cholmod_rowadd and cholmod_rowdel.  For cholmod_updown,
	* its size is maxrank*nrow where maxrank is 2, 4, or 8.  Kept cleared
	* between calls to cholmod (set to zero). */

    /* uninitialized workspace, contents not needed between calls to CHOLMOD */
    void *Iwork ;	/* size iworksize, 2*nrow+ncol for most routines,
			 * up to 6*nrow+ncol for cholmod_analyze. */

    int itype ;		/* If CHOLMOD_LONG, Flag, Head, and Iwork are SuiteSparse_long.
			 * Otherwise all three arrays are int. */

    int dtype ;		/* double or float */

	/* Common->itype and Common->dtype are used to define the types of all
	 * sparse matrices, triplet matrices, dense matrices, and factors
	 * created using this Common struct.  The itypes and dtypes of all
	 * parameters to all CHOLMOD routines must match.  */

    int no_workspace_reallocate ;   /* this is an internal flag, used as a
	* precaution by cholmod_analyze.  It is normally false.  If true,
	* cholmod_allocate_work is not allowed to reallocate any workspace;
	* they must use the existing workspace in Common (Iwork, Flag, Head,
	* and Xwork).  Added for CHOLMOD v1.1 */

    /* ---------------------------------------------------------------------- */
    /* statistics */
    /* ---------------------------------------------------------------------- */

    /* fl and lnz are set only in cholmod_analyze and cholmod_rowcolcounts,
     * in the Cholesky modudle.  modfl is set only in the Modify module. */

    int status ;	    /* error code */
    double fl ;		    /* LL' flop count from most recent analysis */
    double lnz ;	    /* fundamental nz in L */
    double anz ;	    /* nonzeros in tril(A) if A is symmetric/lower,
			     * triu(A) if symmetric/upper, or tril(A*A') if
			     * unsymmetric, in last call to cholmod_analyze. */
    double modfl ;	    /* flop count from most recent update/downdate/
			     * rowadd/rowdel (excluding flops to modify the
			     * solution to Lx=b, if computed) */
    size_t malloc_count ;   /* # of objects malloc'ed minus the # free'd*/
    size_t memory_usage ;   /* peak memory usage in bytes */
    size_t memory_inuse ;   /* current memory usage in bytes */

    double nrealloc_col ;   /* # of column reallocations */
    double nrealloc_factor ;/* # of factor reallocations due to col. reallocs */
    double ndbounds_hit ;   /* # of times diagonal modified by dbound */

    double rowfacfl ;	    /* # of flops in last call to cholmod_rowfac */
    double aatfl ;	    /* # of flops to compute A(:,f)*A(:,f)' */

    /* ---------------------------------------------------------------------- */
    /* future expansion */
    /* ---------------------------------------------------------------------- */

    /* To allow CHOLMOD to be updated without recompiling the user application,
     * additional space is set aside here for future statistics, parameters,
     * and workspace.  Note:  additional entries were added in v1.1 to the
     * method array, above, and thus v1.0 and v1.1 are not binary compatible.
     *
     * v1.1 to the current version are binary compatible.
     */

    /* ---------------------------------------------------------------------- */
    double other1 [10] ;

    double SPQR_xstat [4] ;     /* for SuiteSparseQR statistics */

    /* SuiteSparseQR control parameters: */
    double SPQR_grain ;         /* task size is >= max (total flops / grain) */
    double SPQR_small ;         /* task size is >= small */

    /* ---------------------------------------------------------------------- */
    SuiteSparse_long SPQR_istat [10] ;   /* for SuiteSparseQR statistics */
    SuiteSparse_long other2 [6] ;        /* reduced from size 16 in v1.6 */

    /* ---------------------------------------------------------------------- */
    int other3 [10] ;       /* reduced from size 16 in v1.1. */

    int prefer_binary ;	    /* cholmod_read_triplet converts a symmetric
			     * pattern-only matrix into a real matrix.  If
	* prefer_binary is FALSE, the diagonal entries are set to 1 + the degree
	* of the row/column, and off-diagonal entries are set to -1 (resulting
	* in a positive definite matrix if the diagonal is zero-free).  Most
	* symmetric patterns are the pattern a positive definite matrix.  If
	* this parameter is TRUE, then the matrix is returned with a 1 in each
	* entry, instead.  Default: FALSE.  Added in v1.3. */

    /* control parameter (added for v1.2): */
    int default_nesdis ;    /* Default: FALSE.  If FALSE, then the default
			     * ordering strategy (when Common->nmethods == 0)
	* is to try the given ordering (if present), AMD, and then METIS if AMD
	* reports high fill-in.  If Common->default_nesdis is TRUE then NESDIS
	* is used instead in the default strategy. */

    /* statistic (added for v1.2): */
    int called_nd ;	    /* TRUE if the last call to
			     * cholmod_analyze called NESDIS or METIS. */

    int blas_ok ;           /* FALSE if BLAS int overflow; TRUE otherwise */

    /* SuiteSparseQR control parameters: */
    int SPQR_shrink ;        /* controls stack realloc method */
    int SPQR_nthreads ;      /* number of TBB threads, 0 = auto */

    /* ---------------------------------------------------------------------- */
    size_t  other4 [16] ;

    /* ---------------------------------------------------------------------- */
    void   *other5 [16] ;

} cholmod_common ;

// in ../../src/CHOLMOD/Include/cholmod_core.h  skip forward to - line 1170 :
/* A sparse matrix stored in compressed-column form. */

typedef struct cholmod_sparse_struct
{
    size_t nrow ;	/* the matrix is nrow-by-ncol */
    size_t ncol ;
    size_t nzmax ;	/* maximum number of entries in the matrix */

    /* pointers to int or SuiteSparse_long: */
    void *p ;		/* p [0..ncol], the column pointers */
    void *i ;		/* i [0..nzmax-1], the row indices */

    /* for unpacked matrices only: */
    void *nz ;		/* nz [0..ncol-1], the # of nonzeros in each col.  In
			 * packed form, the nonzero pattern of column j is in
	* A->i [A->p [j] ... A->p [j+1]-1].  In unpacked form, column j is in
	* A->i [A->p [j] ... A->p [j]+A->nz[j]-1] instead.  In both cases, the
	* numerical values (if present) are in the corresponding locations in
	* the array x (or z if A->xtype is CHOLMOD_ZOMPLEX). */

    /* pointers to double or float: */
    void *x ;		/* size nzmax or 2*nzmax, if present */
    void *z ;		/* size nzmax, if present */

    int stype ;		/* Describes what parts of the matrix are considered:
			 *
	* 0:  matrix is "unsymmetric": use both upper and lower triangular parts
	*     (the matrix may actually be symmetric in pattern and value, but
	*     both parts are explicitly stored and used).  May be square or
	*     rectangular.
	* >0: matrix is square and symmetric, use upper triangular part.
	*     Entries in the lower triangular part are ignored.
	* <0: matrix is square and symmetric, use lower triangular part.
	*     Entries in the upper triangular part are ignored.
	*
	* Note that stype>0 and stype<0 are different for cholmod_sparse and
	* cholmod_triplet.  See the cholmod_triplet data structure for more
	* details.
	*/

    int itype ;		/* CHOLMOD_INT:     p, i, and nz are int.
			 * CHOLMOD_INTLONG: p is SuiteSparse_long,
			 *                  i and nz are int.
			 * CHOLMOD_LONG:    p, i, and nz are SuiteSparse_long */

    int xtype ;		/* pattern, real, complex, or zomplex */
    int dtype ;		/* x and z are double or float */
    int sorted ;	/* TRUE if columns are sorted, FALSE otherwise */
    int packed ;	/* TRUE if packed (nz ignored), FALSE if unpacked
			 * (nz is required) */

} cholmod_sparse ;

// in ../../src/CHOLMOD/Include/cholmod_core.h  skip forward to - line 1552 :
/* A symbolic and numeric factorization, either simplicial or supernodal.
 * In all cases, the row indices in the columns of L are kept sorted. */

typedef struct cholmod_factor_struct
{
    /* ---------------------------------------------------------------------- */
    /* for both simplicial and supernodal factorizations */
    /* ---------------------------------------------------------------------- */

    size_t n ;		/* L is n-by-n */

    size_t minor ;	/* If the factorization failed, L->minor is the column
			 * at which it failed (in the range 0 to n-1).  A value
			 * of n means the factorization was successful or
			 * the matrix has not yet been factorized. */

    /* ---------------------------------------------------------------------- */
    /* symbolic ordering and analysis */
    /* ---------------------------------------------------------------------- */

    void *Perm ;	/* size n, permutation used */
    void *ColCount ;	/* size n, column counts for simplicial L */

    void *IPerm ;       /* size n, inverse permutation.  Only created by
                         * cholmod_solve2 if Bset is used. */

    /* ---------------------------------------------------------------------- */
    /* simplicial factorization */
    /* ---------------------------------------------------------------------- */

    size_t nzmax ;	/* size of i and x */

    void *p ;		/* p [0..ncol], the column pointers */
    void *i ;		/* i [0..nzmax-1], the row indices */
    void *x ;		/* x [0..nzmax-1], the numerical values */
    void *z ;
    void *nz ;		/* nz [0..ncol-1], the # of nonzeros in each column.
			 * i [p [j] ... p [j]+nz[j]-1] contains the row indices,
			 * and the numerical values are in the same locatins
			 * in x. The value of i [p [k]] is always k. */

    void *next ;	/* size ncol+2. next [j] is the next column in i/x */
    void *prev ;	/* size ncol+2. prev [j] is the prior column in i/x.
			 * head of the list is ncol+1, and the tail is ncol. */

    /* ---------------------------------------------------------------------- */
    /* supernodal factorization */
    /* ---------------------------------------------------------------------- */

    /* Note that L->x is shared with the simplicial data structure.  L->x has
     * size L->nzmax for a simplicial factor, and size L->xsize for a supernodal
     * factor. */

    size_t nsuper ;	/* number of supernodes */
    size_t ssize ;	/* size of s, integer part of supernodes */
    size_t xsize ;	/* size of x, real part of supernodes */
    size_t maxcsize ;	/* size of largest update matrix */
    size_t maxesize ;	/* max # of rows in supernodes, excl. triangular part */

    void *super ;	/* size nsuper+1, first col in each supernode */
    void *pi ;		/* size nsuper+1, pointers to integer patterns */
    void *px ;		/* size nsuper+1, pointers to real parts */
    void *s ;		/* size ssize, integer part of supernodes */

    /* ---------------------------------------------------------------------- */
    /* factorization type */
    /* ---------------------------------------------------------------------- */

    int ordering ;	/* ordering method used */

    int is_ll ;		/* TRUE if LL', FALSE if LDL' */
    int is_super ;	/* TRUE if supernodal, FALSE if simplicial */
    int is_monotonic ;	/* TRUE if columns of L appear in order 0..n-1.
			 * Only applicable to simplicial numeric types. */

    /* There are 8 types of factor objects that cholmod_factor can represent
     * (only 6 are used):
     *
     * Numeric types (xtype is not CHOLMOD_PATTERN)
     * --------------------------------------------
     *
     * simplicial LDL':  (is_ll FALSE, is_super FALSE).  Stored in compressed
     *	    column form, using the simplicial components above (nzmax, p, i,
     *	    x, z, nz, next, and prev).  The unit diagonal of L is not stored,
     *	    and D is stored in its place.  There are no supernodes.
     *
     * simplicial LL': (is_ll TRUE, is_super FALSE).  Uses the same storage
     *	    scheme as the simplicial LDL', except that D does not appear.
     *	    The first entry of each column of L is the diagonal entry of
     *	    that column of L.
     *
     * supernodal LDL': (is_ll FALSE, is_super TRUE).  Not used.
     *	    FUTURE WORK:  add support for supernodal LDL'
     *
     * supernodal LL': (is_ll TRUE, is_super TRUE).  A supernodal factor,
     *	    using the supernodal components described above (nsuper, ssize,
     *	    xsize, maxcsize, maxesize, super, pi, px, s, x, and z).
     *
     *
     * Symbolic types (xtype is CHOLMOD_PATTERN)
     * -----------------------------------------
     *
     * simplicial LDL': (is_ll FALSE, is_super FALSE).  Nothing is present
     *	    except Perm and ColCount.
     *
     * simplicial LL': (is_ll TRUE, is_super FALSE).  Identical to the
     *	    simplicial LDL', except for the is_ll flag.
     *
     * supernodal LDL': (is_ll FALSE, is_super TRUE).  Not used.
     *	    FUTURE WORK:  add support for supernodal LDL'
     *
     * supernodal LL': (is_ll TRUE, is_super TRUE).  A supernodal symbolic
     *	    factorization.  The simplicial symbolic information is present
     *	    (Perm and ColCount), as is all of the supernodal factorization
     *	    except for the numerical values (x and z).
     */

    int itype ; /* The integer arrays are Perm, ColCount, p, i, nz,
                 * next, prev, super, pi, px, and s.  If itype is
		 * CHOLMOD_INT, all of these are int arrays.
		 * CHOLMOD_INTLONG: p, pi, px are SuiteSparse_long, others int.
		 * CHOLMOD_LONG:    all integer arrays are SuiteSparse_long. */
    int xtype ; /* pattern, real, complex, or zomplex */
    int dtype ; /* x and z double or float */

} cholmod_factor ;

// in ../../src/CHOLMOD/Include/cholmod_core.h  skip forward to - line 1836 :
/* A dense matrix in column-oriented form.  It has no itype since it contains
 * no integers.  Entry in row i and column j is located in x [i+j*d].
 */

typedef struct cholmod_dense_struct
{
    size_t nrow ;	/* the matrix is nrow-by-ncol */
    size_t ncol ;
    size_t nzmax ;	/* maximum number of entries in the matrix */
    size_t d ;		/* leading dimension (d >= nrow must hold) */
    void *x ;		/* size nzmax or 2*nzmax, if present */
    void *z ;		/* size nzmax, if present */
    int xtype ;		/* pattern, real, complex, or zomplex */
    int dtype ;		/* x and z double or float */

} cholmod_dense ;

// in ../../src/CHOLMOD/Include/cholmod_core.h  skip forward to - line 2033 :
/* A sparse matrix stored in triplet form. */

typedef struct cholmod_triplet_struct
{
    size_t nrow ;	/* the matrix is nrow-by-ncol */
    size_t ncol ;
    size_t nzmax ;	/* maximum number of entries in the matrix */
    size_t nnz ;	/* number of nonzeros in the matrix */

    void *i ;		/* i [0..nzmax-1], the row indices */
    void *j ;		/* j [0..nzmax-1], the column indices */
    void *x ;		/* size nzmax or 2*nzmax, if present */
    void *z ;		/* size nzmax, if present */

    int stype ;		/* Describes what parts of the matrix are considered:
			 *
	* 0:  matrix is "unsymmetric": use both upper and lower triangular parts
	*     (the matrix may actually be symmetric in pattern and value, but
	*     both parts are explicitly stored and used).  May be square or
	*     rectangular.
	* >0: matrix is square and symmetric.  Entries in the lower triangular
	*     part are transposed and added to the upper triangular part when
	*     the matrix is converted to cholmod_sparse form.
	* <0: matrix is square and symmetric.  Entries in the upper triangular
	*     part are transposed and added to the lower triangular part when
	*     the matrix is converted to cholmod_sparse form.
	*
	* Note that stype>0 and stype<0 are different for cholmod_sparse and
	* cholmod_triplet.  The reason is simple.  You can permute a symmetric
	* triplet matrix by simply replacing a row and column index with their
	* new row and column indices, via an inverse permutation.  Suppose
	* P = L->Perm is your permutation, and Pinv is an array of size n.
	* Suppose a symmetric matrix A is represent by a triplet matrix T, with
	* entries only in the upper triangular part.  Then the following code:
	*
	*	Ti = T->i ;
	*	Tj = T->j ;
	*	for (k = 0 ; k < n  ; k++) Pinv [P [k]] = k ;
	*	for (k = 0 ; k < nz ; k++) Ti [k] = Pinv [Ti [k]] ;
	*	for (k = 0 ; k < nz ; k++) Tj [k] = Pinv [Tj [k]] ;
	*
	* creates the triplet form of C=P*A*P'.  However, if T initially
	* contains just the upper triangular entries (T->stype = 1), after
	* permutation it has entries in both the upper and lower triangular
	* parts.  These entries should be transposed when constructing the
	* cholmod_sparse form of A, which is what cholmod_triplet_to_sparse
	* does.  Thus:
	*
	*	C = cholmod_triplet_to_sparse (T, 0, &Common) ;
	*
	* will return the matrix C = P*A*P'.
	*
	* Since the triplet matrix T is so simple to generate, it's quite easy
	* to remove entries that you do not want, prior to converting T to the
	* cholmod_sparse form.  So if you include these entries in T, CHOLMOD
	* assumes that there must be a reason (such as the one above).  Thus,
	* no entry in a triplet matrix is ever ignored.
	*/

    int itype ; /* CHOLMOD_LONG: i and j are SuiteSparse_long.  Otherwise int */
    int xtype ; /* pattern, real, complex, or zomplex */
    int dtype ; /* x and z are double or float */

} cholmod_triplet ;

// -------- our (Matrix)  short and const_ forms of of the pointers :
typedef       cholmod_common*        CHM_CM;
typedef       cholmod_dense*         CHM_DN;
typedef const cholmod_dense*   const_CHM_DN;
typedef       cholmod_factor*        CHM_FR;
typedef const cholmod_factor*  const_CHM_FR;
typedef       cholmod_sparse*        CHM_SP;
typedef const cholmod_sparse*  const_CHM_SP;
typedef       cholmod_triplet*       CHM_TR;
typedef const cholmod_triplet* const_CHM_TR;


// --------- Matrix ("M_") R ("R_") pkg  routines "re-exported": ---------------

// "Implementation" of these in ./Matrix_stubs.c
int M_R_cholmod_start(CHM_CM);
void M_R_cholmod_error(int status, const char *file, int line, const char *message);
int M_cholmod_finish(CHM_CM);

CHM_SP M_cholmod_allocate_sparse(size_t nrow, size_t ncol,
				 size_t nzmax, int sorted,
				 int packed, int stype, int xtype,
				 CHM_CM);
int M_cholmod_free_factor(CHM_FR *L, CHM_CM);
int M_cholmod_free_dense(CHM_DN *A, CHM_CM);
int M_cholmod_free_sparse(CHM_SP *A, CHM_CM);
int M_cholmod_free_triplet(CHM_TR *T, CHM_CM);

long M_cholmod_nnz(const_CHM_SP, CHM_CM);
CHM_SP M_cholmod_speye(size_t nrow, size_t ncol, int xtype, CHM_CM);
CHM_SP M_cholmod_transpose(const_CHM_SP, int values, CHM_CM);
int M_cholmod_sort(CHM_SP A, CHM_CM);
CHM_SP M_cholmod_vertcat(const_CHM_SP, const_CHM_SP, int values, CHM_CM);
CHM_SP M_cholmod_copy(const_CHM_SP, int stype, int mode, CHM_CM);
CHM_SP M_cholmod_add(const_CHM_SP, const_CHM_SP, double alpha [2], double beta [2],
		     int values, int sorted, CHM_CM);

// from ../../src/CHOLMOD/Include/cholmod_cholesky.h - line 178 :
#define CHOLMOD_A    0		/* solve Ax=b */
#define CHOLMOD_LDLt 1		/* solve LDL'x=b */
#define CHOLMOD_LD   2		/* solve LDx=b */
#define CHOLMOD_DLt  3		/* solve DL'x=b */
#define CHOLMOD_L    4		/* solve Lx=b */
#define CHOLMOD_Lt   5		/* solve L'x=b */
#define CHOLMOD_D    6		/* solve Dx=b */
#define CHOLMOD_P    7		/* permute x=Px */
#define CHOLMOD_Pt   8		/* permute x=P'x */

CHM_DN M_cholmod_solve(int, const_CHM_FR, const_CHM_DN, CHM_CM);
CHM_SP M_cholmod_spsolve(int, const_CHM_FR, const_CHM_SP, CHM_CM);
int M_cholmod_sdmult(const_CHM_SP, int, const double*, const double*,
		     const_CHM_DN, CHM_DN Y, CHM_CM);
CHM_SP M_cholmod_ssmult(const_CHM_SP, const_CHM_SP, int, int, int,
			CHM_CM);
int M_cholmod_factorize(const_CHM_SP, CHM_FR L, CHM_CM);
int M_cholmod_factorize_p(const_CHM_SP, double *beta, int *fset,
			  size_t fsize, CHM_FR L, CHM_CM);
CHM_SP M_cholmod_copy_sparse(const_CHM_SP, CHM_CM);
CHM_DN M_cholmod_copy_dense(const_CHM_DN, CHM_CM);
CHM_SP M_cholmod_aat(const_CHM_SP, int *fset, size_t fsize, int mode,
		     CHM_CM);
int M_cholmod_band_inplace(CHM_SP A, int k1, int k2, int mode, CHM_CM);
CHM_SP M_cholmod_add(const_CHM_SP, const_CHM_SP, double alpha[2], double beta[2],
		     int values, int sorted, CHM_CM);
CHM_DN M_cholmod_allocate_dense(size_t nrow, size_t ncol, size_t d,
				int xtype, CHM_CM);
CHM_FR M_cholmod_analyze(const_CHM_SP, CHM_CM);
CHM_FR M_cholmod_analyze_p(const_CHM_SP, int *Perm, int *fset,
				    size_t fsize, CHM_CM);
int M_cholmod_change_factor(int to_xtype, int to_ll, int to_super,
			    int to_packed, int to_monotonic,
			    CHM_FR L, CHM_CM);
CHM_FR M_cholmod_copy_factor(const_CHM_FR, CHM_CM);
CHM_SP M_cholmod_factor_to_sparse(const_CHM_FR, CHM_CM);
CHM_SP M_cholmod_dense_to_sparse(const_CHM_DN, int values, CHM_CM);
int M_cholmod_defaults (CHM_CM);
CHM_SP M_cholmod_triplet_to_sparse(const cholmod_triplet*, int nzmax, CHM_CM);
CHM_SP M_cholmod_submatrix(const_CHM_SP, int *rset, int rsize, int *cset,
			   int csize, int values, int sorted,
			   CHM_CM);
CHM_TR M_cholmod_sparse_to_triplet(const_CHM_SP, CHM_CM);
CHM_DN M_cholmod_sparse_to_dense(const_CHM_SP, CHM_CM);
CHM_TR M_cholmod_allocate_triplet (size_t nrow, size_t ncol, size_t nzmax,
				   int stype, int xtype, CHM_CM);

// from ../../src/CHOLMOD/Include/cholmod_matrixops.h - line 107 :
/* scaling modes, selected by the scale input parameter: */
#define CHOLMOD_SCALAR 0	/* A = s*A */
#define CHOLMOD_ROW 1		/* A = diag(s)*A */
#define CHOLMOD_COL 2		/* A = A*diag(s) */
#define CHOLMOD_SYM 3		/* A = diag(s)*A*diag(s) */

int M_cholmod_scale(const_CHM_DN, int scale, CHM_SP, CHM_CM);

#ifdef	__cplusplus
}
#endif

#endif  /* MATRIX_CHOLMOD_H */
