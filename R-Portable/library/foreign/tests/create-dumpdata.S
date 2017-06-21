## file ./dumpdata was created by these (S-PLUS 6.2.1 for Linux):
myobj <-  data.frame(factor = factor(1:3, labels=c("a", "bc", "def")),
		     ints = 1:3, floats = 1+(1:3)/10, logs= c(T,NA,F))
myobj[1,2] <- NA
data.dump("myobj",file="dumpdata", oldStyle=TRUE)
