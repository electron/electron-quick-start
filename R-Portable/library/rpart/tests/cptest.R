library(rpart)
mystate <- data.frame(state.x77, region=factor(state.region))
names(mystate) <- c("population","income" , "illiteracy","life" ,
       "murder", "hs.grad", "frost",     "area",      "region")
#
# This little test came out of a query that cp did not scale
#  with the data size.  It does
#
# tdata = 20 copies of "mystate"  
# trees with tdata and trees with mystate should be the same (they are)
#  except for the n's
tdata <- rbind(mystate, mystate, mystate, mystate, mystate)
tdata <- rbind(tdata, tdata, tdata, tdata)
tfit1 <- rpart(income ~ population + illiteracy + murder + hs.grad + region,
               data = mystate, method = "anova", xval=0, cp=.089)
tfit2 <- rpart(income ~ population + illiteracy + murder + hs.grad + region,
               data = tdata, method='anova', xval=0, cp=.089, 
               minsplit=400, minbucket=140)

all.equal(tfit1$splits[,-1], tfit2$splits[,-1])
 
