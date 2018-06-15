## config -- Simple shell script to get the values of basic R configure
## variables, or the header and library flags necessary for linking
## against R.
##
## Usage:
##   R CMD config [options] [VAR]

## Copyright (C) 2002-2018 The R Core Team
##
## This document is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## A copy of the GNU General Public License is available at
## https://www.R-project.org/Licenses/

revision='$Revision: 74001 $'
version=`set - ${revision}; echo ${2}`
version="R configuration information retrieval script: ${R_VERSION} (r${version})

Copyright (C) 2002-2018 The R Core Team.
This is free software; see the GNU General Public License version 2
or later for copying conditions.  There is NO warranty."

usage="Usage: R CMD config [options] [VAR]

Get the value of a basic R configure variable VAR which must be among
those listed in the 'Variables' section below, or the header and
library flags necessary for linking against R.

Options:
  -h, --help            print short help message and exit
  -v, --version         print version info and exit
      --cppflags        print pre-processor flags required to compile
			a C/C++ file using R as a library
      --ldflags         print linker flags needed for linking a front-end
                        against the R library
      --no-user-files   ignore customization files under ~/.R
      --no-site-files   ignore site customization files under R_HOME/etc
      --all             print names and values of all variables below

Variables:
  BLAS_LIBS     flags needed for linking against external BLAS libraries
  CC            C compiler command
  CFLAGS        C compiler flags
  CPICFLAGS     special flags for compiling C code to be included in a
		shared library
  CPP           C preprocessor
  CPPFLAGS      C/C++ preprocessor flags, e.g. -I<dir> if you have
		headers in a nonstandard directory <dir>
  CXX           default compiler command for C++ code
  CXXCPP        C++ preprocessor
  CXXFLAGS      compiler flags for CXX
  CXXPICFLAGS   special flags for compiling C++ code to be included in a
		shared library
  CXX98         compiler command for C++98 code
  CXX98CPP      C++98 preprocessor
  CXX98FLAGS    compiler flags for CXX98
  CXX98PICFLAGS special flags for compiling C++98 code to be included in a
		shared library
  CXX11         compiler command for C++11 code
  CXX11STD      flag used with CXX11 to enable C++11 support
  CXX11FLAGS    further compiler flags for CXX11
  CXX11PICFLAGS
                special flags for compiling C++11 code to be included in
                a shared library
  CXX14         compiler command for C++14 code
  CXX14STD      flag used with CXX14 to enable C++14 support
  CXX14FLAGS    further compiler flags for CXX14
  CXX14PICFLAGS
                special flags for compiling C++14 code to be included in
                a shared library
  CXX17         compiler command for C++17 code
  CXX17STD      flag used with CXX17 to enable C++17 support
  CXX17FLAGS    further compiler flags for CXX17
  CXX17PICFLAGS
                special flags for compiling C++17 code to be included in
                a shared library
  DYLIB_EXT	file extension (including '.') for dynamic libraries
  DYLIB_LD      command for linking dynamic libraries which contain
		object files from a C or Fortran compiler only
  DYLIB_LDFLAGS
		special flags used by DYLIB_LD
  F77           Fortran 77 compiler command
  FFLAGS        Fortran 77 compiler flags
  FLIBS         linker flags needed to link Fortran code
  FPICFLAGS     special flags for compiling Fortran code to be turned
		into a shared library
  FC            Fortran 9x compiler command
  FCFLAGS       Fortran 9x compiler flags
  FCPICFLAGS    special flags for compiling Fortran 9x code to be turned
		into a shared library
  JAR           Java archive tool command
  JAVA          Java interpreter command
  JAVAC         Java compiler command
  JAVAH         Java header and stub generator command
  JAVA_HOME     path to the home of Java distribution
  JAVA_LIBS     flags needed for linking against Java libraries
  JAVA_CPPFLAGS C preprocessor flags needed for compiling JNI programs
  LAPACK_LIBS   flags needed for linking against external LAPACK libraries
  LIBnn         location for libraries, e.g. 'lib' or 'lib64' on this platform
  LDFLAGS       linker flags, e.g. -L<dir> if you have libraries in a
		nonstandard directory <dir>
  OBJC          Objective C compiler command
  OBJCFLAGS     Objective C compiler flags
  MAKE          Make command
  SAFE_FFLAGS   Safe (as conformant as possible) Fortran 77 compiler flags
  SHLIB_CFLAGS  additional CFLAGS used when building shared objects
  SHLIB_CXXLD   command for linking shared objects which contain
		object files from a C++ compiler (and CXX98 CXX11 CXX14 CXX17)
  SHLIB_CXXLDFLAGS
		special flags used by SHLIB_CXXLD (and CXX98 CXX11 CXX14 CXX17)
  SHLIB_EXT	file extension (including '.') for shared objects
  SHLIB_FFLAGS  additional FFLAGS used when building shared objects
  SHLIB_LD      command for linking shared objects which contain
		object files from a C or Fortran compiler only
  SHLIB_LDFLAGS
		special flags used by SHLIB_LD
  SHLIB_FCLD, SHLIB_FCLDFLAGS
		ditto when using Fortran 9x
  TCLTK_CPPFLAGS
		flags needed for finding the tcl.h and tk.h headers
  TCLTK_LIBS    flags needed for linking against the Tcl and Tk libraries
"

if test "${R_OSTYPE}" = "windows"; then
  usage="${usage}
Windows only:
  COMPILED_BY   name and version of compiler used to build R"
fi

usage="${usage}
  
Report bugs at <https://bugs.R-project.org>."

## <NOTE>
## The variables are basically the precious configure variables (with
## the R_* and MAIN_* ones removed), plus FLIBS and BLAS_LIBS.
## One could use
##   precious_configure_vars=`~/src/R/configure --help \
##     | sed -n '/^Some influential/,/^[^ ]/p' \
##     | sed '/^[^ ]/d' \
##     | sed 's/^  //' \
##     | cut -f1 -d ' ' \
##     | grep -v '^MAIN_' \
##     | grep -v '^R_' \
##     | sort \
##     | uniq`
## to obtain the configure vars and hence create most of the above usage
## info as well as the list of accepted variables below automatically.
## </NOTE>

if test $# = 0; then
  echo "${usage}"
  exit 1
fi

if test "${R_OSTYPE}" = "windows"; then
  MAKE=make
  R_DOC_DIR=${R_HOME}/doc
  R_INCLUDE_DIR=${R_HOME}/include
  R_SHARE_DIR=${R_HOME}/share
fi

makefiles="-f ${R_HOME}/etc${R_ARCH}/Makeconf -f ${R_SHARE_DIR}/make/config.mk"
## avoid passing down -jN
MAKEFLAGS=
export MAKEFLAGS
query="${MAKE} -s ${makefiles} print R_HOME=${R_HOME}"

LIBR=`eval $query VAR=LIBR`
STATIC_LIBR=`eval $query VAR=STATIC_LIBR`
MAIN_LDFLAGS=`eval $query VAR=MAIN_LDFLAGS`
LIBS=`eval $query VAR=LIBS`
LDFLAGS=`eval $query VAR=LDFLAGS`


if test -n "${R_ARCH}"; then
  includes="-I${R_INCLUDE_DIR} -I${R_INCLUDE_DIR}${R_ARCH}"
else
  includes="-I${R_INCLUDE_DIR}"
fi

var=
personal="yes"
site="yes"
all="no"
while test -n "${1}"; do
  case "${1}" in
    -h|--help)
      echo "${usage}"; exit 0 ;;
    -v|--version)
      echo "${version}"; exit 0 ;;
    --cppflags)
      if test -z "${LIBR}"; then
	if test -z "${STATIC_LIBR}"; then
	  echo "R was not built as a library" >&2
	else
	  echo "${includes}"
	fi
      else
	echo "${includes}"
      fi
      exit 0
      ;;
    --ldflags)
      ## changed in R 3.1.0 to be those needed to link a front-end
      if test -z "${LIBR}"; then
	if test -z "${STATIC_LIBR}"; then
	  echo "R was not built as a library" >&2
	else
	  echo "${MAIN_LDFLAGS} ${LDFLAGS} ${STATIC_LIBR}"
	fi
      else
	echo "${MAIN_LDFLAGS} ${LDFLAGS} ${LIBR} ${LIBS}"
      fi
      exit 0
      ;;
    --no-user-files)
      personal="no"
      ;;
    --no-site-files)
      site="no"
      ;;
    --all)
      all="yes"
      ;;
    *)
      if test -z "${var}"; then
	var="${1}"
      else
	echo "ERROR: cannot query more than one variable" >&2
	exit 1
      fi
      ;;
  esac
  shift
done

## quotes added in R 3.3.2
if test "${site}" = "yes"; then
: ${R_MAKEVARS_SITE="${R_HOME}/etc${R_ARCH}/Makevars.site"}
  if test -f "${R_MAKEVARS_SITE}"; then
    makefiles="${makefiles} -f \"${R_MAKEVARS_SITE}\""
  fi
fi
if test "${personal}" = "yes"; then
  if test "${R_OSTYPE}" = "windows"; then
    if test -f "${R_MAKEVARS_USER}"; then
      makefiles="${makefiles} -f \"${R_MAKEVARS_USER}\""
    elif test ${R_ARCH} = "/x64" -a -f "${HOME}/.R/Makevars.win64"; then
      makefiles="${makefiles} -f \"${HOME}\"/.R/Makevars.win64"
    elif test -f "${HOME}/.R/Makevars.win"; then
      makefiles="${makefiles} -f \"${HOME}\"/.R/Makevars.win"
    elif test -f "${HOME}/.R/Makevars"; then
      makefiles="${makefiles} -f \"${HOME}\"/.R/Makevars"
    fi
  else
    . ${R_HOME}/etc${R_ARCH}/Renviron
    if test -f "${R_MAKEVARS_USER}"; then
      makefiles="${makefiles} -f \"${R_MAKEVARS_USER}\""
    elif test -f "${HOME}/.R/Makevars-${R_PLATFORM}"; then
      makefiles="${makefiles} -f \"${HOME}\"/.R/Makevars-${R_PLATFORM}"
    elif test -f "${HOME}/.R/Makevars"; then
      makefiles="${makefiles} -f \"${HOME}\"/.R/Makevars"
    fi
  fi
fi
query="${MAKE} -s ${makefiles} print R_HOME=${R_HOME}"

ok_c_vars="CC CFLAGS CPICFLAGS CPP CPPFLAGS"
ok_cxx_vars="CXX CXXCPP CXXFLAGS CXXPICFLAGS CXX11 CXX11STD CXX11FLAGS CXX11PICFLAGS CXX14 CXX14STD CXX14FLAGS CXX14PICFLAGS CXX98 CXX98STD CXX98FLAGS CXX98PICFLAGS CXX17 CXX17STD CXX17FLAGS CXX17PICFLAGS CXX1X CXX1XSTD CXX1XFLAGS CXX1XPICFLAGS"
ok_dylib_vars="DYLIB_EXT DYLIB_LD DYLIB_LDFLAGS"
ok_objc_vars="OBJC OBJCFLAGS"
ok_java_vars="JAVA JAVAC JAVAH JAR JAVA_HOME JAVA_LIBS JAVA_CPPFLAGS"
ok_f77_vars="F77 FFLAGS FPICFLAGS FLIBS SAFE_FFLAGS FC FCFLAGS FCPICFLAGS"
ok_ld_vars="LDFLAGS"
ok_shlib_vars="SHLIB_CFLAGS SHLIB_CXXLD SHLIB_CXXLDFLAGS SHLIB_CXX98LD SHLIB_CXX98LDFLAGS SHLIB_CXX11LD SHLIB_CXX11LDFLAGS SHLIB_CXX14LD SHLIB_CXX14LDFLAGS SHLIB_CXX17LD SHLIB_CXX17LDFLAGS SHLIB_EXT SHLIB_FFLAGS SHLIB_LD SHLIB_LDFLAGS SHLIB_FCLD SHLIB_FCLDFLAGS SHLIB_CXX1XLD SHLIB_CXX1XLDFLAGS"
ok_tcltk_vars="TCLTK_CPPFLAGS TCLTK_LIBS"
ok_other_vars="BLAS_LIBS LAPACK_LIBS MAKE LIBnn LOCAL_SOFT COMPILED_BY"

if test "${all}" = "yes"; then
  query="${MAKE} -s ${makefiles} print-name-and-value R_HOME=${R_HOME}"
  for v in ${ok_c_vars} ${ok_cxx_vars} ${ok_dylib_vars} ${ok_f77_vars} \
	   ${ok_objc_vars} ${ok_java_vars} \
	   ${ok_ld_vars} ${ok_shlib_vars} ${ok_tcltk_vars} \
	   ${ok_other_vars}; do
    eval "${query} VAR=${v}"
  done
  exit 0
fi

## Can we do this elegantly using case?

var_ok=no
for v in ${ok_c_vars} ${ok_cxx_vars} ${ok_dylib_vars} ${ok_f77_vars} \
	 ${ok_objc_vars} ${ok_java_vars} \
	 ${ok_ld_vars} ${ok_shlib_vars} ${ok_tcltk_vars} \
	 ${ok_other_vars}; do
  if test "${var}" = "${v}"; then
    var_ok=yes
    break
  fi
done

if test "${var_ok}" = yes; then
  eval "${query} VAR=${var}"
else
  echo "ERROR: no information for variable '${var}'"
  exit 1
fi

### Local Variables: ***
### mode: sh ***
### sh-indentation: 2 ***
### End: ***
