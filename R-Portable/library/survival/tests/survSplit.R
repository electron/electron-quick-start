library(survival)
# Make sure that the old-style and new-style calls both work

# new style
vet2 <- survSplit(Surv(time, status) ~ ., data= veteran, cut=c(90, 180), 
                  episode= "tgroup", id="id")
vet2[1:7, c("id", "tstart", "time", "status", "tgroup", "age", "karno")]

# old style
vet3 <- survSplit(veteran, end='time', event='status', cut=c(90,180),
                  episode="tgroup", id="id")
all.equal(vet2, vet3)

all.equal(nrow(vet2), nrow(veteran) + sum(veteran$time >90) + 
                      sum(veteran$time > 180))


