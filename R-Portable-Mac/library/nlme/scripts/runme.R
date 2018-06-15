sdir <- system.file("scripts", package="nlme")
for(f in list.files(sdir, pattern = "^ch[0-9]*[.]R$")) {
    cat("\n",f,":\n------\n", sep='')
    source(file.path(sdir, f), echo=TRUE)
}
## runs through, taking ca  1.5  minutes (in BATCH)
