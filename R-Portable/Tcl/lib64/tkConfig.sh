# tkConfig.sh --
# 
# This shell script (for sh) is generated automatically by Tk's
# configure script.  It will create shell variables for most of
# the configuration options discovered by the configure script.
# This script is intended to be included by the configure scripts
# for Tk extensions so that they don't have to figure this all
# out for themselves.  This file does not duplicate information
# already provided by tclConfig.sh, so you may need to use that
# file in addition to this one.
#
# The information in this file is specific to a single platform.

TK_DLL_FILE="tk86.dll"

# Tk's version number.
TK_VERSION='8.6'
TK_MAJOR_VERSION='8'
TK_MINOR_VERSION='6'
TK_PATCH_LEVEL='.4'

# -D flags for use with the C compiler.
TK_DEFS='-DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DSTDC_HEADERS=1 -DTCL_THREADS=1 -DUSE_THREAD_ALLOC=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DMODULE_SCOPE=extern -DTCL_CFG_DO64BIT=1 -DHAVE_NO_SEH=1 -DHAVE_CAST_TO_UNION=1 -DHAVE_UXTHEME_H=1 -DHAVE_VSSYM32_H=1 -DNDEBUG=1 -DTCL_CFG_OPTIMIZED=1 '

# Flag, 1: we built a shared lib, 0 we didn't
TK_SHARED_BUILD=1

# This indicates if Tk was build with debugging symbols
TK_DBGX=

# The name of the Tk library (may be either a .a file or a shared library):
TK_LIB_FILE='libtk86.a'

# Additional libraries to use when linking Tk.
TK_LIBS='-lnetapi32 -lkernel32 -luser32 -ladvapi32 -lws2_32 -lgdi32 -lcomdlg32 -limm32 -lcomctl32 -lshell32 -luuid -lole32 -loleaut32'

# Top-level directory in which Tcl's platform-independent files are
# installed.
TK_PREFIX='/c/Tclbuild/Tcl64'

# Top-level directory in which Tcl's platform-specific files (e.g.
# executables) are installed.
TK_EXEC_PREFIX='/c/Tclbuild/Tcl64'

# -l flag to pass to the linker to pick up the Tcl library
TK_LIB_FLAG='-ltk86'

# String to pass to linker to pick up the Tk library from its
# build directory.
TK_BUILD_LIB_SPEC='-L/c/Tclbuild/build64/tk8.6.4/win -ltk86'

# String to pass to linker to pick up the Tk library from its
# installed directory.
TK_LIB_SPEC='-L/c/Tclbuild/Tcl64/lib64 -ltk86'

# Location of the top-level source directory from which Tk was built.
# This is the directory that contains a README file as well as
# subdirectories such as generic, unix, etc.  If Tk was compiled in a
# different place than the directory containing the source files, this
# points to the location of the sources, not the location where Tk was
# compiled.
TK_SRC_DIR='/c/Tclbuild/build64/tk8.6.4'

# Needed if you want to make a 'fat' shared library library
# containing tk objects or link a different wish.
TK_CC_SEARCH_FLAGS=''
TK_LD_SEARCH_FLAGS=''

# The name of the Tk stub library (.a):
TK_STUB_LIB_FILE='libtkstub86.a'

# -l flag to pass to the linker to pick up the Tk stub library
TK_STUB_LIB_FLAG='-ltkstub86'

# String to pass to linker to pick up the Tk stub library from its
# build directory.
TK_BUILD_STUB_LIB_SPEC='-L/c/Tclbuild/build64/tk8.6.4/win -ltkstub86'

# String to pass to linker to pick up the Tk stub library from its
# installed directory.
TK_STUB_LIB_SPEC='-L/c/Tclbuild/Tcl64/lib64 -ltkstub86'

# Path to the Tk stub library in the build directory.
TK_BUILD_STUB_LIB_PATH='/c/Tclbuild/build64/tk8.6.4/win/libtkstub86.a'

# Path to the Tk stub library in the install directory.
TK_STUB_LIB_PATH='/c/Tclbuild/Tcl64/lib64/libtkstub86.a'
