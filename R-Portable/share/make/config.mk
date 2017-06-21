print: FORCE
	@echo $($(VAR))
FORCE:

print-name-and-value: FORCE
	@echo $(VAR) = $($(VAR))
