Naming conventions
==================
R/*.R 		R   files (including .Rd comments)
src/*.c		C   files 
man/*.Rd	Automatically generated Rd. files, do not modify

Rd api
======
prebuild.sh		call manually for generating all .Rd files from the .Rd comments in the R files with the help of
exec/make_rd.pl		converts "#! lines" in R/*.R files into man/<name>.Rd files, where <name> is derived from the "#! \name{<name>}" in the first line
