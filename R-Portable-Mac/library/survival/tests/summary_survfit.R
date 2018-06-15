## check that the scale option to summary.survfit works
##  Marc Schwartz reported this as a bug in 2.35-3.
library(survival)
fit <- survfit(Surv(futime, fustat) ~rx, data=ovarian)
temp1 <- summary(fit)
temp2 <- summary(fit, scale=365.25)

all.equal(temp1$time/365.25, temp2$time)
all.equal(temp1$rmean.endtime/365.25, temp2$rmean.endtime)
all.equal(temp1$table[,5:6]/365.25,    temp2$table[,5:6])
temp <- names(fit)
temp <- temp[!temp  %in% c("time", "table", "rmean.endtime")]
all.equal(temp1[temp], temp2[temp])

# Reprise, using the rmean option
temp1 <- summary(fit, rmean=300)
temp2 <- summary(fit, rmean=300, scale=365.25)
all.equal(temp1$time/365.25, temp2$time)
all.equal(temp1$rmean.endtime/365.25, temp2$rmean.endtime)
all.equal(temp1$table[,5:6]/365.25,    temp2$table[,5:6])
all.equal(temp1[temp], temp2[temp])

# Repeat using multi-state data.  Time is in months for mgus2
etime <- with(mgus2, ifelse(pstat==0, futime, ptime))
event <- with(mgus2, ifelse(pstat==0, 2*death, 1))
event <- factor(event, 0:2, labels=c("censor", "pcm", "death"))
mfit <- survfit(Surv(etime, event) ~ sex, mgus2)
temp1 <- summary(mfit)
temp2 <- summary(mfit, scale=12)

all.equal(temp1$time/12, temp2$time)
all.equal(temp1$rmean.endtime/12, temp2$rmean.endtime)
all.equal(temp1$table[,3]/12,    temp2$table[,3])
temp <- names(temp1)
temp <- temp[!temp  %in% c("time", "table", "rmean.endtime")]
all.equal(temp1[temp], temp2[temp])

# Reprise, using the rmean option
temp1 <- summary(mfit, rmean=240)
temp2 <- summary(mfit, rmean=240, scale=12)
all.equal(temp1$time/12, temp2$time)
all.equal(temp1$rmean.endtime/12, temp2$rmean.endtime)
all.equal(temp1$table[,3]/12,    temp2$table[,3])
all.equal(temp1[temp], temp2[temp])


# The n.risk values from summary.survfit were off when there are multiple
#  curves (version 2.39-2)
# Verify all components by subscripting
m1 <- mfit[1,]
m2 <- mfit[2,]
s1 <- summary(m1, times=c(0,100, 200, 300))
s2 <- summary(m2, times=c(0,100, 200, 300))
s3 <- summary(mfit, times=c(0,100, 200, 300))

tfun <- function(what) {
    if (is.matrix(s3[[what]]))
        all.equal(rbind(s1[[what]], s2[[what]]), s3[[what]])
    else all.equal(c(s1[[what]], s2[[what]]), s3[[what]])
}
tfun('n')
tfun("time")
tfun("n.risk")
tfun("n.event")
tfun("n.censor")
tfun("pstate")
all.equal(rbind(s1$p0, s2$p0), s3$p0, check.attributes=FALSE)
tfun("std.err")
tfun("lower")
tfun("upper")

# Check the cumulative sums
temp <- rbind(0, 0,
              colSums(m1$n.event[m1$time <= 100,]),
              colSums(m1$n.event[m1$time <= 200, ]),
              colSums(m1$n.event[m1$time <= 300, ]))
all.equal(s1$n.event, apply(temp,2, diff))

temp <- rbind(0, 0,
              colSums(m2$n.event[m2$time <= 100,]),
              colSums(m2$n.event[m2$time <= 200, ]),
              colSums(m2$n.event[m2$time <= 300, ]))
all.equal(s2$n.event, apply(temp,2, diff))

temp <- c(0, 0,sum(m1$n.censor[m1$time <= 100]),
               sum(m1$n.censor[m1$time <= 200]),
               sum(m1$n.censor[m1$time <= 300]))
all.equal(s1$n.censor, diff(temp))
              
# check the same with survfit objects
s1 <- summary(fit[1], times=c(0, 200, 400, 600))
s2 <- summary(fit[2], times=c(0, 200, 400, 600))
s3 <- summary(fit, times=c(0, 200, 400, 600))
tfun('n')
tfun("time")
tfun("n.risk")
tfun("n.event")
tfun("n.censor")
tfun("surv")
tfun("std.err")
tfun("lower")
tfun("upper")

f2 <- fit[2]
temp <- c(0, 0, sum(f2$n.event[f2$time <= 200]),
                sum(f2$n.event[f2$time <= 400]),
                sum(f2$n.event[f2$time <= 600]))
all.equal(s2$n.event, diff(temp))

f1 <- fit[1]
temp <- c(0, 0,sum(f1$n.censor[f1$time <= 200]),
               sum(f1$n.censor[f1$time <= 400]),
               sum(f1$n.censor[f1$time <= 600]))
all.equal(s1$n.censor, diff(temp))

#
# A check on the censor option
#
s1 <- summary(fit[1])
s2 <- summary(fit[2])
s3 <- summary(fit)
tfun('n')
tfun("time")
tfun("n.risk")
tfun("n.event")
tfun("n.censor")
tfun("surv")
tfun("std.err")
tfun("lower")
tfun("upper")

s1 <- summary(mfit[1])
s2 <- summary(mfit[2])
s3 <- summary(mfit)
tfun('n')
tfun("time")
tfun("n.risk")
tfun("n.event")
tfun("n.censor")
tfun("surv")
tfun("std.err")
tfun("lower")
tfun("upper")
