SuiteSparseQR version 1.1.0, Sept 20, 2008, Copyright (c) 2008, Timothy A. Davis

SuiteSparseQR is a a multithread, multifrontal, rank-revealing sparse QR
factorization method.

QUICK START FOR MATLAB USERS (on Windows, Linux, Solaris, or the Mac OS): To
compile and test the MATLAB mexFunctions, do this in the MATLAB command window:

    cd SuiteSparse/SPQR/MATLAB
    spqr_install
    spqr_demo

FOR MORE DETAILS: please see the User Guide in Doc/spqr_user_guide.pdf.

FOR LINUX/UNIX/Mac USERS who want to use the C++ callable library:

    To compile the C++ library and run a short demo, just type "make" in
        the Unix shell.

    To compile the SuiteSparseQR C++ library, in the Unix shell, do:

        cd Lib ; make

    To compile and test an exhaustive test, edit the Tcov/Makefile to select
    the LAPACK and BLAS libraries, and then do (in the Unix shell):

        cd Tcov ; make

    Compilation options in UFconfig/UFconfig.mk, SPQR/*/Makefile,
    or SPQR/MATLAB/spqr_make.m:

        -DNPARTITION    to compile without METIS (default is to use METIS)

        -DNEXPERT       to compile without the min 2-norm solution option
                        (default is to include the Expert routines)

        -DHAVE_TBB      to compile with Intel's Threading Building Blocks
                        (default is to not use Intel TBB)

        -DTIMING        to compile with timing and exact flop counts enabled
                        (default is to not compile with timing and flop counts)

--------------------------------------------------------------------------------

SuiteSparseQR is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

SuiteSparseQR is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this Module; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA  02110-1301, USA.
