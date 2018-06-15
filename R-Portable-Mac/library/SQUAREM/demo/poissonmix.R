require("SQUAREM")
require("setRNG")
#####---------------------------------------------------------------###########
##we show an example demonstrating the ability of SQUAREM to dramatically######
##speed-up the convergence of the EM algorithm for a binary Poisson mixture####
##estimation.   We use the example from Hasselblad (J of Amer Stat Assoc 1969)#
#####---------------------------------------------------------------###########


#####---------------------------------------------------------------###########
###########################data################################################
#####---------------------------------------------------------------###########
poissmix.dat <- data.frame(death = 0:9, 
                           freq = c(162, 267, 271, 185, 
                                    111, 61, 27, 8, 3, 1))

#####---------------------------------------------------------------###########
#########Generate a random initial guess for 3 parameters######################
#####---------------------------------------------------------------###########
y <- poissmix.dat$freq
tol <- 1.e-08
setRNG(list(kind = "Wichmann-Hill", normal.kind = "Box-Muller", seed = 123))
p0 <- c(runif(1),runif(2, 0, 6))    


#####---------------------------------------------------------------###########
####The fixed point mapping giving a single E and M step of the EM algorithm###
#####---------------------------------------------------------------###########
poissmix.em <- function(p, y) {
        pnew <- rep(NA, 3)
        i <- 0:(length(y) - 1)
        zi <- p[1] * exp(-p[2]) * p[2]^i / 
                (p[1]*exp(-p[2])*p[2]^i + (1 - p[1]) * exp(-p[3]) * p[3]^i)
        pnew[1] <- sum(y * zi)/sum(y)
        pnew[2] <- sum(y * i * zi)/sum(y * zi)
        pnew[3] <- sum(y * i * (1-zi))/sum(y * (1-zi))
        p <- pnew
        return(pnew)
}

#####---------------------------------------------------------------###########
####Objective function whose local minimum is a fixed point. ##################
####Here it is the negative log-likelihood of binary poisson mixture.##########
#####---------------------------------------------------------------###########
poissmix.loglik <- function(p, y) {
        i <- 0:(length(y) - 1)
        loglik <- y * log(p[1] * exp(-p[2]) * p[2]^i/exp(lgamma(i + 1)) + 
                                  (1 - p[1]) * exp(-p[3]) * p[3]^i/exp(lgamma(i + 1)))
        return (-sum(loglik))
}

#####---------------------------------------------------------------###########
#####################################EM Algorithm##############################
#####---------------------------------------------------------------###########
pf1 <- fpiter(p = p0, y = y, fixptfn = poissmix.em, objfn = poissmix.loglik, 
              control = list(tol = tol))
pf1

#####---------------------------------------------------------------###########
###################Squarem to accelerate EM Algorithm##########################
#####---------------------------------------------------------------###########
pf2 <- squarem(p = p0, y = y, fixptfn = poissmix.em, objfn = poissmix.loglik, 
               control = list(tol = tol))
pf2

#######Comment: Note the dramatically faster convergence, 
#######i.e. SQUAREM uses only 72 fixed-point evaluations to achieve convergence.  
#######This is a speed up of a factor of 40.  






