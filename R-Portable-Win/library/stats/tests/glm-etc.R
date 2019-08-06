#### lm, glm, aov, etc --- typically *strict* tests (no *.Rout.save)

data(mtcars)
mtcar2 <- within(mtcars, {
    mpg_c <- mpg * (1+am) + 5
    am <- factor(am)
})
fm2 <- glm(disp ~ am * mpg + mpg_c, data = mtcar2)
c2 <- coef(fm2)
V2 <- vcov(fm2)
jj <- !is.na(c2)
stopifnot(names(which(!jj)) == "am1:mpg"
	, identical(length(c2), 5L), identical(dim(V2), c(5L,5L))
	, all.equal(c2[jj],    coef(fm2, complete=FALSE))
	, all.equal(V2[jj,jj], vcov(fm2, complete=FALSE))
	, all.equal(c2[jj], c(`(Intercept)`= 626.0915, am1 = -249.4183,
			      mpg = -33.74701, mpg_c = 10.97014),
		    tol = 7e-7)# 1.01e-7 [F26 Lnx 64b]
)
