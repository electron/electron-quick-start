require("SQUAREM")
#####---------------------------------------------------------------###########
##For factor analysis maximum likelihood estimation, we will illustrate######## 
##the dramatic acceleration of EM by Squarem and also compare with############# 
##ECME (Liu and Rubin 1998) using a real data example from JoresKog (1967). ###
#####---------------------------------------------------------------###########

#####---------------------------------------------------------------###########
###########################data################################################
#####---------------------------------------------------------------###########
cyy <- diag(9)
cyy[upper.tri(cyy)] <- c(.554, .227, .296, .189, .219, .769, 
                         .461, .479, .237, .212, .506, .530,
                         .243, .226, .520, .408, .425, .304,
                         .291, .514, .473, .280, .311, .718,
                         .681, .313, .348, .374, .241, .311,
                         .730, .661, .245, .290, .306, .672)
cyy[lower.tri(cyy)] <- t(cyy)[lower.tri(t(cyy))]


#####---------------------------------------------------------------###########
######################starting value###########################################
#####---------------------------------------------------------------###########
beta.trans <- matrix(c(0.5954912, 0.6449102, 0.7630006, 0.7163828, 0.6175647, 0.6464100, 0.6452737, 0.7868222, 0.7482302, 
                       -0.4893347, -0.4408213, 0.5053083, 0.5258722, -0.4714808, -0.4628659, -0.3260013, 0.3690580, 0.4326963, 
                       -0.3848925, -0.3555598, -0.0535340, 0.0219100, 0, 0, 0, 0, 0, 
                       0, 0, 0, 0, 0.1931459, 0.4606456, -0.3622682, 0.0630371, 0.0431256), 9, 4)
beta.start <- t(beta.trans)
tau2.start <- rep(10^(-8), 9)
param.start <- c(as.numeric(beta.start), tau2.start)

#####---------------------------------------------------------------###########
####The fixed point mapping giving a single E and M step of the EM algorithm###
#####---------------------------------------------------------------###########
factor.em <- function(param, cyy){
        param.new <- rep(NA, 45)
        
        ###extract beta matrix and tau2 from param
        beta.vec <- param[1:36]
        beta.mat <- matrix(beta.vec, 4, 9)
        tau2 <- param[37:45]
        tau2.mat <- diag(tau2)
        
        ###compute delta/Delta
        inv.quantity <- solve(tau2.mat + t(beta.mat) %*% beta.mat)
        small.delta <- inv.quantity %*% t(beta.mat)
        big.delta <- diag(4) - beta.mat %*% inv.quantity %*% t(beta.mat)
        
        cyy.inverse <- t(small.delta) %*% cyy %*% small.delta + big.delta
        cyy.mat <- t(small.delta) %*% cyy
        
        ###update betas and taus
        beta.new <- matrix(0, 4, 9)
        beta.p1 <- solve(cyy.inverse[1:3, 1:3]) %*% cyy.mat[1:3, 1:4]
        beta.p2 <- solve(cyy.inverse[c(1,2,4), c(1,2,4)]) %*% 
                cyy.mat[c(1,2,4), 5:9]
        beta.new[1:3, 1:4] <- beta.p1
        beta.new[c(1,2,4), 5:9] <- beta.p2
        
        tau.p1 <- diag(cyy)[1:4] - diag(t(cyy.mat[1:3, 1:4]) %*% 
                                                solve(cyy.inverse[1:3, 1:3]) %*% cyy.mat[1:3, 1:4])
        tau.p2 <- diag(cyy)[5:9] - diag(t(cyy.mat[c(1,2,4), 5:9]) %*% 
                                                solve(cyy.inverse[c(1,2,4), c(1,2,4)]) %*% 
                                                cyy.mat[c(1,2,4), 5:9])
        tau.new <- c(tau.p1, tau.p2)
        
        param.new <- c(as.numeric(beta.new), tau.new)
        param <- param.new
        return(param.new)
}

#####---------------------------------------------------------------###########
################The fixed point mapping giving ECME algorithm##################
#####---------------------------------------------------------------###########
factor.ecme <- function(param, cyy){
        n <- 145
        param.new <- rep(NA, 45)
        
        ###extract beta matrix and tau2 from param
        beta.vec <- param[1:36]
        beta.mat <- matrix(beta.vec, 4, 9)
        tau2 <- param[37:45]
        tau2.mat <- diag(tau2)
        
        ###compute delta/Delta
        inv.quantity <- solve(tau2.mat + t(beta.mat) %*% beta.mat)
        small.delta <- inv.quantity %*% t(beta.mat)
        big.delta <- diag(4) - beta.mat %*% inv.quantity %*% t(beta.mat)
        
        cyy.inverse <- t(small.delta) %*% cyy %*% small.delta + big.delta
        cyy.mat <- t(small.delta) %*% cyy
        
        ###update betas
        beta.new <- matrix(0, 4, 9)
        beta.p1 <- solve(cyy.inverse[1:3, 1:3]) %*% cyy.mat[1:3, 1:4]
        beta.p2 <- solve(cyy.inverse[c(1,2,4), c(1,2,4)]) %*% 
                cyy.mat[c(1,2,4), 5:9]
        beta.new[1:3, 1:4] <- beta.p1
        beta.new[c(1,2,4), 5:9] <- beta.p2
        
        ###update taus given betas
        A <- solve(tau2.mat + t(beta.new) %*% beta.new)
        sum.B <- A %*% (n * cyy) %*% A
        gradient <- - tau2/2 * (diag(n*A) - diag(sum.B))
        hessian <- (0.5 * (tau2 %*% t(tau2))) * (A * (n * A - 2 * sum.B))
        diag(hessian) <- diag(hessian) + gradient
        U <- log(tau2)
        U <- U - solve(hessian, gradient)  # Newton step
        
        tau.new <- exp(U)
        param.new <- c(as.numeric(beta.new), tau.new)
        param <- param.new
        return(param.new)
}

#####---------------------------------------------------------------###########
####Objective function whose local minimum is a fixed point. ##################
####Here it is the negative log-likelihood of factor analysis.#################
#####---------------------------------------------------------------###########
factor.loglik <- function(param, cyy){
        ###extract beta matrix and tau2 from param
        beta.vec <- param[1:36]
        beta.mat <- matrix(beta.vec, 4, 9)
        tau2 <- param[37:45]
        tau2.mat <- diag(tau2)
        
        Sig <- tau2.mat + t(beta.mat) %*% beta.mat
        ##suppose n=145 since this does not impact the parameter estimation
        loglik <- -145/2 * log(det(Sig)) - 145/2 * sum(diag(solve(Sig, cyy)))
        return(-loglik)
        ###the negative log-likelihood is returned
}

#####---------------------------------------------------------------###########
#####################################EM Algorithm##############################
#####---------------------------------------------------------------###########
system.time(f1 <- fpiter(par = param.start, cyy = cyy, 
                         fixptfn = factor.em, 
                         objfn = factor.loglik,
                         control = list(tol=10^(-8), 
                                        maxiter = 20000)))
f1$fpevals

#####---------------------------------------------------------------###########
##################################ECME Algorithm###############################
#####---------------------------------------------------------------###########
system.time(f2 <- fpiter(par = param.start, cyy = cyy, 
                         fixptfn = factor.ecme, objfn = factor.loglik, 
                         control = list(tol=10^(-8), maxiter = 20000)))
f2$fpevals

#####---------------------------------------------------------------###########
###################Squarem to accelerate EM Algorithm##########################
#####---------------------------------------------------------------###########
system.time(f3 <- squarem(par = param.start, cyy = cyy, 
                          fixptfn = factor.em, 
                          objfn = factor.loglik, 
                          control = list(tol = 10^(-8))))
f3$fpevals

#####---------------------------------------------------------------###########
###################Squarem to accelerate ECME Algorithm########################
#####---------------------------------------------------------------###########
system.time(f4 <- squarem(par = param.start, cyy = cyy, 
                          fixptfn = factor.ecme, 
                          objfn = factor.loglik, 
                          control = list(tol = 10^(-8))))
f4$fpevals





