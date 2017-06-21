SuiteSparse_config, 2013, Timothy A. Davis, http://www.suitesparse.com
(formerly the UFconfig package)

SuiteSparse_config contains configuration settings for all many of the software
packages that I develop or co-author.  Note that older versions of some of
these packages do not require SuiteSparse_config.

  Package  Description
  -------  -----------
  AMD      approximate minimum degree ordering
  CAMD     constrained AMD
  COLAMD   column approximate minimum degree ordering
  CCOLAMD  constrained approximate minimum degree ordering
  UMFPACK  sparse LU factorization, with the BLAS
  CXSparse int/long/real/complex version of CSparse
  CHOLMOD  sparse Cholesky factorization, update/downdate
  KLU      sparse LU factorization, BLAS-free
  BTF      permutation to block triangular form
  LDL      concise sparse LDL'
  LPDASA   LP Dual Active Set Algorithm
  RBio     read/write files in Rutherford/Boeing format
  SPQR     sparse QR factorization (full name: SuiteSparseQR)

SuiteSparse_config is not required by these packages:

  CSparse       a Concise Sparse matrix package
  MATLAB_Tools  toolboxes for use in MATLAB

In addition, the xerbla/ directory contains Fortan and C versions of the
BLAS/LAPACK xerbla routine, which is called when an invalid input is passed to
the BLAS or LAPACK.  The xerbla provided here does not print any message, so
the entire Fortran I/O library does not need to be linked into a C application.
Most versions of the BLAS contain xerbla, but those from K. Goto do not.  Use
this if you need too.

If you edit this directory (SuiteSparse_config.mk in particular) then you
must do "make purge ; make" in the parent directory to recompile all of
SuiteSparse.  Otherwise, the changes will not necessarily be applied.

--------------------------------------------------------------------------------
A note on the update to SuiteSparse Version 4.0.0:  The SuiteSparse_long macro
defines an integer that is 64-bits in size on 64-bit platforms, and 32-bits on
32-bit platforms.  It was formerly called UF_long, but UF_long has been removed
because of potential name conflicts.  UF_long is still available to user codes,
but it can now be safely #undef'd in case of name conflicts in user code.
Future codes should use SuiteSparse_long in place of UF_long.
--------------------------------------------------------------------------------

