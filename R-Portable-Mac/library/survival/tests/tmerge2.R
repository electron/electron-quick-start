library(survival)

# This test is based on a user report that a 0/1 variable would not reset
#  to zero.  It turned out to be a bug when data2 was not sorted

baseline <- data.frame(idd=1:5,  futime=c(20, 30, 40, 30, 20),
                       status= c(0, 1, 0, 1, 0))
tests <- data.frame(idd = c(2,3,3,3,4,4,5),
                    date = c(25, -1, 15, 23, 17, 19, 14),
                    onoff= c( 1, 1, 0, 1, 1, 0, 1))
tests <- tests[c(7,2,6,3,4,1,5),]  #scramble data2

mydata <- tmerge(baseline, baseline, id=idd, death=event(futime, status))
mydata <- tmerge(mydata, tests, id=idd, ondrug=tdc(date, onoff))

all.equal(mydata$ondrug, c(NA, NA,1, 1,0,1, NA, 1,0, NA, 1))


# Check out addition of a factor
tests$ff <- factor(tests$onoff, 0:1, letters[4:5])
mydata <- tmerge(mydata, tests, id=idd, fgrp= tdc(date, ff),
                 options=list(tdcstart="new"))

all.equal(mydata$fgrp, 
          factor(c(3,3,2,2,1,2,3,2,1,3,2), labels=c("d", "e", "new")))
