library(nlme)
fm1 <- lme(distance ~ age, Orthodont)
str(o1 <- getData(fm1))

df <- Orthodont # note that the name conflicts with df in the stats
fm2 <- lme(distance ~ age, df)
str(o2 <- getData(fm2))
stopifnot(identical(o1, o2))
