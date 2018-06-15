#-*- Makefile -*-
#
# ${R_HOME}/tests/Makefile.install

srcdir = .
top_srcdir = ..

top_builddir = ..

all check: test-all-basics
check-devel: check test-all-devel
check-all: check-devel test-Recommended

include $(top_builddir)/etc$(R_ARCH)/Makeconf
include Makefile.common


## GNU gettext disables LANGUAGE if LC_ALL=C, but other systems might not.
R = LANGUAGE=en LC_ALL=C SRCDIR=$(srcdir) R_DEFAULT_PACKAGES= $(top_builddir)/bin/R --vanilla
R2 = R_DEFAULT_PACKAGES= $(top_builddir)/bin/R --vanilla
R3 = $(top_builddir)/bin/R CMD check
RDIFF = $(top_builddir)/bin/R CMD Rdiff
RDCONV = LC_CTYPE=C $(top_builddir)/bin/R CMD Rdconv
MK = $(MAKE)

all-basic-tests = BasePackages Specific Reg Internet
## Keep in line with Makefile.common.
## not Docs Standalone Packages
all-devel-tests = DateTime IsAs Random Demo Primitive Regexp Internet2 CRANtools Segfault


## <NOTE>
## These depend on an internet connection, and the sites being up.
## So allow this to fail: it may be slow doing so.
test-Internet:
	@$(ECHO) "running tests of Internet functions"
	@$(ECHO) "  expect some differences"
	-@$(MAKE) $(test-out-internet) RVAL_IF_DIFF=0

test-Internet2:
	@$(ECHO) "running more Internet and socket tests"
	-@$(MK) $(test-out-internet2) RVAL_IF_DIFF=0
## </NOTE>

test-BasePackages:
	@$(MKINSTALLDIRS) Packages
	@$(ECHO) "tools::testInstalledPackages(outDir='Packages', scope='base')" | $(R) --slave

test-Recommended:
	@$(MKINSTALLDIRS) Packages
	@$(ECHO) "tools::testInstalledPackages(outDir='Packages', scope='recommended')" | $(R) --slave


mostlyclean: clean
clean:
	-@rm -f stamp-R Rplot* Rprof.out data dumpdata.R \
	  reg-plot-latin1.ps reg-plot.ps reg-tests-?.ps \
	  R-exts.* R-intro.R R-intro.Rout \
	  FALSE* .R .tex mirrors.html PACKAGES*
	-@rm -f testit.txt testit.html testit.tex testit-Ex.R
	-@rm -f ver10.txt ver10.html ver10.tex ver10-Ex.R
	-@rm -f ver11.txt ver11.html ver11.tex ver11-Ex.R
	-@rm -Rf anRpackage myTst* myLib

clean2: clean
	-@rm -f $(test-out) $(test-src-auto) .RData

distclean: clean
	-@for d in $(SUBDIRS); do \
	  (cd $${d} && $(MAKE) $@); \
	done
	-@rm -f $(test-out) $(test-src-auto) .RData
	-@rm -Rf *.Rcheck Packages
maintainer-clean: distclean
