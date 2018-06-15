#!/bin/sh

# Produce the Rd-files for the documentation from the R source files
# 
# Prerequisites:
#   - Perl
#   - R_HOME must be set to the directory where R is installed

echo "#### starting prebuild.sh"

cd ..
mkdir -p man
cd man
find ../R -name '*.[rR]' -exec cat \{\} \; | perl ../exec/make_rd.pl 
cd ../exec

echo "#### prebuild.sh completed!"
