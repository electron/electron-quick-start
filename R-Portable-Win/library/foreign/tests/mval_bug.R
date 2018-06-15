library(foreign)

mydata <- read.spss("mval_bug.sav", use.value.labels = TRUE,
                    to.data.frame = TRUE, use.missings = TRUE)

levels(mydata$Q1_MISSING_NONE)
table(mydata$Q1_MISSING_NONE)

levels(mydata$Q1_MISSING_1)
table(mydata$Q1_MISSING_1)

levels(mydata$Q1_MISSING_2)
table(mydata$Q1_MISSING_2)

levels(mydata$Q1_MISSING_3)
table(mydata$Q1_MISSING_3)

levels(mydata$Q1_MISSING_RANGE)
table(mydata$Q1_MISSING_RANGE)

levels(mydata$Q1_MISSING_LOW)
table(mydata$Q1_MISSING_LOW)

levels(mydata$Q1_MISSING_HIGH)
table(mydata$Q1_MISSING_HIGH)

levels(mydata$Q1_MISSING_RANGE_1)
table(mydata$Q1_MISSING_RANGE_1)

levels(mydata$Q1_MISSING_LOW_1)
table(mydata$Q1_MISSING_LOW_1)

levels(mydata$Q1_MISSING_HIGH_1)
table(mydata$Q1_MISSING_HIGH_1)
