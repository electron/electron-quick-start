### R code from vignette source 'tiedtimes.Rnw'

###################################################
### code chunk number 1: init
###################################################
options(continue="  ", width=60)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=8) #text in graph about the same as regular text
library(survival, quietly=TRUE)


###################################################
### code chunk number 2: interval1
###################################################
birth <- as.Date("1973/03/10")
start <- as.Date("1998/09/13") + 1:40
end   <- as.Date("1998/12/03") + rep(1:10, 4)
interval <- (end-start)
table(interval)


###################################################
### code chunk number 3: interval2
###################################################
start.age <- as.numeric(start-birth)/365.25
end.age   <- as.numeric(end  -birth)/365.25
age.interval <- end.age - start.age
length(unique(age.interval))
table(match(age.interval, sort(unique(age.interval))))


###################################################
### code chunk number 4: tiedtimes.Rnw:82-96
###################################################
ndata <- data.frame(id=1:30, 
                      birth.dt = rep(as.Date("1953/03/10"), 30),
                      enroll.dt= as.Date("1993/03/10") + 1:30,
                      end.dt   = as.Date("1996/10/21") + 1:30 + 
                          rep(1:10, 3),
                      status= rep(0:1, length=30),
                      x = 1:30)
ndata$enroll.age <- with(ndata, as.numeric(enroll.dt - birth.dt))/365.25
ndata$end.age    <- with(ndata, as.numeric(end.dt - birth.dt))/365.25

fudays <- with(ndata, as.numeric(end.dt - enroll.dt))
fuyrs  <- with(ndata, as.numeric(end.age- enroll.age))
cox1 <- coxph(Surv(fudays, status) ~ x, data=ndata)
cox2 <- coxph(Surv(fuyrs,  status) ~ x, data=ndata)


