library(foreign)
pc5 <- read.dta("pc5.dta")
summary(pc5)
str(pc5)
compressed <- read.dta("compressed.dta")
summary(compressed)
all.equal(summary(pc5), summary(compressed))
sun6 <- read.dta("sun6.dta")
summary(sun6)
str(sun6)
all.equal(summary(sun6),summary(pc5))
df <- read.dta("datefactor.dta")
summary(df)
data(esoph)
write.dta(esoph,esophile <- tempfile())
esoph2 <- read.dta(esophile)
all.equal(ordered(esoph2$alcgp),esoph$alcgp)
write.dta(esoph,esophile,convert.factors="string")
esoph2 <- read.dta(esophile)
all.equal(as.character(esoph$alcgp),esoph2$alcgp)
write.dta(esoph,esophile,convert.factors="code")
esoph2 <- read.dta(esophile)
all.equal(as.numeric(esoph$alcgp),as.numeric(esoph2$alcgp))

se <- read.dta("stata7se.dta")
print(se)
v8 <- read.dta("stata8mac.dta")
print(v8)

stata8 <- read.dta("auto8.dta",missing.type=TRUE,convert.underscore=FALSE)
str(stata8)

bq <- read.dta("MLLabelsWithNotesChar.dta")
str(bq)
write.dta(bq, "bq.dta", version = 12)
str(read.dta('bq.dta'))
unlink("bq.dta")

## PR#15290
bq <- read.dta("OneVarTwoValLabels.dta")
str(bq)

## Dates and date-times in Stata12
Sys.setenv(TZ = "UTC") # avoid timezone differences: cannot unset so must be last
read.dta("xxx12.dta")

q()
