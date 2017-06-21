library(foreign)

DF <- data.frame(X1 = 1:3, X2 = 4:6, X3 = paste0("str_", 1:3), 
                 stringsAsFactors = FALSE)

write.foreign(DF, "datafile.dat", "codefile.sps", "SPSS")

files <- c( "datafile.dat", "codefile.sps")
for(f in files) tools::Rdiff(f, file.path("keep", f))
unlink(files)
