## ${R_HOME}/share/make/winshlib.mk

all: $(SHLIB)

BASE = $(shell basename $(SHLIB) .dll)

ADDQU = 's/[^ ][^ ]*/"&"/g'

## do it with explicit rules as packages might add dependencies to this target
## (attempts to do this GNUishly failed for parallel makes,
## but we do want the link targets echoed)
$(SHLIB): $(OBJECTS)
	@if test "z$(OBJECTS)" != "z"; then \
	  if test -e "$(BASE)-win.def"; then \
	    echo $(SHLIB_LD) -shared $(DLLFLAGS) -o $@ $(BASE)-win.def $(OBJECTS) $(ALL_LIBS); \
	    $(SHLIB_LD) -shared $(DLLFLAGS) -o $@ $(BASE)-win.def $(OBJECTS) $(ALL_LIBS); \
	  else \
	    echo EXPORTS > tmp.def; \
	    $(NM) $^ | $(SED) -n $(SYMPAT) $(NM_FILTER) | $(SED) $(ADDQU)  >> tmp.def; \
	    echo $(SHLIB_LD) -shared $(DLLFLAGS) -o $@ tmp.def $(OBJECTS) $(ALL_LIBS); \
	    $(SHLIB_LD) -shared $(DLLFLAGS) -o $@ tmp.def $(OBJECTS) $(ALL_LIBS); \
	    $(RM) tmp.def; \
	  fi \
	fi

.PHONY: all shlib-clean
shlib-clean:
	@rm -f $(OBJECTS) symbols.rds

## FIXME: why not Rscript?
symbols.rds: $(OBJECTS)
	@$(ECHO) "tools:::.shlib_objects_symbol_tables()" | \
	  $(R_HOME)/bin$(R_ARCH)/Rterm.exe --vanilla --slave --args $(OBJECTS)
