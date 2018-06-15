sdir <- system.file("scripts", package="nlme")
for(f in list.files(sdir, pattern = "^ch.*[.]R$")) {
    cat("\n",f,":\n------\n", sep='')
    source(file.path(sdir, f), echo=TRUE)
}
## currently fails in   ch04.R : qqnorm(fm3Orth.lme, ~resid(.) | Sex)
