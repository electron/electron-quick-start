## PR#13788

library(nlme)
qm <-  lmList(height ~ age | Subject, data = Oxboys)
nd <- with(Oxboys,
           expand.grid(age = seq(min(age),max(age),length=50),
                       Subject = levels(Subject))
           )

## failed in 3.1-92
res <- predict(qm, nd, se=TRUE)
