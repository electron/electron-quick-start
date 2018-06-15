#  Copyright (C) 1997-2009 The R Core Team

#### -*- R -*-
require(stats)
Fr <- c(68,42,42,30, 37,52,24,43,
	66,50,33,23, 47,55,23,47,
	63,53,29,27, 57,49,19,29)

Temp <- gl(2, 2, 24, labels = c("Low", "High"))
Soft <- gl(3, 8, 24, labels = c("Hard","Medium","Soft"))
M.user <- gl(2, 4, 24, labels = c("N", "Y"))
Brand <- gl(2, 1, 24, labels = c("X", "M"))

detg <- data.frame(Fr,Temp, Soft,M.user, Brand)
detg.m0 <- glm(Fr ~ M.user*Temp*Soft + Brand, family = poisson, data = detg)
summary(detg.m0)

detg.mod <- glm(terms(Fr ~ M.user*Temp*Soft + Brand*M.user*Temp,
                      keep.order = TRUE),
		family = poisson, data = detg)
summary(detg.mod)
summary(detg.mod, correlation = TRUE, symbolic.cor = TRUE)

anova(detg.m0, detg.mod)
