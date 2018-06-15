library(survival)
# Very simple tmerge example, for checking
data1 <- data.frame(idd = c(1,5,4,3,2,6), x1=1:6, age=50:55)
data2 <- data.frame(idd = c(2,5,1,2,1), x2=5:1, age=48:44)
test1 <- tmerge(data1, data1, id=idd, death=event(age))
test2 <- tmerge(test1, data2, id=idd, zed=tdc(age, x2))
all.equal(test2$id, c(1,1,1,5,5,4,3,2,2,2,6))
all.equal(test2$tstop, c(44, 46, 50, 47, 51, 52, 53, 45, 48, 54, 55))
all.equal(test2$death, c(0,0,1,0,1,1,1,0,0,1,1))
all.equal(test2$zed, c(NA, 1, 3,NA, 4, NA, NA, NA, 2, 5, NA))

#add in a cumtdc variable and cumevent variable
data3 <- data.frame(idd=c(5,5,1,1,6,4,3,2), 
                    age=c(45, 50, 44, 48, 53,-5,0,20),
                    x = c(1,5,2,3,7, 4,6,8))
test3 <- tmerge(test2, data3, id=idd, x=cumtdc(age, x),
                esum = cumevent(age))
all.equal(test3$x, c(NA,2,2,5,NA, 1,1,6,4,6, NA, 8,8,8, NA,7))
all.equal(test3$esum, c(1,0,2,0,1,0,2,0,0,0,1,0,0,0,1,0)) 


# An example from Brendan Caroll
# It went wrong because the data is not sorted

ages <- data.frame( id = c(1L, 2L, 5L, 6L, 9L, 10L, 12L, 13L, 14L, 15L, 16L,
 17L, 18L, 20L, 21L, 24L, 26L, 27L, 28L, 29L, 30L, 31L, 34L, 35L, 36L, 37L, 
38L, 39L, 40L, 42L, 45L, 46L, 43L, 48L, 49L, 50L, 51L, 52L, 54L, 55L, 57L, 
58L, 59L, 60L, 61L, 62L, 63L, 64L, 65L, 66L, 68L, 69L, 70L, 71L, 72L, 73L, 
74L, 75L, 8L, 19L, 22L, 23L, 33L, 41L), 
                   age = c(13668, 21550, 15249, 21550, 
16045, 21550, 14976, 14976, 6574, 21550, 4463, 16927, 16927, 15706, 4567, 
21306, 17235, 22158, 19692, 17632, 17597, 4383, 5811, 7704, 5063, 17351, 
17015, 16801, 4383, 5080, 13185, 12604, 19784, 5310, 15369, 13239, 1638, 
21323, 10914, 21262, 7297, 17214, 17508, 14199, 14062, 2227, 8434, 4593, 
14429, 21323, 4782, 10813, 2667, 2853, 5709, 3140, 12237, 7882, 21550, 
15553, 16466, 16621, 19534, 21842))

transitions <- data.frame(id=c(2,2, 8, 19, 22, 23, 24, 31, 
                               33, 41, 43, 52, 55, 66, 6, 10, 43),
                          transition = c(18993, 13668, 15706, 
                                         11609, 4023, 9316, 16193, 1461, 
                                         4584, 17824, 11261, 16818, 
                                         10670, 15479, 15249, 15887,3713))

# Unsorted
tdata  <- tmerge(ages, ages, id=id, tstop=age)
newdata<- tmerge(tdata, transitions, id=id, enum=cumtdc(transition))

# sorted
test1 <- ages[order(ages$id),]
test2 <- tmerge(test1, test1, id=id, tstop=age)
tran2 <- transitions[order(transitions$id, transitions$transition),]
test3 <- tmerge(test2, tran2, id=id, enum=cumtdc(transition))
all.equal(attr(newdata,'tcount'), attr(test3, 'tcount'))

test4 <- newdata[order(newdata$id, newdata$tstart),]
all.equal(test3, test4, check.attributes=FALSE) #rownames differ

