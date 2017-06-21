## ${R_HOME}/share/make/basepkg.mk


.PHONY: front instdirs mkR mkR1 mkR2 mkRbase mkdesc mkdesc2 mkdemos mkdemos2 \
  mkexec mkman mkpo mksrc mksrc-win mksrc-win2 mkRsimple mklazy mklazycomp \
  mkfigs

front:
	@for f in $(FRONTFILES); do \
	  if test -f $(srcdir)/$${f}; then \
	    $(INSTALL_DATA) $(srcdir)/$${f} \
	      $(top_builddir)/library/$(pkg); \
	  fi; \
	done

instdirs:
	@for D in $(INSTDIRS); do \
	 if test -d $(srcdir)/inst/$${D}; then \
	   $(MKINSTALLDIRS) $(top_builddir)/library/$(pkg)/$${D}; \
	   for f in `ls -d $(srcdir)/inst/$${D}/*`; do \
	     $(INSTALL_DATA) $${f} $(top_builddir)/library/$(pkg)/$${D}; \
	   done; \
	 fi; done

## used for base on Windows.  Every package except base has a namespace
mkR1:
	@$(MKINSTALLDIRS) $(top_builddir)/library/$(pkg)/R
	@(f=$${TMPDIR:-/tmp}/R$$$$; \
	  if test "$(R_KEEP_PKG_SOURCE)" = "yes"; then \
	    for rsrc in $(RSRC); do \
	      $(ECHO) "#line 1 \"$${rsrc}\"" >> "$${f}"; \
	      cat $${rsrc} >> "$${f}"; \
	    done; \
	  else \
	    cat $(RSRC) > "$${f}"; \
	  fi; \
	  $(SHELL) $(top_srcdir)/tools/move-if-change "$${f}" all.R)
	@if test -f $(srcdir)/NAMESPACE;  then \
	  $(INSTALL_DATA) $(srcdir)/NAMESPACE $(top_builddir)/library/$(pkg); \
	fi
	@rm -f $(top_builddir)/library/$(pkg)/Meta/nsInfo.rds

## version for S4-using packages
mkR2:
	@$(MKINSTALLDIRS) $(top_builddir)/library/$(pkg)/R
	@(f=$${TMPDIR:-/tmp}/R$$$$; \
          $(ECHO) ".packageName <- \"$(pkg)\"" >  "$${f}"; \
	  if test "$(R_KEEP_PKG_SOURCE)" = "yes"; then \
		for rsrc in `LC_COLLATE=C ls $(srcdir)/R/*.R`; do \
		  $(ECHO) "#line 1 \"$${rsrc}\"" >> "$${f}"; \
		    cat $${rsrc} >> "$${f}"; \
		done; \
	  else \
		cat `LC_COLLATE=C ls $(srcdir)/R/*.R` >> "$${f}"; \
	  fi; \
	  $(SHELL) $(top_srcdir)/tools/move-if-change "$${f}" all.R)
	@rm -f $(top_builddir)/library/$(pkg)/Meta/nsInfo.rds
	@$(INSTALL_DATA) $(srcdir)/NAMESPACE $(top_builddir)/library/$(pkg)
	@rm -f $(top_builddir)/library/$(pkg)/Meta/nsInfo.rds

## version for base on Unix, substitutes for @which@
## (and so cannot be in src/library/base/Makefile.in)
mkRbase:
	@$(MKINSTALLDIRS) $(top_builddir)/library/$(pkg)/R
	@(f=$${TMPDIR:-/tmp}/R$$$$; \
	  if test "$(R_KEEP_PKG_SOURCE)" = "yes"; then \
	    $(ECHO) > "$${f}"; \
	    for rsrc in $(RSRC); do \
	      $(ECHO) "#line 1 \"$${rsrc}\"" >> "$${f}"; \
	      cat $${rsrc} >> "$${f}"; \
	    done; \
	  else \
	    cat $(RSRC) > "$${f}"; \
	  fi; \
	  f2=$${TMPDIR:-/tmp}/R2$$$$; \
	  sed -e "s:@WHICH@:${WHICH}:" "$${f}" > "$${f2}"; \
	  rm -f "$${f}"; \
	  $(SHELL) $(top_srcdir)/tools/move-if-change "$${f2}" all.R)
	@if ! test -f $(top_builddir)/library/$(pkg)/R/$(pkg); then \
	  $(INSTALL_DATA) all.R $(top_builddir)/library/$(pkg)/R/$(pkg); \
	else if test all.R -nt $(top_builddir)/library/$(pkg)/R/$(pkg); then \
	  $(INSTALL_DATA) all.R $(top_builddir)/library/$(pkg)/R/$(pkg); \
	  fi \
	fi

mkdesc:
	@if test -f DESCRIPTION; then \
	  if test "$(PKG_BUILT_STAMP)" != ""; then \
	    $(ECHO) "tools:::.install_package_description('.', '$(top_builddir)/library/${pkg}', '$(PKG_BUILT_STAMP)')" | \
	    R_DEFAULT_PACKAGES=NULL $(R_EXE) > /dev/null ; \
	  else \
	  $(ECHO) "tools:::.install_package_description('.', '$(top_builddir)/library/${pkg}')" | \
	  R_DEFAULT_PACKAGES=NULL $(R_EXE) > /dev/null ; \
	  fi; \
	fi

## for base and tools
mkdesc2:
	@$(INSTALL_DATA) DESCRIPTION $(top_builddir)/library/$(pkg)
	@if test "$(PKG_BUILT_STAMP)" != ""; then \
	  $(ECHO) "Built: R $(VERSION); ; $(PKG_BUILT_STAMP); $(R_OSTYPE)" \
	     >> $(top_builddir)/library/$(pkg)/DESCRIPTION ; \
	else \
	  $(ECHO) "Built: R $(VERSION); ; `TZ=UTC date`; $(R_OSTYPE)" \
	     >> $(top_builddir)/library/$(pkg)/DESCRIPTION ; \
	fi

mkdemos:
	@$(ECHO) "tools:::.install_package_demos('$(srcdir)', '$(top_builddir)/library/$(pkg)')" | \
	  R_DEFAULT_PACKAGES=NULL $(R_EXE) > /dev/null

## for base
mkdemos2:
	@$(MKINSTALLDIRS) $(top_builddir)/library/$(pkg)/demo
	@for f in `ls -d $(srcdir)/demo/* | sed -e '/00Index/d'`; do \
	  $(INSTALL_DATA) "$${f}" $(top_builddir)/library/$(pkg)/demo; \
	done

mkexec:
	@if test -d $(srcdir)/exec; then \
	  $(MKINSTALLDIRS) $(top_builddir)/library/$(pkg)/exec; \
	  for f in  $(srcdir)/exec/*; do \
	    $(INSTALL_DATA) "$${f}" $(top_builddir)/library/$(pkg)/exec; \
	  done; \
	fi

## only used if byte-compilation is disabled
mklazy:
	@$(INSTALL_DATA) all.R $(top_builddir)/library/$(pkg)/R/$(pkg)
	@$(ECHO) "tools:::makeLazyLoading(\"$(pkg)\")" | \
	  R_DEFAULT_PACKAGES=$(DEFPKGS) LC_ALL=C $(R_EXE) > /dev/null

mklazycomp: $(top_builddir)/library/$(pkg)/R/$(pkg).rdb

mkRsimple:
	@$(INSTALL_DATA) all.R $(top_builddir)/library/$(pkg)/R/$(pkg)
	@rm -f $(top_builddir)/library/$(pkg)/R/$(pkg).rd?

mksrc:
	@if test -d src; then \
	  (cd src && $(MAKE)) || exit 1; \
	fi

mksrc-win2:
	@if test -d src; then \
	  (cd src && $(MAKE) -f Makefile.win EXT_LIBS="$(EXT_LIBS)") || exit 1; \
	fi

sysdata: $(srcdir)/R/sysdata.rda
	@$(ECHO) "installing 'sysdata.rda'"
	@$(ECHO) "tools:::sysdata2LazyLoadDB(\"$(srcdir)/R/sysdata.rda\",\"$(top_builddir)/library/$(pkg)/R\")" | \
	  R_DEFAULT_PACKAGES=NULL LC_ALL=C $(R_EXE)


## install man/figures: currently only used for graphics
mkfigs:
	@if test -d  $(srcdir)/man/figures; then \
	  mkdir -p $(top_builddir)/library/$(pkg)/help/figures; \
	  cp $(srcdir)/man/figures/* \
	    $(top_builddir)/library/$(pkg)/help/figures; \
	fi

install-tests:
	@if test -d tests; then \
	  mkdir -p $(top_builddir)/library/$(pkg)/tests; \
	  cp tests/* $(top_builddir)/library/$(pkg)/tests; \
	fi



Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
	@cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
DESCRIPTION: $(srcdir)/DESCRIPTION.in $(top_builddir)/config.status
	@cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@

mostlyclean: clean
clean:
	@if test -d src; then (cd src && $(MAKE) $@); fi
	-@rm -f all.R .RData
distclean: clean
	@if test -d src; then (cd src && $(MAKE) $@); fi
	-@rm -f Makefile DESCRIPTION
maintainer-clean: distclean

clean-win:
	@if test -d src; then \
	  $(MAKE) -C src -f Makefile.win clean; \
	fi
	-@rm -f all.R .RData
distclean-win: clean-win
	-@rm -f DESCRIPTION


distdir: $(DISTFILES)
	@for f in $(DISTFILES); do \
	  test -f $(distdir)/$${f} \
	    || ln $(srcdir)/$${f} $(distdir)/$${f} 2>/dev/null \
	    || cp -p $(srcdir)/$${f} $(distdir)/$${f}; \
	done
	@for d in R data demo exec inst man noweb src po tests vignettes; do \
	  if test -d $(srcdir)/$${d}; then \
	    ((cd $(srcdir); \
	          $(TAR) -c -f - $(DISTDIR_TAR_EXCLUDE) $${d}) \
	        | (cd $(distdir); $(TAR) -x -f -)) \
	      || exit 1; \
	  fi; \
	done
