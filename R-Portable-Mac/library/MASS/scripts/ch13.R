#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 13   Survival Analysis

library(MASS)
options(width=65, digits=5, height=9999)
options(contrasts=c("contr.treatment", "contr.poly"))
pdf("ch13.pdf", width=8, height=6, pointsize=9)

library(survival)

# 13.1  Estimators of survivor curves

plot(survfit(Surv(time) ~ ag, data=leuk), lty = 2:3, col = 2:3)
legend(80, 0.8, c("ag absent", "ag present"), lty = 2:3, col = 2:3)

attach(gehan)
Surv(time, cens)
plot(log(time) ~ pair)
# product-limit estimators with Greenwood's formula for errors:
gehan.surv <- survfit(Surv(time, cens) ~ treat, data = gehan,
                      conf.type = "log-log")
summary(gehan.surv)
plot(gehan.surv, conf.int = TRUE, lty = 3:2, log = TRUE,
     xlab = "time of remission (weeks)", ylab = "survival")
lines(gehan.surv, lty = 3:2, lwd = 2, cex = 2)
legend(25, 0.1 , c("control", "6-MP"), lty = 2:3, lwd = 2)
detach()

survdiff(Surv(time, cens) ~ treat, data = gehan)
survdiff(Surv(time) ~ ag, data = leuk)


# 13.2  Parametric models

plot(gehan.surv,  lty = 3:4, col = 2:3, fun = "cloglog",
     xlab = "time of remission (weeks)", ylab = "log H(t)")
legend(2, 0.5, c("control","6-MP"), lty = 4:3, col = 3:2)

survreg(Surv(time) ~ ag*log(wbc), leuk, dist = "exponential")
summary(survreg(Surv(time) ~ ag + log(wbc), leuk, dist = "exponential"))
summary(survreg(Surv(time) ~ ag + log(wbc), leuk)) # Weibull
summary(survreg(Surv(time) ~ ag + log(wbc), leuk,
                dist="loglogistic"))
anova(survreg(Surv(time) ~ log(wbc), data = leuk),
   survreg(Surv(time) ~ ag + log(wbc), data = leuk))
summary(survreg(Surv(time) ~ strata(ag) + log(wbc), data=leuk))
leuk.wei <- survreg(Surv(time) ~ ag + log(wbc), leuk)
ntimes <- leuk$time * exp(-leuk.wei$linear.predictors)
plot(survfit(Surv(ntimes) ~ 1), log = TRUE)

survreg(Surv(time, cens) ~ factor(pair) + treat, gehan,
        dist = "exponential")
summary(survreg(Surv(time, cens) ~ treat, gehan, dist = "exponential"))
summary(survreg(Surv(time, cens) ~ treat, gehan))

plot(survfit(Surv(time, cens) ~ factor(temp), motors), conf.int = FALSE)
motor.wei <- survreg(Surv(time, cens) ~ temp, motors)
summary(motor.wei)
unlist(predict(motor.wei, data.frame(temp=130), se.fit = TRUE))

predict(motor.wei, data.frame(temp=130), type = "quantile",
        p = c(0.5, 0.1))
t1 <-  predict(motor.wei, data.frame(temp=130),
               type = "uquantile", p = 0.5, se = TRUE)
exp(c(LL=t1$fit - 2*t1$se, UL=t1$fit + 2*t1$se))
t1 <-  predict(motor.wei, data.frame(temp=130),
               type = "uquantile", p = 0.1, se = TRUE)
exp(c(LL=t1$fit - 2*t1$se, UL=t1$fit + 2*t1$se))

# summary(censorReg(censor(time, cens) ~ treat, gehan))

# 13.3  Cox proportional hazards model

attach(leuk)
leuk.cox <- coxph(Surv(time) ~ ag + log(wbc), data = leuk)
summary(leuk.cox)
update(leuk.cox, ~ . -ag)

(leuk.coxs <- coxph(Surv(time) ~ strata(ag) + log(wbc), data = leuk))

(leuk.coxs1 <- update(leuk.coxs, . ~ . + ag:log(wbc)))
plot(survfit(Surv(time) ~ ag), lty = 2:3, log = TRUE)
lines(survfit(leuk.coxs), lty = 2:3, lwd = 3)
legend(80, 0.8, c("ag absent", "ag present"), lty = 2:3)
leuk.cox <- coxph(Surv(time) ~ ag, leuk)
detach()

gehan.cox <- coxph(Surv(time, cens) ~ treat, gehan, method = "exact")
summary(gehan.cox)

# The next fit is slow
coxph(Surv(time, cens) ~ treat + factor(pair), gehan,
        method = "exact")
1 - pchisq(45.5 - 16.2, 20)

(motor.cox <- coxph(Surv(time, cens) ~ temp, motors))
coxph(Surv(time, cens) ~ temp, motors, method = "breslow")
coxph(Surv(time, cens) ~ temp, motors, method = "exact")
plot( survfit(motor.cox, newdata=data.frame(temp=200),
               conf.type = "log-log") )
summary( survfit(motor.cox, newdata = data.frame(temp=130)) )


# 13.4  Further examples

# VA.temp <- as.data.frame(cancer.vet)
# dimnames(VA.temp)[[2]] <- c("treat", "cell", "stime",
#     "status", "Karn", "diag.time","age","therapy")
# attach(VA.temp)
# VA <- data.frame(stime, status, treat = factor(treat), age,
#     Karn, diag.time, cell = factor(cell), prior = factor(therapy))
# detach(VA.temp)
(VA.cox <- coxph(Surv(stime, status) ~ treat + age  + Karn +
                 diag.time + cell + prior, data = VA))

(VA.coxs <- coxph(Surv(stime, status) ~ treat + age + Karn +
     diag.time + strata(cell) + prior, data = VA))

par(mfrow=c(1,2), pty="s")
plot(survfit(VA.coxs), log = TRUE, lty = 1:4, col = 2:5)
#legend(locator(1), c("squamous", "small", "adeno", "large"), lty = 1:4, col = 2:5)
plot(survfit(VA.coxs), fun = "cloglog", lty = 1:4, col = 2:5)
cKarn <- factor(cut(VA$Karn, 5))
VA.cox1 <- coxph(Surv(stime, status) ~ strata(cKarn) + cell, data = VA)
plot(survfit(VA.cox1), fun="cloglog")
VA.cox2 <- coxph(Surv(stime, status) ~ Karn + strata(cell), data = VA)
scatter.smooth(VA$Karn, residuals(VA.cox2))

VA.wei <- survreg(Surv(stime, status) ~ treat + age + Karn +
                  diag.time + cell + prior, data = VA)
summary(VA.wei, cor = FALSE)

VA.exp <- survreg(Surv(stime, status) ~ Karn + cell,
                  data = VA, dist = "exponential")
summary(VA.exp, cor = FALSE)

cox.zph(VA.coxs)

par(mfrow = c(3, 2), pty="m"); plot(cox.zph(VA.coxs))

VA2 <- VA ## needed because VA and stepAIC are both in MASS
VA2$Karnc <- VA2$Karn - 50
VA.coxc <- update(VA.cox, ~ . - Karn + Karnc, data=VA2)
VA.cox2 <- stepAIC(VA.coxc, ~ .^2)
VA.cox2$anova

(VA.cox3 <- update(VA.cox2, ~ treat/Karnc + prior*Karnc
   + treat:prior + cell/diag.time))

cox.zph(VA.cox3)

par(mfrow = c(2, 2))
plot(cox.zph(VA.cox3), var = c(1, 3, 7))
par(mfrow = c(1, 1))

#data(heart) # in package survival
coxph(Surv(start, stop, event) ~ transplant*
    (age + surgery + year), data = heart)
(stan <- coxph(Surv(start, stop, event) ~ transplant*year +
    age + surgery, data = heart))

stan1 <- coxph(Surv(start, stop, event) ~ strata(transplant) +
    year + year:transplant + age + surgery, heart)
par(mfrow=c(1,2), pty="s")
plot(survfit(stan1), conf.int = TRUE, log = TRUE, lty = c(1, 3), col = 2:3)
#legend(locator(1), c("before", "after"), lty = c(1, 3), col= 2:3)

attach(heart)
plot(year[transplant==0], residuals(stan1, collapse = id),
     xlab = "year", ylab = "martingale residual")
lines(lowess(year[transplant == 0],
             residuals(stan1, collapse = id)))
par(mfrow = c(1,1), pty = "m")
sresid <- resid(stan1, type = "dfbeta", collapse = id)
detach()
-100 * sresid %*% diag(1/stan1$coef)

# Survivor curve for the "average" subject
summary(survfit(stan))
#  follow-up for two years
stan2 <- data.frame(start = c(0, 183), stop= c(183, 2*365),
    event = c(0, 0), year = c(4, 4), age = c(50, 50) - 48,
    surgery = c(1, 1), transplant = as.factor(c(0, 1)))
summary(survfit(stan, stan2, individual = TRUE, conf.type = "log-log"))

# Aids analysis
time.depend.covar <- function(data) {
  id <- row.names(data); n <- length(id)
  events <- c(0, 10043, 11139, 12053) # julian days
  crit1 <- matrix(events[1:3], n, 3 ,byrow = TRUE)
  crit2 <- matrix(events[2:4], n, 3, byrow = TRUE)
  diag <- matrix(data$diag,n,3); death <- matrix(data$death,n,3)
  incid <- (diag < crit2) & (death >= crit1); incid <- t(incid)
  indr <- col(incid)[incid]; indc <- row(incid)[incid]
  ind <- cbind(indr, indc); idno <- id[indr]
  state <- data$state[indr]; T.categ <- data$T.categ[indr]
  age <- data$age[indr]; sex <- data$sex[indr]
  late <- indc - 1
  start <- t(pmax(crit1 - diag, 0))[incid]
  stop <- t(pmin(crit2, death + 0.9) - diag)[incid]
  status <- matrix(as.numeric(data$status),n,3)-1 # 0/1
  status[death > crit2] <- 0; status <- status[ind]
  levels(state) <- c("NSW", "Other", "QLD", "VIC")
  levels(T.categ) <- c("hs", "hsid", "id", "het", "haem",
                       "blood", "mother", "other")
  levels(sex) <- c("F", "M")
  data.frame(idno, zid=factor(late), start, stop, status,
             state, T.categ, age, sex)
}
Aids3 <- time.depend.covar(Aids2)

attach(Aids3)
aids.cox <- coxph(Surv(start, stop, status)
     ~ zid + state + T.categ + sex + age, data = Aids3)
summary(aids.cox)

aids1.cox <- coxph(Surv(start, stop, status)
  ~ zid + strata(state) + T.categ + age, data = Aids3)
(aids1.surv <- survfit(aids1.cox))
plot(aids1.surv, mark.time = FALSE, lty = 1:4, col = 2:5,
     xscale = 365.25/12, xlab = "months since diagnosis")
#legend(locator(1), levels(state), lty = 1:4, col = 2:5)

aids2.cox <- coxph(Surv(start, stop, status)
  ~ zid + state + strata(T.categ) + age, data = Aids3)
(aids2.surv <- survfit(aids2.cox))

par(mfrow = c(1, 2), pty="s")
plot(aids2.surv[1:4], mark.time = FALSE, lty = 1:4, col = 2:5,
  xscale=365.25/12, xlab="months since diagnosis")
#legend(locator(1), levels(T.categ)[1:4], lty = 1:4, col = 2:5)

plot(aids2.surv[c(1, 5, 6, 8)], mark.time = FALSE, lty = 1:4, col = 2:5,
  xscale=365.25/12, xlab="months since diagnosis")
#legend(locator(1), levels(T.categ)[c(1, 5, 6, 8)], lty = 1:4, col = 2:5)
par(mfrow=c(1,1), pty="m")

cases <- diff(c(0,idno)) != 0
aids.res <- residuals(aids.cox, collapse = idno)
scatter.smooth(age[cases], aids.res, xlab = "age",
  ylab="martingale residual")

age2 <- cut(age, c(-1, 15, 30, 40, 50, 60, 100))
c.age <- factor(as.numeric(age2), labels = c("0-15", "16-30",
  "31-40", "41-50", "51-60", "61+"))
table(c.age)
c.age <- relevel(c.age, "31-40")

summary(coxph(Surv(start, stop, status) ~ zid  + state
  + T.categ + age + c.age, data = Aids3))
detach()

make.aidsp <- function(){
  cutoff <- 10043
  btime <- pmin(cutoff, Aids2$death) - pmin(cutoff, Aids2$diag)
  atime <- pmax(cutoff, Aids2$death) - pmax(cutoff, Aids2$diag)
  survtime <- btime + 0.5*atime
  status <- as.numeric(Aids2$status)
  data.frame(survtime, status = status - 1, state = Aids2$state,
    T.categ = Aids2$T.categ, age = Aids2$age, sex = Aids2$sex)
}
Aidsp <- make.aidsp()
aids.wei <- survreg(Surv(survtime + 0.9, status) ~  state
    + T.categ + sex + age, data = Aidsp)
summary(aids.wei, cor = FALSE)

survreg(Surv(survtime + 0.9, status) ~ state + T.categ
  + age, data = Aidsp)

(aids.ps <- survreg(Surv(survtime + 0.9, status) ~  state
   + T.categ + pspline(age, df=6), data = Aidsp))
zz <- predict(aids.ps, data.frame(
   state = factor(rep("NSW", 83), levels = levels(Aidsp$state)),
   T.categ = factor(rep("hs", 83), levels = levels(Aidsp$T.categ)),
   age = 0:82), se = T, type = "linear")
plot(0:82, exp(zz$fit)/365.25, type = "l", ylim = c(0, 2),
   xlab = "age", ylab = "expected lifetime (years)")
lines(0:82, exp(zz$fit+1.96*zz$se.fit)/365.25, lty = 3, col = 2)
lines(0:82, exp(zz$fit-1.96*zz$se.fit)/365.25, lty = 3, col = 2)
rug(Aidsp$age+runif(length(Aidsp$age), -0.5, 0.5), ticksize = 0.015)

# End of ch13
