options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

# From Gail, Sautner and Brown, Biometrics 36, 255-66, 1980

# 48 rats were injected with a carcinogen, and then randomized to either
# drug or placebo.  The number of tumors ranges from 0 to 13; all rats were
# censored at 6 months after randomization.

# Variables: rat, treatment (1=drug, 0=control), o
# 	   observation # within rat,
#	   (start, stop] status
# The raw data has some intervals of zero length, i.e., start==stop.
#  We add .1 to these times as an approximate solution
#
rat2 <- read.table('data.rat2', col.names=c('id', 'rx', 'enum', 'start',
				  'stop', 'status'))
temp1 <- rat2$start
temp2 <- rat2$stop
for (i in 1:nrow(rat2)) {
    if (temp1[i] == temp2[i]) {
	temp2[i] <- temp2[i] + .1
	if (i < nrow(rat2) && rat2$id[i] == rat2$id[i+1]) {
	    temp1[i+1] <- temp1[i+1] + .1
	    if (temp2[i+1] <= temp1[i+1]) temp2[i+1] <- temp1[i+1]
	    }
        }
    }
rat2$start <- temp1
rat2$stop  <- temp2

r2fit0 <- coxph(Surv(start, stop, status) ~ rx + cluster(id), rat2)

r2fitg <-  coxph(Surv(start, stop, status) ~ rx + frailty(id), rat2)
r2fitm <-  coxph(Surv(start, stop, status) ~ rx + frailty.gaussian(id), rat2)

r2fit0
r2fitg
r2fitm

#This example is unusual: the frailties variances end up about the same,
#  but the effect on rx differs.  Double check it
# Because of different iteration paths, the coef won't be exactly the
#     same, but darn close.

temp <- coxph(Surv(start, stop, status) ~ rx + offset(r2fitm$frail[id]), rat2)
all.equal(temp$coef, r2fitm$coef[1], tolerance=1e-7)

temp <- coxph(Surv(start, stop, status) ~ rx + offset(r2fitg$frail[id]), rat2)
all.equal(temp$coef, r2fitg$coef[1], tolerance=1e-7)

#
# What do I get with AIC
#
r2fita1 <- coxph(Surv(start, stop, status) ~ rx + frailty(id, method='aic'),
		 rat2)
r2fita2 <- coxph(Surv(start, stop, status) ~ rx + frailty(id, method='aic',
							  dist='gauss'), rat2)
r2fita3 <- coxph(Surv(start, stop, status) ~ rx + frailty(id, dist='t'),
		 rat2)

r2fita1
r2fita2
r2fita3
