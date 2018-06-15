## ${R_HOME}/share/make/shlib.mk

all: $(SHLIB)

$(SHLIB): $(OBJECTS)
	@if test  "z$(OBJECTS)" != "z"; then \
	  echo $(SHLIB_LINK) -o $@ $(OBJECTS) $(ALL_LIBS); \
	  $(SHLIB_LINK) -o $@ $(OBJECTS) $(ALL_LIBS); \
	fi

.PHONY: all shlib-clean

shlib-clean:
	@rm -Rf .libs _libs
	@rm -f $(OBJECTS) symbols.rds


## FIXME: why not Rscript?
symbols.rds: $(OBJECTS)
	@$(ECHO) "tools:::.shlib_objects_symbol_tables()" | \
	  $(R_HOME)/bin/R --vanilla --slave --args $(OBJECTS)
