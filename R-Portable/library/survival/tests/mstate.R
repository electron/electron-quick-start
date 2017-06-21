#
# A tiny multi-state example
#
library(survival)
aeq <- function(x,y) all.equal(as.vector(x), as.vector(y))
mtest <- data.frame(id= c(1, 1, 1,  2,  3,  4, 4, 4,  5, 5),
                    t1= c(0, 4, 9,  0,  2,  0, 2, 8,  1, 3),
                    t2= c(4, 9, 10, 5,  9,  2, 8, 9,  3, 11),
                    st= c(1, 2,  1, 2,  3,  1, 3, 0,  2,  0))

mtest$state <- factor(mtest$st, 0:3, c("censor", "a", "b", "c"))
mtest <- mtest[c(1,3,2,4,5,7,6,10, 9, 8),]  #not in time order

mfit <- survfit(Surv(t1, t2, state) ~ 1, mtest, id=id)

# True results
#
#time       state                    probabilities
#         entry  a   b  c         entry  a    b     c
#
#0        124                      1     0    0     0
#1+       1245
#2+       1235   4                3/4   1/4   0     0    4 -> a, add 3
#3+       123    4   5            9/16  1/4  3/16   0    5 -> b
#4+        23    14  5            6/16  7/16 3/16   0    1 -> a
#5+        3     14  5            3/16  7/16 6/16   0    2 -> b, exits
#8+        3     1   5  4         3/16  7/32 6/16  7/32  4 -> c
#9+                  15            0     0  19/32 13/32  1->b, 3->c & exit
# 10+            1   5                19/64 19/64 13/32  1->a

# In mfit, the "entry" state is last in the matrices
all.equal(mfit$n.risk, matrix(c(0,1,1,2,2,1,0,0,
                                0,0,1,1,1,1,2,1,
                                0,0,0,0,0,1,0,0,
                                4,4,3,2,1,1,0,0), ncol=4))
all.equal(mfit$pstate,  matrix(c(8,  8, 14, 14, 7, 0,  9.5, 9.5, 
                                0,  6,  6, 12, 12,19,9.5, 9.5, 
                                0,  0,  0,  0, 7, 13, 13, 13,
                               24, 18, 12,  6, 6, 0, 0,  0)/32, ncol=4))
all.equal(mfit$n.event, matrix(c(1,0,1,0,0,0,1,0,
                                 0,1,0,1,0,1,0,0,
                                 0,0,0,0,1,1,0,0,
                                 0,0,0,0,0,0,0,0), ncol=4))
all.equal(mfit$time, c(2, 3, 4, 5, 8, 9, 10, 11))


# Somewhat more complex.
#  Scramble the input data
#  Not everyone starts at the same time or in the same state
#  Two "istates" that vary, only the first should be noticed.
#  Case weights
#
tdata <- data.frame(id= c(1, 1, 1,  2,  3,  4, 4, 4,  5,  5),
                    t1= c(0, 4, 9,  1,  2,  0, 2, 8,  1,  3),
                    t2= c(4, 9, 10, 5,  9,  2, 8, 9,  3, 11),
                    st= c(1, 2,  1, 2,  3,  1, 3, 0,  3,  0),
                    i0= c(4, 4,  4, 1,  4,  4, 4, 1,  2,  2))

tdata$st <- factor(tdata$st, c(0:4),
                    labels=c("censor", "1", "2", "3", "entry"))

tfun <- function(wt, data=tdata) {
    reorder <- c(10, 9, 1, 2, 5, 4, 3, 7, 8, 6)
    new <- data[reorder,]
    new$wt <- rep(wt,length=10)[reorder]
    new
}

# These weight vectors are in the order of tdata
# w[9] is the weight for subject 5 at time 1.5, for instance
p0 <- function(w) c(w[4], w[9], 0, w[1]+ w[6])/ (w[1]+ w[4] + w[6] + w[9])

#  aj2 = Aalen-Johansen H matrix at time 2, etc.
aj2 <- function(w) {
    rbind(c(1, 0, 0, 0),    # state a (1) stays put
          c(0, 1, 0, 0),
          c(0, 0, 1, 0),
          c(w[6], 0, 0, w[1])/(w[1] + w[6]))  #subject 4 moves to 'a'
}
aj3 <- function(w) rbind(c(1, 0, 0, 0),   
                         c(0, 0, 1, 0),  # 5 moves from b to c
                         c(0, 0, 1, 0),
                         c(0, 0, 0, 1))
aj4 <- function(w) rbind(c(1, 0, 0, 0),
                         c(0, 1, 0, 0),  
                         c(0, 0, 1, 0),
                         c(w[1], 0, 0, w[5])/(w[1] + w[5])) #1 moves from 4 to a
aj5 <- function(w) rbind(c(w[2]+w[7], w[4], 0, 0)/(w[2]+ w[4] + w[7]), #2 to b
                         c(0, 1, 0, 0),  
                         c(0, 0, 1, 0),
                         c(0, 0, 0, 1))
aj8 <- function(w) rbind(c(w[2], 0, w[7], 0)/(w[2]+ w[7]), # 4  to c
                         c(0, 1, 0, 0),  
                         c(0, 0, 1, 0),
                         c(0, 0, 0, 1))
aj9 <- function(w) rbind(c(0, 1, 0, 0), # 1  to b
                         c(0, 1, 0, 0),  
                         c(0, 0, 1, 0),
                         c(0, 0, 1 ,0)) # 3 to c
aj10 <- function(w)rbind(c(1, 0, 0, 0),
                         c(1, 0, 0, 0),  #1 back to a
                         c(0, 0, 1, 0),
                         c(0, 0, 0, 1))

#time       state               
#         a   b  c  entry
#
#1        2   5     14       initial distribution
#2        24  5     1        4 -> a, add 3
#3        24     5  13       5 from b to c
#4       124     5   3       1 -> a
#5        14     5   3       2 -> b, exits
#8        1      45  3       4 -> c
#9            1  45          1->b, 3->c & exit
#10       1      45          1->a

# P is a product of matrices
dopstate <- function(w) {
    p1 <- p0(w)
    p2 <- p1 %*% aj2(w)
    p3 <- p2 %*% aj3(w)
    p4 <- p3 %*% aj4(w)
    p5 <- p4 %*% aj5(w)
    p8 <- p5 %*% aj8(w)
    p9 <- p8 %*% aj9(w)
    p10<- p9 %*% aj10(w)
    rbind(p2, p3, p4, p5, p8, p9, p10, p10)
}

# Check the pstate estimate
w1 <- rep(1, 10)
mtest2 <- tfun(w1)
mfit2 <- survfit(Surv(t1, t2, st) ~ 1, tdata, id=id, istate=i0) # ordered
aeq(mfit2$pstate, dopstate(w1))
aeq(mfit2$p0, p0(w1))

mfit2b <- survfit(Surv(t1, t2, st) ~ 1, mtest2, id=id, istate=i0)#scrambled
aeq(mfit2b$pstate, dopstate(w1))
aeq(mfit2b$p0, p0(w1))

mfit2b$call <- mfit2$call <- NULL
all.equal(mfit2b, mfit2) 

# Now the harder one, where subjects change weights
mtest3 <- tfun(1:10)  
mfit3  <- survfit(Surv(t1, t2, st) ~ 1, mtest3, id=id, istate=i0,
                  weights=wt, influence=TRUE)
aeq(mfit3$p0, p0(1:10))
aeq(mfit3$pstate, dopstate(1:10))
    

# The derivative of a matrix product AB is (dA)B + A(dB) where dA is the
#  elementwise derivative of A and etc for B.
# dp0 creates the derivatives of p0 with respect to each subject, a 5 by 4
#  matrix
dp0 <- function(w) {
  p <- p0(w)
  w0 <- w[c(1,4,6,9)]  # the 4 obs at the start, subjects 1, 2, 4, 5
  rbind(c(0, 0, 0, 1) - p,   # subject 1 affects p[4]
        c(1, 0, 0, 0) - p,   # subject 2 affects p0[1]
        0,                   # subject 3 affects none
        c(0, 0, 0, 1) - p,   # subject 4 affect p[4]
        c(0, 1, 0, 0) - p) / sum(w0)
}
  

dp2 <- function(w) {
    h2 <- aj2(w)   # H matrix at time 2
    part1 <- dp0(w) %*% h2

    # 1 and 4 in state 4, obs 1 and 6, 4 moves to a
    mult  <- p0(w)[4]/(w[1] + w[6])  #p(t-) / weights in state
    part2 <- rbind((c(0,0,0,1)- h2[4,]) * mult,
                   0,
                   0,
                   (c(1,0,0,0) - h2[4,]) * mult,
                   0)
    part1 + part2
}

dp3 <- function(w) {
    dp2(w) %*% aj3(w)
}

dp4 <- function(w) {
    h4 <- aj4(w)   # H matrix at time 4
    part1 <- dp3(w) %*% h4

    # subjects 1 and 3 in state 4, obs 1 and 5, 1 moves to a
    mult <- dopstate(w)[2,4]/ (w[1] + w[5])   # p_4(time 4-0) / wt
    part2 <- rbind((c(1,0,0,0)- h4[4,]) * mult,
                   0,
                   (c(0,0,0,1)- h4[4,]) * mult,
                   0,
                   0)
    part1 + part2
}
dp5 <- function(w) {
    h5 <- aj5(w)   # H matrix at time 5
    part1 <- dp4(w) %*% h5

    # subjects 124 in state 1, obs 2,4,7, 2 goes to 2
    mult <- dopstate(w)[3,1]/ (denom <- w[2] + w[4] + w[7]) 
    part2 <- rbind((c(1,0,0,0)- h5[1,]) * mult,
                   (c(0,1,0,0)- h5[1,]) * mult,
                   0,
                   (c(1,0,0,0)- h5[1,]) * mult,
                   0)
    part1 + part2
}
dp8 <- function(w) {
    h8 <- aj8(w)   # H matrix at time 8
    part1 <- dp5(w) %*% h8

    # subjects 14 in state 1, obs 2 &7, 4 goes to c
    mult <- dopstate(w)[4, 1]/ (w[2] + w[7]) 
    part2 <- rbind((c(1,0,0,0)- h8[1,]) * mult,
                   0,
                   0,
                   (c(0,0,1,0)- h8[1,]) * mult,
                   0)
    part1 + part2
}
dp9 <- function(w) dp8(w) %*% aj9(w)
dp10<- function(w) dp9(w) %*% aj10(w)

w1 <- 1:10
aeq(mfit3$influence[,1,], dp0(w1))
aeq(mfit3$influence[,2,], dp2(w1))
aeq(mfit3$influence[,3,], dp3(w1))
aeq(mfit3$influence[,4,], dp4(w1))
aeq(mfit3$influence[,5,], dp5(w1))
aeq(mfit3$influence[,6,], dp8(w1))
aeq(mfit3$influence[,7,], dp9(w1))
aeq(mfit3$influence[,8,], dp10(w1))
aeq(mfit3$influence[,9,], dp10(w1)) # no changes at time 11

aeq(mfit3$cumhaz[,,1], aj2(w1)- diag(4))
aeq(mfit3$cumhaz[,,2] - mfit3$cumhaz[,,1], aj3(w1)- diag(4))
aeq(mfit3$cumhaz[,,3] - mfit3$cumhaz[,,2], aj4(w1)- diag(4))
aeq(mfit3$cumhaz[,,4] - mfit3$cumhaz[,,3], aj5(w1)- diag(4))
aeq(mfit3$cumhaz[,,5] - mfit3$cumhaz[,,4], aj8(w1)- diag(4))
aeq(mfit3$cumhaz[,,6] - mfit3$cumhaz[,,5], aj9(w1)- diag(4))
