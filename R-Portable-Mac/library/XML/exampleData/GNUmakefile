XSLT_PROCESSOR=export LD_LIBRARY_PATH=/tmp/xml-xalan/c/lib ; /tmp/xml-xalan/c/bin/testXSLT

PREFIX=$(OMEGA_HOME)/XML/Literate/
C_XSL=$(PREFIX)/croutine.xsl
C_XSL=$(PREFIX)/fragment1.xsl

writeRS.c: writeRS.xml $(C_XSL)
	($(XSLT_PROCESSOR) $(XSLT_FLAGS) -in writeRS.xml -xsl $(C_XSL) -out $@ )

writeRS.S: writeRS.xml
	($(XSLT_PROCESSOR) $(XSLT_FLAGS) -in $^ -xsl $(C_XSL) -param language "'S'" -out $@ )

writeRS.html: writeRS.xml $(PREFIX)/article.xsl
	($(XSLT_PROCESSOR) $(XSLT_FLAGS) -in writeRS.xml -xsl $(PREFIX)/article.xsl -param language "'S'" -param cssURL "'file:///home/duncan/Projects/org/omegahat/XML/Literate/OmegaTech.css'" -param inputFile "'writeRS.xml'" -param outputFile "'writeRS.html'"  -param inputXSL "'$(PREFIX)/article.xsl'" -out $@ -TT )



CFLAGS+= -I$(R_HOME)/include -I$(R_HOME)/src/include
writeRS.so:

writeRS.o: writeRS.c

writeRS.so: writeRS.o
	R SHLIB -o $@ $^

