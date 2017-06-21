## Generate using
##   prefixes <- c("CPP", "C", "CXX", "F", "FC", "OBJC", "OBJCXX")
##   writeLines(c(sprintf("\t@echo PKG_%sFLAGS: \"$(PKG_%sFLAGS)\"",
##                        prefixes, prefixes),
##                sprintf("\t@echo %sFLAGS: \"$(%sFLAGS)\"",
##                        prefixes, prefixes)))

makevars_test:
	@echo PKG_CPPFLAGS: "$(PKG_CPPFLAGS)"
	@echo PKG_CFLAGS: "$(PKG_CFLAGS)"
	@echo PKG_CXXFLAGS: "$(PKG_CXXFLAGS)"
	@echo PKG_FFLAGS: "$(PKG_FFLAGS)"
	@echo PKG_FCFLAGS: "$(PKG_FCFLAGS)"
	@echo PKG_OBJCFLAGS: "$(PKG_OBJCFLAGS)"
	@echo PKG_OBJCXXFLAGS: "$(PKG_OBJCXXFLAGS)"
	@echo CPPFLAGS: "$(CPPFLAGS)"
	@echo CFLAGS: "$(CFLAGS)"
	@echo CXXFLAGS: "$(CXXFLAGS)"
	@echo FFLAGS: "$(FFLAGS)"
	@echo FCFLAGS: "$(FCFLAGS)"
	@echo OBJCFLAGS: "$(OBJCFLAGS)"
	@echo OBJCXXFLAGS: "$(OBJCXXFLAGS)"
