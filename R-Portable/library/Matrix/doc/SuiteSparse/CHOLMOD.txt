CHOLMOD: a sparse CHOLesky MODification package, Copyright (c) 2005-2012.
http://www.suitesparse.com
-----------------------------------------------

    CHOLMOD is a set of routines for factorizing sparse symmetric positive
    definite matrices of the form A or AA', updating/downdating a sparse
    Cholesky factorization, solving linear systems, updating/downdating
    the solution to the triangular system Lx=b, and many other sparse matrix
    functions for both symmetric and unsymmetric matrices.  Its supernodal
    Cholesky factorization relies on LAPACK and the Level-3 BLAS, and obtains
    a substantial fraction of the peak performance of the BLAS.  Both real and
    complex matrices are supported.  CHOLMOD is written in ANSI/ISO C, with both
    C and MATLAB interfaces.  This code works on Microsoft Windows and many
    versions of Unix and Linux.


Some Modules of CHOLMOD are copyrighted by the University of Florida (the
Core and Partition Modules).  The rest are copyrighted by the authors:
Timothy A. Davis (all of them), and William W. Hager (the Modify Module).

CHOLMOD relies on several other packages:  AMD, CAMD, COLAMD, CCOLAMD,
SuiteSparse_config, METIS, the BLAS, and LAPACK.  All but METIS, the BLAS, and
LAPACK are part of SuiteSparse.

AMD is authored by T. Davis, Iain Duff, and Patrick Amestoy.
COLAMD is authored by T. Davis and Stefan Larimore, with algorithmic design
in collaboration with John Gilbert and Esmond Ng.
CCOLAMD is authored by T. Davis and Siva Rajamanickam.
CAMD is authored by T. Davis and Y. Chen.

LAPACK and the BLAS are authored by Jack Dongarra and many others.
LAPACK is available at http://www.netlib.org/lapack

METIS is authored by George Karypis, Univ. of Minnesota.  Its use in CHOLMOD
is optional.  See http://www-users.cs.umn.edu/~karypis/metis.
Place a copy of the metis-4.0 directory in the same directory that
contains the CHOLMOD, AMD, COLAMD, and CCOLAMD directories prior to compiling
with "make".

If you do not wish to use METIS, you must edit SuiteSparse_config and change
the line:

    CHOLMOD_CONFIG =

to

    CHOLMOD_CONFIG = -DNPARTITION

The CHOLMOD, AMD, COLAMD, CCOLAMD, and SuiteSparse)config directories must all
reside in a common parent directory.  To compile all these libraries, edit
SuiteSparse)config/SuiteSparse)config.mk to reflect your environment (C
compiler, location of the BLAS, and so on) and then type "make" in either the
CHOLMOD directory or in the parent directory of CHOLMOD.  See each package for
more details on how to compile them.

For use in MATLAB (on any system, including Windows):  start MATLAB,
cd to the CHOLMOD/MATLAB directory, and type cholmod_make in the MATLAB
Command Window.  This is the best way to compile CHOLMOD for MATLAB; it
provides a workaround for a METIS design feature, in which METIS terminates
your program (and thus MATLAB) if it runs out of memory.  Using cholmod_make
also ensures your mexFunctions are compiled with -fexceptions, so that
exceptions are handled properly (when hitting control-C in the MATLAB command
window, for example).

On the Pentium, do NOT use the Intel MKL BLAS prior to MKL Version 8.0 with
CHOLMOD.  Older versions (prior to 8.0) have a bug in dgemm when computing
A*B'.  The bug generates a NaN result, when the inputs are well-defined.  Use
the Goto BLAS or the MKL v8.0 BLAS instead.  The Goto BLAS is faster and more
reliable.  See http://www.tacc.utexas.edu/~kgoto/ or
http://www.cs.utexas.edu/users/flame/goto/.
Sadly, the Intel MKL BLAS 7.x is the default for MATLAB 7.0.4.  See
http://www.mathworks.com/support/bugreports/details.html?rp=252103 for more
details.  To workaround this problem on Linux, set environment variable
BLAS_VERSION to libmkl_p3.so:libguide.so. On Windows, set environment variable
BLAS_VERSION to mkl_p3.dll.  Better yet, get MATLAB 7sp3 (MATLAB 7.1) or later.

Acknowledgements:  this work was supported in part by the National Science
Foundation (NFS CCR-0203270 and DMS-9803599), and a grant from Sandia National
Laboratories (Dept. of Energy) which supported the development of CHOLMOD's
Partition Module.

